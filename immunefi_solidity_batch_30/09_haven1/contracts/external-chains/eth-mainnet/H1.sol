// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title Haven1
 *
 * @author The Haven1 Development Team
 *
 * @notice The Haven1 (H1) token contract.
 *
 * Haven1 is an EVM-compatible Layer 1 blockchain that seamlessly incorporates
 * key principles of traditional finance into the Web3 ecosystem.
 */
contract Haven1 is ERC20, ERC20Permit {
    /**
     * @notice Constructs the contract.
     *
     * @param to        The recipient of the supply of tokens.
     * @param supply    The supply to be initially minted.
     */
    constructor(
        address to,
        uint256 supply
    ) ERC20("Haven1", "H1") ERC20Permit("Haven1") {
        _mint(to, supply);
    }
}
