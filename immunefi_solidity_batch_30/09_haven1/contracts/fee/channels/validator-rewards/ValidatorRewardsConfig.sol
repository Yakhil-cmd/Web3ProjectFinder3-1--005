// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { IValidatorRewardsConfig, Validator } from "../../interfaces/IValidatorRewardsConfig.sol";
import { NetworkGuardian } from "../../../network-guardian/NetworkGuardian.sol";
import { Address } from "../../../utils/Address.sol";
import { IVersion } from "../../../utils/interfaces/IVersion.sol";
import { Semver } from "../../../utils/Semver.sol";

/**
 * @title ValidatorConfig
 *
 * @author The Haven1 Development Team
 *
 * @dev This contract manages the configuration and maintenance of validators
 * for the purpose of reward distribution within the Haven1 network.
 *
 * It provides functionality for adding, removing, and updating validator
 * configurations, as well as various queries. The contract ensures that only
 * valid and unique validator configurations are maintained, and includes various
 * safeguards to prevent invalid operations.
 */
contract ValidatorRewardsConfig is
    NetworkGuardian,
    IValidatorRewardsConfig,
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
     * @dev The list of active validator reward addresses. All addresses in this
     * array are eligible for rewards.
     */
    address[] private _validatorAddresses;

    /**
     * @dev Mapping from validator ID to validator configuration.
     */
    mapping(uint256 => Validator) private _validators;

    /**
     * @dev Mapping from validator reward address to ID for reverse lookup.
     */
    mapping(address => uint256) private _addressToID;

    /* FUNCTIONS
    ==================================================*/

    /* Init
    ========================================*/
    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     *
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     * @param validators_           Array of validator configurations.
     */
    function initialize(
        address association_,
        address guardianController_,
        Validator[] memory validators_
    ) external initializer {
        __NetworkGuardian_init(association_, guardianController_);

        uint256 l = validators_.length;

        for (uint256 i; i < l; ++i) {
            _addValidator(validators_[i]);
        }
    }

    /* External
    ========================================*/
    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function addValidator(
        Validator memory v_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addValidator(v_);
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function removeValidator(
        uint256 id_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _assertValidatorExists(id_);

        Validator memory validator = _validators[id_];

        uint256 idx = _indexOfExn(validator.addr);
        uint256 l = _validatorAddresses.length;

        _validatorAddresses[idx] = _validatorAddresses[l - 1];
        _validatorAddresses.pop();

        delete _validators[id_];
        _addressToID[validator.addr] = 0;

        emit ValidatorRemoved(id_, validator.name, validator.addr);
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function updateValidatorName(
        uint256 id_,
        string calldata name_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _assertValidatorExists(id_);
        _assertValidName(name_);

        Validator storage validator = _validators[id_];
        string memory prev = validator.name;

        validator.name = name_;

        emit ValidatorNameUpdated(id_, prev, name_);
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function updateValidatorAddress(
        uint256 id_,
        address addr_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _assertValidatorExists(id_);
        _assertUniqueAddr(addr_);

        addr_.assertNotZero();

        Validator storage validator = _validators[id_];
        address prev = validator.addr;
        uint256 idx = _indexOfExn(prev);

        _addressToID[prev] = 0;
        _addressToID[addr_] = id_;

        _validatorAddresses[idx] = addr_;

        validator.addr = addr_;

        emit ValidatorAddressUpdated(id_, prev, addr_);
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function validatorConfig(
        uint256 id_
    ) external view returns (Validator memory) {
        return _validators[id_];
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function addressOf(uint256 id_) external view returns (address) {
        return _validators[id_].addr;
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function nameOf(uint256 id_) external view returns (string memory) {
        return _validators[id_].name;
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function idOf(address addr_) external view returns (uint256) {
        return _addressToID[addr_];
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function validatorAddresses() external view returns (address[] memory) {
        return _validatorAddresses;
    }

    /**
     * @inheritdoc IValidatorRewardsConfig
     */
    function numberOf() external view returns (uint256) {
        return _validatorAddresses.length;
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
     * @notice Adds a validator's configuration to the contract.
     *
     * @param v_ The validator configuration struct.
     *
     * @dev Requirements:
     * -    The reward address cannot be the zero address.
     * -    The ID cannot be zero.
     * -    The validator must not already exist.
     * -    The reward address cannot be in use by another validator.
     *
     * Emits a `ValidatorAdded` event.
     */
    function _addValidator(Validator memory v_) private {
        _assertIDNotZero(v_.id);
        _assertUniqueID(v_.id);
        _assertValidName(v_.name);
        _assertUniqueAddr(v_.addr);
        v_.addr.assertNotZero();

        _validators[v_.id] = v_;
        _validatorAddresses.push(v_.addr);
        _addressToID[v_.addr] = v_.id;

        emit ValidatorAdded(v_.id, v_.name, v_.addr);
    }

    /**
     * @notice Returns the index of a validator in the `_validatorAddresses`
     * array.
     *
     * @param addr_ The validator address to find.
     *
     * @return The index of the validator in the `_validatorAddresses` array.
     *
     * @dev Will revert if the ID is not found.
     */
    function _indexOfExn(address addr_) private view returns (uint256) {
        uint256 l = _validatorAddresses.length;

        for (uint256 i; i < l; ++i) {
            if (_validatorAddresses[i] == addr_) {
                return i;
            }
        }

        revert ValidatorConfig__ValidatorNotFound(addr_);
    }

    /**
     * @notice Asserts that a given validator ID exists.
     *
     * @param id_ The validator ID.
     */
    function _assertValidatorExists(uint256 id_) private view {
        if (_validators[id_].addr == address(0)) {
            revert ValidatorConfig__ValidatorDoesNotExist(id_);
        }
    }

    /**
     * @notice Asserts that a given ID is not in use by another validator.
     *
     * @param id_ The validator ID.
     */
    function _assertUniqueID(uint256 id_) private view {
        if (_validators[id_].addr != address(0)) {
            revert ValidatorConfig__IDInUse(id_);
        }
    }

    /**
     * @notice Asserts that a given reward address is not in use by another
     * validator.
     *
     * @param addr_ The reward address.
     */
    function _assertUniqueAddr(address addr_) private view {
        uint256 id = _addressToID[addr_];
        if (id != 0) {
            revert ValidatorConfig__AddressInUse(addr_, id);
        }
    }

    /**
     * @notice Asserts that a given validator ID is not zero (`0`).
     *
     * @param id_ The validator ID.
     */
    function _assertIDNotZero(uint256 id_) private pure {
        if (id_ == 0) {
            revert ValidatorConfig__InvalidID(id_);
        }
    }

    /**
     * @notice Asserts that a given name is not of length zero (`0`).
     *
     * @param name_ The validator name to check.
     */
    function _assertValidName(string memory name_) private pure {
        if (bytes(name_).length == 0) {
            revert ValidatorConfig__InvalidName();
        }
    }
}
