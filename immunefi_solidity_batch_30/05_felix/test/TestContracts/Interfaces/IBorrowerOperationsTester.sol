// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../../../src/Interfaces/IBorrowerOperations.sol";

interface IBorrowerOperationsTester is IBorrowerOperations {
    function getCollToken() external view returns (IERC20);
    function getSortedTroves() external view returns (ISortedTroves);
    function getfeUSDToken() external view returns (IfeUSDToken);
    function getCollSurplusPool() external view returns (address);
    function getGasPoolAddress() external view returns (address);
    function getTroveManager() external view returns (address);
    function getWHYPE() external view returns (address);
    function getPriceFeed() external view returns (address);
    function getDefaultPool() external view returns (address);
    function getTroveNFT() external view returns (address);

    function applyPendingDebt(uint256 _troveId) external;
    function getNewTCRFromTroveChange(
        uint256 _collChange,
        bool isCollIncrease,
        uint256 _debtChange,
        bool isDebtIncrease,
        uint256 _price
    ) external view returns (uint256);
    function shutdownFromOracleFailure(address _failedOracleAddr) external;
}
