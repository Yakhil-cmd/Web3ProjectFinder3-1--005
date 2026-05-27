// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title IReceiver
 *
 * @author The Haven1 Development Team
 */
interface IReceiver {
    /**
     * @notice Emitted when H1 is received into the contract.
     *
     * @param from      The address that sent the H1.
     * @param amount    The amount of H1 that was received.
     */
    event H1Received(address indexed from, uint256 amount);

    /**
     * Allows H1 to be deposited into the contract.
     */
    function deposit() external payable;
}
