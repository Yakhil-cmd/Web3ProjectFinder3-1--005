// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ISwapRouter } from "../vendor/uniswapV3/interfaces/v3-periphery/ISwapRouter.sol";
import { IQuoterV2 } from "../vendor/uniswapV3/interfaces/v3-periphery/IQuoterV2.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import { NetworkGuardian } from "../network-guardian/NetworkGuardian.sol";
import { INetworkGuardian } from "../network-guardian/interfaces/INetworkGuardian.sol";
import { Address } from "./Address.sol";
import { IOnChainRouting } from "./interfaces/IOnChainRouting.sol";
import { IVersion } from "../utils/interfaces/IVersion.sol";
import { Semver } from "../utils/Semver.sol";

/**
 * @title OnChainRouting
 *
 * @author The Haven1 Development Team
 *
 * @notice This contract facilitates on-chain token swaps for BackedHRC20 tokens.
 * It provides routing logic to find swap paths and executes swaps via the
 * SwapRouter.
 *
 * Only accounts with the role `OPERATOR_ROLE` can execute swaps using this
 * contract.
 *
 * This contract supports multi-hop swaps using a set of base tokens, and uses
 * the QuoterV2 contract to estimate swap amounts and paths.
 *
 * The SwapRouter, QuoterV2, and base token list can be updated by an account
 * with the role: `DEFAULT_ADMIN_ROLE`.
 */
