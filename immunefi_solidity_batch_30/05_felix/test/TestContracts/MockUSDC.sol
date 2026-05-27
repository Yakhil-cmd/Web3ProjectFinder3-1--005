// SPDX-License-Identifier: MIT


pragma solidity 0.8.24;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {

    uint256 public constant INITIAL_SUPPLY = 10_000_000e6;

    constructor() ERC20("MockUSDC", "mUSDC") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function tap(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }    
}