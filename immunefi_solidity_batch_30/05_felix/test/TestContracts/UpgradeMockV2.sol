// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract UpgradeMockV2 is Initializable {
    function initialize() public reinitializer(2) {}
}