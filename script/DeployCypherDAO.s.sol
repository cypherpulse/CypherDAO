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

import "forge-std/Script.sol";
import "../src/CypherDAO.sol";
import "../src/CypherDAOTimelock.sol";
import "../src/CypherDAOGovernor.sol";

/**
 * @title DeployCypherDAO
 * @author CypherDAO Team
 * @notice Deployment script for CypherDAO governance stack.
 * @dev Deploys token, timelock, governor, and wires roles.
 */
contract DeployCypherDAO is Script {
    function run() external {
        vm.startBroadcast();

        address initialOwner = msg.sender; // Deployer as initial owner

        // Deploy token
        CypherDAO token = new CypherDAO(initialOwner);

        // Deploy timelock with 2 days delay, no initial proposers, anyone can execute
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        CypherDAOTimelock timelock = new CypherDAOTimelock(2 days, proposers, executors);

        // Deploy governor
        CypherDAOGovernor governor = new CypherDAOGovernor(IVotes(address(token)), timelock);

        // Wire roles
        timelock.grantRole(keccak256("PROPOSER_ROLE"), address(governor));
        timelock.grantRole(keccak256("CANCELLER_ROLE"), address(governor));
        timelock.renounceRole(keccak256("TIMELOCK_ADMIN_ROLE"), initialOwner);

        vm.stopBroadcast();

        console.log("CypherDAO Token deployed at:", address(token));
        console.log("CypherDAOTimelock deployed at:", address(timelock));
        console.log("CypherDAOGovernor deployed at:", address(governor));
    }
}