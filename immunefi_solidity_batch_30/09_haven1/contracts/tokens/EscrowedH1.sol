// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC20Upgradeable, IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import { H1NativeApplicationUpgradeable } from "../h1-native-application/H1NativeApplicationUpgradeable.sol";
import { IEscrowedH1, VestingInfo } from "./interfaces/IEscrowedH1.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title EscrowedH1
 *
 * @author The Haven1 Development Team
 *
 * @notice Contract responsible for minting esH1 and vesting a user's esH1 to
 * H1.
 *
 * Note that the following functions require an application fee to be sent:
 * -    `startVesting`
 * -    `claim`
 * -    `claimFor`
 */
contract EscrowedH1 is
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    H1NativeApplicationUpgradeable,
    RecoverableUpgradeable,
    IEscrowedH1,
    IVersion
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* STATE
    ==================================================*/

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The amount of time, in seconds, that tokens vest.
     */
    uint256 private _vestingDuration;

    /**
     * @dev Mapping of depositor addresses to an array of `VestingInfo` structs.
     *
     * Each address may have multiple positions vesting at one time.
     *
     * Each entry in the array represents an __open__ position.
     *
     * Positions in the array are __not__ guaranteed to be ordered.
     */
    mapping(address => VestingInfo[]) private _inProgressVesting;

    /**
     * @dev Mapping of depositor addresses to an array of `VestingInfo` structs.
     *
     * Each address may have multiple positions vesting at one time.
     *
     * Each entry in the array represents a __finished__ position.
     *
     * Positions in the array are __not__ guaranteed to be ordered.
     */
    mapping(address => VestingInfo[]) private _finishedVesting;

    /**
     * @dev Mapping of address to bool that indicates whether an address has the
     * ability to transfer esH1. By default, esH1 will be non-transferable.
     */
    mapping(address => bool) private _whitelist;

    /* ERRORS
    ==================================================*/
    /**
     * @dev Raised if the transfer fails.
     *
     * @param amount The amount attempted to transfer.
     */
    error EscrowedH1__TransferFailed(uint256 amount);

    /**
     * @dev Raised if a user tries to mint or vest zero esH1.
     */
    error EscrowedH1__ZeroValueNotApplicable();

    /**
     * @dev Raised if there is an insufficient H1 / token balance.
     */
    error EscrowedH1__InsufficientBalance();

    /**
     * @dev Raised if there is no position at a given index in an address'
     * `VestingInfo` array.
     *
     * @param account   The address that was checked.
     * @param index     The index at which no position exists.
     */
    error EscrowedH1__InvalidIndex(address account, uint256 index);

    /**
     * @dev Raised if the from or to address of a transfer is not whitelisted.
     *
     * @param from  The address that was checked.
     * @param to    The address that was checked.
     */
    error EscrowedH1__NotWhitelisted(address from, address to);

    /* MODIFIERS
    ==================================================*/
    /**
     * @dev Modifier that checks that an account is whitelisted to transfer H1.
     *
     * Requirements:
     * -    If we are not mitning or burning, either the from or to address must
     *      be whitelisted.
     */
    modifier whitelisted(address from, address to) {
        bool fromWL = _whitelist[from];
        bool toWL = _whitelist[to];

        // --------------------------------------------------------------------
        // Explanation of Condition:
        // --------------------------------------------------------------------
        // 1.   If the "from" address is the zero address, we are minting.
        // 2.   If the "to" address is the zero address, we are burning.
        // 3.   If we are not minting or burning, then either the "from" address
        //      or the "to" address must be whitelisted.
        //
        // --------------------------------------------------------------------
        // This means:
        // --------------------------------------------------------------------
        // 1.   Any address can mint.
        // 2.   Any address can vest.
        // 3.   Transfer to the zero address are prohibited in `_transfer`.
        // 4.   Any address that is whitelisted can transfer to any address.
        // 5.   Any address can transfer to a whitelisted address.
        if (from != address(0) && to != address(0) && !fromWL && !toWL) {
            revert EscrowedH1__NotWhitelisted(from, to);
        }

        _;
    }

    /* FUNCTIONS
    ==================================================*/
    /* Constructor
    ========================================*/

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /* Receive and Fallback
    ========================================*/

    /**
     * @notice Receives H1 into the contract and mints an equivalent amount of
     * esH1 back to the sender.
     *
     * Note: `mintEscrowedH1` should be preferred.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     *
     * Emits a `DepositedH1` event.
     */
    receive() external payable {
        _requireNotGuardianPaused();
        _mint(msg.sender, msg.value);
        emit DepositedH1(msg.sender, msg.value);
    }

    /**
     * @notice Receives H1 into the contract and mints an equivalent amount of
     * esH1 back to the sender.
     *
     * Note: `mintEscrowedH1` should be preferred.
     *
     * @dev Requirements:
     * -    The contract must not be paused.
     *
     * Emits a `DepositedH1` event.
     */
    fallback() external payable {
        _requireNotGuardianPaused();
        _mint(msg.sender, msg.value);
        emit DepositedH1(msg.sender, msg.value);
    }

    /* External
    ========================================*/
    /**
     * @notice Initializes the contract.
     *
     * @param name_                  The token's name.
     * @param symbol_                The token's symbol.
     * @param association_           The Haven1 Association address.
     * @param feeContract_           The Fee Cntract address.
     * @param guardianController_    The Network Guardian Controller address.
     * @param vestingDuration_       The vesting duration, in seconds.
     * @param toWhitelist_           An array of additional address to whitelist.
     *
     * @dev This contract address, the Association, and all addresses in the
     * `toWhitelist_` array will all be whitelisted upon initialization.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address association_,
        address feeContract_,
        address guardianController_,
        uint256 vestingDuration_,
        address[] memory toWhitelist_
    ) external initializer {
        __ERC20_init(name_, symbol_);
        __ReentrancyGuard_init();
        __Recoverable_init();
        __H1NativeApplication_init(
            association_,
            guardianController_,
            feeContract_
        );

        _vestingDuration = vestingDuration_;

        _whitelist[address(this)] = true;
        _whitelist[association_] = true;

        uint256 l = toWhitelist_.length;
        for (uint256 i; i < l; i++) {
            _whitelist[toWhitelist_[i]] = true;
        }
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function startVesting(
        uint256 amount
    )
        external
        payable
        whenNotGuardianPaused
        nonReentrant
        applicationFee(true, false)
    {
        // This would be caught by _burn, however better to catch early and
        // provide a more contextually appropriate error message.
        if (amount == 0) {
            revert EscrowedH1__ZeroValueNotApplicable();
        }

        _burn(msg.sender, amount);

        VestingInfo memory v = VestingInfo({
            amount: amount,
            depositTimestamp: block.timestamp,
            lastClaimTimestamp: block.timestamp,
            totalClaimed: 0,
            finishedClaiming: false
        });

        _inProgressVesting[msg.sender].push(v);

        uint256 val = _msgValueAfterFee();
        if (val > 0) {
            (bool success, ) = payable(msg.sender).call{ value: val }("");
            if (!success) revert EscrowedH1__TransferFailed(val);
        }

        emit DepositedEscrowedH1(msg.sender, amount);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function claim(
        uint256 index
    )
        external
        payable
        whenNotGuardianPaused
        nonReentrant
        applicationFee(true, false)
    {
        _claim(msg.sender, index);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function claimFor(
        address account,
        uint256 index
    )
        external
        payable
        whenNotGuardianPaused
        nonReentrant
        applicationFee(true, false)
    {
        _claim(account, index);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function emergencyWithdraw(
        address payable to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 bal = address(this).balance;

        (bool success, ) = to.call{ value: bal }("");

        if (!success) revert EscrowedH1__TransferFailed(bal);

        emit H1Withdrawn(to, bal);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function recoverHRC20(
        address token,
        address to,
        uint256 amount
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token, to, amount);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function recoverAllHRC20(
        address token,
        address to
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 bal = IERC20Upgradeable(token).balanceOf(address(this));
        _recoverHRC20(token, to, bal);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function mintEscrowedH1(
        address recipient
    ) external payable whenNotGuardianPaused {
        if (msg.value == 0) {
            revert EscrowedH1__ZeroValueNotApplicable();
        }

        _mint(recipient, msg.value);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function calculateClaimableAmount(
        address user,
        uint256 index
    ) external view returns (uint256) {
        return _calculateClaimable(user, index);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function addToWhitelist(
        address account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_whitelist[account]) return;
        _whitelist[account] = true;
        emit AddedToWhitelist(account);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function removeFromWhitelist(
        address account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!_whitelist[account]) return;
        _whitelist[account] = false;
        emit RemovedFromWhitelist(account);
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getVestingDuration() external view returns (uint256) {
        return _vestingDuration;
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getUserVestingByIndex(
        address user,
        uint256 index
    ) external view returns (VestingInfo memory) {
        return _inProgressVesting[user][index];
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getUserVestingsByAddress(
        address user
    ) external view returns (VestingInfo[] memory) {
        return _inProgressVesting[user];
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getCurrentlyVestingCount(
        address user
    ) external view returns (uint256) {
        return _inProgressVesting[user].length;
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getFinishedPosition(
        address user,
        uint256 index
    ) external view returns (VestingInfo memory) {
        return _finishedVesting[user][index];
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getFinishedPositions(
        address user
    ) external view returns (VestingInfo[] memory) {
        return _finishedVesting[user];
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function getFinishedPositionsCount(
        address user
    ) external view returns (uint256) {
        return _finishedVesting[user].length;
    }

    /**
     * @inheritdoc IEscrowedH1
     */
    function isWhitelisted(address account) external view returns (bool) {
        return _whitelist[account];
    }

    /**
     * @inheritdoc IVersion
     */
    function version() external pure returns (uint64) {
        return VERSION;
    }

    /**
     * @inheritdoc IVersion
     */
    function versionDecoded() external pure returns (uint32, uint16, uint16) {
        return Semver.decode(VERSION);
    }

    /* Internal
    ========================================*/

    /**
     * @dev overrides `_beforeTokenTransfer` from `ERC20Upgradeable`, adding
     * the `whitelisted` modifier. Ensures that esH1 may only be transferred
     * from or to a whitelisted addresses.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whitelisted(from, to) {}

    /* Private
    ========================================*/

    /**
     * @notice Marks a given position as finished and moves it to the account's
     * `_completedVesting` array.
     *
     * @param account   The address owner of the position.
     * @param index     The index to mark as complete and move.
     *
     * @dev Requirements:
     * -    Assumes that the index is valid - any strict validation must occur
     *      prior to calling this function.

     * Note that this operation will leave the account's `_inProgressVesting`
     * array __unordered__.
     *
     * Emits a `VestingFinished` event.
     */
    function _moveToFinished(address account, uint256 index) private {
        VestingInfo memory tmp = _inProgressVesting[account][index];
        tmp.finishedClaiming = true;

        _finishedVesting[account].push(tmp);

        uint256 l = _inProgressVesting[account].length;
        _inProgressVesting[account][index] = _inProgressVesting[account][l - 1];
        _inProgressVesting[account].pop();

        emit VestingFinished(account, tmp.amount);
    }

    /**
     * @notice Claims the available vested H1 from a user's vesting position.
     *
     * @param account   The address to claim on behalf of.
     * @param index     The index in the account's `VestingInfo` array.
     *
     * @dev Requirements:
     * -    Valid account.
     * -    Valid index.
     *
     * Functions calling this private function should include the `nonReentrant`
     * modifier.
     *
     * Emits a `ClaimedH1` event.
     */
    function _claim(address account, uint256 index) private {
        _assertValidIndex(account, index);

        uint256 claimable = _calculateClaimable(account, index);

        // Sanity check
        if (claimable > address(this).balance) {
            revert EscrowedH1__InsufficientBalance();
        }

        VestingInfo storage info = _inProgressVesting[account][index];

        info.totalClaimed += claimable;
        info.lastClaimTimestamp = block.timestamp;

        bool isFinished = info.amount == info.totalClaimed;

        if (isFinished) {
            _moveToFinished(account, index);
        }

        (bool success, ) = payable(account).call{ value: claimable }("");

        if (!success) {
            revert EscrowedH1__TransferFailed(claimable);
        }

        uint256 val = _msgValueAfterFee();
        if (val > 0) {
            (bool valSuccess, ) = payable(msg.sender).call{ value: val }("");
            if (!valSuccess) revert EscrowedH1__TransferFailed(val);
        }

        emit ClaimedH1(account, claimable);
    }

    /**
     * @notice Returns the amount of H1 that a user may claim from a given
     * position.
     *
     * @param account   The address for which the amount claimable is calculated.
     * @param index     The index in the account's `VestingInfo` array.
     *
     * @return The claimable amount.
     */
    function _calculateClaimable(
        address account,
        uint256 index
    ) internal view returns (uint256) {
        _assertValidIndex(account, index);

        VestingInfo memory info = _inProgressVesting[account][index];

        uint256 dt = block.timestamp - info.lastClaimTimestamp;
        bool vested = block.timestamp >=
            info.depositTimestamp + _vestingDuration;

        uint256 claimable = (info.amount * dt) / _vestingDuration;
        uint256 remaining = info.amount - info.totalClaimed;

        if (claimable > remaining || vested) {
            claimable = remaining;
        }

        return claimable;
    }

    /**
     * @dev Will validate that a given index in an address' `VestingInfo` array
     * exists.
     *
     * @param account   The adderss to check.
     * @param index     The index into the address' `VestingInfo` array.
     */
    function _assertValidIndex(address account, uint256 index) private view {
        if (index >= _inProgressVesting[account].length) {
            revert EscrowedH1__InvalidIndex(account, index);
        }
    }
}
