// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { IDistributor } from "./IDistributor.sol";
import { IReceiver } from "./IReceiver.sol";

/**
 * @title IValidatorRewards
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the ValidatorRewards contract.
 */
interface IValidatorRewards is IDistributor, IReceiver {
    /**
     * @notice Emitted when the distribution frequency is updated.
     *
     * @param distFreq The updated distribution frequency, in seconds.
     */
    event DistributionFrequencyUpdated(uint256 distFreq);

    /**
     * @notice Emitted when the Validator Rewards Config address is updated.
     *
     * @param cfg The updated Validator Rewards Config address.
     */
    event ValidatorConfigUpdated(address cfg);

    /**
     * @notice Allows H1 to be deposited into the contract.
     *
     * Emits an `H1Received` event.
     */
    function deposit() external payable override(IReceiver);

    /**
     * @notice Distributes accrued rewards equally among the validators.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    Enough time must have passed since the previous distribution.
     *
     * Emits `RewardsDistributed` events.
     */
    function distribute() external override(IDistributor);

    /**
     * @notice Distributes accrued rewards equally among the validators.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * Emits `RewardsDistributed` events.
     */
    function distributeAdmin() external;

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
     * @notice Sets the Validator Rewards Config address.
     *
     * @param cfg_ The new Validator Rewards Config address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `ValidatorConfigUpdated` event.
     */
    function setValidatorConfig(address cfg_) external;

    /**
     * @notice Sets the distribution frequency.
     *
     * @param distFreqSec_ The new distribution frequency.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `DistributionFrequencyUpdated` event.
     */
    function setDistributionFrequency(uint256 distFreqSec_) external;

    /**
     * @notice Returns the address of the Validator Rewards Config contract.
     *
     * @return The address of the Validator Rewards Config contract.
     */
    function validatorConfig() external view returns (address);

    /**
     * @notice Returns the minimum time, in seconds, that must pass between
     * distributions.
     *
     * @return The minimum time, in seconds, that must pass between distributions.
     */
    function distributionFrequency() external view returns (uint256);

    /**
     * @notice Returns the timestamp of the last distribution.
     *
     * @return The timestamp of the last distribution.
     */
    function lastDistribution() external view returns (uint256);

    /**
     * @notice Returns whether a distribution can occur.
     *
     * @return True if a distribution can occur, false otherwise.
     */
    function canDistribute() external view returns (bool);

    /**
     * @notice Returns the amount of rewards to send each validator upon the
     * next distribution.
     *
     * @return The amount of rewards to send each validator upon the next distribution.
     */
    function calculateShare() external view returns (uint256);
}
