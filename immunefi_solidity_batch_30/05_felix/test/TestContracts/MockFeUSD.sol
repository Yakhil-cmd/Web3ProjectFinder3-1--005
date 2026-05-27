// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockFeUSD is ERC20 {

    uint256 public constant INITIAL_SUPPLY = 10_000_000 ether;

    constructor() ERC20("MockFeUSD", "mFeUSD") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function tap(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }
}