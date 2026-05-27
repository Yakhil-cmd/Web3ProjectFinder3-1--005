// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../../src/ActivePool.sol";
import "./Interfaces/IActivePoolTester.sol";

/* Tester contract inherits from ActivePool, and provides external functions
for testing the parent's internal functions. */
contract ActivePoolTester is ActivePool, IActivePoolTester {
    function feUSDTokenAddress() external view returns (address) {
        return address(feUSDToken);
    }
}
