// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../../Interfaces/IfeUSDToken.sol";
import "./Curve/ICurvePool.sol";
import "../../Interfaces/IExchange.sol";

contract CurveExchange is IExchange {
    using SafeERC20 for IERC20;

    IERC20 public immutable collToken;
    IfeUSDToken public immutable feUSDToken;
    ICurvePool public immutable curvePool;
    uint256 public immutable COLL_TOKEN_INDEX;
    uint256 public immutable feUSD_TOKEN_INDEX;

    constructor(
        IERC20 _collToken,
        IfeUSDToken _feUSDToken,
        ICurvePool _curvePool,
        uint256 _collIndex,
        uint256 _feUSDIndex
    ) {
        collToken = _collToken;
        feUSDToken = _feUSDToken;
        curvePool = _curvePool;
        COLL_TOKEN_INDEX = _collIndex;
        feUSD_TOKEN_INDEX = _feUSDIndex;
    }

    function swapFromfeUSD(uint256 _feUSDAmount, uint256 _minCollAmount) external {
        ICurvePool curvePoolCached = curvePool;
        uint256 initialfeUSDBalance = feUSDToken.balanceOf(address(this));
        feUSDToken.transferFrom(msg.sender, address(this), _feUSDAmount);
        feUSDToken.approve(address(curvePoolCached), _feUSDAmount);

        uint256 output = curvePoolCached.exchange(feUSD_TOKEN_INDEX, COLL_TOKEN_INDEX, _feUSDAmount, _minCollAmount);
        collToken.safeTransfer(msg.sender, output);

        uint256 currentfeUSDBalance = feUSDToken.balanceOf(address(this));
        if (currentfeUSDBalance > initialfeUSDBalance) {
            feUSDToken.transfer(msg.sender, currentfeUSDBalance - initialfeUSDBalance);
        }
    }

    function swapTofeUSD(uint256 _collAmount, uint256 _minfeUSDAmount) external returns (uint256) {
        ICurvePool curvePoolCached = curvePool;
        uint256 initialCollBalance = collToken.balanceOf(address(this));
        collToken.safeTransferFrom(msg.sender, address(this), _collAmount);
        collToken.approve(address(curvePoolCached), _collAmount);

        uint256 output = curvePoolCached.exchange(COLL_TOKEN_INDEX, feUSD_TOKEN_INDEX, _collAmount, _minfeUSDAmount);
        feUSDToken.transfer(msg.sender, output);

        uint256 currentCollBalance = collToken.balanceOf(address(this));
        if (currentCollBalance > initialCollBalance) {
            collToken.transfer(msg.sender, currentCollBalance - initialCollBalance);
        }

        return output;
    }
}
