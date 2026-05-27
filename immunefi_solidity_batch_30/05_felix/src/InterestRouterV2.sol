// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IGauge} from "./Zappers/Modules/Exchanges/Curve/IGauge.sol";

/**
 * @title InterestRouterV2
 * @notice This contract is used to distribute the rewards to the different destinations
 * @dev It is used to distribute the rewards to the different destinations
 * @author @gfranchi3s
 */
contract InterestRouterV2 is Initializable {

    using SafeERC20 for IERC20;
    using Address for address;

    /// @notice The allocation config is used to distribute the rewards to the different destinations
    /// @dev The reward destinations are the addresses that will receive the rewards
    /// @dev The percentages are the percentages of the rewards that will be sent to each destination
    /// @dev The reward selectors are the function selectors that will be called on each destination (0 bytes4 means no function call)
    /// @dev The lastUpdatedTimestamp is the timestamp of the last time the allocation config was updated (1 week)
    struct AllocationConfig {
        address[] rewardDestinations;
        uint256[] percentages;
        bytes4[] rewardSelectors;
        uint256 lastUpdatedTimestamp;
    }

    /// @notice It is thrown if the allocation config length is greater than the max allowed size
    error InterestRouterV2__AllocationLengthSizeExceeded();
    /// @notice It is thrown if the allocation config lengths do not match
    error InterestRouterV2__AllocationLengthMismatch();
    /// @notice It is thrown if the allocation config lengths are 0
    error InterestRouterV2__AllocationLengthCannotBeZero();
    /// @notice It is thrown if the allocation config percentages do not sum up or exceed 100%
    error InterestRouterV2__InvalidAllocationPercentages();
    /// @notice It is thrown if the allocation config percentages contain a 0 value
    error InterestRouterV2__NoZeroPercentages();
    /// @notice It is thrown if the admin controller is address(0)  
    error InterestRouterV2__InvalidAdminController();
    /// @notice It is thrown if the feUSD token is address(0)
    error InterestRouterV2__InvalidFeUSDToken();
    /// @notice It is thrown if the caller is not the admin controller
    error InterestRouterV2__CallerIsNotAdminController();
    /// @notice It is thrown if the reward interval has not passed
    error InterestRouterV2__RewardIntervalNotMet();
    /// @notice It is thrown if the reward amount is less than the min allowed amount
    error InterestRouterV2__NoRewardsToClaim();
    /// @notice It is thrown if the reward call fails on a contract destination
    error InterestRouterV2__RewardCallFailed();
    /// @notice It is thrown if the destination is not valid
    error InterestRouterV2__InvalidDestination();
    /// @notice It is thrown if we have a function selector for an address that is not a contract
    error InterestRouterV2__NonContractDestination();

    /**
     * @notice Emitted when the allocation config is updated, this happens at triggerDistribution
     * @param _newAllocationConfig The new allocation config
     */
    event AllocationConfigUpdated(AllocationConfig indexed _newAllocationConfig);
    /**
     * @notice Emitted when a new allocation config is proposed
     * @param _newAllocationConfig The new allocation config
     */
    event NewAllocationConfigProposed(AllocationConfig indexed _newAllocationConfig);
    /**
     * @notice Emitted when the admin controller is set
     * @param _newAdminController The new admin controller
     */
    event AdminControllerSet(address indexed _newAdminController);
    /**
     * @notice Emitted when the feUSD token is set
     * @param _newFeUSDToken The new feUSD token
     */
    event FeUSDTokenSet(address indexed _newFeUSDToken);
    /**
     * @notice Emitted when a reward is claimed
     * @param _rewardDestination The destination of the reward
     * @param _rewardAmount The amount of the reward
     * @param _timestamp The timestamp of the reward
     * @param _functionSelector The function selector of the reward
     */
    event RewardClaimed(address indexed _rewardDestination, uint256 indexed _rewardAmount, uint256 indexed _timestamp, bytes4 _functionSelector);
    /**
     * @notice Emitted when the rewards are triggered
     * @param _timestamp The timestamp of the rewards
     * @param _amount The amount of the rewards
     */
    event RewardsTriggered(uint256 indexed _timestamp, uint256 indexed _amount);

    /**
     * @notice Emitted when the allocation config is adjusted in case of emergency
     * @param _newAllocationConfig The new allocation config
     */
    event AllocationConfigAdjusted(AllocationConfig indexed _newAllocationConfig);

    /// @notice The max allowed size of the allocation config arrays, this is to prevent DoS.
    uint256 public constant MAX_ALLOCATION_CONFIG_SIZE = 10;
    /// @notice The percentage denominator, it represents 100%
    uint256 public constant PERCENTAGE_DENOMINATOR = 1e18;
    /// @notice The interval of the rewards distribution, it is 1 week
    uint256 public constant REWARD_INTERVAL = 1 weeks;
    /// @notice The min amount of rewards that can be claimed, this is to prevent possible reverts if amount is 0.
    uint256 public constant MIN_REWARDS_AMOUNT = 100 ether;
    /// @notice The bytes4 value of an empty function selector
    bytes4 public constant ZERO_BYTES4 = bytes4(0);

    /// @notice The admin controller address, it is the only address that can set the allocation config
    address public s_adminController;
    /// @notice The feUSD token address, it is the token that is being distributed
    address public s_feUSDToken;

    /// @notice The current allocation config, it is the allocation config that is being used to distribute the rewards
    AllocationConfig private s_currentAllocationConfig;
    /// @notice The next allocation config, it is the allocation config that will be used to distribute the rewards after the next distribution
    AllocationConfig private s_nextAllocationConfig;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the InterestRouterV2 contract
     * @dev It sets the lastUpdatedTimestamp to the current timestamp so rewards will be distributed on the next week
     * @dev This will be deployed simultaneously with the protocol so interest needs time to accrue before the first distribution
     * @dev The proxy admin is controlled by the AdminController contract
     * @param _adminController The admin controller address
     * @param _feUSDToken The feUSD token address
     * @param _initialAllocationConfig The initial allocation config
     * @notice It emits the AllocationConfigUpdated event
     * @notice It emits the AdminControllerSet event
     * @notice It emits the FeUSDTokenSet event
     */
    function initialize(address _adminController, address _feUSDToken, AllocationConfig memory _initialAllocationConfig) external initializer {
        if (_adminController == address(0)) revert InterestRouterV2__InvalidAdminController();
        if (_feUSDToken == address(0)) revert InterestRouterV2__InvalidFeUSDToken();

        _requireValidAllocLengths(_initialAllocationConfig);
        _requireValidAllocPercentagesAndDestinations(_initialAllocationConfig);

        s_adminController = _adminController;
        s_feUSDToken = _feUSDToken;

        _initialAllocationConfig.lastUpdatedTimestamp = block.timestamp;

        s_currentAllocationConfig = _initialAllocationConfig;

        emit AllocationConfigUpdated(_initialAllocationConfig);
        emit AdminControllerSet(_adminController);
        emit FeUSDTokenSet(_feUSDToken);
    }

    /**
     * @notice Triggers the distribution of the rewards
     * @dev It will distribute the rewards to the destinations specified in the current allocation config
     * @dev If there is a next allocation config it will replace the current one after the distribution
     * @dev Some dust is expected, it is redistributed on the next distribution
     * @dev It can be called by the admin controller
     * @dev It is can be called only if the reward interval has passed
     * @dev It can be called only if there are rewards to distribute greater than the min allowed amount
     * @notice It emits the AllocationConfigUpdated event
     * @notice It emits the RewardsTriggered event
     */
    function triggerDistribution() external {
        _requireCallerIsAdminController();

        AllocationConfig memory _currentAllocationConfig = s_currentAllocationConfig;
        AllocationConfig memory _nextAllocationConfig = s_nextAllocationConfig;

        _requireWeekHasPassed(_currentAllocationConfig.lastUpdatedTimestamp);

        uint256 _rewardAmount = _requireHasRewards();

        if (_nextAllocationConfig.rewardDestinations.length > 0) {
            s_currentAllocationConfig = _nextAllocationConfig;
            delete s_nextAllocationConfig;
            emit AllocationConfigUpdated(_nextAllocationConfig);
        }

        s_currentAllocationConfig.lastUpdatedTimestamp = block.timestamp;
        
        // Some dust is expected, it is redistributed on the next distribution
        _distributeRewards(_rewardAmount, _currentAllocationConfig);

        emit RewardsTriggered(block.timestamp, _rewardAmount);
    }

    /**
     * @notice Sets a new allocation config
     * @dev It can be called only by the admin controller
     * @notice It emits the NewAllocationConfigProposed event
     */
    function setNewAllocationConfig(AllocationConfig memory _newAllocationConfig) external {
        _requireCallerIsAdminController();

        _requireValidAllocLengths(_newAllocationConfig);
        _requireValidAllocPercentagesAndDestinations(_newAllocationConfig);

        s_nextAllocationConfig = _newAllocationConfig;

        emit NewAllocationConfigProposed(_newAllocationConfig);
    }

    /**
     * @notice Adjusts the allocation config in case of emergency
     * @dev It can be called only by the admin controller
     * @notice It emits the AllocationConfigUpdated event
     * @notice This function is used as a safety net for edge cases of OOG reverts
     * @notice It takes effect immediately
     */

    /**
      DoS on external calls should be mitigated since the function selectors are passed only for trusted destinations like curve gauges distributors.
      However, if an external destination triggered by trusted distributors performs an extremely intensive operation it could lead to an Out of Gas (OOG) revert.
      Despite this scenario being very unlikely, if this happens the contract will be stuck since the triggerDistribution function, which is the one that also changes the allocation config,
      will revert.
      This function is used to mitigate this edge case by allowing to adjust the allocation config in case of emergency immediately.
     */
    function emergencyAdjustAllocationConfig(AllocationConfig memory _newAllocationConfig) external {
        _requireCallerIsAdminController();

        _requireValidAllocLengths(_newAllocationConfig);
        _requireValidAllocPercentagesAndDestinations(_newAllocationConfig);

        uint256 _lastUpdatedTimestamp = s_currentAllocationConfig.lastUpdatedTimestamp;
        _newAllocationConfig.lastUpdatedTimestamp = _lastUpdatedTimestamp;

        s_currentAllocationConfig = _newAllocationConfig;

        emit AllocationConfigAdjusted(_newAllocationConfig);
    }

    /**
     * @notice Returns the current allocation config
     * @return The current allocation config
     */
    function getCurrentAllocationConfig() external view returns (AllocationConfig memory) {
        return s_currentAllocationConfig;
    }

    /**
     * @notice Returns the next allocation config
     * @return The next allocation config
     */
    function getNextAllocationConfig() external view returns (AllocationConfig memory) {
        return s_nextAllocationConfig;
    }

    /**
     * @notice Distributes the rewards to the destinations specified in the allocation config
     * @dev It is called by the triggerDistribution function
     * @param _rewardAmount The amount of the rewards to distribute
     * @param _currentAllocationConfig The current allocation config
     * @notice It emits the RewardClaimed event for each destination
     * @notice It emits the RewardsTriggered event
     */
    function _distributeRewards(uint256 _rewardAmount, AllocationConfig memory _currentAllocationConfig) internal {

        address _cachedFeUSDToken = s_feUSDToken;

		for (uint256 _i; _i < _currentAllocationConfig.rewardDestinations.length; _i++) {
            address _rewardDestination = _currentAllocationConfig.rewardDestinations[_i];
            uint256 _percentage = _currentAllocationConfig.percentages[_i];
            bytes4 _rewardSelector = _currentAllocationConfig.rewardSelectors[_i];

            uint256 _rewardAmountForDestination = (_rewardAmount * _percentage) / PERCENTAGE_DENOMINATOR;

            IERC20(_cachedFeUSDToken).safeTransfer(_rewardDestination, _rewardAmountForDestination);

            if (_rewardSelector != ZERO_BYTES4) {

                if (!_rewardDestination.isContract()) revert InterestRouterV2__NonContractDestination();

                bytes memory _callData = abi.encodeWithSelector(_rewardSelector);
                (bool _success,) = _rewardDestination.call(_callData);
                /// @notice This could theoretically create a DoS, but since the allocations are decided by the admin controller, 
                // the function selectors will be passed only for trusted destinations like curve gauges distributors.
                // Each time a destination with a function selector is added it will always be an adapter contract under our control.
                if (!_success) revert InterestRouterV2__RewardCallFailed();
            }

            emit RewardClaimed(_rewardDestination, _rewardAmountForDestination, block.timestamp, _rewardSelector);
        }
    }

    /**
     * @dev It is used to check if there are rewards to distribute greater than the min allowed amount
     * @notice Returns the amount of rewards to distribute
     * @return The amount of rewards to distribute
     */
    function _requireHasRewards() internal view returns (uint256) {
        uint256 _rewardAmount = IERC20(s_feUSDToken).balanceOf(address(this));
        if (_rewardAmount < MIN_REWARDS_AMOUNT) revert InterestRouterV2__NoRewardsToClaim();

        return _rewardAmount;
    }

    /**
     * @dev It is used to check if the allocation config lengths are valid
     * @param _allocationConfig The allocation config to check
     * @dev All the arrays should have the same length
     * @dev The length should be less than or equal to the max allowed size
     * @dev The length should not be 0
     */
    function _requireValidAllocLengths(AllocationConfig memory _allocationConfig) internal pure {
        uint256 _referenceLength = _allocationConfig.rewardDestinations.length;

        if (_referenceLength == 0) revert InterestRouterV2__AllocationLengthCannotBeZero();
        if (_referenceLength > MAX_ALLOCATION_CONFIG_SIZE) revert InterestRouterV2__AllocationLengthSizeExceeded();
        if (_referenceLength != _allocationConfig.percentages.length) revert InterestRouterV2__AllocationLengthMismatch();
        if (_referenceLength != _allocationConfig.rewardSelectors.length) revert InterestRouterV2__AllocationLengthMismatch();
    }

    /**
     * @dev It is used to check if the allocation config percentages and destinations are valid
     * @param _allocationConfig The allocation config to check
     * @dev The percentages should sum up to the max percentage
     * @dev The destinations should be valid
     * @dev The percentages should not contain a 0 value
     */
    function _requireValidAllocPercentagesAndDestinations(AllocationConfig memory _allocationConfig) internal pure {
        uint256 _totalPercentages;

        for (uint256 _i; _i < _allocationConfig.percentages.length; _i++) {
            if (_allocationConfig.percentages[_i] == 0) revert InterestRouterV2__NoZeroPercentages();
            _totalPercentages += _allocationConfig.percentages[_i];
            _requireValidDestination(_allocationConfig.rewardDestinations[_i]);
        }
        
        if (_totalPercentages != PERCENTAGE_DENOMINATOR) revert InterestRouterV2__InvalidAllocationPercentages(); 
    }

    /**
     * @dev It is used to check if the destination is valid
     * @param _destination The destination to check
     * @dev The destination should not be address(0)
     */
    function _requireValidDestination(address _destination) internal pure {
        if (_destination == address(0)) revert InterestRouterV2__InvalidDestination();
    }

    /**
     * @dev It is used to check if the caller is the admin controller
     */
    function _requireCallerIsAdminController() internal view {
        if (msg.sender != s_adminController) revert InterestRouterV2__CallerIsNotAdminController();
    }

    /**
     * @dev It is used to check if the reward interval has passed
     * @param _lastUpdatedTimestamp The timestamp of the last time the allocation config was updated
     * @dev The timestamp should be greater than the last updated timestamp
     */
    function _requireWeekHasPassed(uint256 _lastUpdatedTimestamp) internal view {
        if (block.timestamp - _lastUpdatedTimestamp < REWARD_INTERVAL) revert InterestRouterV2__RewardIntervalNotMet();
    }

}