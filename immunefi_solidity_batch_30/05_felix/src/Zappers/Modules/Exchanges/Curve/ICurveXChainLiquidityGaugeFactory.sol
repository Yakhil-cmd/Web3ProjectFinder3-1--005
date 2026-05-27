// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICurveXChainLiquidityGaugeFactory {
    function deploy_gauge(address _lp_token, bytes32 _salt, address _manager) external returns (address);
    function owner() external view returns (address);
    function set_crv(address _crv_token) external;
}