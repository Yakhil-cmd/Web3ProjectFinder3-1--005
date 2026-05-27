// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "./Constants.sol";
import "./LiquityMath.sol";
import "../Interfaces/IAddressesRegistry.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/IPriceFeedLst.sol";
import "../Interfaces/ILiquityBase.sol";
import "../Libraries/LiquityBaseInit.sol";

/*
* Base contract for TroveManager, BorrowerOperations and StabilityPool. Contains global system constants and
* common functions.
*/
abstract contract LiquityBaseLst is Initializable, ILiquityBase {
    IActivePool public activePool;
    IDefaultPool internal defaultPool;
    IPriceFeedLst internal priceFeed;
    uint256[50] private __gap;

    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);

    constructor() {
        _disableInitializers();
    }

    function __LiquityBase_init(IAddressesRegistry _addressesRegistry) internal {
        LiquityBaseInit.initialize(_addressesRegistry);
    }
    // --- Gas compensation functions ---

    function getEntireBranchColl() public view returns (uint256 entireSystemColl) {
        uint256 activeColl = activePool.getCollBalance();
        uint256 liquidatedColl = defaultPool.getCollBalance();

        return activeColl + liquidatedColl;
    }

    function getEntireBranchDebt() public view returns (uint256 entireSystemDebt) {
        uint256 activeDebt = activePool.getfeUSDDebt();
        uint256 closedDebt = defaultPool.getfeUSDDebt();

        return activeDebt + closedDebt;
    }

    function _getTCR(uint256 _price) internal view returns (uint256 TCR) {
        uint256 entireSystemColl = getEntireBranchColl();
        uint256 entireSystemDebt = getEntireBranchDebt();

        TCR = LiquityMath._computeCR(entireSystemColl, entireSystemDebt, _price);

        return TCR;
    }

    function _checkBelowCriticalThreshold(uint256 _price, uint256 _CCR) internal view returns (bool) {
        uint256 TCR = _getTCR(_price);

        return TCR < _CCR;
    }

    function _calcInterest(uint256 _weightedDebt, uint256 _period) internal pure returns (uint256) {
        return _weightedDebt * _period / ONE_YEAR / DECIMAL_PRECISION;
    }
}
