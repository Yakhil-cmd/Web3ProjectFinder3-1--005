// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IInterestRouter.sol";
import "./IfeUSDRewardsReceiver.sol";
import "../Types/TroveChange.sol";
import "./IAddressesRegistry.sol";
import "./IfeUSDToken.sol";
import "./IInterestRouter.sol";
interface IActivePool {
    function collToken() external view returns (IERC20);
    function defaultPoolAddress() external view returns (address);
    function borrowerOperationsAddress() external view returns (address);
    function troveManagerAddress() external view returns (address);
    function interestRouter() external view returns (IInterestRouter);
    // We avoid IStabilityPool here in order to prevent creating a dependency cycle that would break flattening
    function stabilityPool() external view returns (IfeUSDRewardsReceiver);

    function getCollBalance() external view returns (uint256);
    function getfeUSDDebt() external view returns (uint256);
    function lastAggUpdateTime() external view returns (uint256);
    function aggRecordedDebt() external view returns (uint256);
    function aggWeightedDebtSum() external view returns (uint256);
    function aggBatchManagementFees() external view returns (uint256);
    function aggWeightedBatchManagementFeeSum() external view returns (uint256);
    function calcPendingAggInterest() external view returns (uint256);
    function calcPendingSPYield() external view returns (uint256);
    function calcPendingAggBatchManagementFee() external view returns (uint256);
    function getNewApproxAvgInterestRateFromTroveChange(TroveChange calldata _troveChange)
        external
        view
        returns (uint256);

    function mintAggInterest() external;
    function mintAggInterestAndAccountForTroveChange(TroveChange calldata _troveChange, address _batchManager)
        external;
    function mintBatchManagementFeeAndAccountForChange(TroveChange calldata _troveChange, address _batchAddress)
        external;

    function setShutdownFlag() external;
    function hasBeenShutDown() external view returns (bool);
    function shutdownTime() external view returns (uint256);

    function sendColl(address _account, uint256 _amount) external;
    function sendCollToDefaultPool(uint256 _amount) external;
    function receiveColl(uint256 _amount) external;
    function accountForReceivedColl(uint256 _amount) external;
    function initialize(IAddressesRegistry _addressesRegistry, uint256 _spYieldSplit) external;
    function setSPYieldSplit(uint256 _spYieldSplit) external;
    function setInterestRouter(address _interestRouter) external;
    function SP_YIELD_SPLIT() external view returns (uint256);
    function feUSDToken() external view returns (IfeUSDToken);
}
