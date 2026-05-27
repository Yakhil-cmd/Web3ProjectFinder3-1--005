// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import { IWH1 } from "./interfaces/IWH1.sol";
import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { INetworkGuardian } from "../network-guardian/interfaces/INetworkGuardian.sol";
import { Address } from "../utils/Address.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { BlacklistableUpgradeable } from "../utils/upgradeable/BlacklistableUpgradeable.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title WH1
 *
 * @author The Haven1 Development Team
 *
 * @notice Adaptation of the WETH9 contract. Fully compatible with the original
 * WETH9 interface.
 */
contract WH1 is
    RecoverableUpgradeable,
    NetworkGuardian,
    ReentrancyGuardUpgradeable,
    BlacklistableUpgradeable,
    IWH1,
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
     * @dev The token's name.
     */
    string private constant _NAME = "Wrapped H1";

    /**
     * @dev The token's symbol.
     */
    string private constant _SYMBOL = "wH1";

    /**
     * @dev The token's decimals.
     */
    uint8 private constant _DECIMALS = 18;

    /**
     * @dev Maps an address to their wH1 balance.
     */
    mapping(address => uint256) private _balanceOf;

    /**
     * @dev Maps an owner address to a spender address to the spender's
     * allowance (owner => spender => allowance).
     */
    mapping(address => mapping(address => uint256)) private _allowance;

    /* ERRORS
    ==================================================*/
    /**
     * @dev Raised if a withdrawal fails.
     */
    error WH1__WithdrawFailed();

    /**
     * @dev Raised if there is insufficient WH1 balance to complete the
     * operation.
     *
     * @param supplied  The amount supplied.
     * @param balance   The balance available.
     */
    error WH1__InsufficientWH1Balance(uint256 supplied, uint256 balance);

    /**
     * @dev Raised if the spender has an insufficient allowance over the owner's
     * wH1.
     *
     * @param owner     The owner's address.
     * @param spender   The spender's address.
     * @param allowance The allowance.
     */
    error WH1__InsufficientAllowance(
        address owner,
        address spender,
        uint256 allowance
    );

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

    /* Init
    ========================================*/
    /**
     * @notice Initializes the contract.
     *
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     * @param proofOfIdentity_      The Proof of Identity address.
     */
    function initialize(
        address association_,
        address guardianController_,
        address proofOfIdentity_
    ) external initializer {
        __Recoverable_init();
        __Blacklistable_init(proofOfIdentity_);
        __ReentrancyGuard_init();
        __NetworkGuardian_init(association_, guardianController_);
    }

    /* Receive and Fallback
    ========================================*/
    receive() external payable whenNotGuardianPaused {
        deposit();
    }

    fallback() external payable whenNotGuardianPaused {
        deposit();
    }

    /* External
    ========================================*/
    /**
     * @inheritdoc IWH1
     */
    function withdraw(uint256 wad) external whenNotGuardianPaused nonReentrant {
        _assertNotBlacklisted(tx.origin);

        uint256 bal = _balanceOf[msg.sender];
        if (bal < wad) {
            revert WH1__InsufficientWH1Balance(wad, bal);
        }

        _balanceOf[msg.sender] -= wad;

        (bool success, ) = msg.sender.call{ value: wad }("");
        if (!success) {
            revert WH1__WithdrawFailed();
        }

        emit Withdrawal(msg.sender, wad);
    }

    /**
     * @inheritdoc IWH1
     */
    function approve(
        address guy,
        uint256 wad
    ) external whenNotGuardianPaused returns (bool) {
        _assertNotBlacklisted(tx.origin);
        _assertNotBlacklisted(guy);

        return _approve(msg.sender, guy, wad);
    }

    /**
     * @inheritdoc IWH1
     */
    function increaseAllowance(
        address guy,
        uint256 amt
    ) external whenNotGuardianPaused returns (bool) {
        _assertNotBlacklisted(tx.origin);
        _assertNotBlacklisted(guy);

        return _approve(msg.sender, guy, _allowance[msg.sender][guy] + amt);
    }

    /**
     * @inheritdoc IWH1
     */
    function decreaseAllowance(
        address guy,
        uint256 amt
    ) external whenNotGuardianPaused returns (bool) {
        _assertNotBlacklisted(tx.origin);
        _assertNotBlacklisted(guy);

        uint256 currentAllowance = _allowance[msg.sender][guy];
        if (amt > currentAllowance) {
            revert WH1__InsufficientAllowance(msg.sender, guy, amt);
        }

        return _approve(msg.sender, guy, currentAllowance - amt);
    }

    /**
     * @inheritdoc IWH1
     */
    function transfer(
        address dst,
        uint256 wad
    ) external whenNotGuardianPaused returns (bool) {
        return _transferFrom(msg.sender, dst, wad);
    }

    /**
     * @inheritdoc IWH1
     */
    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external whenNotGuardianPaused returns (bool) {
        return _transferFrom(src, dst, wad);
    }

    /**
     * @inheritdoc IWH1
     */
    function transferFromAdmin(
        address src,
        address dst,
        uint256 wad
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        uint256 bal = _balanceOf[src];
        if (bal < wad) {
            revert WH1__InsufficientWH1Balance(wad, bal);
        }

        _balanceOf[src] -= wad;
        _balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    /**
     * @inheritdoc IWH1
     */
    function recoverHRC20(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token, to, amount);
    }

    /**
     * @inheritdoc IWH1
     */
    function recoverAllHRC20(
        address token,
        address to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 bal = IERC20Upgradeable(token).balanceOf(address(this));
        _recoverHRC20(token, to, bal);
    }

    /**
     * @inheritdoc IWH1
     */
    function addToBlacklist(address addr) external onlyRole(OPERATOR_ROLE) {
        _addToBlacklist(addr);
    }

    /**
     * @inheritdoc IWH1
     */
    function removeFromBlacklist(
        address addr
    ) external onlyRole(OPERATOR_ROLE) {
        _removeFromBlacklist(addr);
    }

    /**
     * @inheritdoc IWH1
     */
    function balanceOf(address guy) external view returns (uint256) {
        return _balanceOf[guy];
    }

    /**
     * @inheritdoc IWH1
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowance[owner][spender];
    }

    /**
     * @inheritdoc IWH1
     */
    function totalSupply() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @inheritdoc IWH1
     */
    function name() external pure returns (string memory) {
        return _NAME;
    }

    /**
     * @inheritdoc IWH1
     */
    function symbol() external pure returns (string memory) {
        return _SYMBOL;
    }

    /**
     * @inheritdoc IWH1
     */
    function decimals() external pure returns (uint8) {
        return _DECIMALS;
    }

    /* Public
    ========================================*/
    /**
     * @inheritdoc IWH1
     */
    function deposit() public payable whenNotGuardianPaused {
        _assertNotBlacklisted(tx.origin);

        _balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @inheritdoc IWH1
     */
    function hasMaxAllowance(
        address owner,
        address spender
    ) public view returns (bool) {
        return _allowance[owner][spender] == type(uint256).max;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(NetworkGuardian) returns (bool) {
        return
            interfaceId == type(IWH1).interfaceId ||
            super.supportsInterface(interfaceId);
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
     * @dev Transfers an amount of tokens from the source address to the
     * destination address.
     *
     * @param src The source address.
     * @param dst The destination address.
     * @param wad The amount to transfer.
     *
     * @return Will always return `true` if the call does not revert.
     *
     * @dev Requirements:
     * -    The caller must not be blacklisted.
     * -    The source address must not be blacklisted.
     * -    The destination address must not be blacklisted.
     * -    The transfer amount must not exceed the caller's balance.
     * -    If the source address is not the caller, then the caller's allowance
     *      over the source address' tokens must not exceed the transfer amount.
     *
     * Emits an `Transfer` event.
     */
    function _transferFrom(
        address src,
        address dst,
        uint256 wad
    ) private returns (bool) {
        _assertNotBlacklisted(tx.origin);
        _assertNotBlacklisted(src);
        _assertNotBlacklisted(dst);

        uint256 bal = _balanceOf[src];
        if (bal < wad) {
            revert WH1__InsufficientWH1Balance(wad, bal);
        }

        if (src != msg.sender && !hasMaxAllowance(src, msg.sender)) {
            uint256 allow = _allowance[src][msg.sender];

            if (allow < wad) {
                revert WH1__InsufficientAllowance(src, msg.sender, allow);
            }

            _allowance[src][msg.sender] -= wad;
        }

        _balanceOf[src] -= wad;
        _balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    /**
     * @dev Sets `wad` as the allowance of `guy` over the `owners`'s tokens.
     *
     * @param owner The owner of the tokens.
     * @param guy   The address to which the allowance is granted.
     * @param wad   The allowance to grant.
     *
     * @return Returns true.
     *
     * Emits an `Approval` event.
     */
    function _approve(
        address owner,
        address guy,
        uint256 wad
    ) private returns (bool) {
        _allowance[owner][guy] = wad;
        emit Approval(owner, guy, wad);
        return true;
    }
}
