// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MockL1Read {

    uint256 public constant ETH_PRICE = 10 ether;
    uint256 public constant WBTC_PRICE = 99_000 ether;
    uint256 public constant SOL_PRICE = 270 ether;
    uint256 public constant PURR_PRICE = 0.3 ether;
    uint256 public constant HYPE_PRICE = 27 ether;
    uint256 public constant WETH_PRICE = 3_750 ether;
    function oraclePx(uint16 _l1Index) public view returns (uint64) {
        if (_l1Index == 4) {
            return uint64(WETH_PRICE);
        } else if (_l1Index == 3) {
            return uint64(WBTC_PRICE);
        } else if (_l1Index == 0) {
            return uint64(SOL_PRICE);
        } else if (_l1Index == 125) {
            return uint64(PURR_PRICE);
        } else if (_l1Index == 135) {
            return uint64(HYPE_PRICE);
        }else return uint64(ETH_PRICE);
    }
}
