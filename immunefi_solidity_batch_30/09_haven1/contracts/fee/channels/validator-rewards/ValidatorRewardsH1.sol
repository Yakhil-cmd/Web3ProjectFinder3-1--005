// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { ValidatorRewardsBase } from "./ValidatorRewardsBase.sol";
import { IVersion } from "../../../utils/interfaces/IVersion.sol";
import { Semver } from "../../../utils/Semver.sol";

/**
 * @title ValidatorRewardsH1
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract facilitates the distribution of fees, paid in H1, to
 * the network validators.
 *
 * Validators will receive an equal share in the accrued rewards.
 */
contract ValidatorRewardsH1 is ValidatorRewardsBase, IVersion {
    /* STATE
    ==================================================*/

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @dev The null address used to represent native H1.
     */
    address private constant _H1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

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
     */
    function initialize(
        address association_,
        address guardianController_,
        address validatorConfig_,
        uint256 distFreqSec_
    ) external initializer {
        __ValidatorRewards_init(
            association_,
            guardianController_,
            validatorConfig_,
            distFreqSec_
        );
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
     * @notice Equally distributes native H1 rewards among the validators.
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

            bool success = _sendValue(payable(v), amount);
            if (!success) {
                return false;
            }

            emit RewardsDistributed(v, _H1, amount);
        }

        return true;
    }

    /* Private
    ========================================*/

    /**
     * @notice Sends an amount of H1.
     *
     * @param to        The recipient of the H1.
     * @param amount    The amount of H1 to send.
     *
     * @return True if the value was sent correctly, false otherwise.
     */
    function _sendValue(
        address payable to,
        uint256 amount
    ) private returns (bool) {
        (bool success, ) = to.call{ value: amount }("");
        return success;
    }
}
