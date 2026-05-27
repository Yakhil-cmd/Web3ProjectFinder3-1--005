// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {IGauge} from "./Zappers/Modules/Exchanges/Curve/IGauge.sol";
import {IInterestRouter} from "./Interfaces/IInterestRouter.sol";


contract InterestRouter is Initializable, IInterestRouter {

    error InterestRouter__InvalidCurveGauge();
    error InterestRouter__InvalidFeUSDToken();
    error InterestRouter__NoRewardsToProvide();
    error InterestRouter__RewardsClaimIntervalHasNotPassed();


    event InterestRouterInitialized(address indexed _curveGauge, address indexed _feUSDToken);
    event RewardsProvidedToGauge(uint256 indexed _timestamp, uint256 indexed _amount);


    uint256 public constant REWARDS_CLAIM_INTERVAL = 1 weeks;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    

    address public s_curveGauge;
    address public s_feUSDToken;

    uint256 public s_lastClaimTimestamp;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function initialize(address _curveGauge, address _feUSDToken) external initializer {
        if (_curveGauge == address(0)) revert InterestRouter__InvalidCurveGauge();
        if (_feUSDToken == address(0)) revert InterestRouter__InvalidFeUSDToken();

        s_curveGauge = _curveGauge;
        s_feUSDToken = _feUSDToken;

        s_lastClaimTimestamp = block.timestamp;

        IERC20(s_feUSDToken).approve(s_curveGauge, MAX_UINT256);

        emit InterestRouterInitialized(_curveGauge, _feUSDToken);
    }


    function provideRewardsToGauge() external {

        _requireRewardsClaimIntervalHasPassed();

        uint256 _feUSDTokenBalance = _requireFeUSDTokenBalance();

        s_lastClaimTimestamp = block.timestamp;

        IGauge(s_curveGauge).deposit_reward_token(s_feUSDToken, _feUSDTokenBalance);

        emit RewardsProvidedToGauge(block.timestamp, _feUSDTokenBalance);
    }

    
    function _getFeUSDTokenBalance() internal view returns (uint256) {
        return IERC20(s_feUSDToken).balanceOf(address(this));
    }

    function _requireFeUSDTokenBalance() internal view returns (uint256) {
        uint256 _feUSDTokenBalance = _getFeUSDTokenBalance();
        if (_feUSDTokenBalance == 0) revert InterestRouter__NoRewardsToProvide();
        return _feUSDTokenBalance;
    }

    function _requireRewardsClaimIntervalHasPassed() internal view {
        if (block.timestamp - s_lastClaimTimestamp < REWARDS_CLAIM_INTERVAL) revert InterestRouter__RewardsClaimIntervalHasNotPassed();
    }

}