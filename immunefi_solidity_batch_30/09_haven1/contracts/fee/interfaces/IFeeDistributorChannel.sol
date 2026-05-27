// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { IDistributor } from "./IDistributor.sol";
import { IReceiver } from "./IReceiver.sol";

/**
 * @title IFeeDistributorChannel
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the FeeDistributorChannel contract.
 */
interface IFeeDistributorChannel is IDistributor, IReceiver {
    /**
     * @notice Emitted when the Fee Distributor contract address is updated.
     *
     * @param prev The previous address.
     * @param curr The current address.
     */
    event FeeDistributorUpdated(address indexed prev, address indexed curr);

    /**
     * @notice Emitted when the Wrapped H1 contract address is updated.
     *
     * @param prev The previous address.
     * @param curr The current address.
     */
    event WH1Updated(address indexed prev, address indexed curr);

    /**
     * @notice Allows H1 to be deposited into the contract.
     *
     * Emits an `H1Received` event.
     */
    function deposit() external payable override(IReceiver);

    /**
     * @notice Distributes all accrued rewards to the `FeeDistributor` contract
     * in the form of WH1 tokens.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Emits a `RewardsDistributed` event.
     */
    function distribute() external override(IDistributor);

    /**
     * @notice Distributes an amount of the accrued rewards to the Fee Distributor
     * contract in the form of WH1 tokens.
     *
     * @param amt The amount to distribute.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The amount to distribute must be less than, or equal to, the amount
     *      of H1 stored in the contract.
     *
     * Emits a `RewardsDistributed` event.
     */
    function distributePartial(uint256 amt) external;

    /**
     * @notice Allows the admin to recover HRC20 tokens from this contract.
     *
     * @param token     The token to recover.
     * @param to        The recipient of the recovered tokens.
     * @param amount    The amount of tokens to recover.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits an `HRC20Recovered` event.
     */
    function recoverHRC20(address token, address to, uint256 amount) external;

    /**
     * @notice Updates the `FeeDistributor` contract address.
     *
     * @param addr The new contract address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `FeeDistributorUpdated` event.
     */
    function setFeeDistributor(address addr) external;

    /**
     * @notice Updates the `WH1` contract address.
     *
     * @param addr The new contract address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `FeeDistributorUpdated` event.
     */
    function setWH1(address addr) external;

    /**
     * @notice Returns the address of the `FeeDistributor` contract.
     *
     * @return The `FeeDistributor` contract address.
     */
    function feeDistributor() external view returns (address);

    /**
     * @notice Returns the address of the `WH1` contract.
     *
     * @return The `WH1` contract address.
     */
    function WH1() external view returns (address);

    /**
     * @notice Returns the timestamp of the last distribution.
     *
     * @return The timestamp of the last distribution.
     */
    function lastDistribution() external view returns (uint256);
}
