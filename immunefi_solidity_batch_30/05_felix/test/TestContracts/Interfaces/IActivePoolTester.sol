// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../../../src/Interfaces/IActivePool.sol";

interface IActivePoolTester is IActivePool {
    function feUSDTokenAddress() external view returns (address);
}
