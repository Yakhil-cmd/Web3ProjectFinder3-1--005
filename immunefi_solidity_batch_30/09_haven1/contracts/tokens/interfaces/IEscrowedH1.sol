// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
 * @dev The deposit and claim information.
 */
struct VestingInfo {
    uint256 amount;
    uint256 depositTimestamp;
    uint256 lastClaimTimestamp;
    uint256 totalClaimed;
    bool finishedClaiming;
}

/**
 * @title IEscrowedH1
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the `EscrowedH1` contract.
 */
interface IEscrowedH1 is IERC20Upgradeable {
    /**
     * @notice Emitted when Escrowed H1 is deposited into the contract.
     *
     * @param user      The address of the user who vested.
     * @param amount    The amount of esH1 vested.
     */
    event DepositedEscrowedH1(address indexed user, uint256 amount);

    /**
     * @notice Emitted when H1 is deposited into the contract.
     *
     * @param user      The address of the user who deposited.
     * @param amount    The amount of H1 deposited.
     */
    event DepositedH1(address indexed user, uint256 amount);

    /**
     * @notice Emitted when an address claims H1.
     *
     * @param user      The user making the claim.
     * @param amount    The amount of H1 the claimed.
     */
    event ClaimedH1(address indexed user, uint256 amount);

    /**
     * @notice Emitted when H1 is withdrawn from the contract.
     *
     * @param to        The address the H1 was withdrawn to.
     * @param amount    The amount of H1 that was withdrawn.
     */
    event H1Withdrawn(address indexed to, uint256 amount);

    /**
     * @notice Emitted when a user's position has finished vesting.
     *
     * @param user          The address whose position has finished vesting.
     * @param totalVested   The total amount of esH1 that was vested into H1.
     */
    event VestingFinished(address indexed user, uint256 totalVested);

