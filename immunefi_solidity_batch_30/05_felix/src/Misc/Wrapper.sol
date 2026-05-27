// SPDX-License-Identifier: MIT


pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
/**
 * @title Wrapper
 * @notice A wrapper contract for ERC20 tokens with less than 18 decimals
 * @notice This contract does not support tokens with >= 18 decimals
 * @notice This contract does not support tokens with 0 decimals
 * @notice This contract does not support rebasing, fee-on-transfer or deflationary tokens
 * @notice This contract is controlled by the owner so the decision of the collateral is protected
 */
contract Wrapper is ERC20, ReentrancyGuard {

    using SafeERC20 for IERC20;

    error Wrapper__ZeroAddress();
    error Wrapper__ZeroDecimals();
    error Wrapper__InvalidDecimals();
    error Wrapper__ZeroAmount();
    error Wrapper__InsufficientBalance();

    event WrapperCreated(address indexed originalToken, address indexed wrapper);
    event Deposited(address indexed user, uint256 indexed amount);
    event Withdrawn(address indexed user, uint256 indexed amount);


    uint256 public constant MAX_DECIMALS = 18;
    IERC20 public immutable i_originalToken;
    uint8 public immutable i_originalTokenDecimals;

    constructor(address _originalToken, string memory _name, string memory _symbol) ERC20(_name, _symbol) {

        if (_originalToken == address(0)) revert Wrapper__ZeroAddress();
        i_originalToken = IERC20(_originalToken);
        i_originalTokenDecimals = IERC20Metadata(_originalToken).decimals();
        if (i_originalTokenDecimals == 0 || i_originalTokenDecimals >= MAX_DECIMALS) revert Wrapper__InvalidDecimals();

        emit WrapperCreated(_originalToken, address(this));
    }

    /**
     * @notice Deposit original tokens into the wrapper
     * @param _amount The amount of original tokens to deposit
     */
    function deposit(uint256 _amount) external nonReentrant returns (uint256) {
        if (_amount == 0) revert Wrapper__ZeroAmount();

        uint256 _scaledAmount = _scaleUpAmount(_amount);

        _mint(msg.sender, _scaledAmount);

        i_originalToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposited(msg.sender, _amount);

        return _scaledAmount;
    }

    /**
     * @notice Withdraw original tokens from the wrapper
     * @param _amount The amount of the Wrapped assets to withdraw 18 decimals
     */
    function withdraw(uint256 _amount) external nonReentrant returns (uint256) {
        if (_amount == 0) revert Wrapper__ZeroAmount();

        uint256 _scaledAmount = _scaleDownAmount(_amount); 

        _burn(msg.sender, _amount);

        i_originalToken.safeTransfer(msg.sender, _scaledAmount);

        emit Withdrawn(msg.sender, _scaledAmount);

        return _scaledAmount;
    }


    function _scaleUpAmount(uint256 _amount) internal view returns (uint256) {
        return _amount * (10 ** (MAX_DECIMALS - i_originalTokenDecimals));
    }

    function _scaleDownAmount(uint256 _amount) internal view returns (uint256 scaledAmount) {
        scaledAmount = _amount / (10 ** (MAX_DECIMALS - i_originalTokenDecimals));
        if (scaledAmount == 0) revert Wrapper__InsufficientBalance();
    }

}