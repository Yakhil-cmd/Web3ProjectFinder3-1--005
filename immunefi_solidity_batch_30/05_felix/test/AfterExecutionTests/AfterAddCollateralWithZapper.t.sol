// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AfterAddCollateral} from "./AfterAddCollateral.t.sol";
import {WrapperZappers} from "../../src/Zappers/WrapperZappers.sol";
import {Wrapper} from "../../src/Misc/Wrapper.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IZapper} from "../../src/Zappers/Interfaces/IZapper.sol";
import "../../src/Dependencies/Constants.sol";
contract AfterAddCollateralWithZapper is AfterAddCollateral {
    WrapperZappers public constant WRAPPER_ZAPPER =
        WrapperZappers(0x557dE9e0C3Cc187CEe25e14325A7ef845Dad286c); // TODO: update it
    uint256 public constant BASE_EXPONENT = 10;
    uint256 public constant STANDARD_DECIMALS = 18;

    uint256 public constant AMOUNT_OF_UNDERLYING_TOKENS_FOR_USERS = 10; // Decimal agnostic
    uint256 public constant COLLATERAL_AMOUNT_FOR_TROVE_OPENING = 2; // Decimal agnostic
    uint256 public constant DEBT_AMOUNT_FOR_TROVE_OPENING = 10_000 ether;
    uint256 public constant DEBT_AMOUNT_TO_REPAY = 1_000 ether;
    uint256 public constant DEBT_AMOUNT_TO_INCREASE = 5_000 ether;
    uint256 public constant ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE =
        2 ether; // This will take into account the fees for opening the trove

    uint256 public constant AMOUNT_OF_COLLATERAL_TO_WITHDRAW = 1e7; // Decimal agnostic
    uint256 public constant AMOUNT_OF_COLLATERAL_TO_WITHDRAW_STANDARD_DECIMALS =
        1e17;
    uint256 public constant AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL = 1; // Decimal agnostic

    uint256 public amountOfUnderlyingTokensForUsers;

    address public underlyingToken;
    uint256 public underlyingTokenDecimals;

    function setUp() public override {
        super.setUp();
        _setUnderlyingTokenInfo();
        _setAmountOfUnderlyingTokensForUsers();
        _dealUnderlyingTokensToUsers();
        _giveAllApprovalToZapper();
    }

    function test_openTroveWithZapper() public {
        uint256 _bobFeUSDAmountBefore = _getFeUSDBalance(bob);

        uint256 _troveId = _openTroveWithZapper(bob);

        _assertFeUSDAndCollateralAmountAreZeroForZapper();

        uint256 _bobDebt = _getTroveDebt(_troveId, Collaterals.WBTC);
        uint256 _bobCollateral = _getTroveColl(_troveId, Collaterals.WBTC);
        assertApproxEqRel(
            _bobDebt,
            DEBT_AMOUNT_FOR_TROVE_OPENING,
            ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE,
            "Debt amount is not correct in trove"
        );
        assertEq(
            _bobCollateral,
            _scaleAmountToStandardDecimals(COLLATERAL_AMOUNT_FOR_TROVE_OPENING),
            "Collateral amount is not correct in trove"
        );

        uint256 _bobFeUSDAmountAfter = _getFeUSDBalance(bob);
        assertEq(
            _bobFeUSDAmountAfter,
            _bobFeUSDAmountBefore + DEBT_AMOUNT_FOR_TROVE_OPENING,
            "FeUSD amount is not correct after trove opening"
        );
    }

    function test_closeTroveWithZapper() public {
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        _receiveFeUSD(charlie, bob, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);

        uint256 _bobWrapperTokenBalanceBefore = _getWrapperTokenBalance(bob);

        _assertFeUSDAndCollateralAmountAreZeroForZapper();

        _closeTroveWithZapper(bob, _troveId);

        uint256 _bobTroveDebt = _getTroveDebt(_troveId, Collaterals.WBTC);
        uint256 _bobTroveColl = _getTroveColl(_troveId, Collaterals.WBTC);
        assertEq(_bobTroveDebt, 0, "Debt amount is not correct in trove");
        assertEq(_bobTroveColl, 0, "Collateral amount is not correct in trove");

        uint256 _bobUnderlyingTokenBalance = _getUnderlyingTokenBalance(bob);
        assertEq(
            _bobUnderlyingTokenBalance,
            amountOfUnderlyingTokensForUsers,
            "Underlying token balance is not correct"
        );

        uint256 _bobWrapperTokenBalanceAfter = _getWrapperTokenBalance(bob);
        assertEq(
            _bobWrapperTokenBalanceAfter,
            _bobWrapperTokenBalanceBefore,
            "Wrapper token balance is not correct"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_addCollateralWithZapper() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobUnderlyingTokenBalanceBefore = _getUnderlyingTokenBalance(
            bob
        );
        uint256 _bobTroveCollBefore = _getTroveColl(_troveId, Collaterals.WBTC);
        _addCollateralWithZapper(
            bob,
            _troveId,
            _scaleAmountToUnderlyingDecimals(
                AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL
            )
        );

        uint256 _bobUnderlyingTokenBalanceAfter = _getUnderlyingTokenBalance(
            bob
        );
        assertEq(
            _bobUnderlyingTokenBalanceAfter,
            _bobUnderlyingTokenBalanceBefore -
                _scaleAmountToUnderlyingDecimals(
                    AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL
                ),
            "Underlying token balance is not correct"
        );

        uint256 _bobTroveCollAfter = _getTroveColl(_troveId, Collaterals.WBTC);
        assertEq(
            _bobTroveCollAfter,
            _bobTroveCollBefore +
                _scaleAmountToStandardDecimals(
                    AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL
                ),
            "Collateral amount is not correct in trove"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_repayDebtWithZapper() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobFeUSDAmountBefore = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );

        _repayDebtWithZapper(bob, _troveId, DEBT_AMOUNT_TO_REPAY);

        uint256 _bobFeUSDAmountAfter = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );
        assertEq(
            _bobFeUSDAmountAfter,
            _bobFeUSDAmountBefore - DEBT_AMOUNT_TO_REPAY,
            "FeUSD amount is not correct after debt repayment"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_increaseDebtWithZapper() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobFeUSDAmountBefore = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );

        _increaseDebtWithZapper(bob, _troveId, DEBT_AMOUNT_TO_INCREASE);

        uint256 _bobFeUSDAmountAfter = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );
        assertApproxEqRel(
            _bobFeUSDAmountAfter,
            _bobFeUSDAmountBefore + DEBT_AMOUNT_TO_INCREASE,
            ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE,
            "FeUSD amount is not correct after debt increase"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_adjustTroveRepayingDebtReturnsExcedingFeUSD() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        _receiveFeUSD(charlie, bob, FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE);

        uint256 _bobDebtAmountBefore = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );

        _adjustTroveReducingDebt(bob, _troveId, _bobDebtAmountBefore);

        _assertFeUSDAndCollateralAmountAreZeroForZapper();

        uint256 _bobDebtAmountAfter = _getTroveDebt(_troveId, Collaterals.WBTC);
        assertEq(
            _bobDebtAmountAfter,
            MIN_DEBT,
            "Debt amount is not correct after debt repayment"
        );

        assertApproxEqRel(
            _getFeUSDBalance(bob),
            MIN_DEBT + FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE,
            ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE,
            "FeUSD amount is not correct after debt repayment"
        );
    }

    function test_withdrawCollToUnderlying() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobUnderlyingTokenBalanceBefore = _getUnderlyingTokenBalance(
            bob
        );

        _withdrawCollToUnderlying(
            bob,
            _troveId,
            AMOUNT_OF_COLLATERAL_TO_WITHDRAW
        );

        uint256 _bobUnderlyingTokenBalanceAfter = _getUnderlyingTokenBalance(
            bob
        );
        assertEq(
            _bobUnderlyingTokenBalanceAfter,
            _bobUnderlyingTokenBalanceBefore + AMOUNT_OF_COLLATERAL_TO_WITHDRAW,
            "Underlying token balance is not correct"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_adjustTroveIncreasingDebt() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobDebtAmountBefore = _getTroveDebt(
            _troveId,
            Collaterals.WBTC
        );
        _adjustTroveIncreasingDebt(bob, _troveId, DEBT_AMOUNT_TO_INCREASE);

        uint256 _bobDebtAmountAfter = _getTroveDebt(_troveId, Collaterals.WBTC);
        assertApproxEqRel(
            _bobDebtAmountAfter,
            _bobDebtAmountBefore + DEBT_AMOUNT_TO_INCREASE,
            ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE,
            "Debt amount is not correct after debt increase"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function test_adjustTroveReducingColl() public {
        _openTroveWithZapperGeneral(alice);
        _assertFeUSDAndCollateralAmountAreZeroForZapper();
        uint256 _troveId = _openTroveWithZapperGeneral(bob);

        uint256 _bobCollAmountBefore = _getTroveColl(_troveId, Collaterals.WBTC);

        _adjustTroveReducingColl(bob, _troveId, AMOUNT_OF_COLLATERAL_TO_WITHDRAW);

        uint256 _bobCollAmountAfter = _getTroveColl(_troveId, Collaterals.WBTC);
        assertEq(
            _bobCollAmountAfter,
            _bobCollAmountBefore -
            AMOUNT_OF_COLLATERAL_TO_WITHDRAW_STANDARD_DECIMALS ,
            "Coll amount is not correct after debt increase"
        );

        _assertFeUSDAndCollateralAmountAreZeroForZapper();
    }

    function _setUnderlyingTokenInfo() internal {
        address _collateralToken = WRAPPER_ZAPPER.collateralToken();
        _setUnderlyingToken(_collateralToken);
        _setUnderlyingTokenDecimals(_collateralToken);
    }

    function _setUnderlyingToken(address _collateralToken) internal {
        underlyingToken = address(Wrapper(_collateralToken).i_originalToken());
    }

    function _setUnderlyingTokenDecimals(address _collateralToken) internal {
        underlyingTokenDecimals = Wrapper(_collateralToken)
            .i_originalTokenDecimals();
    }

    function _setAmountOfUnderlyingTokensForUsers() internal {
        amountOfUnderlyingTokensForUsers =
            AMOUNT_OF_UNDERLYING_TOKENS_FOR_USERS *
            (BASE_EXPONENT ** underlyingTokenDecimals);
    }

    function _dealUnderlyingTokensToUsers() internal {
        _dealTokens(underlyingToken, bob, amountOfUnderlyingTokensForUsers);
        _dealTokens(underlyingToken, alice, amountOfUnderlyingTokensForUsers);
        _dealTokens(underlyingToken, charlie, amountOfUnderlyingTokensForUsers);
    }

    function _giveAllApprovalToZapper() internal {
        _approveZapper(underlyingToken, bob);
        _approveZapper(underlyingToken, alice);
        _approveZapper(underlyingToken, charlie);
    }

    function _approveZapper(address _token, address _user) internal {
        vm.startPrank(_user);
        IERC20(_token).approve(address(WRAPPER_ZAPPER), MAX_UINT256);
        vm.stopPrank();
    }

    function _openTroveWithZapper(
        address _user
    ) internal returns (uint256 _troveId) {
        vm.startPrank(_user);
        IZapper.OpenTroveParams memory _params = _getOpenTroveParams(_user);
        _troveId = WRAPPER_ZAPPER.openTroveWithUnderlying(_params);
        vm.stopPrank();
    }

    function _getOpenTroveParams(
        address _user
    ) internal returns (IZapper.OpenTroveParams memory _params) {
        _params = IZapper.OpenTroveParams({
            owner: _user,
            ownerIndex: ++ownerIndex,
            collAmount: _scaleAmountToUnderlyingDecimals(
                COLLATERAL_AMOUNT_FOR_TROVE_OPENING
            ),
            feUSDAmount: DEBT_AMOUNT_FOR_TROVE_OPENING,
            upperHint: STANDARD_HINT,
            lowerHint: STANDARD_HINT,
            annualInterestRate: INETEREST_RATE,
            batchManager: address(0),
            maxUpfrontFee: MAX_UINT256,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
    }

    function _openTroveWithZapperGeneral(
        address _user
    ) internal returns (uint256 _troveId) {
        uint256 _userFeUSDAmountBefore = _getFeUSDBalance(_user);

        _troveId = _openTroveWithZapper(_user);

        uint256 _userDebt = _getTroveDebt(_troveId, Collaterals.WBTC);
        uint256 _userCollateral = _getTroveColl(_troveId, Collaterals.WBTC);
        assertApproxEqRel(
            _userDebt,
            DEBT_AMOUNT_FOR_TROVE_OPENING,
            ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE,
            "Debt amount is not correct in trove"
        );
        assertEq(
            _userCollateral,
            _scaleAmountToStandardDecimals(COLLATERAL_AMOUNT_FOR_TROVE_OPENING),
            "Collateral amount is not correct in trove"
        );

        uint256 _userFeUSDAmountAfter = _getFeUSDBalance(_user);
        assertEq(
            _userFeUSDAmountAfter,
            _userFeUSDAmountBefore + DEBT_AMOUNT_FOR_TROVE_OPENING,
            "FeUSD amount is not correct after trove opening"
        );
    }

    function _closeTroveWithZapper(address _user, uint256 _troveId) internal {
        vm.startPrank(_user);
        _giveFeUSDApprovalIfNeeded(_user, address(WRAPPER_ZAPPER));
        WRAPPER_ZAPPER.closeTroveToUnderlying(_troveId);
        vm.stopPrank();
    }

    function _addCollateralWithZapper(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        WRAPPER_ZAPPER.addCollateralFromUnderlying(_troveId, _amount);
        vm.stopPrank();
    }

    function _adjustTroveReducingDebt(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        _giveFeUSDApprovalIfNeeded(_user, address(WRAPPER_ZAPPER));
        WRAPPER_ZAPPER.adjustTroveWithUnderlying(
            _troveId,
            0,
            false,
            _amount,
            false,
            MAX_UINT256
        );
        vm.stopPrank();
    }

    function _adjustTroveIncreasingDebt(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        WRAPPER_ZAPPER.adjustTroveWithUnderlying(
            _troveId,
            0,
            false,
            _amount,
            true,
            MAX_UINT256
        );
        vm.stopPrank();
    }

    function _withdrawCollToUnderlying(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        WRAPPER_ZAPPER.withdrawCollToUnderlying(_troveId, _amount);
        vm.stopPrank();
    }

    function _adjustTroveReducingColl(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);

        WRAPPER_ZAPPER.adjustTroveWithUnderlying(
            _troveId,
            _amount,
            false,
            0,
            false,
            MAX_UINT256
        );
        vm.stopPrank();
    }

    function _repayDebtWithZapper(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        _giveFeUSDApprovalIfNeeded(_user, address(WRAPPER_ZAPPER));
        WRAPPER_ZAPPER.repayfeUSD(_troveId, _amount);
        vm.stopPrank();
    }

    function _increaseDebtWithZapper(
        address _user,
        uint256 _troveId,
        uint256 _amount
    ) internal {
        vm.startPrank(_user);
        WRAPPER_ZAPPER.withdrawfeUSD(_troveId, _amount, MAX_UINT256);
        vm.stopPrank();
    }

    function _scaleAmountToUnderlyingDecimals(
        uint256 _amount
    ) internal view returns (uint256) {
        return _amount * (BASE_EXPONENT ** underlyingTokenDecimals);
    }

    function _scaleAmountToStandardDecimals(
        uint256 _amount
    ) internal view returns (uint256) {
        return _amount * (BASE_EXPONENT ** STANDARD_DECIMALS);
    }

    function _getUnderlyingTokenBalance(
        address _user
    ) internal view returns (uint256) {
        return IERC20(underlyingToken).balanceOf(_user);
    }

    function _getWrapperTokenBalance(
        address _user
    ) internal view returns (uint256) {
        return IERC20(_getCollateralAddress(Collaterals.WBTC)).balanceOf(_user);
    }

    function _assertFeUSDAndCollateralAmountAreZeroForZapper() internal {
        uint256 _zapperUnderlyingTokenBalance = _getUnderlyingTokenBalance(
            address(WRAPPER_ZAPPER)
        );
        assertEq(
            _zapperUnderlyingTokenBalance,
            0,
            "Underlying token balance is not correct"
        );

        uint256 _zapperWrapperTokenBalance = _getWrapperTokenBalance(
            address(WRAPPER_ZAPPER)
        );
        assertEq(
            _zapperWrapperTokenBalance,
            0,
            "Wrapper token balance is not correct"
        );

        uint256 _zapperFeUSDBalance = _getFeUSDBalance(address(WRAPPER_ZAPPER));
        assertEq(_zapperFeUSDBalance, 0, "FeUSD balance is not correct");
    }
}
