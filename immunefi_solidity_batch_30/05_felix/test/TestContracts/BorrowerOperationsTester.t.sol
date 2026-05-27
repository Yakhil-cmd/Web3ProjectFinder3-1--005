// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "../../src/Interfaces/IAddressesRegistry.sol";
import "../../src/BorrowerOperations.sol";
import "./Interfaces/IBorrowerOperationsTester.sol";

/* Tester contract inherits from BorrowerOperations, and provides external functions
for testing the parent's internal functions. */
contract BorrowerOperationsTester is BorrowerOperations, IBorrowerOperationsTester {
    function get_CCR() external view returns (uint256) {
        return CCR;
    }

    function getCollToken() external view returns (IERC20) {
        return collToken;
    }

    function getSortedTroves() external view returns (ISortedTroves) {
        return sortedTroves;
    }

    function getfeUSDToken() external view returns (IfeUSDToken) {
        return feUSDToken;
    }

    function getCollSurplusPool() external view returns (address) {
        return address(collSurplusPool);
    }

    function getGasPoolAddress() external view returns (address) {
        return gasPoolAddress;
    }

    function getTroveManager() external view returns (address) {
        return address(troveManager);
    }

    function getWHYPE() external view returns (address) {
        return address(WHYPE);
    }

    function getPriceFeed() external view returns (address) {
        return address(priceFeed);
    }

    function getDefaultPool() external view returns (address) {
        return address(defaultPool);
    }

    function getTroveNFT() external view returns (address) {
        return address(troveNFT);
    }

    function applyPendingDebt(uint256 _troveId) external {
        applyPendingDebt(_troveId, 0, 0);
    }

    function getNewTCRFromTroveChange(
        uint256 _collChange,
        bool isCollIncrease,
        uint256 _debtChange,
        bool isDebtIncrease,
        uint256 _price
    ) external view returns (uint256) {
        TroveChange memory troveChange;
        _initTroveChange(troveChange, _collChange, isCollIncrease, _debtChange, isDebtIncrease);
        return _getNewTCRFromTroveChange(troveChange, _price);
    }

    function shutdownFromOracleFailure(address _failedOracleAddr) external override(BorrowerOperations, IBorrowerOperationsTester) {}
}
