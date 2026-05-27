// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ISimpleStaking
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the Simple Staking contract.
 */
interface ISimpleStaking {
    /**
     * @dev Emitted when tokens are staked.
     *
     * @param user      The address of the user who staked.
     * @param amount    The amount that was staked.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @dev Emitted when a user withdraws from the contract.
     *
     * @param user      The address of the user who has withdrawn.
     * @param amount    The amount that was withdrawn.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Emitted when a user claims their rewards.
     *
     * @param user      The address of the user to whom rewards were sent.
     * @param amount    The amount of rewards sent.
     */
    event RewardPaid(address indexed user, uint256 amount);

    /**
     * @dev Emitted when the Reward Duration is updated.
     *
     * @param duration The new duration.
     */
    event RewardDurationUpdated(uint256 duration);

    /**
     * @dev Emitted when the rewards have been added into the contract.
     *
     * @param finishAt      The new finish at time.
     * @param rewardRate    The new reward rate.
     */
    event RewardNotified(uint256 finishAt, uint256 rewardRate);

    /**
     * @notice Sets the duration over which rewards are distributed.
     *
     * @param duration_ The rewards duration, in seconds.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The current rewards duration must have ended.
     */
    function setRewardsDuration(uint256 duration_) external;

    /**
     * @notice Notifies the contract that new rewards have been sent in, sets
     * the reward rate, the finished at time, and the updated at time.
     *
     * @param amount_ The amount of rewards.
     *
     * @dev Requirements:
     * -    The caller must have the role: `OPERATOR_ROLE`.
     * -    The resulting reward rate cannot be zero.
     * -    The contract must have enough reward tokens available to pay out the
     *      new total amount.
     */
    function notifyRewardAmount(uint256 amount_) external;

    /**
     * @notice Allows users to stake tokens or H1.
     *
     * @param amount_ The amount of tokens to be staked.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The `amount_` must be greater than zero.
     * -    The sender must have approved the contract to spend the `_stakingToken`
     *      for at least `amount_`.

     * Emits a `Staked` event.
     */
    function stake(uint256 amount_) external;

    /**
     * @notice Allows a user to withdraw their staked tokens.
     *
     * @param amount_  The amount of staking tokens to withdraw.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The withdrawal amount must be greater than zero.
     *
     * Emits a `Withdrawn` event.
     */
    function withdraw(uint256 amount_) external;

    /**
     * @notice Allows a user to claim rewards.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The user must have a pending reward balance for the call to succeed.
     * -    A Native Application fee must be sent in.
     *
     * Emits a `RewardPaid` event.
     */
    function getReward() external payable;

    /**
     * @notice Allows for the recovery of an amount of an HRC-20 token to a
     * given address.
     *
     * @param token_    The address of the HRC-20 token to recover.
     * @param to_       The address to which the tokens  will be sent.
     * @param amount_   The amount of tokens to send.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The to address must not be the zero address.
     * -    The token to recover must not be the staking or reward token.
     * -    The contract must have at least `amount` of `token` balance.
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external;

    /**
     * @notice Returns the amount of rewards per token.
     *
     * @return The rewards per token, scaled by 1e18.
     *
     * @dev Computes the running summation of R / total supply.
     */
    function rewardPerToken() external view returns (uint256);

    /**
     * @notice Gets the amount of rewards earned by an account.
     *
     * @param account_ The address of the account.
     *
     * @return The rewards earned for the account.
     *
     * @dev The formula is:
     *
     * k ( ∑t=0 to b - 1 of R/L(t) - ∑t=0 to a - 1 of R/L(t) )
     *
     * Which is:
     * total tokens staked * reward per token - user reward per token paid.
     *
     * Reward per token and user reward per token paid are scaled up by `1e18`.
     * Therefore the result will be divided by `1e18` to format correctly.
     * We add to this the previous amount of rewards earned by the user.
     */
    function earned(address account_) external view returns (uint256);

    /**
     * @notice Gets the last time rewards were applicable.
     *
     * @return The last time rewards were applicable.
     */
    function lastTimeRewardApplicable() external view returns (uint256);

    /**
     * @notice Returns the address of the staking token.
     *
     * @return The address of the staking token.
     */
    function stakingToken() external view returns (address);

    /**
     * @notice Returns the address of the reward token.
     *
     * @return The address of the reward token.
     */
    function rewardToken() external view returns (address);

    /**
     * @notice Returns the total supply (total amount staked in the contract).
     *
     * @return The total supply.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Returns the timestamp tokens will stop earning rewards.
     *
     * @return The timestamp that tokens will stop earning rewards.
     */
    function finishAt() external view returns (uint256);

    /**
     * @notice Returns the timestamp of the last time the rewards were updated.
     *
     * @return The timestamp that the rewards were last updated.
     */
    function updatedAt() external view returns (uint256);

    /**
     * @notice Returns the total duration tokens will be staking, in seconds.
     *
     * @return The total duration tokens will be staking, in seconds.
     */
    function duration() external view returns (uint256);

    /**
     * @notice Returns the rewards to be paid out per second.
     *
     * @return The rewards to be paid out per second.
     */
    function rewardRate() external view returns (uint256);

    /**
     * @notice Returns the amount of staking tokens an `account` has deposited
     * in the contract.
     *
     * @param account The address of the account to check.
     *
     * @return The amount of staking tokens an `account` has deposited in the
     * contract.
     */
    function balanceOf(address account) external view returns (uint256);
}
