// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IGauge} from "./IGauge.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IInterestRouterV2} from "../../../../Interfaces/IInterestRouterV2.sol";

/**
 * @title CurveGaugeDistributor
 * @notice This contract is used to distribute the rewards to the curve gauge
 * @notice It is used to distribute the rewards to the curve gauge
 */
contract CurveGaugeDistributor is Ownable {

    using SafeERC20 for IERC20;

    /// @notice It is thrown when the curve gauge is address(0)
    error CurveGaugeDistributor__InvalidCurveGauge();
    /// @notice It is thrown when the feUSD token is address(0)
    error CurveGaugeDistributor__InvalidFeUSDToken();
    /// @notice It is thrown when the interest router is address(0)
    error CurveGaugeDistributor__InvalidInterestRouter();
    /// @notice It is thrown when the owner is address(0)
    error CurveGaugeDistributor__InvalidOwner();
    /// @notice It is thrown when the caller is not the interest router
    error CurveGaugeDistributor__NotInterestRouter();

    /**
     * @notice It is emitted when the curve gauge is set
     * @param _newCurveGauge The new curve gauge
     */
    event CurveGaugeSet(address indexed _newCurveGauge);
    /**
     * @notice It is emitted when the feUSD token is set
     * @param _newFeUSDToken The new feUSD token
     */
    event FeUSDTokenSet(address indexed _newFeUSDToken);
    /**
     * @notice It is emitted when the interest router is set
     * @param _newInterestRouter The new interest router
     */
    event InterestRouterSet(address indexed _newInterestRouter);
    /**
     * @notice It is emitted when the rewards are distributed
     * @param _gauge The gauge that received the rewards
     * @param _amount The amount of rewards distributed
     */
    event RewardsDistributed(address indexed _gauge, uint256 indexed _amount);
    /**
     * @notice It is emitted when the funds failed to distribute
     * @param _gauge The gauge that should have received the rewards
     * @param _amount The amount of rewards that failed to distribute
     */
    event FundsFailedToDistribute(address indexed _gauge, uint256 indexed _amount);

    /// @notice The maximum uint256 value
    uint256 public constant MAX_UINT256 = type(uint256).max;

    /// @notice The curve gauge
    address public s_curveGauge;
    /// @notice The feUSD token
    address public s_feUSDToken;
    /// @notice The interest router
    address public s_interestRouter;

    /// @notice Modifier to check if the caller is the interest router
    modifier onlyInterestRouter() {
        if (msg.sender != s_interestRouter) revert CurveGaugeDistributor__NotInterestRouter();
        _;
    }


    /**
     * @notice Constructor
     * @param _feUSDToken The feUSD token
     * @dev It should give max approval to the curve gauge
     */
    constructor(address _feUSDToken, address _owner) Ownable() {
        if (_feUSDToken == address(0)) revert CurveGaugeDistributor__InvalidFeUSDToken();
        if (_owner == address(0)) revert CurveGaugeDistributor__InvalidOwner();

        s_feUSDToken = _feUSDToken;

        _transferOwnership(_owner);

        emit FeUSDTokenSet(_feUSDToken);
    }

    /**
     * @notice It sets the interest router
     * @param _interestRouter The interest router
     * @dev It is needed for breaking deployment circular dependency
     * @dev It should be called only once
     */
    function setInterestRouterAndCurveGauge(address _interestRouter, address _curveGauge) external onlyOwner {
        if (_interestRouter == address(0)) revert CurveGaugeDistributor__InvalidInterestRouter();
        if (_curveGauge == address(0)) revert CurveGaugeDistributor__InvalidCurveGauge();
        s_interestRouter = _interestRouter;
        s_curveGauge = _curveGauge;

        IERC20(s_feUSDToken).approve(_curveGauge, MAX_UINT256);
        renounceOwnership();
        emit InterestRouterSet(_interestRouter);
        emit CurveGaugeSet(_curveGauge);
    }

    /**
     * @notice It distributes the rewards to the curve gauge
     * @dev It can be called only by the interest router
     * @dev It should not revert if the call to the gauge fails
     * @dev If the call fails it just returns the funds to the interest router
     */
    function distributeRewardsToGauge() external onlyInterestRouter {
        // We don't need to check if the balance is 0, because the interest router will revert if there are no rewards to distribute
        address _cachedFeUSDToken = s_feUSDToken;
        address _cachedCurveGauge = s_curveGauge;
        uint256 _balance = IERC20(_cachedFeUSDToken).balanceOf(address(this));


        bytes memory _callData = abi.encodeWithSelector(IGauge.deposit_reward_token.selector, _cachedFeUSDToken, _balance);

        (bool _success,) = _cachedCurveGauge.call(_callData);

        if (_success) {
            emit RewardsDistributed(_cachedCurveGauge, _balance);
            uint256 _balanceAfterSuccess = IERC20(_cachedFeUSDToken).balanceOf(address(this));
            if (_balanceAfterSuccess > 0) {
                IERC20(_cachedFeUSDToken).safeTransfer(s_interestRouter, _balanceAfterSuccess);
            }
        }else {
            IERC20(_cachedFeUSDToken).safeTransfer(s_interestRouter, _balance);
            emit FundsFailedToDistribute(_cachedCurveGauge, _balance);
        }
    }

}