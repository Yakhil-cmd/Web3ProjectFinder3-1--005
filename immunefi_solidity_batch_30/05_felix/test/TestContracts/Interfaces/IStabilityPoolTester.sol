// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../../../src/Interfaces/IStabilityPool.sol";

interface IStabilityPoolTester is IStabilityPool {
    function priceFeedAddress() external view returns (address);
    function defaultPoolAddress() external view returns (address);
}
