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

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CypherDAO
 * @author CypherDAO Team
 * @notice ERC20Votes governance token for CypherDAO.
 * @dev This token is used for voting in CypherDAOGovernor. It supports delegation and checkpoints for voting power.
 * Designed to run on Celo (EVM-compatible), deployment via Foundry script with appropriate Celo RPC.
 */
contract CypherDAO is ERC20, ERC20Permit, ERC20Votes, Ownable {
    /**
     * @notice Constructor for CypherDAO token.
     * @param initialOwner The address that will own the contract and receive initial supply.
     * @dev Mints 1,000,000 CYDAO to the initial owner.
     */
    constructor(address initialOwner)
        ERC20("CypherDAO", "CYDAO")
        ERC20Permit("CypherDAO")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 1_000_000 * 10 ** decimals());
    }

    /**
     * @notice Mints new tokens to a specified address.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     * @dev Only callable by the owner.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Overrides for ERC20Votes
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}