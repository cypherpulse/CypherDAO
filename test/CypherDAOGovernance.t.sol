// SPDX-License-Identifier: MIT


// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CypherDAO.sol";
import "../src/CypherDAOTimelock.sol";
import "../src/CypherDAOGovernor.sol";
import "../src/Box.sol";

/**
 * @title CypherDAOGovernanceTest
 * @author CypherDAO Team
 * @notice End-to-end tests for CypherDAO governance lifecycle.
 */
contract CypherDAOGovernanceTest is Test {
    CypherDAO token;
    CypherDAOTimelock timelock;
    CypherDAOGovernor governor;
    Box box;

    address voter = makeAddr("voter");
    address nonVoter = makeAddr("nonVoter");
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    function setUp() public {
        // Deploy contracts
        token = new CypherDAO(address(this));
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        timelock = new CypherDAOTimelock(2 days, proposers, executors);
        governor = new CypherDAOGovernor(IVotes(address(token)), timelock);

        // Wire roles
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));

        // Deploy Box with timelock as owner
        box = new Box(address(timelock));

        // Mint tokens to voter
        token.mint(voter, 1000 * 10 ** 18);

        // Voter delegates to self
        vm.prank(voter);
        token.delegate(voter);
    }

    function testFullProposalLifecycle() public {
        // Propose
        address[] memory targets = new address[](1);
        targets[0] = address(box);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(Box.store.selector, 42);
        string memory description = "Store 42 in Box";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Wait voting delay
        vm.roll(block.number + governor.votingDelay() + 1);

        // Vote
        vm.prank(voter);
        governor.castVote(proposalId, 1); // For

        // Wait voting period
        vm.roll(block.number + governor.votingPeriod() + 1);

        // Queue
        governor.queue(targets, values, calldatas, keccak256(bytes(description)));

        // Wait min delay
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);

        // Execute
        governor.execute(targets, values, calldatas, keccak256(bytes(description)));

        // Assert
        assertEq(box.getValue(), 42);
    }

    function testNonDelegatedCannotVote() public {
        // Mint to nonVoter but don't delegate
        token.mint(nonVoter, 100 * 10 ** 18);

        address[] memory targets = new address[](1);
        targets[0] = address(box);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(Box.store.selector, 42);
        string memory description = "Store 42 in Box";

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(nonVoter);
        vm.expectRevert(); // Should revert because no voting power
        governor.castVote(proposalId, 1);
    }

    function testQuorumThreshold() public {
        // Mint small amount to voter, below quorum
        vm.prank(address(token.owner()));
        token.mint(voter, 1 * 10 ** 18); // Very small

        address[] memory targets = new address[](1);
        targets[0] = address(box);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(Box.store.selector, 42);
        string memory description = "Store 42 in Box";

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + governor.votingPeriod() + 1);

        // Should not succeed due to low quorum
        assert(governor.state(proposalId) != IGovernor.ProposalState.Succeeded);
    }
}