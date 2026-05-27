// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { Address } from "../utils/Address.sol";

import { IWH1 } from "../tokens/interfaces/IWH1.sol";
import { IBridgeController } from "./interfaces/IBridgeController.sol";
import { ILockedH1 } from "./interfaces/ILockedH1.sol";

import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title LockedH1
 *
 * @author The Haven1 Development Team
 *
 * @notice A contract for managing the locking and unlocking of H1 tokens on the
 * Haven1 network. This contract is part of the Haven1 network's suite of
 * bridging contracts.
 *
 * @dev This contract is the central mechanism for ensuring the synchronization
 * of H1 token supplies between the Haven1 network and the Ethereum mainnet. It
 * locks H1 tokens deposited on the Ethereum mainnet and allows corresponding
 * native H1 tokens to be unlocked and distributed on the Haven1 network. It
 * also facilitates bridging operations and handles fees associated with these
 * processes.
 *
 * ## Key Responsibilities
 *
 * -    Locking the total supply of H1 tokens in the contract during initialization.
 * -    Unlocking H1 tokens upon bridging from the Ethereum mainnet.
 * -    Locking H1 tokens upon bridging out to the Ethereum mainnet.
 * -    Distributing fees to the Haven1 Association for bridge operations.
 * -    Ensuring the contract's state remains consistent with the ERC20 H1 token
 *      supply on the Ethereum mainnet.
 *
 * ## Deploying and Configuration
 *
 * The contract must be initialized with the following:
 * -    Total supply of H1 tokens available on the Haven1 network. This number
 *      must match the total supply of H1 tokens minted on Ethereum Mainnet.
 *
 * -    Addresses for the Bridge Controller, WH1 token contract, Haven1
 *      Association, and Network Guardian Controller.
 *
 * After initialization, the total supply of H1 tokens must be deposited via
 * `lockH1()` to enable the contract's functionality.
 *
 * ## Permissions and Roles
 *
 * -    `DEFAULT_ADMIN_ROLE`: Reserved for administrative actions, including
 *      updating contract dependencies.
 *
 * -    `BRIDGE_ROLE`: Permits the finalization of deposits and withdrawals on
 *      the contract.
 *
 * ## Important Notes
 *
 * -    All H1 tokens on the Haven1 network originate from this contract.
 *
 * -    The balance of H1 in this contract reflects the amount tokens available
 *      for unlocking.
 *
 * -    H1 is unlocked by bridging in H1 from the Ethereum mainnet.
 *
 * -    The contract utilizes WH1 (Wrapped H1) tokens for wrapping and
 *      unwrapping native H1 during certain operations.
 *
 * -    The Haven1 Association will receive Wrapped H1 for the fee of the bridge.
 *
 * -    The user will receive native H1 when depositing.
 */
