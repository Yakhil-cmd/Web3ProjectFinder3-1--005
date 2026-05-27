// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IInterestRouterV2 {

    struct AllocationConfig {
        address[] rewardDestinations;
        uint256[] percentages;
        bytes4[] rewardSelectors;
        uint256 lastUpdatedTimestamp;
    }

    function MAX_ALLOCATION_CONFIG_SIZE() external view returns (uint256);
    function MAX_PERCENTAGE() external view returns (uint256);
    function REWARD_INTERVAL() external view returns (uint256);
    function ZERO_BYTES4() external view returns (bytes4);

    function s_adminController() external view returns (address);
    function s_feUSDToken() external view returns (address);

    function getCurrentAllocationConfig() external view returns (AllocationConfig memory);
    function getNextAllocationConfig() external view returns (AllocationConfig memory);

    function triggerDistribution() external;

    function setNewAllocationConfig(AllocationConfig memory _newAllocationConfig) external;

    function initialize(address _adminController, address _feUSDToken, AllocationConfig memory _initialAllocationConfig) external;
    function emergencyAdjustAllocationConfig(AllocationConfig memory _newAllocationConfig) external;
}