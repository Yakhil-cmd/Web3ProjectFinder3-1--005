// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "../Interfaces/IAddressesRegistry.sol";
import "./LiquityBaseInit.sol";

/**
 * @notice This library initializes the TroveManager contract.
 * @dev The following inheritance order is required for the initialization scheme to work:
 * Initializable, LiquityBase
 * If the order is changed, the slot constants should be updated accordingly
 */
library TroveManagerInit {
    /// @dev on every storage variable change, the slot number must be updated accordingly
    /// @notice TroveManager storage slots
    uint256 constant TROVE_NFT_SLOT = 53;
    uint256 constant BORROWER_OPERATIONS_SLOT = 54;
    uint256 constant STABILITY_POOL_SLOT = 55;
    uint256 constant GAS_POOL_SLOT = 56;
    uint256 constant COLL_SURPLUS_POOL_SLOT = 57;
    uint256 constant FEUSD_TOKEN_SLOT = 58;
    uint256 constant SORTED_TROVES_SLOT = 59;
    uint256 constant COLLATERAL_REGISTRY_SLOT = 60;
    uint256 constant WHYPE_ADDRESS_SLOT = 61;
    uint256 constant CCR_SLOT = 62;
    uint256 constant MCR_SLOT = 63;
    uint256 constant SCR_SLOT = 64;
    uint256 constant LIQUIDATION_PENALTY_SP_SLOT = 65;
    uint256 constant LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT = 66;

    /// @notice TroveManager events
    event TroveNFTAddressChanged(address _newTroveNFTAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event feUSDTokenAddressChanged(address _newfeUSDTokenAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event CollateralRegistryAddressChanged(address _collateralRegistryAddress);

    function initialize(IAddressesRegistry _addressesRegistry) external {
        /// @notice Initialize LiquityBase
        LiquityBaseInit.initialize(_addressesRegistry);

        /// @notice Initialize TroveManager
        {
            uint256 CCR = _addressesRegistry.CCR();
            uint256 MCR = _addressesRegistry.MCR();
            uint256 SCR = _addressesRegistry.SCR();
            uint256 LIQUIDATION_PENALTY_SP = _addressesRegistry.LIQUIDATION_PENALTY_SP();
            uint256 LIQUIDATION_PENALTY_REDISTRIBUTION = _addressesRegistry.LIQUIDATION_PENALTY_REDISTRIBUTION();

            address troveNFT = address(_addressesRegistry.troveNFT());
            address borrowerOperations = address(_addressesRegistry.borrowerOperations());
            address stabilityPool = address(_addressesRegistry.stabilityPool());
            address gasPoolAddress = address(_addressesRegistry.gasPoolAddress());
            address collSurplusPool = address(_addressesRegistry.collSurplusPool());
            address feUSDToken = address(_addressesRegistry.feUSDToken());
            address sortedTroves = address(_addressesRegistry.sortedTroves());
            address WHYPE = address(_addressesRegistry.WHYPE());
            address collateralRegistry = address(_addressesRegistry.collateralRegistry());


            assembly {
                sstore(CCR_SLOT, CCR)
                sstore(MCR_SLOT, MCR)
                sstore(SCR_SLOT, SCR)
                sstore(LIQUIDATION_PENALTY_SP_SLOT, LIQUIDATION_PENALTY_SP)
                sstore(LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT, LIQUIDATION_PENALTY_REDISTRIBUTION)
                sstore(TROVE_NFT_SLOT, troveNFT)
                sstore(BORROWER_OPERATIONS_SLOT, borrowerOperations)
                sstore(STABILITY_POOL_SLOT, stabilityPool)
                sstore(GAS_POOL_SLOT, gasPoolAddress)
                sstore(COLL_SURPLUS_POOL_SLOT, collSurplusPool)
                sstore(FEUSD_TOKEN_SLOT, feUSDToken)
                sstore(SORTED_TROVES_SLOT, sortedTroves)
                sstore(WHYPE_ADDRESS_SLOT, WHYPE)
                sstore(COLLATERAL_REGISTRY_SLOT, collateralRegistry)
            }
            
            emit TroveNFTAddressChanged(address(troveNFT));
            emit BorrowerOperationsAddressChanged(address(borrowerOperations));
            emit StabilityPoolAddressChanged(address(stabilityPool));
            emit GasPoolAddressChanged(gasPoolAddress);
            emit CollSurplusPoolAddressChanged(address(collSurplusPool));
            emit feUSDTokenAddressChanged(address(feUSDToken));
            emit SortedTrovesAddressChanged(address(sortedTroves));
            emit CollateralRegistryAddressChanged(address(collateralRegistry));
        }
    }
}