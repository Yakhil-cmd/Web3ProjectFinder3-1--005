// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import { IValidatorRewards } from "../../interfaces/IValidatorRewards.sol";
import { IValidatorRewardsConfig } from "../../interfaces/IValidatorRewardsConfig.sol";

import { NetworkGuardian } from "../../../network-guardian/NetworkGuardian.sol";
import { RecoverableUpgradeable } from "../../../utils/upgradeable/RecoverableUpgradeable.sol";
import { Address } from "../../../utils/Address.sol";

/**
 * @title ValidatorRewardsBase
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract forms the base for managing validator rewards within
 * the Haven1 network. It exposes functions to calculate the [equal] share of
 * rewards that validators will receive, along with mechanisms for depositing
 * native H1 into the contract, configuring reward distribution parameters, and
 * ensuring secure operations.
 *
 * @dev This contract is abstract. Inheriting contracts must implement the
 * `_distribute` function to satisfy the interface. If a distribution of rewards
 * to any validator fails, the whole distribution will be reverted. This ensures
 * that we can easily recover from a failed distribution and that no validators
 * are treated preferentially.
 *
 * Application fees on Haven1 are distributed to channels in the form of native
 * H1. The suite of contracts that inherit from this base are expected to only
 * store native H1. The inheriting contracts may forward rewards to validators
 * either in the form of native H1, or swap to a different token before
 * distributing.
 *
 * This contract inherits from, and initialises, the `RecoverableUpgradeable`
 * contract. It exposes the ability for an admin the recover HRC20 tokens from
 * the contract in the event that they were mistakenly sent in. The admin cannot
 * recover native H1.
 *
 * This contract inherits from, and initialises, the `NetworkGuardian` contract,
 * relieving the need for any Validator Rewards channels to implement.
 *
 * Calls to `distribute` and `distributeAdmin` are non-reentrant calls.
 */
abstract contract ValidatorRewardsBase is
    ReentrancyGuardUpgradeable,
    NetworkGuardian,
    RecoverableUpgradeable,
    IValidatorRewards
{
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;

    /* STATE
    ==================================================*/
    /**
     * @dev The ValidatorConfig contract.
     */
    IValidatorRewardsConfig internal _validatorConfig;

    /**
     * @dev The minimum time, in seconds, between distributions.
     */
    uint256 internal _distFreqSec;

    /**
     * @dev The timestamp of the last distribution.
     */
    uint256 internal _lastDistribution;

    /* ERRORS
    ==================================================*/
    error ValidatorRewards__DistributionFailed();

    /* FUNCTIONS
    ==================================================*/

    /* Init
    ========================================*/

    /**
     * @notice Initializes the contract.
     *
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     * @param validatorConfig_      The Validator Config address.
     * @param distFreqSec_          The minimum time between distributions.
     */
    function __ValidatorRewards_init(
        address association_,
        address guardianController_,
        address validatorConfig_,
        uint256 distFreqSec_
    ) internal onlyInitializing {
        __ReentrancyGuard_init();
        __NetworkGuardian_init(association_, guardianController_);
        __Recoverable_init();
        __ValidatorRewards_init_unchained(validatorConfig_, distFreqSec_);
    }

    /**
     * @param validatorConfig_  The Validator Config address.
     * @param distFreqSec_      The minimum time between distributions.
     *
     * @dev Requirements:
     * -    The Validator Config address cannot be the zero address.
     */
    function __ValidatorRewards_init_unchained(
        address validatorConfig_,
        uint256 distFreqSec_
    ) internal onlyInitializing {
        validatorConfig_.assertNotZero();

        _validatorConfig = IValidatorRewardsConfig(validatorConfig_);
        _distFreqSec = distFreqSec_;
    }

    /* Receive and Fallback
    ========================================*/

    receive() external payable {
        _deposit();
    }

    fallback() external payable {
        _deposit();
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IValidatorRewards
     */
    function deposit() external payable {
        _deposit();
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function distribute() external whenNotGuardianPaused nonReentrant {
        if (!canDistribute()) return;

        bool success = _distribute();
        if (!success) {
            revert ValidatorRewards__DistributionFailed();
        }

        _updateLastDistribution();
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function distributeAdmin() external onlyRole(OPERATOR_ROLE) nonReentrant {
        bool success = _distribute();
        if (!success) {
            revert ValidatorRewards__DistributionFailed();
        }

        _updateLastDistribution();
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token_, to_, amount_);
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function setValidatorConfig(
        address cfg_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        cfg_.assertNotZero();
        _validatorConfig = IValidatorRewardsConfig(cfg_);
        emit ValidatorConfigUpdated(cfg_);
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function setDistributionFrequency(
        uint256 distFreqSec_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _distFreqSec = distFreqSec_;
        emit DistributionFrequencyUpdated(distFreqSec_);
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function validatorConfig() external view returns (address) {
        return address(_validatorConfig);
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function distributionFrequency() external view returns (uint256) {
        return _distFreqSec;
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function lastDistribution() external view returns (uint256) {
        return _lastDistribution;
    }

    /* Public
    ========================================*/

    /**
     * @inheritdoc IValidatorRewards
     */
    function canDistribute() public view returns (bool) {
        bool isTime = block.timestamp > _lastDistribution + _distFreqSec;
        return isTime && !guardianPaused();
    }

    /**
     * @inheritdoc IValidatorRewards
     */
    function calculateShare() public view returns (uint256) {
        uint256 b = address(this).balance;
        if (b == 0) {
            return 0;
        }

        uint256 n = _validatorConfig.numberOf();
        if (n == 0) {
            return 0;
        }

        return b / n;
    }

    /* Internal
    ========================================*/

    /**
     * @notice Updates the last distibution timestamp.
     */
    function _updateLastDistribution() internal {
        _lastDistribution = block.timestamp;
    }

    /**
     * @notice Encapsulates the rewards distribution logic.
     */
    function _distribute() internal virtual returns (bool success);

    /* Private
    ==================================================*/

    /**
     * @notice Encapsulates the deposit logic.
     */
    function _deposit() private {
        emit H1Received(msg.sender, msg.value);
    }

    /* GAP
    ==================================================*/

    /**
     * @dev This empty reserved space allows new state variables to be added
     * without compromising the storage compatibility with existing deployments.
     *
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     *
     * As new variables are added, be sure to reduce the gap as required.
     * For e.g., if the starting `__gap` is `25` and a new variable is added
     * (256 bits in size or part thereof), the gap must now be reduced to `24`.
     */
    uint256[25] private __gap;
}
