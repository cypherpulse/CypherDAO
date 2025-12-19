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

/**
 * @title Box
 * @author CypherDAO Team
 * @notice Simple storage contract for testing governance.
 * @dev Used in tests to verify proposal execution.
 */
contract Box {
    uint256 private s_value;
    address private immutable i_owner;

    event ValueChanged(uint256 newValue);

    /**
     * @notice Constructor for Box.
     * @param owner The address that can store values.
     */
    constructor(address owner) {
        i_owner = owner;
    }

    /**
     * @notice Stores a new value.
     * @param value The value to store.
     * @dev Only callable by the owner.
     */
    function store(uint256 value) external {
        require(msg.sender == i_owner, "Only owner");
        s_value = value;
        emit ValueChanged(value);
    }

    /**
     * @notice Gets the stored value.
     * @return The stored value.
     */
    function getValue() external view returns (uint256) {
        return s_value;
    }
}