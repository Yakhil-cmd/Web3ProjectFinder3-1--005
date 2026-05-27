// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { IAirdropClaim } from "./interfaces/IAirdropClaim.sol";
import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { IEscrowedH1 } from "../tokens/interfaces/IEscrowedH1.sol";
import { Address } from "../utils/Address.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";
import "./lib/Errors.sol";

/**
 * @title AirdropClaim
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract manages the distribution of an H1 airdrop to the Haven1
 * community in a transparent and fair manner. It allows allocation of airdrop
 * tokens based on user-earned XP and LP points, which were collected on the
 * Haven1 testnet.
 *
 * The contract includes mechanisms for allocating, claiming, canceling, and
 * handling unclaimed or discarded tokens.
 *
 * @dev To correctly setup this contract's functionality, the airdrop amount in
 * H1 must be deposited using `depositAirdrop`.
 *
 * Allocations can be set before or after depositing.
 *
 * XP and LP allocations are calculated based on the `_maxXpAmount` and `_maxLpAmount`,
 * which must reflect the total earned points in the Haven1 testnet. These values
 * can be modified until any allocation is set.
 *
 * The contract is also capable of handling cases of incorrect metrics by
 * resetting allocations or canceling the airdrop.
 *
 * Users can claim their allocation by specifying the percentage to be converted
 * to esH1 using the `esh1BPS_` parameter.
 *
 * Airdrops can only be claimed by the user who owns the allocation. If the user
 * opts for a partial esH1 claim, the remaining H1 portion is subject to a
 * 75% deduction. Any remaining or discarded H1 can be collected by the Association
 * via the `collectDiscarded` function after the airdrop has started.
 *
 * The start and end dates of the airdrop can be modified until they are in the
 * past.
 *
 * A network guardian can pause the airdrop if necessary.
 */
