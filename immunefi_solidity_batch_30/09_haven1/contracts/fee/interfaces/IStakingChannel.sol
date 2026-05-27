// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { IDistributor } from "./IDistributor.sol";
import { IReceiver } from "./IReceiver.sol";

/**
 * @title IStakingChannel
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the StakingChannel contract.
 */
interface IStakingChannel is IDistributor, IReceiver {
    /**
     * @notice Emitted when the Staking contract address is updated.
     *
     * @param prev The previous address.
     * @param curr The current address.
     */
    event StakingUpdated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the Escrowed H1 contract address is updated.
     *
     * @param prev The previous address.
     * @param curr The current address.
     */
    event ESH1Updated(address indexed prev, address indexed curr);

    /**
     * @notice Allows H1 to be deposited into the contract.
     *
     * Emits an `H1Received` event.
     */
    function deposit() external payable override(IReceiver);

    /**
     * @notice Distributes all accrued rewards to the Staking contract in the
     * form of ESH1 tokens.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Emits a `RewardsDistributed` event.
     */
    function distribute() external override(IDistributor);

    /**
     * @notice Distributes an amount of the accrued rewards to the Staking
     * contract in the form of ESH1 tokens.
     *
     * @param amt_ The amount to distribute.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The amount to distribute must be less than, or equal to, the amount
     *      of H1 stored in the contract.
     *
     * Emits a `RewardsDistributed` event.
     */
    function distributePartial(uint256 amt_) external;

    /**
     * @notice Allows the admin to recover HRC20 tokens from this contract.
     *
     * @param token_    The token to recover.
     * @param to_       The recipient of the recovered tokens.
     * @param amount_   The amount of tokens to recover.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits an `HRC20Recovered` event.
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external;

    /**
     * @notice Updates the Staking contract address.
     *
     * @param addr_ The new contract address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `StakingUpdated` event.
     */
    function setStaking(address addr_) external;

    /**
     * @notice Updates the Escrowed H1 contract address.
     *
     * @param addr_ The new contract address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `ESH1Updated` event.
     */
    function setESH1(address addr_) external;

    /**
     * @notice Returns the address of the Staking contract.
     *
     * @return The Staking contract address.
     */
    function staking() external view returns (address);

    /**
     * @notice Returns the address of the Escrowed H1 contract.
     *
     * @return The Escrowed H1 contract address.
     */
    function esH1() external view returns (address);

    /**
     * @notice Returns the timestamp of the last distribution.
     *
     * @return The timestamp of the last distribution.
     */
    function lastDistribution() external view returns (uint256);
}
