// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import { NetworkGuardian } from "../../../network-guardian/NetworkGuardian.sol";
import { RecoverableUpgradeable } from "../../../utils/upgradeable/RecoverableUpgradeable.sol";
import { Address } from "../../../utils/Address.sol";

import { IFeeDistributor } from "../../../governance/interfaces/IFeeDistributor.sol";
import { IWH1 } from "../../../tokens/interfaces/IWH1.sol";
import { IFeeDistributorChannel } from "../../interfaces/IFeeDistributorChannel.sol";

import { IVersion } from "../../../utils/interfaces/IVersion.sol";
import { Semver } from "../../../utils/Semver.sol";

/**
 * @title FeeDistributorChannelWH1
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract serves as a channel for distributing WH1 to the Fee
 * Distributor contract.
 *
 * It handles the process of receiving native H1 tokens, wrapping them into WH1
 * tokens, and forwarding them to the Fee Distributor contract, enabling efficient
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
 * -    WH1 must be enabled for claiming on the Fee Distributor contract.
 * -    The current `block.timestamp` must be greater than the start time on
 *      the `FeeDistributor` contract.
 */
contract FeeDistributorChannelWH1 is
    ReentrancyGuardUpgradeable,
    NetworkGuardian,
    RecoverableUpgradeable,
    IFeeDistributorChannel,
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
     * @dev The address of the `FeeDistributor` contract. Will be the recipient
     * of the forwarded `WH1`.
     */
    IFeeDistributor private _feeDistributor;

    /**
     * @dev The `WH1` contract.
     */
    IWH1 private _WH1;

    /**
     * @dev The timestamp of the last distribution.
     */
    uint256 internal _lastDistribution;

    /* ERRORS
    ==================================================*/

    /**
     * @dev Error raised when trying to distribute an amount of H1 that exceeds
     * the contract's balance.
     *
     * @param amt       The amount attempted to be sent.
     * @param available The amount available to send.
     */
    error FeeDistributorChannel__InsufficientH1(uint256 amt, uint256 available);

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
     * @param feeDistributor_       The Fee Distributor address.
     * @param WH1_                  The WH1 address.
     */
    function initialize(
        address association_,
        address guardianController_,
        address feeDistributor_,
        address WH1_
    ) external initializer {
        feeDistributor_.assertNotZero();
        WH1_.assertNotZero();

        __ReentrancyGuard_init();

        __NetworkGuardian_init(association_, guardianController_);
        __Recoverable_init();

        _feeDistributor = IFeeDistributor(feeDistributor_);
        _WH1 = IWH1(WH1_);
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
     * @inheritdoc IFeeDistributorChannel
     */
    function deposit() external payable {
        _deposit();
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function distribute() external nonReentrant onlyRole(OPERATOR_ROLE) {
        uint256 amt = address(this).balance;
        _distribute(amt);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function distributePartial(
        uint256 amt
    ) external nonReentrant onlyRole(OPERATOR_ROLE) {
        _distribute(amt);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function recoverHRC20(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _recoverHRC20(token, to, amount);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function setFeeDistributor(
        address addr
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        address prev = address(_feeDistributor);
        _feeDistributor = IFeeDistributor(addr);

        emit FeeDistributorUpdated(prev, addr);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function setWH1(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        address prev = address(_WH1);
        _WH1 = IWH1(addr);

        emit WH1Updated(prev, addr);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function feeDistributor() external view returns (address) {
        return address(_feeDistributor);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
     */
    function WH1() external view returns (address) {
        return address(_WH1);
    }

    /**
     * @inheritdoc IFeeDistributorChannel
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
     * @notice Distributes an amount of rewards to the Fee Distributor contract
     * in the form of WH1.
     *
     * @param amt The amount of H1 tokens to distribute.
     *
     * @dev Requirements:
     * -    The amount to distribute must be less than, or equal to, the amount
     *      of H1 stored in the contract.
     * -    WH1 must be enabled for claiming on the Fee Distributor contract.
     * -    The current `block.timestamp` must be greater than the start time on
     *      the `FeeDistributor` contract.
     *
     * @dev Emits a `RewardsDistributed` event.
     */
    function _distribute(uint256 amt) internal {
        uint256 bal = address(this).balance;
        if (amt > bal) {
            revert FeeDistributorChannel__InsufficientH1(amt, bal);
        }

        _lastDistribution = block.timestamp;

        address feeDistAddr = address(_feeDistributor);
        address wh1Addr = address(_WH1);
        IWH1 wh1 = _WH1;

        wh1.deposit{ value: amt }();
        wh1.approve(feeDistAddr, amt);

        _feeDistributor.depositToken(IERC20Upgradeable(wh1Addr), amt);

        uint256 allowance = wh1.allowance(address(this), feeDistAddr);
        assert(allowance == 0);

        emit RewardsDistributed(feeDistAddr, wh1Addr, amt);
    }

    /**
     * @notice Encapsulates the deposit logic.
     */
    function _deposit() private {
        emit H1Received(msg.sender, msg.value);
    }
}