contract OnChainRouting is NetworkGuardian, IOnChainRouting, IVersion {
    /* TYPE DECLARATIONS
    ==================================================*/
    using Address for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* STATE
    ==================================================*/

    /**
     * @dev The current version of the contract, packed into a uint64 as:
     * `[32-bit major | 16-bit minor | 16-bit patch]`.
     */
    uint64 private constant VERSION = uint64(0x0100000000); // Semver.encode(1, 0, 0)

    /**
     * @notice Represents the 0.05% fee tier.
     */
    uint24 private constant FEE_TIER_1 = 500;

    /**
     * @notice Represents the 0.30% fee tier.
     */
    uint24 private constant FEE_TIER_2 = 3000;

    /**
     * @notice Represents the 1.00% fee tier.
     */
    uint24 private constant FEE_TIER_3 = 10_000;

    /**
     * @notice The SwapRouter contract.
     */
    ISwapRouter public swapRouter;

    /**
     * @notice The QuoterV2 contract.
     */
    IQuoterV2 public quoter;

    /**
     * @notice An array of tokens used to help calculate swap paths.
     */
    address[] public baseTokens;

    /* FUNCTIONS
    ==================================================*/

    /* Init
    ========================================*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     *
     * @param swapRouter_           The SwapRouter contract address.
     * @param quoter_               The QuoterV2 contract address.
     * @param baseTokens_           An array of the most swapped tokens on the chain.
     * @param association_          The Haven1 Association address.
     * @param guardianController_   The Network Guardian Controller address.
     */
    function initialize(
        address swapRouter_,
        address quoter_,
        address[] memory baseTokens_,
        address association_,
        address guardianController_
    ) external initializer {
        swapRouter_.assertNotZero();
        quoter_.assertNotZero();

        uint256 nTokens = baseTokens_.length;
        if (nTokens == 0) {
            revert OnChainRouting__InvalidBaseTokens();
        }

        for (uint256 i; i < nTokens; ) {
            baseTokens_[i].assertNotZero();

            unchecked {
                ++i;
            }
        }

        __NetworkGuardian_init(association_, guardianController_);

        swapRouter = ISwapRouter(swapRouter_);
        quoter = IQuoterV2(quoter_);
        baseTokens = baseTokens_;
    }

    /* External
    ========================================*/

    /**
     * @inheritdoc IOnChainRouting
     */
    function executeSwap(
        bytes memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        address recipient
    ) external payable onlyRole(OPERATOR_ROLE) returns (uint256) {
        return _executeSwap(path, amountIn, amountOutMin, recipient);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function getRouteAndSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address recipient
    ) external payable onlyRole(OPERATOR_ROLE) returns (uint256) {
        (uint256 amountOutExpected, bytes memory path) = _getRoute(
            tokenIn,
            tokenOut,
            amountIn
        );

        if (amountOutExpected == 0) {
            return 0;
        }

        return _executeSwap(path, amountIn, amountOutExpected, recipient);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function setSwapRouter(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();
        swapRouter = ISwapRouter(addr);
        emit SwapRouterUpdated(addr);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function setQuoter(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();
        quoter = IQuoterV2(addr);
        emit QuoterUpdated(addr);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function addBaseToken(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        addr.assertNotZero();

        if (_isBaseToken(addr)) {
            revert OnChainRouting__BaseTokenAlreadyExists();
        }

        if (baseTokens.length == type(uint8).max) {
            revert OnChainRouting__MaxBaseTokensReached();
        }

        baseTokens.push(addr);
        emit BaseTokenAdded(addr);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function removeBaseToken(
        address baseToken_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (baseTokens.length < 2) {
            revert OnChainRouting__InvalidBaseTokens();
        }

        uint256 index = _indexOfTokenExn(baseToken_);
        baseTokens[index] = baseTokens[baseTokens.length - 1];
        baseTokens.pop();

        emit BaseTokenRemoved(baseToken_);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function getRoute(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256, bytes memory) {
        return _getRoute(tokenIn, tokenOut, amountIn);
    }

    /**
     * @inheritdoc IOnChainRouting
     */
    function getBaseTokens() external view returns (address[] memory) {
        return baseTokens;
    }

    /**
     * @inheritdoc IVersion
     */
    function version() external pure returns (uint64) {
        return VERSION;
    }

    /**
     * @inheritdoc IVersion
     */
    function versionDecoded() external pure returns (uint32, uint16, uint16) {
        return Semver.decode(VERSION);
    }

    /* Public
    ========================================*/

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(NetworkGuardian) returns (bool) {
        return
            interfaceId == type(IOnChainRouting).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* Private
    ========================================*/
    /**
     * @notice Given an inbound asset, an outbound asset, and an amount of the
     * inbound asset, calculates a route for the swap using the QuoterV2,
     * contract, returning the expected amount of outbound tokens and the path.
     *
     * @param tokenIn   The inbound asset.
     * @param tokenOut  The outbound asset.
     * @param amountIn  The amount of the inbound asset.
     *
     * @return The expected amount of oubound tokens
     * @return The swap path.
     */
    function _getRoute(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private returns (uint256, bytes memory) {
        // Check a single (direct) swap for all the fee tiers.
        (uint24 feeSingle, uint256 outSingle) = _calcFeeTierSingle(
            tokenIn,
            tokenOut,
            amountIn
        );

        // Check a multi (two) hop swap.
        (bytes memory path, uint256 outPath) = _calcFeeTierMulti(
            tokenIn,
            tokenOut,
            amountIn
        );

        if (outSingle > outPath) {
            return (outSingle, abi.encodePacked(tokenIn, feeSingle, tokenOut));
        }

        if (outPath == 0) {
            path = bytes("");
        }

        return (outPath, path);
    }

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
     * @dev The swap path is a sequence of `tokenAddress`, `fee`, and
     * `tokenAddress`.
     */
    function _executeSwap(
        bytes memory path,
        uint256 amountIn,
        uint256 amountOutMin,
        address recipient
    ) private returns (uint256) {
        address tokenIn;
        assembly {
            // Load the first 32 bytes of the path (skipping the length field).
            let data := mload(add(path, 0x20))

            // The tokenIn is the upper 20 bytes, so we need to shift right by
            // 12 bytes (96 bits / 0x60).
            tokenIn := shr(0x60, data)
        }

        IERC20Upgradeable(tokenIn).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        IERC20Upgradeable(tokenIn).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: path,
                recipient: recipient,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin
            });

        // Execute the swap and return the amountOut.
        return swapRouter.exactInput{ value: msg.value }(params);
    }

    /**
     * @notice For a given inbound asset, outbound asset, and an amount of the
     * inbound asset, obtains a quote for a single-route swap against each of
     * the fee tiers. The quote with the highest amount of tokens out is
     * returned as (fee tier, amount out).
     *
     * @param tokenIn   The inbound asset.
     * @param tokenOut  The outbound asset.
     * @param amountIn  The amount of the inbound asset.
     *
     * @return The most favourable fee tier.
     * @return The amount of outbound tokens.
     */
    function _calcFeeTierSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private returns (uint24, uint256) {
        uint256 out1 = _quoteSingle(tokenIn, tokenOut, FEE_TIER_1, amountIn);
        uint256 out2 = _quoteSingle(tokenIn, tokenOut, FEE_TIER_2, amountIn);
        uint256 out3 = _quoteSingle(tokenIn, tokenOut, FEE_TIER_3, amountIn);

        if (out1 > out2 && out1 > out3) {
            return (FEE_TIER_1, out1);
        }

        if (out2 > out3) {
            return (FEE_TIER_2, out2);
        }

        return (FEE_TIER_3, out3);
    }

    /**
     * @notice Computes a swap path and expected output amount for a multi-hop
     * (two hop) swap using intermediary base tokens.
     *
     * @param tokenIn   The inbound asset.
     * @param tokenOut  The outbound asset.
     * @param amountIn  The amount of the inbound asset.
     *
     * @return path         The encoded swap path.
     * @return amountOut    The output amount obtained from the selected path.
     *
     * @dev The function iterates over `baseTokens`, attempting to find the best
     * swap route from `tokenIn` to `tokenOut` via a single intermediary base
     * token. It selects the route that yields the highest output amount.
     */
    function _calcFeeTierMulti(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private returns (bytes memory path, uint256 amountOut) {
        uint8 n = uint8(baseTokens.length);

        for (uint8 i; i < n; ) {
            address baseToken = baseTokens[i];

            // Skip this iteration if the base token is the same as the tokenIn
            // or the tokenOut.
            if (baseToken == tokenIn || baseToken == tokenOut) {
                unchecked {
                    ++i;
                }
                continue;
            }

            // Quote to swap from tokenIn to the base token first.
            (uint24 feeTierBase, uint256 outBase) = _calcFeeTierSingle(
                tokenIn,
                baseToken,
                amountIn
            );

            // Quote to swap from the base token to tokenOut.
            (uint24 feeTierTokenOut, uint256 outFinal) = _calcFeeTierSingle(
                baseToken,
                tokenOut,
                outBase
            );

            // If the final output amount is the most favourable of the quotes
            // received so far, create the path associated path.
            if (outFinal > amountOut) {
                // Create the swap path for the V3 Router.
                path = abi.encodePacked(
                    tokenIn,
                    feeTierBase,
                    baseToken,
                    feeTierTokenOut,
                    tokenOut
                );

                amountOut = outFinal;
            }

            unchecked {
                ++i;
            }
        }

        return (path, amountOut);
    }

    /**
     * @notice Retrieves a quote for a single-hop swap.
     *
     * This function calls the QuoterV2 contract to estimate the output amount
     * when swapping `amountIn` of `tokenIn` for `tokenOut` at a given `fee` tier.
     * If the quote call fails, it returns `0` as a fallback.
     *
     * @param tokenIn   The inbound asset.
     * @param tokenOut  The outbound asset.
     * @param fee       The fee tier for the Uniswap V3 pool.
     * @param amountIn  The amount of the inbound asset.
     *
     * @return The estimated output amount of `tokenOut`, or `0` if the quote
     * fails.
     */
    function _quoteSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn
    ) private returns (uint256) {
        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2
            .QuoteExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                amountIn: amountIn,
                fee: fee,
                sqrtPriceLimitX96: 0
            });

        try quoter.quoteExactInputSingle(params) returns (
            uint256 amountOut,
            uint160,
            uint32,
            uint256
        ) {
            return amountOut;
        } catch {
            return 0;
        }
    }

    /**
     * @notice Returns true if the `token` exists in the `baseTokens` array,
     * false otherwise.
     *
     * @param token The address to locate in the array.
     *
     * @return True if the `token` exists in the `baseTokens` array, false otherwise.
     */
    function _isBaseToken(address token) private view returns (bool) {
        uint256 n = baseTokens.length;

        for (uint256 i; i < n; ) {
            if (token == baseTokens[i]) return true;

            unchecked {
                ++i;
            }
        }

        return false;
    }

    /**
     * @notice Finds the index of a specified `token` address in the `baseTokens`
     * array. Reverts if the token is not found.
     *
     * @param token The address to locate in the array.
     *
     * @return The index of `token` in `baseTokens`.
     */
    function _indexOfTokenExn(address token) private view returns (uint256) {
        uint256 n = baseTokens.length;

        for (uint256 i; i < n; ) {
            if (token == baseTokens[i]) return i;

            unchecked {
                ++i;
            }
        }

        revert OnChainRouting__BaseTokenDoesNotExist();
    }
}
