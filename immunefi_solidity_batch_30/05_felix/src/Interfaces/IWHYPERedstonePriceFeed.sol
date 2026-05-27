// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWHYPERedstonePriceFeed {
    function initialize(address _borrowOperationsAddress, address _whypeUsdOracleAddress) external;
}
