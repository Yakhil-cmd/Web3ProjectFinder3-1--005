// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IOnChainRouting
 *
 * @author The Haven1 Development Team
 *
 * @notice The interface for the OnChainRouting contract.
 */
interface IOnChainRouting {
    /* ERRORS
    ==================================================*/
    error OnChainRouting__InvalidAddress();
    error OnChainRouting__InvalidBaseTokens();
    error OnChainRouting__BaseTokenAlreadyExists();
    error OnChainRouting__BaseTokenDoesNotExist();
    error OnChainRouting__MaxBaseTokensReached();

    /* EVENTS
    ==================================================*/
    event SwapRouterUpdated(address indexed swapRouter);
    event QuoterUpdated(address indexed quoter);
    event BaseTokenAdded(address indexed baseToken);
    event BaseTokenRemoved(address indexed baseToken);

    /* FUNCTIONS
    ==================================================*/

    /**
     * @notice Given a swap path, an amount of the inbound asset, and a minimum
     * amount of the outbound asset, executes a swap and sends the outbound assets
     * to the recipient.
     *
     * @param path          The swap path.
     * @param amountIn      The amount of the inbound asset.
     * @param amountOutMin  The minimum amount of the outbound asset.
     * @param recipient     The destination address of the outbound asset.
     *
     * @return The amount of the outbound asset received after the swap.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     *
     * The swap path is a sequence of `tokenAddress`, `fee`, and `tokenAddress`.
     */
    function executeSwap(
        bytes memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        address recipient
    ) external payable returns (uint256);

    /**
     * @notice Given an inbound asset, an outbound asset, and an amount of the
     * inbound asset, calculates a route for the swap using the QuoterV2 contract,
     * executes the swap and sents the outbound assets to the recipient.
     *
     * @param tokenIn       The inbound asset.
     * @param tokenOut      The outbound asset.
     * @param amountIn      The amount of the inbound asset.
     * @param recipient     The destination address of the outbound asset.
     *
     * @return The amount of the outbound asset received after the swap.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `OPERATOR_ROLE`.
     */
    function getRouteAndSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address recipient
    ) external payable returns (uint256);

    /**
     * @notice Sets the Swap Router address.
     *
     * @param addr The new Swap Router address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address cannot be the zero address.
     */
    function setSwapRouter(address addr) external;

    /**
     * @notice Sets the Quoter address.
     *
     * @param addr The new Quoter address.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The new address cannot be the zero address.
     */
    function setQuoter(address addr) external;

    /**
     * @notice Adds an address to the list of base tokens.
     *
     * @param addr The address to add.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The address cannot be the zero address.
     * -    The address must not already exist in the `baseTokens` array.
     * -    The `baseTokens` array must not be at capacity (uint8.max).
     *
     * Emits a `BaseTokenAdded` event.
     */
    function addBaseToken(address addr) external;

    /**
     * @notice Removes an address from the list of base tokens.
     *
     * @param addr The address to remove.
     *
     * @dev Requirements:
     * -    Only callable by an account with the role: `DEFAULT_ADMIN_ROLE`.
     * -    The `baseTokens` array must always have at least one item populated.
     * -    The address to remove must exist in the `baseTokens` array.
     *
     * The order of addresses within the `baseTokens` array _is not_ maintained.
     *
     * Emits a `BaseTokenRemoved` event.
     */
    function removeBaseToken(address addr) external;

    /**
     * @notice Given an inbound asset, an outbound asset, and an amount of the
     * inbound asset, calculates a route for the swap using the QuoterV2,
     * contract, returning the expected amount of outbound tokens and the path.
     *
     * @param tokenIn   The inbound asset.
     * @param tokenOut  The outbound asset.
     * @param amountIn  The amount of the inbound asset.
     *
     * @return The expected amount of the oubound asset.
     * @return The swap path.
     */
    function getRoute(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256, bytes memory);

    /**
     * @notice Returns the list of base tokens used to calculate paths.
     *
     * @return The list of base tokens used to calculate paths.
     */
    function getBaseTokens() external view returns (address[] memory);
}
