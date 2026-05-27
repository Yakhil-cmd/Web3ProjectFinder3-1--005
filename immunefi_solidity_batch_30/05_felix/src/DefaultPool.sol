// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import "./Interfaces/IDefaultPool.sol";
import "./Interfaces/IAddressesRegistry.sol";
import "./Interfaces/IActivePool.sol";

/*
 * The Default Pool holds the Coll and feUSD debt (but not feUSD tokens) from liquidations that have been redistributed
 * to active troves but not yet "applied", i.e. not yet recorded on a recipient active trove's struct.
 *
 * When a trove makes an operation that applies its pending Coll and feUSD debt, its pending Coll and feUSD debt is moved
 * from the Default Pool to the Active Pool.
 */
contract DefaultPool is Initializable, IDefaultPool {
    using SafeERC20 for IERC20;

    string public constant NAME = "DefaultPool";

    IERC20 public collToken;
    address public troveManagerAddress;
    address public activePoolAddress;
    uint256 internal collBalance; // deposited Coll tracker
    uint256 internal feUSDDebt; // debt

    event CollTokenAddressChanged(address _newCollTokenAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolfeUSDDebtUpdated(uint256 _feUSDDebt);
    event DefaultPoolCollBalanceUpdated(uint256 _collBalance);

    constructor() {
        _disableInitializers();
    }

    function initialize(IAddressesRegistry _addressesRegistry) external initializer {
        collToken = _addressesRegistry.collToken();
        troveManagerAddress = address(_addressesRegistry.troveManager());
        activePoolAddress = address(_addressesRegistry.activePool());

        emit CollTokenAddressChanged(address(collToken));
        emit TroveManagerAddressChanged(troveManagerAddress);
        emit ActivePoolAddressChanged(activePoolAddress);

        // Allow funds movements between Liquity contracts
        collToken.approve(activePoolAddress, type(uint256).max);   
    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the collBalance state variable.
    *
    * Not necessarily equal to the the contract's raw Coll balance - ether can be forcibly sent to contracts.
    */
    function getCollBalance() external view override returns (uint256) {
        return collBalance;
    }

    function getfeUSDDebt() external view override returns (uint256) {
        return feUSDDebt;
    }

    // --- Pool functionality ---

    function sendCollToActivePool(uint256 _amount) external override {
        _requireCallerIsTroveManager();
        uint256 newCollBalance = collBalance - _amount;
        collBalance = newCollBalance;
        emit DefaultPoolCollBalanceUpdated(newCollBalance);

        // Send Coll to Active Pool and increase its recorded Coll balance
        IActivePool(activePoolAddress).receiveColl(_amount);
    }

    function receiveColl(uint256 _amount) external {
        _requireCallerIsActivePool();

        uint256 newCollBalance = collBalance + _amount;
        collBalance = newCollBalance;

        // Pull Coll tokens from ActivePool
        collToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit DefaultPoolCollBalanceUpdated(newCollBalance);
    }

    function increasefeUSDDebt(uint256 _amount) external override {
        _requireCallerIsTroveManager();
        feUSDDebt = feUSDDebt + _amount;
        emit DefaultPoolfeUSDDebtUpdated(feUSDDebt);
    }

    function decreasefeUSDDebt(uint256 _amount) external override {
        _requireCallerIsTroveManager();
        feUSDDebt = feUSDDebt - _amount;
        emit DefaultPoolfeUSDDebtUpdated(feUSDDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == activePoolAddress, "DefaultPool: Caller is not the ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == troveManagerAddress, "DefaultPool: Caller is not the TroveManager");
    }
}
