// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IVotingEscrow {
    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    function point_history(
        uint256 timestamp
    ) external view returns (Point memory);

    function user_point_history(
        address user,
        uint256 timestamp
    ) external view returns (Point memory);

    function epoch() external view returns (uint256);

    function user_point_epoch(address user) external view returns (uint256);

    /// @notice Add address to whitelist smart contract depositors `addr`
    /// @param addr Address to be whitelisted
    function add_to_whitelist(address addr) external;

    /// @notice Remove a smart contract address from whitelist
    /// @param addr Address to be removed from whitelist
    function remove_from_whitelist(address addr) external;

    /// @notice Unlock all locked balances
    function unlock() external;

    /// @notice Get the most recently recorded rate of voting power decrease for `_addr`
    /// @param addr Address of the user wallet
    /// @return Value of the slope
    function get_last_user_slope(address addr) external view returns (int128);

    /// @notice Get the timestamp for checkpoint `_idx` for `_addr`
    /// @param _addr User wallet address
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function user_point_history__ts(
        address _addr,
        uint256 _idx
    ) external view returns (uint);

    /// @notice Get timestamp when `_addr`'s lock finishes
    /// @param _addr User wallet address
    /// @return Epoch time of the lock end
    function locked__end(address _addr) external view returns (uint);

    /// @notice Record global data to checkpoint
    function checkpoint() external;

    /// @notice Deposit `_value` tokens for `_addr` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _addr User's wallet address
    /// @param _value Amount to add to user's lock
    /// @param _deposit_token The token to be deposited.
    function deposit_for(
        address _addr,
        uint256 _value,
        address _deposit_token
    ) external payable;

    /// @notice Deposit `_value` tokens for `_addr` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @dev Like `deposit_for` expect it does not require the fee.
    /// @param _addr User's wallet address
    /// @param _value Amount to add to user's lock
    /// @param _deposit_token The token to be deposited.
    /// @param _transfer_from The address from which the token will be transferred.
    function deposit_for_admin(
        address _addr,
        uint256 _value,
        address _deposit_token,
        address _transfer_from
    ) external payable;

    /// @notice External function for _create_lock
    /// @param _value Amount to deposit
    /// @param _unlock_time Epoch time when tokens unlock, rounded down to whole weeks
    /// @param _deposit_token The token to be deposited.
    function create_lock(
        uint256 _value,
        uint256 _unlock_time,
        address _deposit_token
    ) external payable;

    /// @notice Deposit `_value` additional tokens for `msg.sender` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    /// @param _deposit_token The token to be deposited.
    function increase_amount(
        uint256 _value,
        address _deposit_token
    ) external payable;

    /// @notice Extend the unlock time for `msg.sender` to `_unlock_time`
    /// @param _unlock_time New epoch time for unlocking
    function increase_unlock_time(uint256 _unlock_time) external payable;

    /// @notice Extend the unlock time and/or for `msg.sender` to `_unlock_time`
    /// @param _unlock_time New epoch time for unlocking
    /// @param _deposit_token The token to be deposited.
    function increase_amount_and_time(
        uint256 _value,
        uint256 _unlock_time,
        address _deposit_token
    ) external payable;

    /// @notice Withdraw all tokens for `msg.sender`.
    function withdraw() external payable;

    /// @notice Returns the voting power of an address at time `_t`.
    /// @param addr The address to check.
    /// @param _t The ts to check.
    /// @return The voting power of `addr` at time `_t`.
    function balanceOfAtT(
        address addr,
        uint256 _t
    ) external view returns (uint);

    /// @notice Returns the voting power of `addr`.
    /// @param addr The address to check.
    /// @return The voting power of `addr`.
    function balanceOf(address addr) external view returns (uint);

    /// @notice Measure voting power of `addr` at block height `_block`
    /// @dev Adheres to MiniMe `balanceOfAt` interface: https://github.com/Giveth/minime
    /// @param addr User's wallet address
    /// @param _block Block to calculate the voting power at
    /// @return Voting power
    function balanceOfAt(
        address addr,
        uint256 _block
    ) external view returns (uint);

    /// @notice Calculates the total voting power at time `t` in the past.
    /// @param t The ts in the past to check.
    /// @return Total voting power at some time `t` in the past.
    function totalSupplyAtT(uint256 t) external view returns (uint);

    /// @notice Calculates the current total voting power.
    /// @return The current total voting power.
    function totalSupply() external view returns (uint);

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function totalSupplyAt(uint256 _block) external view returns (uint);

    /// @notice Adds `addr` as an approved deposit token.
    /// @param addr The token address to add.
    function add_deposit_token(address addr) external;

    /// @notice Removes `addr` as an approved deposit token.
    /// @param addr The token address to add.
    function remove_deposit_token(address addr) external;

    /// @notice Returns the list of currently active deposit token addresses.
    /// @return The list of currently active deposit token addresses.
    function active_deposit_tokens() external view returns (address[] memory);

    /// @notice Whitelist of tokens that can be deposited.
    /// @param tkn The token address to check.
    /// @return True if the token is a valid deposit token, false otherwise.
    function deposit_tokens(address tkn) external view returns (bool);

    /// @notice A historical list of all deposit token addresses.
    /// @return The historical list of all deposit token addresses.
    function historical_deposit_tokens()
        external
        view
        returns (address[] memory);
}
