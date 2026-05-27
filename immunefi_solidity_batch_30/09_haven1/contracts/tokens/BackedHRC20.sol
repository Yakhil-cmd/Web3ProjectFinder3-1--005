// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { ERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import { IBackedHRC20 } from "./interfaces/IBackedHRC20.sol";
import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { INetworkGuardian } from "../network-guardian/interfaces/INetworkGuardian.sol";
import { Address } from "../utils/Address.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { BlacklistableUpgradeable } from "../utils/upgradeable/BlacklistableUpgradeable.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title BackedHRC20
 *
 * @author The Haven1 Development Team
 *
 * @notice Tokens bridged to Haven1 are held by in storage by the Haven1
 * Association and represented 1:1 on-chain by `BackedHRC20` tokens. These
 * representative tokens can be redeemed for their underlying tokens through
 * the Haven1 Portal.
 *
 * @dev The minting of `BackedHRC20` tokens is restricted to accounts with the
 * role: `TOKEN_MANAGER`.
 *
 * This contract includes the functionality to blacklist addresses. Blacklisted
 * addresses cannot send or receive tokens, except during minting and burning
 * operations, which are privileged functions exempt from the blacklist to
 * ensure network security and correct operation of the bridge.
 */
contract BackedHRC20 is
    ERC20PermitUpgradeable,
    RecoverableUpgradeable,
    BlacklistableUpgradeable,
    NetworkGuardian,
    IBackedHRC20,
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
     * @dev The Token Manager role. Responsible for minting and burning tokens.
     */
    bytes32 public constant TOKEN_MANAGER = keccak256("TOKEN_MANAGER");

    /**
     * @dev The tokens's decimals.
     */
    uint8 private _decimals;

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
     * @param name_                 The name of the token.
     * @param symbol_               The symbol of the token.
     * @param decimals_             The token decimals.
     * @param association_          The Haven1 Association address.
     * @param bridgeController_     The Bridge Controller address.
     * @param guardianController_   The Network Guardian Controller address.
     * @param proofOfIdentity_      The Proof of Identity address.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address association_,
        address bridgeController_,
        address guardianController_,
        address proofOfIdentity_
    ) external initializer {
        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __Recoverable_init();
        __Blacklistable_init(proofOfIdentity_);
        __NetworkGuardian_init(association_, guardianController_);

        _grantRole(TOKEN_MANAGER, association_);
        _grantRole(TOKEN_MANAGER, bridgeController_);

        _decimals = decimals_;
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IBackedHRC20
     */
    function issueBackedToken(
        address to,
        uint256 amount
    ) external onlyRole(TOKEN_MANAGER) bypassBlacklist {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            _requireNotGuardianPaused();
        }
        _mint(to, amount);
        emit TokensIssued(to, amount);
    }

    /**
     * @inheritdoc IBackedHRC20
     */
    function burnFrom(
        address target,
        uint256 amount,
        string calldata reason
    ) external onlyRole(TOKEN_MANAGER) bypassBlacklist {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            _requireNotGuardianPaused();
        }

        _burn(target, amount);

        emit TokensBurnedFromAccount(target, amount, reason);
    }

    /**
     * @inheritdoc IBackedHRC20
     */
    function addToBlacklist(address addr) external onlyRole(OPERATOR_ROLE) {
        _addToBlacklist(addr);
    }

    /**
     * @inheritdoc IBackedHRC20
     */
    function removeFromBlacklist(
        address addr
    ) external onlyRole(OPERATOR_ROLE) {
        _removeFromBlacklist(addr);
    }

    /**
     * @inheritdoc IBackedHRC20
     */
    function recoverHRC20(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token, to, amount);
    }

    /**
     * @inheritdoc IBackedHRC20
     */
    function recoverAllHRC20(
        address token,
        address to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 bal = IERC20Upgradeable(token).balanceOf(address(this));
        _recoverHRC20(token, to, bal);
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

    /* Public
    ========================================*/

    /**
     * @notice Returns the token's decimals.
     */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, IBackedHRC20)
        returns (uint8)
    {
        return _decimals;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(NetworkGuardian) returns (bool) {
        return
            interfaceId == type(INetworkGuardian).interfaceId ||
            interfaceId == type(IBackedHRC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* Internal
    ========================================*/

    /**
     * @inheritdoc NetworkGuardian
     */
    function _beforeSetAssociation(address addr) internal override {
        _grantRole(TOKEN_MANAGER, addr);
        _revokeRole(TOKEN_MANAGER, association());
    }

    /**
     * @notice Overrides OpenZeppelin's `_beforeTokenTransfer` to add additional
     * safety checks.
     *
     * @param from  Address from which tokens are removed.
     * @param to    Address that receives the tokens.
     *
     * @dev Requirements:
     * -    Minting and burning call be performed by an Operator at any stage.
     * -    If the action is not a mint or a burn, the contract must not be paused.
     * -    If the blacklist is not being bypassed, neither the `from` nor `to`
     *      address can be blacklisted.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal view override {
        if (from != address(0) && to != address(0)) {
            _requireNotGuardianPaused();
        }

        if (_isBypassingBlacklist()) return;
        _assertNotBlacklisted(from);
        _assertNotBlacklisted(to);
    }
}
