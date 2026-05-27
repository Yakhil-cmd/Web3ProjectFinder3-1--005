// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Raised when a transfer fails.
 */
error Staking__TransferFailed();

/**
 * @dev Raised when there are no rewards available for the user to claim.
 */
error Staking__NoRewards();

/**
 * @dev Raised when a request to withdraw an invalid amount of H1 is made.
 *
 * @param bal The available balance.
 */
error Staking__InsufficientH1Balance(uint256 bal);

/**
 * @dev Raised when a request to withdraw an invalid token amount is made.
 *
 * @param bal The available balance.
 */
error Staking__InsufficientTokenBalance(uint256 bal);

/**
 * @dev Raised when an invalid attempt is made to set the rewards duration.
 *
 * @param completeTime The timestamp of when the rewards finish staking.
 */
error Staking__RewardDurationNotFinished(uint256 completeTime);

/**
 * @dev Raised when an invalid attempt is made to set the rewards duration.
 *
 * @param duration The invalid duration value that was supplied.
 */
error Staking__InvalidRewardDuration(uint256 duration);

/**
 * @dev Raised if the reward rate that results from notifying a reward amount
 * is zero.
 */
error Staking__RewardRateEqualsZero();

/**
 * @dev Raised when there is an insufficient amount of rewards to be paid out
 * based on the new reward rate.
 *
 * @param amount            The attempted amount.
 * @param contractBalance   The contract's balance.
 */
error Staking__RewardsExceedBalance(uint256 amount, uint256 contractBalance);

/**
 * @dev Raised when the token being recovered is either the staking token or
 * the reward token.
 *
 * @param stakingToken  The address of the staking token.
 * @param rewardToken   The address of the reward token.
 * @param userInput     The address that was provided by the admin for rescue.
 */
error Staking__CannotRecoverTokens(
    address stakingToken,
    address rewardToken,
    address userInput
);

/**
 * @dev Raised when the amount of staking token and native H1 provided are zero.
 */
error Staking__NoAmountsProvided();

/**
 * @dev Raised when the proposed staking token is invalid.
 */
error Staking__InvalidStakingToken();

/**
 * @dev Raised when the staking token and the reward token are the same.
 */
error Staking__StakingMatchesReward();
