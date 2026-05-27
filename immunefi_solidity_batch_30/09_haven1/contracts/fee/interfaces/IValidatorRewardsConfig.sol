// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @dev Represents the configuration of a validator for the purposes of rewards
 * distribution.
 */
struct Validator {
    // Unique ID for the validator. Must be non-zero.
    uint256 id;
    // The Validator's name.
    string name;
    // The address to which the validator's rewards will be sent.
    address addr;
}

/**
 * @title IValidatorRewardsConfig
 *
 * @author The Haven1 Development Team
 *
 * @dev The interface for the ValidatorRewardsConfig contract.
 */
interface IValidatorRewardsConfig {
    /**
     * @notice Emitted when a new validator is added.
     *
     * @param id    The ID of the validator.
     * @param name  The name of the validator.
     * @param addr  The address at which the validator will receive rewards.
     */
    event ValidatorAdded(uint256 indexed id, string name, address indexed addr);

    /**
     * @notice Emitted when a validator is removed.
     *
     * @param id    The ID of the validator.
     * @param name  The name of the validator.
     * @param addr  The address at which the validator received rewards.
     */
    event ValidatorRemoved(
        uint256 indexed id,
        string name,
        address indexed addr
    );

    /**
     * @notice Emitted when a validator's reward address was updated.
     *
     * @param id    The ID of the validator.
     * @param prev  The validator's previous reward address.
     * @param curr  The validator's new reward address.
     */
    event ValidatorAddressUpdated(
        uint256 indexed id,
        address indexed prev,
        address indexed curr
    );

    /**
     * @notice Emitted when a validator's name was updated.
     *
     * @param id    The ID of the validator.
     * @param prev  The validator's previous name.
     * @param curr  The validator's new name.
     */
    event ValidatorNameUpdated(uint256 indexed id, string prev, string curr);

    /* ERRORS
    ==================================================*/
    /**
     * @notice Raised when initializing the contract with no validators.
     */
    error ValidatorConfig__NoValidators();

    /**
     * @notice Raised when an invalid validator ID is provided.
     *
     * @param id The invalid ID.
     */
    error ValidatorConfig__InvalidID(uint256 id);

    /**
     * @notice Raised when trying to add a validator configuration to the
     * contract with an ID that already exists.
     *
     * @param id The invalid ID.
     */
    error ValidatorConfig__IDInUse(uint256 id);

    /**
     * @notice Raised when an invalid validator name is provided.
     */
    error ValidatorConfig__InvalidName();

    /**
     * @notice Raised when trying to set the reward address of a validator to an
     * address that is in use by another validator.
     *
     * @param addr      The address that is in use.
     * @param usedBy    The ID associated with the address in use.
     */
    error ValidatorConfig__AddressInUse(address addr, uint256 usedBy);

    /**
     * @notice Raised when trying to remove a validator configuration from the
     * contract that does not exist.
     *
     * @param id The invalid ID.
     */
    error ValidatorConfig__ValidatorDoesNotExist(uint256 id);

    /**
     * @notice Raised when trying to locate the index of a non-existent validator
     * in the `_validatorAddresses` array.
     *
     * @param addr The invalid address.
     */
    error ValidatorConfig__ValidatorNotFound(address addr);

    /**
     * @notice Adds a validator's configuration to the contract.
     *
     * @param v_ The validator configuration struct.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The reward address cannot be the zero address.
     * -    The ID cannot be zero.
     * -    The validator must not already exist.
     * -    The reward address cannot be in use by another validator.
     *
     * Emits a `ValidatorAdded` event.
     */
    function addValidator(Validator memory v_) external;

    /**
     * @notice Removes a validator's configuration from the contract.
     *
     * @param id_ The ID of the validator.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The provided ID must match an existing validator.
     *
     * Emits a `ValidatorRemoved` event.
     */
    function removeValidator(uint256 id_) external;

    /**
     * @notice Updates a validator's name.
     *
     * @param id_   The ID of the validator.
     * @param name_ The validator's new name.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The provided ID must match an existing validator.
     * -    The new name must not be blank.
     *
     * Emits a `ValidatorNameUpdated` event.
     */
    function updateValidatorName(uint256 id_, string calldata name_) external;

    /**
     * @notice Updates a validator's reward address.
     *
     * @param id_   The ID of the validator.
     * @param addr_  The new reward address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The provided ID must match an existing validator.
     * -    The new reward address must not be in use by another validator.
     *
     * Emits a `ValidatorAddressUpdated` event.
     */
    function updateValidatorAddress(uint256 id_, address addr_) external;

    /**
     * @notice Returns the validator configuation struct associated with a
     * given validator ID.
     *
     * @param id_ The validator ID.
     *
     * @return The validator configuation struct associated with a given
     * validator ID.
     */
    function validatorConfig(
        uint256 id_
    ) external view returns (Validator memory);

    /**
     * @notice Returns the reward address associated with a given validator ID.
     *
     * @param id_ The validator ID.
     *
     * @return The reward address associated with a given validator ID.
     */
    function addressOf(uint256 id_) external view returns (address);

    /**
     * @notice Returns the name associated with a given validator ID.
     *
     * @param id_ The validator ID.
     *
     * @return The name associated with a given validator ID.
     */
    function nameOf(uint256 id_) external view returns (string memory);

    /**
     * @notice Returns the validator ID associated with a given reward address.
     *
     * @param addr_ The reward address of the validator.
     *
     * @return The validator ID associated with a given reward address.
     */
    function idOf(address addr_) external view returns (uint256);

    /**
     * @notice Returns an array of active validator reward addresses.
     *
     * @return An array of active validator reward addresses.
     */
    function validatorAddresses() external view returns (address[] memory);

    /**
     * @notice Returns the number of active validators currently receiving rewards.
     *
     * @return The number of active validators currently receiving rewards.
     */
    function numberOf() external view returns (uint256);
}
