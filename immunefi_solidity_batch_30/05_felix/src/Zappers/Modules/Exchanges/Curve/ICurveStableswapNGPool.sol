// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICurveStableswapNGPool {
    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256 output);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256 output);
    function coins(uint256 index) external view returns (address);
    function get_dx(int128 i, int128 j, uint256 dy) external view returns (uint256 dx);
    function remove_liquidity(uint256 burn_amount, uint256[] memory min_amounts) external;
    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);
}
