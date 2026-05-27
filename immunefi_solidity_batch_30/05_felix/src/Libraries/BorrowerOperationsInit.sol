// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../Interfaces/IAddressesRegistry.sol";
import "./LiquityBaseInit.sol";

/**
 * @notice This library initializes the BorrowerOperations contract.
 * @dev The following inheritance order is required for the initialization scheme to work:
 * Initializable, LiquityBase, AddRemoveManagers
 * If the order is changed, the slot constants should be updated accordingly
 */
library BorrowerOperationsInit {
    /// @dev on every storage variable change, the slot number must be updated accordingly
    /// @notice AddRemoveManager storage slots
    uint256 constant TROVE_NFT_SLOT = 53;

    /// @notice TroveManager storage slots
    uint256 constant COLL_TOKEN_SLOT = 106;
    uint256 constant TROVE_MANAGER_SLOT = 107;
    uint256 constant GAS_POOL_ADDRESS_SLOT = 108;
    uint256 constant COLL_SURPLUS_POOL_SLOT = 109;
    uint256 constant FEUSD_TOKEN_SLOT = 110;
    uint256 constant SORTED_TROVES_SLOT = 111;
    uint256 constant WHYPE_SLOT = 112;
    uint256 constant CCR_SLOT = 113;
    uint256 constant SCR_SLOT = 114;
    uint256 constant MCR_SLOT = 116;
    uint256 constant MAX_CAP_SLOT = 117;

    /// @notice AddRemoveManager events
    event TroveNFTAddressChanged(address _newTroveNFTAddress);

    /// @notice BorrowerOperations events
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event feUSDTokenAddressChanged(address _feUSDTokenAddress);

    function initialize(IAddressesRegistry _addressesRegistry) external {
        /// @notice Initialize LiquityBase
        LiquityBaseInit.initialize(_addressesRegistry);

        /// @notice Initialize AddRemoveManagers
        {
            address troveNFT = address(_addressesRegistry.troveNFT());
            assembly {
                sstore(TROVE_NFT_SLOT, troveNFT)
            }
            emit TroveNFTAddressChanged(troveNFT);
        }

        /// @notice Initialize BorrowerOperations
        {
            address collToken = address(_addressesRegistry.collToken());
            address WHYPE = address(_addressesRegistry.WHYPE());
            uint256 CCR = _addressesRegistry.CCR();
            uint256 SCR = _addressesRegistry.SCR();
            uint256 MCR = _addressesRegistry.MCR();
            address troveManager = address(_addressesRegistry.troveManager());
            address gasPoolAddress = address(_addressesRegistry.gasPoolAddress());
            address collSurplusPool = address(_addressesRegistry.collSurplusPool());
            address sortedTroves = address(_addressesRegistry.sortedTroves());
            address feUSDToken = address(_addressesRegistry.feUSDToken());
            uint256 maxDebtCap = _addressesRegistry.maxDebtCap();

            assembly {
                sstore(COLL_TOKEN_SLOT, collToken)
                sstore(WHYPE_SLOT, WHYPE)
                sstore(CCR_SLOT, CCR)
                sstore(SCR_SLOT, SCR)
                sstore(MCR_SLOT, MCR)
                sstore(TROVE_MANAGER_SLOT, troveManager)
                sstore(GAS_POOL_ADDRESS_SLOT, gasPoolAddress)
                sstore(COLL_SURPLUS_POOL_SLOT, collSurplusPool)
                sstore(SORTED_TROVES_SLOT, sortedTroves)
                sstore(FEUSD_TOKEN_SLOT, feUSDToken)
                sstore(MAX_CAP_SLOT, maxDebtCap)
            }

            emit TroveManagerAddressChanged(troveManager);
            emit GasPoolAddressChanged(gasPoolAddress);
            emit CollSurplusPoolAddressChanged(collSurplusPool);
            emit SortedTrovesAddressChanged(sortedTroves);
            emit feUSDTokenAddressChanged(feUSDToken);

            address activePool = address(_addressesRegistry.activePool());
            IERC20Metadata(collToken).approve(activePool, type(uint256).max);
        }
    }
}