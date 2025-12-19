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

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

/**
 * @title CypherDAOGovernor
 * @author CypherDAO Team
 * @notice Governor contract for CypherDAO using token-based voting with timelock.
 * @dev Integrates with CypherDAO token for voting power and CypherDAOTimelock for delayed execution.
 * Designed to run on Celo (EVM-compatible), deployment via Foundry script with appropriate Celo RPC.
 */
contract CypherDAOGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    /**
     * @notice Constructor for CypherDAOGovernor.
     * @param _token The ERC20Votes token for voting.
     * @param _timelock The TimelockController for delayed execution.
     * @dev Sets voting delay to 1 block, voting period to 45818 blocks (~1 week), proposal threshold to 100 CYDAO, quorum fraction to 4%.
     */
    constructor(IVotes _token, TimelockController _timelock)
        Governor("CypherDAOGovernor")        GovernorSettings(1, 45818, 100e18)        GovernorCountingSimple()
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {}

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return 1;
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return 45818;
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return 100e18;
    }

    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function supportsInterface(bytes4 interfaceId) public view override(Governor, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(GovernorTimelockControl) returns (address) {
        return super._executor();
    }

    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function proposalNeedsQueuing(uint256 proposalId) public view override(GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(proposalId);
    }

    function name() public pure override returns (string memory) {
    return "CypherDAOGovernor";
    }

}


