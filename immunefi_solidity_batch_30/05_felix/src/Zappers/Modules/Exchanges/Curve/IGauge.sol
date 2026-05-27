// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGauge {

    struct Reward {
        address distributor;
        uint256 period_finish;
        uint256 rate;
        uint256 last_update;
        uint256 integral;
    }

    function add_reward(address _reward_token, address _distributor) external;
    function set_reward_distributor(address _reward_token, address _distributor) external;  
    function deposit_reward_token(address _reward_token, uint256 _amount) external;
    function set_gauge_manager(address _gauge_manager) external;
    function deposit(uint256 _value) external;
    function withdraw(uint256 _value, bool _claim_rewards) external;
    function manager() external view returns (address);
    function reward_data(address _reward_token) external view returns (Reward memory);
}
