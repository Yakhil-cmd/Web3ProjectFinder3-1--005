// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* LockedH1
==================================================*/

/**
 * @notice Raised when the H1 amount sent during `depositAirdrop()` is not equal
 *          to the expected airdrop amount.
 *
 * @param providedValue The provided H1 amount.
 * @param expectedValue The expected H1 amount.
 */
error AirdropClaim__WrongAidropAmount(
    uint256 providedValue,
    uint256 expectedValue
);

/**
 * @notice Raised when the airdrop is not ready.
 * @dev The contract is not ready if the airdrop H1 was not deposited yet.
 */
error AirdropClaim__IsReady();

/**
 * @notice Raised when the airdrop is reverted.
 * @dev This happens when H1 is sent ot the contract directly.
 */
error AirdropClaim__Revert();

/**
 * @notice Raised when the airdrop has already started.
 * @dev This happens when the start timestamp in the past.
 */
error AirdropClaim__AlreadyStarted();

/**
 * @notice Raised when an attempt to collect the discard airdrop amounts is made
 * before the airdrop is finished.
 */
error AirdropClaim__InProgress();

/**
 * @notice Raised when the airdrop is not active.
 * @dev This happens if the current timestamp is not between the start and end timestamp
 *      or the contract is not ready.
 */
error AirdropClaim__NotActive();

/**
 * @notice Raised when the provided input data is false in some form.
 */
error AirdropClaim__WrongData();

/**
 * @notice Raised when the provided BPS is invalid.
 * @dev This happens when the BPS provided for the claim is not in the range of 0 to 10_000.
 *
 * @param wrongBPS The wrong BPS value, which is not in the range of 0 to 10_000.
 * @param maxBps   The maximum BPS value, which is 10_000.
 */
error AirdropClaim__InvalidBps(uint16 wrongBPS, uint16 maxBps);

/**
 * @notice Raised when the contract failed to send H1.
 */
error AirdropClaim__FailedToSend();

/**
 * @notice Raised when some allocation is already done.
 * @dev This happens when changing the max XP or LP amount after some allocation was done.
 *      This is to prevent incorrect allocation that were based on the old max XP or LP amount.
 */
error AirdropClaim__AlreadyAllocated();

/**
 * @notice Raised when a user does not have any airdrop allocated.
 * @dev This happens during `claimAirdrop()`.
 */
error AirdropClaim__NoAllocation();

/**
 * @notice Raised when the airdrop amount left is not enough for the planned allocation.
 * @dev This happens during `_setAllocation()`.
 *
 * @param expectedAllocation The expected allocation amount.
 * @param allocationLeft     The allocation amount left.
 */
error AirdropClaim__NoAirdropLeft(
    uint256 expectedAllocation,
    uint256 allocationLeft
);
