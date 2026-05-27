// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "../Interfaces/IAddressesRegistry.sol";
/**
 * @notice This library initializes the LiquityBase contract.
 */
library LiquityBaseInit {
    /// @dev on every storage variable change, the slot number must be updated accordingly
    /// @notice LiquityBase storage slots

    /// @dev Offset in bytes within the slot from right to left
    uint256 constant ACTIVE_POOL_OFFSET = 2;
    uint256 constant ACTIVE_POOL_SLOT = 0;
    uint256 constant DEFAULT_POOL_SLOT = 1;
    uint256 constant PRICE_FEED_SLOT = 2;

    /// @notice LiquityBase events
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);

    function initialize(IAddressesRegistry _addressesRegistry) external {
        address activePool = address(_addressesRegistry.activePool());
        address defaultPool = address(_addressesRegistry.defaultPool());
        address priceFeed = address(_addressesRegistry.priceFeed());

        assembly {
            /// @dev Storage variables are written from right to left
            /// Thus the active pool address is located at 2 bytes offset from the right in the slot
            let ptr := sload(ACTIVE_POOL_SLOT)
            let mask := not(shl(mul(ACTIVE_POOL_OFFSET, 8), sub(shl(160, 1), 1)))
            ptr := and(ptr, mask)
            ptr := or(ptr, shl(mul(ACTIVE_POOL_OFFSET, 8), activePool))

            sstore(ACTIVE_POOL_SLOT, ptr)
            sstore(DEFAULT_POOL_SLOT, defaultPool)
            sstore(PRICE_FEED_SLOT, priceFeed)
        }

        emit ActivePoolAddressChanged(activePool);
        emit DefaultPoolAddressChanged(defaultPool);
        emit PriceFeedAddressChanged(priceFeed);
    }
}