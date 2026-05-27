// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;


interface ICryptoSwapFactory {
    function deploy_pool(
        string memory _name,
        string memory _symbol,
        address[2] memory _coins,
        uint256 _implementation_id,
        uint256 _A, // 20000000
        uint256 _gamma, // 10000000000000000
        uint256 _mid_fee, // 3000000
        uint256 _out_fee, // 45000000
        uint256 _fee_gamma, // 300000000000000000
        uint256 _allowed_extra_profit, // 10000000000
        uint256 _adjustment_step, // 5500000000000
        uint256 _ma_half_time, // 600
        uint256 _initial_price // coin1 / coin0 (expressed in 18 decimals)
    ) external returns (address);
}