contract AirdropClaim is
    ReentrancyGuardUpgradeable,
    NetworkGuardian,
    IAirdropClaim,
    IVersion
{
    using Address for address;

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @notice Basis points scale for percentage calculations.
     * @dev 10,000 basis points = 100%
     */
    uint16 constant _BPS_SCALE = 10_000;

    /**
     * @notice Basis points uesd to calculate the deducted H1 allocation during
     * the claim process.
     */
    uint16 constant _H1_DEDUCTION_BPS = 2_500;

    /**
     * @notice Basis points for XP allocation in the airdrop (80%).
     */
    uint16 constant _XP_AIRDROP_BPS = 8_000;

    /**
     * @notice Precision used in calculations to avoid rounding issues.
     */
    uint256 constant _PRECISION = 10 ** 18;

    /**
     * @notice Indicates if the contract is ready for airdrop operations.
     */
    bool private _ready;

    /**
     * @notice The total amount of LP  points that were earned on testnet.
     */
    uint256 private _maxLpAmount;

    /**
     * @notice H1 tokens allocated for LP points in the airdrop.
     */
    uint256 private _lpH1Allocation;

    /**
     * @notice The total amount of XP points that was earned on testnet.
     */
    uint256 private _maxXpAmount;

    /**
     * @notice H1 tokens allocated for XP points in the airdrop.
     */
    uint256 private _xpH1Allocation;

    /**
     * @notice The timestamp when the airdrop starts.
     */
    uint32 private _startTS;

    /**
     * @notice The timestamp when the airdrop ends.
     */
    uint32 private _endTS;

    /**
     * @notice Total amount of H1 tokens allocated for the airdrop.
     */
    uint256 private _airdropAmount;

    /**
     * @notice Total amount of H1 tokens available to be claimed from the airdrop.
     */
    uint256 private _availableAirdrop;

    /**
     * @notice Total amount of discarded H1 tokens from unclaimed airdrop allocations.
     */
    uint256 private _discardedAirdrop;

    /**
     * @notice The total amount of discarded H1 that has been collected.
     */
    uint256 private _discardedCollected;

    /**
     * @notice The address of the EscrowedH1 contract.
     */
    address private _escrowedH1;

    /**
     * @notice Mapping that stores user allocations of H1 tokens for the airdrop.
     */
    mapping(address user => uint256 allocation) private _allocation;

    /* MODIFIERS
    ==================================================*/

    modifier isReady() {
        if (!_ready) revert AirdropClaim__NotActive();
        _;
    }

    modifier notEnded() {
        if (block.timestamp > _endTS) revert AirdropClaim__NotActive();
        _;
    }

    modifier notStarted() {
        if (block.timestamp >= _startTS) revert AirdropClaim__AlreadyStarted();
        _;
    }

    /* Constructor
    ========================================*/

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /* Init
    ========================================*/
    /**
     * @notice Initializes the contract.
     *
     * @param airdropAmount_        The amount of H1 available for the airdrop.
     * @param startTS_              The start timestamp of the airdrop.
     * @param endTS_                The end timestamp of the airdrop.
     * @param maxLpAmount_          The sum of all lp points that can be collected.
     * @param maxXpAmount_          The sum of all xp points that can be collected.
     * @param escrowedH1_           The escrowed H1 address.
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     */
    function initialize(
        uint256 airdropAmount_,
        uint32 startTS_,
        uint32 endTS_,
        uint256 maxLpAmount_,
        uint256 maxXpAmount_,
        address escrowedH1_,
        address association_,
        address guardianController_
    ) external initializer {
        escrowedH1_.assertNotZero();
        _checkNotZero(airdropAmount_);
        _checkNotZero(maxLpAmount_);
        _checkNotZero(maxXpAmount_);

        if (startTS_ >= endTS_ || startTS_ < block.timestamp) {
            revert AirdropClaim__WrongData();
        }

        __ReentrancyGuard_init();
        __NetworkGuardian_init(association_, guardianController_);

        _maxLpAmount = maxLpAmount_;
        _maxXpAmount = maxXpAmount_;

        _ready = false;
        _airdropAmount = airdropAmount_;
        _startTS = startTS_;
        _endTS = endTS_;
        _escrowedH1 = escrowedH1_;
        _calculateXpLpAllocation();
    }

    /* External
    ========================================*/

    receive() external payable {
        revert AirdropClaim__Revert();
    }

    fallback() external payable {
        revert AirdropClaim__Revert();
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function depositAirdrop() external payable notStarted {
        if (_ready) {
            revert AirdropClaim__IsReady();
        }

        if (msg.value != _airdropAmount) {
            revert AirdropClaim__WrongAidropAmount(msg.value, _airdropAmount);
        }

        _ready = true;

        emit AirdropDeposited(msg.value);
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function cancelAirdrop()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        notStarted
        nonReentrant
    {
        _sendH1(association(), address(this).balance);
        _startTS = 0;
        _endTS = 0; // The end is now in the past, all external functions are blocked (execpt collectDiscarded()).
        _availableAirdrop = 0;
        emit AirdropCanceled();
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function setMaxXpAndLpAmount(
        uint256 maxXpAmount_,
        uint256 maxLpAmount_
    ) external notStarted onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_availableAirdrop != 0) {
            revert AirdropClaim__AlreadyAllocated();
        }

        _checkNotZero(maxXpAmount_);
        _checkNotZero(maxLpAmount_);

        _maxXpAmount = maxXpAmount_;
        _maxLpAmount = maxLpAmount_;
        _calculateXpLpAllocation();

        emit XpLpAmountUpdated(_maxXpAmount, _maxLpAmount);
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function setStartTimestamp(
        uint32 startTS_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) notStarted {
        if (startTS_ >= _endTS || block.timestamp >= startTS_) {
            revert AirdropClaim__WrongData();
        }

        emit StartUpdated(startTS_, _startTS);
        _startTS = startTS_;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function setEndTimestamp(
        uint32 endTS_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) notEnded {
        if (endTS_ <= _startTS || block.timestamp > endTS_) {
            revert AirdropClaim__WrongData();
        }

        emit EndUpdated(endTS_, _endTS);
        _endTS = endTS_;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function setAllocation(
        address user_,
        uint256 xpAmount_,
        uint256 lpAmount_
    ) external onlyRole(OPERATOR_ROLE) notEnded {
        _setAllocation(user_, xpAmount_, lpAmount_);
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function setAllocations(
        address[] calldata users_,
        uint256[2][] calldata amounts_
    ) external onlyRole(OPERATOR_ROLE) notEnded {
        uint256 length = users_.length;
        if (length != amounts_.length) {
            revert AirdropClaim__WrongData();
        }

        for (uint256 i = 0; i < length; ++i) {
            _setAllocation(users_[i], amounts_[i][0], amounts_[i][1]);
        }
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function claimAirdrop(
        uint16 esh1BPS_
    ) external isReady notEnded whenNotGuardianPaused nonReentrant {
        if (esh1BPS_ > _BPS_SCALE) {
            revert AirdropClaim__InvalidBps(esh1BPS_, _BPS_SCALE);
        }

        if (block.timestamp < _startTS) {
            revert AirdropClaim__NotActive();
        }

        uint256 amount = _allocation[msg.sender];
        if (amount == 0) {
            revert AirdropClaim__NoAllocation();
        }

        _allocation[msg.sender] = 0;

        uint256 availableAirdrop = _availableAirdrop;
        uint256 discardedAirdrop = _discardedAirdrop;

        uint256 esH1 = (amount * esh1BPS_) / _BPS_SCALE;
        uint256 h1 = ((amount - esH1) * _H1_DEDUCTION_BPS) / _BPS_SCALE;

        availableAirdrop -= amount;
        discardedAirdrop += (amount - (esH1 + h1));

        // Mint esH1 to user
        if (esH1 > 0) {
            IEscrowedH1(_escrowedH1).mintEscrowedH1{ value: esH1 }(msg.sender);
        }
        // Send H1 to user
        if (h1 > 0) {
            _sendH1(msg.sender, h1);
        }

        _availableAirdrop = availableAirdrop;
        _discardedAirdrop = discardedAirdrop;

        emit AirdropClaimed(msg.sender, h1, esH1);
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function collectDiscarded()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isReady
        nonReentrant
    {
        if (block.timestamp < _startTS) {
            revert AirdropClaim__NotActive();
        }

        uint256 withdrawAmount = 0;

        if (block.timestamp > _endTS) {
            // If we are in this branch, the airdrop is over. The remaining
            // balance of the contract must be withdrawn, and the available
            // airdrop set to zero.
            withdrawAmount = address(this).balance;
            _availableAirdrop = 0;
        } else {
            // If we are in this branch, the airdrop is still active and we
            // are collecting the H1 that has either been discarded so far or
            // not allocated.
            withdrawAmount = address(this).balance - _availableAirdrop;
        }

        if (withdrawAmount > 0) {
            // If there is an amount to withdraw, we increase the amount of
            // discarded H1 collected by the amount to be withdrawn and then
            // set the total discarded airdrop to equal the amount collected.
            _discardedCollected += withdrawAmount;
            _discardedAirdrop = 0;

            _sendH1(association(), withdrawAmount);
            emit DiscardedAirdropCollected(withdrawAmount);
        }
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getStartTimestamp() external view returns (uint32) {
        return _startTS;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getEndTimestamp() external view returns (uint32) {
        return _endTS;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getFullAirdropAmount() external view returns (uint256) {
        return _airdropAmount;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getClaimableAirdrop() external view returns (uint256) {
        return _availableAirdrop;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getDiscardedAirdrop() external view returns (uint256) {
        return _discardedAirdrop;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getDiscardedCollected() external view returns (uint256) {
        return _discardedCollected;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getToBeCollected() external view returns (uint256) {
        if (block.timestamp > _endTS) {
            return address(this).balance;
        }

        return address(this).balance - _availableAirdrop;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function checkAirdropActive() external view returns (bool) {
        return
            (block.timestamp >= _startTS) &&
            (block.timestamp <= _endTS && _ready);
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getUserAllocation(address user_) external view returns (uint256) {
        return _allocation[user_];
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getXpAllocationBps() external pure returns (uint16) {
        return _XP_AIRDROP_BPS;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getXpAllocation() external view returns (uint256) {
        return _xpH1Allocation;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getLpAllocationBps() external pure returns (uint16) {
        return _BPS_SCALE - _XP_AIRDROP_BPS;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getLpAllocation() external view returns (uint256) {
        return _lpH1Allocation;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getUnallocatedAirdrop() external view returns (uint256) {
        uint256 amount = _airdropAmount;

        if (_ready) {
            amount = address(this).balance - _discardedAirdrop;
        }

        return amount - _availableAirdrop;
    }

    /**
     * @inheritdoc IAirdropClaim
     */
    function getExpectedAirdrop(
        uint256 xp_,
        uint256 lp_
    ) external view returns (uint256) {
        (uint256 h1XP, uint256 h1LP) = _calculateUserAllocation(xp_, lp_);
        return h1XP + h1LP;
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

    /* Private
    ========================================*/

    /**
     * @dev Calculates the amount of H1 to allocate to XP and LP points.
     *
     * The amount of H1 allocated to XP Points is 80%.
     * The amount of H1 allocated to LP Points is 20%.
     */
    function _calculateXpLpAllocation() private {
        _xpH1Allocation = (_airdropAmount * _XP_AIRDROP_BPS) / _BPS_SCALE;
        _lpH1Allocation = _airdropAmount - _xpH1Allocation;
    }

    /**
     * @dev Calculates the user's airdrop allocation.
     *
     * Computes the airdrop allocation by determining the user's shares of total
     * XP and LP points earned relative to the total amounts earned, and then
     * scales those shares against the total available allocations.
     *
     * @param xp_ The amount of XP points the user holds.
     * @param lp_ The amount of LP points the user holds.
     *
     * @return The airdrop allocation based on the user's share of XP points.
     * @return The airdrop allocation based on the user's share of LP points.
     */
    function _calculateUserAllocation(
        uint256 xp_,
        uint256 lp_
    ) private view returns (uint256, uint256) {
        uint256 xpAlloc = 0;
        uint256 lpAlloc = 0;

        uint256 xpShares = ((xp_ * _PRECISION) / _maxXpAmount) * _BPS_SCALE;
        uint256 lpShares = ((lp_ * _PRECISION) / _maxLpAmount) * _BPS_SCALE;

        xpAlloc = (_xpH1Allocation * xpShares) / (_BPS_SCALE * _PRECISION);
        lpAlloc = (_lpH1Allocation * lpShares) / (_BPS_SCALE * _PRECISION);

        return (xpAlloc, lpAlloc);
    }

    /**
     * @dev Sets the airdrop allocation for a user.
     *
     * @param user_ The user for which the allocation is set.
     * @param xp_   The amount of XP points the user earned on testnet.
     * @param lp_   The amount of LP points the user earned on testnet.
     */
    function _setAllocation(address user_, uint256 xp_, uint256 lp_) private {
        user_.assertNotZero();

        // Cache values for gas optimisation.
        uint256 availableAirdrop = _availableAirdrop;
        uint256 allocation = _allocation[user_];

        // Calculate the allocation amount based on XP and LP points.
        (uint256 xpAlloc, uint256 lpAlloc) = _calculateUserAllocation(xp_, lp_);

        uint256 amount = xpAlloc + lpAlloc;
        uint256 balance = _ready ? address(this).balance : _airdropAmount;

        // If the user already has an allocation, we need to adjust the total
        // available airdrop amount.
        if (allocation > 0) {
            availableAirdrop -= allocation;
        }

        // Check if there is allocation left.
        uint256 remaining = balance - _discardedAirdrop;
        if ((amount + availableAirdrop) > remaining) {
            revert AirdropClaim__NoAirdropLeft(amount, remaining);
        }

        _availableAirdrop = availableAirdrop + amount;
        _allocation[user_] = amount;

        emit AllocationSet(user_, amount, xpAlloc, lpAlloc);
    }

    /**
     * @dev Sends an amount of H1 to the user. Will revert if not successful.
     *
     * @param user_     The recipient.
     * @param amount_   The amount of H1 to send.
     */
    function _sendH1(address user_, uint256 amount_) private {
        (bool success, ) = payable(user_).call{ value: amount_ }("");
        if (!success) {
            revert AirdropClaim__FailedToSend();
        }
    }

    /**
     * @dev Asserts that a given u256 value is not zero (0).
     *
     * @param a The value to check.
     */
    function _checkNotZero(uint256 a) private pure {
        if (a == 0) {
            revert AirdropClaim__WrongData();
        }
    }
}
