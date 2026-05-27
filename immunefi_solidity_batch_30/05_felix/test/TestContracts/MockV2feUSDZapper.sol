// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {FeUSDZapper} from "../../src/Zappers/FeUSDZapper.sol";

contract MockV2feUSDZapper is FeUSDZapper {

    bool public isNewImplementation;

    function reinitialize() external reinitializer(2) {
        isNewImplementation = true;
    }
}