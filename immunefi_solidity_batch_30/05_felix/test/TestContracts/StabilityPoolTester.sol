// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../../src/StabilityPool.sol";
import "./Interfaces/IStabilityPoolTester.sol";

/* Tester contract inherits from StabilityPool, and provides external functions
for testing the parent's internal functions. */
contract StabilityPoolTester is StabilityPool, IStabilityPoolTester {
    function priceFeedAddress() external view returns (address) {
        return address(priceFeed);
    }

    function defaultPoolAddress() external view returns (address) {
        return address(defaultPool);
    }
}