    /**
     * Emitted when an emergency token withdrawal occurs.
     *
     * @param token     The address of the token that was withdrawn.
     * @param to        The address the token was withdrawn to.
     * @param amount    The amount of the token that was withdrawn.
     */
    event EmergencyTokenWithdrawal(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    /**
     * @notice Emitted when an address is whitelisted.
     *
     * @param account The address added to the whitelist.
     */
    event AddedToWhitelist(address indexed account);

    /**
     * @notice Emitted when an address is removed from the whitelist.
     *
     * @param account The address removed from the whitelist.
     */
    event RemovedFromWhitelist(address indexed account);

    /**
     * @notice Begins vesting a user's esH1 into H1.
     *
     * @param amount The number of tokens to vest.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The amount to vest must be greater than zero.
     * -    The amount to vest must be within the user's available esH1 balance.
     * -    Must supply the Native Application Fee.
     *
     * Emits a `DepositedEscrowedH1` event.
     *
     * Will immediately burn the user's esH1 tokens and linearly vest the
     * corresponding H1.
     */
    function startVesting(uint256 amount) external payable;

    /**
     * @notice Claims the available H1 from a user's vesting position. See also
     * `claimFor` to claim on behalf of an account.
     *
     * @param index The index in the account's `VestingInfo` array.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The supplied index must be valid.
     * -    Must supply the Native Application Fee.
     *
     * Emits a `ClaimedH1` event.
     * Emtis a `VestingFinished` event if the given position has finished vesting.
     */
    function claim(uint256 index) external payable;

    /**
     * @notice Claims the available H1 from a user's vesting position on behalf
     * of that user.
     *
     * @param account   The address to claim on behalf of.
     * @param index     The index in the account's `VestingInfo` array.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The supplied account must be valid.
     * -    The supplied index must be valid.
     * -    Must supply the Native Application Fee.
     *
     * Emits a `ClaimedH1` event.
     * Emtis a `VestingFinished` event if the given position has finished vesting.
     */
    function claimFor(address account, uint256 index) external payable;

    /**
     * @notice Withdraws the balance of H1 from this contract to the `to` address.
     *
     * @param to The address to send the withdrawn H1 to.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `H1Withdrawn` event.
     */
    function emergencyWithdraw(address payable to) external;

    /**
     * @notice Allows for the recovery of an amount of an HRC-20 token to a
     * given address.
     *
     * @param token     The address of the HRC-20 token to recover.
     * @param to        The address to which the tokens  will be sent.
     * @param amount    The amount of tokens to send.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The to address must not be the zero address.
     * -    The contract must have at least `amount` of `token` balance.
     */
    function recoverHRC20(address token, address to, uint256 amount) external;

    /**
     * @notice Allows for the recovery of this contract's balance of an HRC-20
     * token to a given address.
     *
     * @param token The address of the HRC-20 token to recover.
     * @param to    The address to which the tokens  will be sent.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     * -    The to address must not be the zero address.
     */
    function recoverAllHRC20(address token, address to) external;

    /**
     * @notice Payable function that mints an amount of esH1 to the `recipient`
     * equal to the amount of H1 that was sent in.
     *
     * @param recipient The address to receive the esH1.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     * -    The `msg.value` must not be zero.
     */
    function mintEscrowedH1(address recipient) external payable;

    /**
     * @notice Returns the amount of H1 that a user may claim from a given
     * position.
     *
     * @param user  The address that made the deposit.
     * @param index The index in the user's `VestingInfo` array.
     *
     * @dev will return `0` if there is no valid position for the user at the
     * given index or the position has already finished vesting.
     */
    function calculateClaimableAmount(
        address user,
        uint256 index
    ) external view returns (uint256);

    /**
     * @notice Adds an address to the whitelist.
     *
     * @param account The address to add.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits an `AddedToWhitelist` event.
     */
    function addToWhitelist(address account) external;

    /**
     * @notice Removes an address from the whitelist.
     *
     * @param account The address to remove.
     *
     * @dev Requirements:
     * -    The caller must have the role: `DEFAULT_ADMIN_ROLE`.
     *
     * Emits a `RemovedFromWhitelist` event.
     */
    function removeFromWhitelist(address account) external;

    /**
     * @notice Returns the vesting duration.
     *
     * @return The vesting duration.
     */
    function getVestingDuration() external view returns (uint256);

    /**
     * @notice Returns the `VestingInfo` for a particular user's vesting
     * position.
     *
     * @param user  The user's address.
     * @param index The index in the user's `VestingInfo` array.
     *
     * @return The position details as `VestingInfo`.
     */
    function getUserVestingByIndex(
        address user,
        uint256 index
    ) external view returns (VestingInfo memory);

    /**
     * @notice Returns an array of `VestingInfo` for the user.
     *
     * @param user The address of the user.
     *
     * @return The users `VestingInfo` array.
     */
    function getUserVestingsByAddress(
        address user
    ) external view returns (VestingInfo[] memory);

    /**
     * @notice Returns the amount of positions a user has currently vesting.
     *
     * @param user The address of the user.
     *
     * @return The amount of positions a user has currently vesting.
     */
    function getCurrentlyVestingCount(
        address user
    ) external view returns (uint256);

    /**
     * @notice Returns the `VestingInfo` for a particular user's finished
     * vesting position.
     *
     * @param user  The user's address.
     * @param index The index in the user's `VestingInfo` array.
     *
     * @return The position details as `VestingInfo`.
     */
    function getFinishedPosition(
        address user,
        uint256 index
    ) external view returns (VestingInfo memory);

    /**
     * @notice Returns all of a users' positions that have finished vesting as
     * as array of `VestingInfo`.
     *
     * @param user The address of the user.
     *
     * @return The users `VestingInfo` array.
     */
    function getFinishedPositions(
        address user
    ) external view returns (VestingInfo[] memory);

    /**
     * @notice Returns the amount of positions a user has finished vesting.
     *
     * @param user The address of the user.
     *
     * @return The amount of positions a user has finished vesting.
     */
    function getFinishedPositionsCount(
        address user
    ) external view returns (uint256);

    /**
     * @notice Returns whether an address has been whitelisted to transfer
     * esH1.
     *
     * @param account The address to check.
     *
     * @return True if the address is whitelisted, false otherwise.
     */
    function isWhitelisted(address account) external view returns (bool);
}
