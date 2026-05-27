// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IAirdropClaim {
    /* EVENTS
    ==================================================*/

    /**
     * @notice Emitted when the airdrop H1 was deposited.
     *
     * @param amount The amount of deposited H1. Must must be exactly `_airdropAmount`.
     */
    event AirdropDeposited(uint256 amount);

    /**
     * @notice Emitted when the airdrop was canceled. The contract is now bricked.
     *
     * @dev Sets the start and end timestamp to 0 which blocks functionality.
     */
    event AirdropCanceled();

    /**
     * @notice Emitted when the start timestamp was updated.
     *
     * @dev This is only possible before the airdrop claiming starts.
     *
     * @param newStart  The new start timestamp.
     * @param prevStart The previous start timestamp.
     */
    event StartUpdated(uint32 newStart, uint32 prevStart);

    /**
     * @notice Emitted when the end timestamp was updated.
     *
     * @dev This is only possible before the airdrop claiming ends.
     *
     * @param newEnd    The new end timestamp.
     * @param prevEnd   The previous end timestamp.
     */
    event EndUpdated(uint32 newEnd, uint32 prevEnd);

    /**
     * @notice Emitted when the sum of all XP and LP points on the Haven1
     * testnet was updated.
     *
     * @dev This is only possible before any airdrop was allocated.
     *
     * @param newMaxXp The new maximum XP amount.
     * @param newMaxLp The new maximum LP amount.
     */
    event XpLpAmountUpdated(uint256 newMaxXp, uint256 newMaxLp);

    /**
     * @notice Emitted when a user's allocation is set.
     *
     * @dev This is only possible before the end of the airdrop claiming and if
     * there is still unallocated airdrop left.
     *
     * @param user          The user to allocate the airdrop for.
     * @param allocatedH1   The amount of total H1 that was allocated to the user.
     * @param fromXp        The amount of H1 that was allocated based on XP points.
     * @param fromLp        The amount of H1 that was allocated based on LP points.
     */
    event AllocationSet(
        address indexed user,
        uint256 allocatedH1,
        uint256 fromXp,
        uint256 fromLp
    );

    /**
     * @notice Emitted when the airdrop was claimed by a user.
     *
     * @param user  The user that claimed his airdrop.
     * @param h1    The amount of H1 that was claimed by the user.
     * @param esH1  The amount of esH1 that was minted to the user.
     */
    event AirdropClaimed(address indexed user, uint256 h1, uint256 esH1);

    /**
     * @notice Emitted when the Association collects the amount of H1 that was
     * discarded.
     *
     * @dev While the airdrop is active, the Association can claim all unallocated
     * and currently discarded H1.
     *
     * After the end of the airdrop claiming, all remaining H1 can be collected.
     *
     * @param amount The amount of H1 that was collected.
     */
    event DiscardedAirdropCollected(uint256 amount);

    /* FUNCTIONS
    ==================================================*/

    /**
     * @notice Deposit the airdrop amount.
     *
     * @dev Requirements:
     * -    Only callable once, when the airdrop is not `_ready` and before the
     *      airdrop has started.
     * -    The `msg.value` must exactly equal the set `_airdrop` amount.
     * -    Must be called before any claim can be made.
     *
     * Emits an `AirdropDeposited` event.
     */
    function depositAirdrop() external payable;

    /**
     * @notice Cancels the airdrop.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    Only callable at a time before the airdrop has started.
     *
     * Example use case:
     * -    If incorrect XP/LP maximum amounts where set, we may wish to cancel
     *      and redeploy.
     *
     * Emits an `AirdropCanceled` event.
     */
    function cancelAirdrop() external;

    /**
     * @notice Changes the sum of all LP and XP points collected on the Haven1
     * testnet.
     *
     * @param maxXpAmount_ The sum of all XP points.
     * @param maxLpAmount_ The sum of all LP points.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    Only callable at a time before the airdrop has started.
     * -    Cannot be called if the airdrop has already been allocated.
     * -    Neither of the provided amounts can be zero (0).
     *
     * The only way to replace the maximum XP and LP amounts after an allocation
     * has happened it to first cancel the airdrop (by calling `cancelAirdrop`)
     * and redeploy. Note that cancelling the airdrop can only occur before the
     * airdrop has started.
     *
     * Emits an `XpLpAmountUpdated` event.
     */
    function setMaxXpAndLpAmount(
        uint256 maxXpAmount_,
        uint256 maxLpAmount_
    ) external;

    /**
     * @notice Change the start timestamp of the airdrop.
     *
     * @param startTS_ The new start timestamp.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    Only callable at a time before the airdrop starts.
     * -    The new start time must be less than the current end time.
     * -    The new start time must be in the future.
     *
     * Emits a `StartUpdated` event.
     */
    function setStartTimestamp(uint32 startTS_) external;

    /**
     * @notice Change the end timestamp of the airdrop.
     *
     * @param endTS_ The new end timestamp.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    Only callable at a time before the airdrop claiming as ended.
     * -    The new end time must be after the current start time.
     * -    The new end time must be in the future.
     *
     * Emits an `EndUpdated` event.
     */
    function setEndTimestamp(uint32 endTS_) external;

    /**
     * @notice Sets the user's airdrop allocation based on their XP and LP points
     * earned from Haven1 testnet.
     *
     * @dev The allocation can only be done by the Association.
     *
     * @param user_     The user to allocate the airdrop for.
     * @param xpAmount_ The xp amount of the user on Haven1 testnet.
     * @param lpAmount_ The lp amount of the user on Haven1 testnet.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The user address cannot be the zero address.
     * -    The airdrop must not have ended.
     * -    There must be sufficient remaining airdrop to allocate.
     *
     * Emits an `AllocationSet` event.
     */
    function setAllocation(
        address user_,
        uint256 xpAmount_,
        uint256 lpAmount_
    ) external;

    /**
     * @notice Sets the airdrop allocation for multiple users based on their
     * XP and LP points from Haven1 testnet.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     * -    The user address cannot be the zero address.
     * -    The airdrop must not have ended.
     * -    There must be sufficient remaining airdrop to allocate.
     * -    index [0] must be the user's total XP amount.
     * -    index [1] must be the user's total LP amount.
     *
     * @param users_    An array of the users to allocate the airdrop to.
     * @param amounts_  The amount of XP and LP points the user earned on Haven1 testnet.
     *
     * Emits `AllocationSet` events.
     */
    function setAllocations(
        address[] calldata users_,
        uint256[2][] calldata amounts_
    ) external;

    /**
     * @notice Claim the airdrop.
     *
     * @param esh1BPS_ The percentage of the airdrop that will be minted as esH1.
     *
     *
     * @dev Requirements:
     * -    The airdrop must be ready and active.
     * -    The contract must not be paused.
     * -    THe user must have an amount to claim.
     *
     * The user can claim their airdrop by providing the percentage of esH1
     * they wants to receive (in BPS).
     *
     * The `esh1BPS_` is the percentage of the airdrop that will be minted as
     * esH1. E.g., To mint the whole allocation as esH1, the value passed would
     * be: `10000` (ten thousand basis points is 100%).
     *
     * The rest of the airdrop will be sent as H1 to the user, after deducting
     * the amount of H1 that is discarded based on _H1_DEDUCTION_BPS.
     *
     * Emits an `AirdropClaimed` event.
     */
    function claimAirdrop(uint16 esh1BPS_) external;

    /**
     * @notice Collect the discarded airdrop.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    Only callable when the contract is ready.
     *
     * Before the airdrop has ended, unallocated H1 and discarded H1 can be
     * collected. After the airdrop has ended, all remaining H1 can be collected.
     *
     * Emits a `DiscardedAirdropCollected` event.
     */
    function collectDiscarded() external;

    /**
     * @notice Get the start timestamp of the airdrop.
     *
     * @return The start timestamp of the airdrop.
     */
    function getStartTimestamp() external view returns (uint32);

    /**
     * @notice Get the end timestamp of the airdrop.
     *
     * @return The end timestamp of the airdrop.
     */
    function getEndTimestamp() external view returns (uint32);

    /**
     * @notice Get the full amount of H1 in the airdrop.
     *
     * @return The full amount of the airdrop in the airdrop.
     */
    function getFullAirdropAmount() external view returns (uint256);

    /**
     * @notice Get the amount of the airdrop that is dedicated to be claimed.
     *
     * @return The amount of the airdrop that is dedicated to be claimed.
     */
    function getClaimableAirdrop() external view returns (uint256);

    /**
     * @notice Get the amount of the airdrop that has been discarded.
     *
     * @return The amount of the airdrop that was discarded.
     */
    function getDiscardedAirdrop() external view returns (uint256);

    /**
     * @notice Gets the amount of discarded airdop that has been collected.
     *
     * @return The amount of discarded airdop that has been collected.
     */
    function getDiscardedCollected() external view returns (uint256);

    /**
     * @notice Gets the available amount of H1 that is discarded and can be
     * collected. This differs from `getDiscardedAirdrop` as it includes any
     * amounts not allocated.
     *
     * @return The available amount of H1 that is discarded and can be collected.
     */
    function getToBeCollected() external view returns (uint256);

    /**
     * @notice Check if the airdrop is currently active.
     *
     * @return True if the airdrop is active, false otherwise.
     */
    function checkAirdropActive() external view returns (bool);

    /**
     * @notice Get the user's airdrop allocation.
     *
     * @param user_ The user to check.
     *
     * @return The H1 allocated to the user.
     */
    function getUserAllocation(address user_) external view returns (uint256);

    /**
     * @notice Get the percentage of the airdrop allocation that is dedicated to
     * XP points (returned as basis points).
     *
     * @return The allocation percentage that is dedicated to XP points.
     */
    function getXpAllocationBps() external pure returns (uint16);

    /**
     * @notice Get the amount of H1 from airdrop that is dedicated to XP points.
     *
     * @return The amount of the airdrop that is dedicated to XP points.
     */
    function getXpAllocation() external view returns (uint256);

    /**
     * @notice Get the percentage of the airdrop allocation that is dedicated to
     * LP points (returned as basis points).
     *
     * @return The allocation percentage that is dedicated to LP points.
     */
    function getLpAllocationBps() external pure returns (uint16);

    /**
     * @notice Get the amount of H1 from airdrop that is dedicated to LP points.
     *
     * @return The amount of the airdrop that is dedicated to LP points.
     */
    function getLpAllocation() external view returns (uint256);

    /**
     * @notice Get the amount of H1 from airdrop that is not yet allocated to
     * any user.
     *
     * @return The amount of the airdrop that is not allocated.
     */
    function getUnallocatedAirdrop() external view returns (uint256);

    /**
     * @notice Allows a caller to get their estimated H1 airdrop allocation
     * based on their XP and LP points earned from Haven1 testnet.
     *
     * @param xp_ The xp amount of the user.
     * @param lp_ The lp amount of the user.
     *
     * @return The expected amount of H1 from airdrop for the user.
     */
    function getExpectedAirdrop(
        uint256 xp_,
        uint256 lp_
    ) external view returns (uint256);
}
