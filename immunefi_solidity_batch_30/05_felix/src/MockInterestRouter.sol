// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "./Interfaces/IInterestRouter.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MockInterestRouter is Initializable, IInterestRouter {

    address public owner;

    function initialize(address _curveGauge, address _feUSDToken) public initializer {
        owner = msg.sender;
    }


    function withdrawToken(address _token) external {
        require(msg.sender == owner, "MockInterestRouter: only owner can withdraw");
        IERC20(_token).transfer(owner, IERC20(_token).balanceOf(address(this)));
    }

    function provideRewardsToGauge() external {}
    
}
