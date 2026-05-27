// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { IEscrowedH1 } from "../../../tokens/interfaces/IEscrowedH1.sol";
import { ValidatorRewardsBase } from "./ValidatorRewardsBase.sol";
import { Address } from "../../../utils/Address.sol";
import { IVersion } from "../../../utils/interfaces/IVersion.sol";
import { Semver } from "../../../utils/Semver.sol";

/**
 * @title ValidatorRewardsESH1
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract facilitates the distribution of fees, paid in esH1, to
 * the network validators.
 *
 * Validators will receive an equal share in the accrued rewards.
 */
contract ValidatorRewardsESH1 is ValidatorRewardsBase, IVersion {
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
     * @dev The Escrowed H1 contract address.
     */
    address private _esH1;

    /* EVENTS
    ==================================================*/

    /**
     * @notice Emitted when the esH1 contract address is updated.
     *
     * @param prev The previous esH1 address.
     * @param curr The current esH1 address.
     */
    event ESH1AddressSet(address indexed prev, address indexed curr);

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
     * @param validatorConfig_      The Validator Config address.
     * @param distFreqSec_          The minimum time between distributions.
     * @param esH1_                 The Escrowed H1 contract address.
     */
    function initialize(
        address association_,
        address guardianController_,
        address validatorConfig_,
        uint256 distFreqSec_,
        address esH1_
    ) external initializer {
        esH1_.assertNotZero();

        __ValidatorRewards_init(
            association_,
            guardianController_,
            validatorConfig_,
            distFreqSec_
        );

        _esH1 = esH1_;
    }

    /* External
    ========================================*/

    /**
     * @notice Sets the Escrowed H1 contract address.
     *
     * @param esH1_ The updated Escrowed H1 contract address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address cannot be the zero address.
     *
     * Emits an `ESH1AddressSet` event.
     */
    function setESH1Address(
        address esH1_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        esH1_.assertNotZero();
        address prev = _esH1;
        _esH1 = esH1_;

        emit ESH1AddressSet(prev, esH1_);
    }

    /**
     * @notice Returns the Escrowed H1 contract address.
     */
    function esH1Address() external view returns (address) {
        return _esH1;
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
     * @notice Equally distributes esH1 rewards among the validators.
     *
     * @return True if the distribution was successful, false otherwise.
     */
    function _distribute() internal override returns (bool) {
        uint256 amount = calculateShare();
        if (amount == 0) {
            return true;
        }

        address[] memory addrs = _validatorConfig.validatorAddresses();
        uint256 l = addrs.length;

        for (uint256 i; i < l; ++i) {
            address v = addrs[i];

            IEscrowedH1(_esH1).mintEscrowedH1{ value: amount }(v);

            emit RewardsDistributed(v, _esH1, amount);
        }

        return true;
    }
}
