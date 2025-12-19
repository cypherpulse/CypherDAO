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

import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title CypherDAOTimelock
 * @author CypherDAO Team
 * @notice Timelock controller for CypherDAO governance.
 * @dev Delays execution of proposals to allow for review and cancellation.
 * Designed to run on Celo (EVM-compatible), deployment via Foundry script with appropriate Celo RPC.
 */
contract CypherDAOTimelock is TimelockController {
    /**
     * @notice Constructor for CypherDAOTimelock.
     * @param minDelay Minimum delay before execution.
     * @param proposers Addresses that can propose.
     * @param executors Addresses that can execute.
     * @dev The admin is set to msg.sender initially.
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(minDelay, proposers, executors, msg.sender) {}
}