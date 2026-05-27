// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import { NetworkGuardian } from "../../../network-guardian/NetworkGuardian.sol";
import { RecoverableUpgradeable } from "../../../utils/upgradeable/RecoverableUpgradeable.sol";
import { Address } from "../../../utils/Address.sol";

import { IStaking } from "../../../staking/interfaces/IStaking.sol";
import { IEscrowedH1 } from "../../../tokens/interfaces/IEscrowedH1.sol";
import { IStakingChannel } from "../../interfaces/IStakingChannel.sol";

import { IVersion } from "../../../utils/interfaces/IVersion.sol";
import { Semver } from "../../../utils/Semver.sol";

/**
 * @title StakingChannelESH1
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract serves as a channel for distributing ESH1 to the Staking
 * contract.
 *
 * It handles the process of receiving native H1 tokens, swapping them to ESH1
 * tokens, and forwarding them to the Staking contract, enabling efficient
 * distribution of rewards across the network.
 *
 * @dev This contract inherits from, and initialises, the `RecoverableUpgradeable`
 * contract. It exposes the ability for an admin the recover HRC20 tokens from
 * the contract in the event that they were mistakenly sent in. The admin cannot
 * recover native H1.
 *
 * This contract inherits from, and initialises, the `NetworkGuardian` contract.
 *
 * Calls to `distribute` and `distributePartial` are non-reentrant calls.
 *
 * For a call to any of the distribute functions in this contract to be
 * successful:
 * -    The amount to distribute must be less than, or equal to, the amount
 *      of H1 stored in the contract.
 * -    This contract must be set as an Operator on the Staking contract in
 *      order to call `notifyRewardAmount`.
 * -    A Rewards Duration must be set on the Staking contract.
 */
contract StakingChannelESH1 is
    ReentrancyGuardUpgradeable,
    NetworkGuardian,
    RecoverableUpgradeable,
    IStakingChannel,
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
     * @dev The address of the Staking contract. Will be the recipient of the
     * forwarded Escrowed H1.
     */
    IStaking private _staking;

    /**
     * @dev The Escrowed H1 contract.
     */
    IEscrowedH1 private _esH1;

    /**
     * @dev The timestamp of the last distribution.
     */
    uint256 private _lastDistribution;

    /* ERRORS
    ==================================================*/

    /**
     * @dev Error raised when trying to distribute an amount of H1 that exceeds
     * the contract's balance.
     *
     * @param amt       The amount attempted to be sent.
     * @param available The amount available to send.
     */
    error StakingChannel__InsufficientH1(uint256 amt, uint256 available);

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
     * @param stakingContract_      The Staking contract address.
     * @param esH1_                 The ESH1 contract address.
     */
    function initialize(
        address association_,
        address guardianController_,
        address stakingContract_,
        address esH1_
    ) external initializer {
        stakingContract_.assertNotZero();
        esH1_.assertNotZero();

        __ReentrancyGuard_init();

        __NetworkGuardian_init(association_, guardianController_);
        __Recoverable_init();

        _staking = IStaking(stakingContract_);
        _esH1 = IEscrowedH1(esH1_);
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
     * @inheritdoc IStakingChannel
     */
    function deposit() external payable {
        _deposit();
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function distribute() external nonReentrant onlyRole(OPERATOR_ROLE) {
        uint256 amt = address(this).balance;
        _distribute(amt);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function distributePartial(
        uint256 amt_
    ) external nonReentrant onlyRole(OPERATOR_ROLE) {
        _distribute(amt_);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function recoverHRC20(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token_, to_, amount_);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function setStaking(address addr_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr_.assertNotZero();

        address prev = address(_staking);
        _staking = IStaking(addr_);

        emit StakingUpdated(prev, addr_);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function setESH1(address addr_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr_.assertNotZero();

        address prev = address(_esH1);
        _esH1 = IEscrowedH1(addr_);

        emit ESH1Updated(prev, addr_);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function staking() external view returns (address) {
        return address(_staking);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function esH1() external view returns (address) {
        return address(_esH1);
    }

    /**
     * @inheritdoc IStakingChannel
     */
    function lastDistribution() external view returns (uint256) {
        return _lastDistribution;
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
     * @notice Distributes an amount of rewards to the Staking contract in the
     * form of ESH1.
     *
     * @param amt_ The amount of H1 tokens to distribute.
     *
     * @dev Requirements:
     * -    The amount to distribute must be less than, or equal to, the amount
     *      of H1 stored in the contract.
     * -    This contract must be set as an Operator on the Staking contract in
     *      order to call `notifyRewardAmount`.
     * -    A Rewards Duration must be set on the Staking contract.
     *
     * @dev Emits a `RewardsDistributed` event.
     */
    function _distribute(uint256 amt_) internal {
        uint256 bal = address(this).balance;
        if (amt_ > bal) {
            revert StakingChannel__InsufficientH1(amt_, bal);
        }

        _lastDistribution = block.timestamp;

        address stakingAddr = address(_staking);
        address esH1Addr = address(_esH1);

        _esH1.mintEscrowedH1{ value: amt_ }(stakingAddr);
        _staking.notifyRewardAmount(amt_);

        emit RewardsDistributed(stakingAddr, esH1Addr, amt_);
    }

    /**
     * @notice Encapsulates the deposit logic.
     */
    function _deposit() private {
        emit H1Received(msg.sender, msg.value);
    }
}
