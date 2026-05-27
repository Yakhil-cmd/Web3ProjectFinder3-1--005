// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { ERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import { IHRC20 } from "./interfaces/IHRC20.sol";
import { IProofOfIdentity } from "../proof-of-identity/interfaces/IProofOfIdentity.sol";

import { Address } from "../utils/Address.sol";
import { RecoverableUpgradeable } from "../utils/upgradeable/RecoverableUpgradeable.sol";
import { H1DevelopedApplication } from "../h1-developed-application/H1DevelopedApplication.sol";

/**
 * @title HRC20
 *
 * @author The Haven1 Development Team
 *
 * @notice An abstract contract that forms the base of all natively issued
 * tokens on Haven1.
 *
 * @dev Implements `ERC20` and `ERC20Permit`. May be extended with extra
 * functionality from the ERC20 standard as required.
 *
 * Implements `H1DevelopedApplication` on behalf of the developer.
 *
 * Note that any external or public functions that modify state must attach the
 * `whenNotGuardianPaused` and `developerFee` modifiers. For further details,
 * see the `H1DevelopedApplication` documentation.
 */
abstract contract HRC20 is
    ERC20PermitUpgradeable,
    RecoverableUpgradeable,
    H1DevelopedApplication,
    IHRC20
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;

    struct TokenConfig {
        string name;
        string symbol;
        uint8 decimals;
        address proofOfIdentity;
    }

    struct H1DevConfig {
        address feeContract;
        address guardianController;
        address association;
        address developer;
        address devFeeCollector;
        string[] fnSigs;
        uint256[] fnFees;
        bool storesH1;
    }

    /* STATE
    ==================================================*/
    /**
     * @dev The tokens's decimals.
     */
    uint8 private _decimals;

    /**
     * @dev Maps an address to its blacklist status.
     */
    mapping(address => bool) private _blacklist;

    /**
     * @dev The Proof of Identity contract address.
     */
    IProofOfIdentity private _poi;

    /* MODIFIERS
    ==================================================*/

    /**
     * @param addr the address to check.
     *
     * @dev Modifier that checks a given address is not blacklisted.
     */
    modifier whenNotBlacklisted(address addr) {
        _assertNotBlacklisted(addr);
        _;
    }

    /*
     * @param from  Address from which tokens are setn.
     * @param to    Address that receives the tokens.
     *
     * @dev Requirements:
     * -    The contract must not be paused for any operation to succeed.
     * -    Neither the `from` nor the `to` address can be blacklisted.
     */
    modifier beforeTransfer(address from, address to) {
        _requireNotGuardianPaused();
        _assertNotBlacklisted(from);
        _assertNotBlacklisted(to);
        _;
    }

    /* FUNCTIONS
    ==================================================*/
    /* Init
    ========================================*/

    /*
     * @notice Initializes the contract.
     *
     * @param tokenCfg The token configuration struct.
     * @param h1DevCfg The H1 Developed Application configuration struct.
     */
    function __HRC20_init(
        TokenConfig memory tokenCfg,
        H1DevConfig memory h1DevCfg
    ) internal onlyInitializing {
        __ERC20_init(tokenCfg.name, tokenCfg.symbol);
        __ERC20Permit_init(tokenCfg.name);

        __Recoverable_init();
        __H1DevelopedApplication_init(
            h1DevCfg.feeContract,
            h1DevCfg.guardianController,
            h1DevCfg.association,
            h1DevCfg.developer,
            h1DevCfg.devFeeCollector,
            h1DevCfg.fnSigs,
            h1DevCfg.fnFees,
            h1DevCfg.storesH1
        );

        __HRC20_init_unchained(tokenCfg.decimals, tokenCfg.proofOfIdentity);
    }

    /*
     * @notice Initializes the contract.
     *
     * @param decimals_         The token decimals.
     * @param proofOfIdentity_  The Proof of Identity address.
     */
    function __HRC20_init_unchained(
        uint8 decimals_,
        address proofOfIdentity_
    ) internal onlyInitializing {
        proofOfIdentity_.assertNotZero();
        _poi = IProofOfIdentity(proofOfIdentity_);
        _decimals = decimals_;
    }

    /**
     * @inheritdoc IHRC20
     */
    function addToBlacklist(address addr) external onlyRole(OPERATOR_ROLE) {
        addr.assertNotZero();

        // We are blacklisting the principal account, so any auxilliary accounts
        // will be blacklisted as well.
        address principal = _poi.principalAccount(addr);
        if (principal == address(0)) {
            // principal could be zero if the user has no POI
            if (!_blacklist[addr]) {
                _blacklist[addr] = true;
                emit Blacklisted(addr);
            }
            return;
        }

        if (!_blacklist[principal]) {
            _blacklist[principal] = true;
            emit Blacklisted(principal);
        }
    }

    /**
     * @inheritdoc IHRC20
     */
    function removeFromBlacklist(
        address addr
    ) external onlyRole(OPERATOR_ROLE) {
        addr.assertNotZero();

        // Removing the principal account, so any auxilliary accounts will be
        // unlocked as well.
        address principal = _poi.principalAccount(addr);

        // Remove the provided address from the blacklist.
        // This is for the edge case that a user got banned while not having a POI.
        if (_blacklist[addr]) {
            _blacklist[addr] = false;
            emit BlacklistRemoved(addr);
        }

        if (principal != address(0) && _blacklist[principal]) {
            _blacklist[principal] = false;
            emit BlacklistRemoved(principal);
        }
    }

    /**
     * @inheritdoc IHRC20
     */
    function recoverHRC20(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token, to, amount);
    }

    /**
     * @inheritdoc IHRC20
     */
    function recoverAllHRC20(
        address token,
        address to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 bal = IERC20Upgradeable(token).balanceOf(address(this));
        _recoverHRC20(token, to, bal);
    }

    /**
     * @inheritdoc IHRC20
     */
    function setPOI(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        address prev = address(_poi);
        _poi = IProofOfIdentity(addr);

        emit POIUpdated(prev, addr);
    }

    /**
     * @inheritdoc IHRC20
     */
    function blacklisted(address addr) external view returns (bool) {
        return _isBlacklisted(addr);
    }

    /**
     * @inheritdoc IHRC20
     */
    function poi() external view returns (address) {
        return address(_poi);
    }

    /* Public
    ========================================*/

    /**
     * @inheritdoc IHRC20
     */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, IHRC20)
        returns (uint8)
    {
        return _decimals;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IHRC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* Internal
    ========================================*/

    /**
     * @notice Overrides OpenZeppelin's `_beforeTokenTransfer` to add additional
     * safety checks.
     *
     * @param from  Address from which tokens are setn.
     * @param to    Address that receives the tokens.
     *
     * @dev Requirements:
     * -    The contract must not be paused for any operation to succeed..
     * -    Neither the from nor the to address can be blacklisted.
     *
     * If this function is further overridden by the inheriting contract, it too
     * must attach the `beforeTransfer` modifier.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal view override beforeTransfer(from, to) {}

    /**
     * @notice Returns whether a given address is blacklisted.
     *
     * @param addr The address to check.
     *
     * @return True if the address has been blacklisted, false otherwise.
     */
    function _isBlacklisted(address addr) internal view returns (bool) {
        if (addr == address(0)) {
            return false;
        }

        address principal = _poi.principalAccount(addr);
        if (principal == address(0)) {
            return _blacklist[addr];
        }

        return _blacklist[principal];
    }

    /**
     * @notice Asserts that the given address is not on the blacklist.
     *
     * @dev Will revert if the address is on the blacklist.
     */
    function _assertNotBlacklisted(address addr) internal view {
        if (_isBlacklisted(addr)) {
            revert HRC20__IsBlacklisted(addr);
        }
    }

    /**
     * @dev This empty reserved space allows new state variables to be added
     * without compromising the storage compatibility with existing deployments.
     *
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     *
     * As new variables are added, be sure to reduce the gap as required.
     * For e.g., if the starting `__gap` is `50` and a new variable is added
     * (256 bits in size or part thereof), the gap must now be reduced to `49`.
     */
    uint256[50] private __gap;
}