contract LockedH1 is
    NetworkGuardian,
    RecoverableUpgradeable,
    ILockedH1,
    IVersion
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;

    /* STATE
    ==================================================*/
    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The minimum required WH1 version, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant MIN_WH1_VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The minimum required Bridge version, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant MIN_BRIDGE_VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @notice Permissioned to finalize deposits and withdrawals on this
     * contract.
     */
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

    /**
     * @notice The WH1 contract.
     */
    IWH1 public wh1;

    /**
     * @notice The Bridge Controller contract.
     */
    IBridgeController public bridgeController;

    /**
     * @notice The total amount of H1 that is available on the Haven1 network.
     */
    uint256 private _totalSupply;

    /**
     * @notice Indicates whether the contract is ready for operation.
     */
    bool private _ready;

    /**
     * @notice The amount of H1 that is currently unlocked.
     */
    uint256 private _h1Unlocked;

    /* MODIFIERS
    ==================================================*/

    modifier whenReady() {
        if (!_ready) revert LockedH1__NotReady();
        _;
    }

    /* FUNCTIONS
    ==================================================*/
    /* Init
    ========================================*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     *
     * @param totalSupply_          The total amount of H1 that will be available on the Haven1 network.
     * @param bridgeController_     The Bridge Controller address.
     * @param wh1_                  The WH1 address.
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     *
     * @dev The amount of locked H1 _must_ be the same as the total supply of
     * ERC20 H1 on Ethereum Mainnet.
     *
     * Send in the H1 after initializing via lockH1().
     */
    function initialize(
        uint256 totalSupply_,
        address bridgeController_,
        address wh1_,
        address association_,
        address guardianController_
    ) external initializer {
        if (totalSupply_ == 0) {
            revert LockedH1__InvalidAmount(totalSupply_, 1);
        }

        wh1_.assertNotZero();
        bridgeController_.assertNotZero();

        uint64 wh1Ver = IVersion(wh1_).version();
        if (!Semver.hasCompatibleMajorVersion(wh1Ver, MIN_WH1_VERSION)) {
            revert LockedH1__InvalidAddress(wh1_);
        }

        uint64 bridgeVer = IVersion(bridgeController_).version();
        if (!Semver.hasCompatibleMajorVersion(bridgeVer, MIN_BRIDGE_VERSION)) {
            revert LockedH1__InvalidAddress(bridgeController_);
        }

        __NetworkGuardian_init(association_, guardianController_);
        __Recoverable_init();

        _grantRole(BRIDGE_ROLE, bridgeController_);

        _totalSupply = totalSupply_;
        wh1 = IWH1(wh1_);
        bridgeController = IBridgeController(bridgeController_);
        _ready = false;
    }

    /* Receive and Fallback
    ========================================*/

    receive() external payable {
        if (msg.sender != address(wh1)) {
            revert LockedH1__Revert();
        }
    }

    fallback() external payable {
        revert LockedH1__Revert();
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc ILockedH1
     */
    function lockH1() external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_ready) {
            revert LockedH1__AlreadyReady();
        }

        if (msg.value != _totalSupply) {
            revert LockedH1__InvalidAmount(msg.value, _totalSupply);
        }

        _ready = true;

        emit LockedH1(msg.value);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function setBridgeController(
        address bridgeController_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bridgeController_.assertNotZero();

        uint64 v = IVersion(bridgeController_).version();
        if (!Semver.hasCompatibleMajorVersion(v, MIN_BRIDGE_VERSION)) {
            revert LockedH1__InvalidAddress(bridgeController_);
        }

        address prev = address(bridgeController);

        _revokeRole(BRIDGE_ROLE, prev);
        _grantRole(BRIDGE_ROLE, bridgeController_);

        bridgeController = IBridgeController(bridgeController_);

        emit BridgeControllerUpdated(prev, bridgeController_);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function setWH1(address wh1_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        wh1_.assertNotZero();

        uint64 v = IVersion(wh1_).version();
        if (!Semver.hasCompatibleMajorVersion(v, MIN_WH1_VERSION)) {
            revert LockedH1__InvalidAddress(wh1_);
        }

        address prev = address(wh1);
        wh1 = IWH1(wh1_);

        emit WH1Updated(prev, wh1_);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function finishDeposit(
        address to_,
        uint256 amount_,
        uint256 fee_
    ) external onlyRole(BRIDGE_ROLE) whenReady {
        // The amount of H1 being deposited can never exceed the balance of this
        // contract. The amount of H1 must always be in sync with the ERC20 H1
        // token on Ethereum Mainnet.
        uint256 total = amount_ + fee_;
        uint256 bal = address(this).balance;
        if (total > bal) {
            revert LockedH1__InsufficientBalance(total, bal);
        }

        _unlockH1(to_, amount_, false);
        _unlockH1(association(), fee_, true);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function finishWithdrawal(
        uint256 amount_
    ) external onlyRole(BRIDGE_ROLE) whenReady {
        // The amount of H1 being withdrawn can never exceed the amount of H1
        // that has been unlocked on the network. H1 needs to have been deposited
        // via `finishDeposit` before it can be withdrawn.
        if (_h1Unlocked < amount_) {
            revert LockedH1__InsufficientSupply(amount_, _h1Unlocked);
        }

        _h1Unlocked -= amount_;

        // Collect WH1 from Bridge to lock
        wh1.transferFrom(msg.sender, address(this), amount_);
        wh1.withdraw(amount_);
        // Unwrap WH1 so native H1 is locked and the WH1 totalSupply is correct + Recover is possible.
        emit Lock(amount_);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // This is possible because WH1 is never intentionally stored in the contract
        _recoverHRC20(token_, to_, amount_);
    }

    /**
     * @inheritdoc ILockedH1
     */
    function isReady() external view returns (bool) {
        return _ready;
    }

    /**
     * @inheritdoc ILockedH1
     */
    function unlockedH1() external view returns (uint256) {
        return _h1Unlocked;
    }

    /**
     * @inheritdoc ILockedH1
     */
    function lockedH1() external view returns (uint256) {
        return _totalSupply - _h1Unlocked;
    }

    /**
     * @inheritdoc ILockedH1
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
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
     * @notice Handles unlocking H1.
     *
     * @param to_       The address to which the unlocked tokens will be sent.
     * @param amount_   The amount of tokens to unlock and send.
     * @param wrapped_  Whether the transfer should use WH1 (true) or H1 (false).
     */
    function _unlockH1(address to_, uint256 amount_, bool wrapped_) private {
        _h1Unlocked += amount_;

        if (wrapped_) {
            wh1.deposit{ value: amount_ }();
            wh1.transfer(to_, amount_);
        } else {
            (bool success, ) = to_.call{ value: amount_ }("");
            if (!success) revert LockedH1__FailedToSend(to_, amount_);
        }

        emit Unlock(to_, amount_);
    }
}
