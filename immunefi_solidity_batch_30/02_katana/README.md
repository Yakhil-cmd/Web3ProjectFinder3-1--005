<div align="center">

# Vault Bridge

**[⛓️ Deployments](#deployments)**
**&nbsp;&nbsp; [📙 Documentation](#documentation)**
**&nbsp;&nbsp; [🧭 Website](https://www.agglayer.dev/agglayer-vaultbridge)**
**&nbsp;&nbsp; [🦙 DefiLlama](https://defillama.com/protocol/vault-bridge)**

</div>

## Contents

- [Contents](#contents)
- [Overview](#overview)
  - [TL;DR](#tldr)
  - [Vault Bridge Token](#vault-bridge-token)
  - [Migration Manager](#migration-manager)
  - [Custom Token](#custom-token)
  - [Native Converter](#native-converter)
- [Get Started](#get-started)
- [Documentation](#documentation)
- [Deployments](#deployments)
- [Usage](#usage)
- [License](#license)

## Overview

> [!NOTE]
> This section should be updated, as Vault Bridge has evolved into a larger protocol.

Vault Bridge enables chains and apps to generate native yield on TVL by putting bridged assets to work.

The protocol is comprised of:

- One Primary Chain
  - [Vault Bridge Token](#vault-bridge-token)
  - [Migration Manager](#migration-manager)
- Many Secondary Chains
  - [Custom Token](#custom-token)
  - [Native Converter](#native-converter)

### TL;DR

Select assets are bridged from Primary Chain to Secondary Chain. These assets are deposited into Vault Bridge Token contract on Primary Chain, which mints and bridges vbToken to Secondary Chain. Deposited assets are used to generate yield on Primary Chain, while bridged vbTokens are used in DeFi on Secondary Chain. Generated yield gets distributed to chains and apps participating in the revenue sharing program.

Native Converter contract can be deployed on Secondary Chain to enable acquisition of vbToken on Secondary Chain without having to bridge from Primary Chain. Accumulated backing in Native Converter on Secondary Chain gets migrated to Primary Chain and deposited into Vault Bridge Token contract.

### Vault Bridge Token

A Vault Bridge Token is:

- [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token
- [ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vault
- [Agglayer Bridge](https://github.com/agglayer/agglayer-contracts) extension

Assets in high demand with available yield strategies, such as WETH and USDC, can get their versions of vbTokens. The underlying asset is deposited into Vault Bridge Token contract, and vbToken is minted in a 1:1 ratio. The same can be withdrawn by burning vbToken. Vault Bridge Token contract doubles a pseudo bridge, so vbToken can be minted and bridged, or claimed and redeemed, in a single call. Deposited underlying assets are put into an external, ERC-4626 compatible vault ("yield vault") where they generate yield. Yield is distributed to chains and apps that participate in the revenue sharing program. Vault Bridge Token contracts also includes functionality that enables minting of vbToken directly on Secondary Chain via Native Converter, with backing migration to Primary Chain via Migration Manager.

### Migration Manager

The Migration Manager is:

- [Vault Bridge Token](#vault-bridge-token) dependency

vbTokens can be minted directly on Secondary Chain. In order for an underlying asset that backs vbToken minted on Secondary Chain to be deposited in Vault Bridge Token contract on Primary Chain, backing is migrated to Primary Chain via Native Converter and Migration Manager. Migration Manager completes migrations by interacting with Vault Bridge Token contract. All vbTokens share the same Migration Manager contract.

### Custom Token

A Custom Token is:

- [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token

Bridged vbToken can be upgraded to Custom Token on Secondary Chain. This enables custom behavior, such as bridged vbETH to integrate WETH9 interface, replacing WETH on Secondary Chain.

### Native Converter

A Native Converter is:

- [Vault Bridge Token](#vault-bridge-token) extension
- [Agglayer Bridge](https://github.com/agglayer/agglayer-contracts) extension

Native Converter can be deployed on Secondary Chain to enable minting of vbToken directly on Secondary Chain by converting the bridged underlying asset, in a 1:1 ratio. The same can be deconverted to by burning bridged vbToken. Accumulated backing in Native Converter on Secondary Chain can be migrated to Primary Chain to be deposited into Vault Bridge Token contract via Migration Manger. For this reason, liqudity for deconverting to the bridged underlying token on Secondary Chain is guaranteed only up to a certain percentage. Native Converter doubles a bridge extension, so vbToken can be deconverted and bridged in a single call.

## Get Started

> [!NOTE]
> This section needs to be updated, as the official support for several third-party bridges has been added!

Getting started should be easy as Vault Bridge Token contracts follow the ERC-4626 interface. Variants of the standard ERC-4626 functions include `depositAndBridge` and `claimAndRedeem`. Please see [Documentation](#documentation) for more information.

If your chain is part of Agglayer, you can start using the official vbTokens immediately. Please note that you will get vbToken when bridging, not the underlying token, therefore activity should be incentivized in vbToken. You must participate in the revenue sharing program in order to receive yield. [Contact our team](https://info.polygon.technology/vaultbridge-intake-form) if interested in revenue sharing.

If your chain is not part of Agglayer, you can start using the official vbTokens immediately. Please note that you will need to use a third-party bridge to bridge vbTokens to your chain, and Native Converter functionality will not be supported. You must participate in the revenue sharing program in order to receive yield. [Contact our team](https://info.polygon.technology/vaultbridge-intake-form) if interested in revenue sharing.

Full support for non-Agglayer chains, third-party bridges, as well as non-EVM chains is coming soon. [Contact our team](https://info.polygon.technology/vaultbridge-intake-form) to register interest.

## Documentation

> [!NOTE]
> This section needs to be updated, as some NatSpec is outdated and/or missing.

- [General Documentation](https://docs.agglayer.dev/vault-bridge/get-started/overview/)
- [Source Code](./src/): The Source Code is 100% documented and you are encouraged to take a reference it.
  - Pay attention to the following bookmarks:
    - `@note CAUTION!`
    - `@note IMPORTANT:`
    - `@note (ATTENTION)`

## Deployments

See [`broadcast/README.md`](./broadcast/README.md).

## Usage

Clone:

```
git clone git@github.com:agglayer/vault-bridge.git
```

Install:

```
forge soldeer install & npm install
```

Build:

```
forge build
```

Test:

```
forge test
```

Coverage:

```
forge coverage --ir-minimum --report lcov && genhtml -o coverage lcov.info
```

## License

This codebase is licensed under Source Available License.

See [`LICENSE-SOURCE-AVAILABLE`](./LICENSE-SOURCE-AVAILABLE).

Your use of this software constitutes acceptance of these license terms.

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:46Z`  
Project: `02_katana`  
Solidity files: `103`

### Structure
Top Solidity directories:
- `test`: 56 `.sol` files
- `src`: 33 `.sol` files
- `certora`: 7 `.sol` files
- `script`: 7 `.sol` files

Pragmas:
- `0.8.29`
- `^0.8.29`

Contracts/Libraries/Interfaces detected: `109`

### Life Total / Balance Values
Detected accounting/state total variables:
- `bwUnderlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `VAULT_BRIDGE_PROTOCOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol` = `"1.0.0"`
- `migrationManagerInitialBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `minimumReservePercentage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVault` | type: `MockVault internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVaultMaxDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVaultMaxWithdraw` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `vaultBridgeTokenStorage` | type: `VaultBridgeToken.VaultBridgeTokenStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `BW_UNDERLYING_ASSET_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `BW_UNDERLYING_ASSET_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Bridge Wrapped Underlying Asset"`
- `BW_UNDERLYING_ASSET_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"BWUAT"`
- `LEAF_TYPE_ASSET` | type: `uint8 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0`
- `MAX_RESERVE_PERCENTAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e18`
- `MIGRATION_MANAGER_INITIAL_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1000000e18`
- `MINIMUM_RESERVE_PERCENTAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e17`
- `MINIMUM_YIELD_VAULT_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e12`
- `MINIMUM_YIELD_VAULT_DEPOSIT_INTEGRATION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e18`
- `RESERVE_ASSET_STORAGE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44702"`
- `UNDERLYING_ASSET_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `UNDERLYING_ASSET_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Underlying Asset"`
- `UNDERLYING_ASSET_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"UAT"`
- `YIELD_VAULT_ALLOWED_SLIPPAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e16`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `_balanceOf` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `REBALANCER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `keccak256("REBALANCER_ROLE")`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `src/primary-chain/VaultBridgeToken.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenInitializer` @ `src/primary-chain/VaultBridgeTokenInitializer.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenPart2` @ `src/primary-chain/VaultBridgeTokenPart2.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`

All detected state variables (full list):
- `bwUnderlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `bwVbToken` | type: `MockLxlyBridgeWrappedToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `bwVbTokenMetaData` | type: `bytes` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `abi.encode("", "", 18)`
- `customToken` | type: `GenericCustomToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `forkIdSecondaryChain` | type: `uint256` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `migrationManager` | type: `MigrationManager` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `nativeConverter` | type: `GenericNativeConverter` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `makeAddr("owner")`
- `recipient` | type: `address` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `makeAddr("recipient")`
- `sender` | type: `address` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `vm.addr(senderPrivateKey)`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbToken` | type: `GenericVaultBridgeToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbTokenMetaData` | type: `bytes` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `abi.encode(VBTOKEN_NAME, VBTOKEN_SYMBOL, VBTOKEN_DECIMALS)`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `wrappedGasToken` | type: `MockWETH` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `yieldRecipient` | type: `address` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `makeAddr("yieldRecipient")`
- `MINTER_BURNER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CustomToken` @ `src/secondary-chain/CustomToken.sol` = `keccak256("MINTER_BURNER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CustomToken` @ `src/secondary-chain/CustomToken.sol` = `keccak256("PAUSER_ROLE")`
- `customTokenHarness` | type: `TestHarnessCustomToken internal` | vis: `internal` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `customTokenImpl` | type: `address internal` | vis: `internal` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `existingCustomTokenProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `childChainManagerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `genericCustomTokenPolygonImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `ownerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `secondaryChainName` | type: `string public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `vbUsdc` | type: `GenericCustomTokenPolygon public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `vbUsds` | type: `GenericCustomTokenPolygon public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `vbUsdt` | type: `GenericCustomTokenPolygon public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `gasTokenIsEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `genericCustomTokenWormholeImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `nttManagerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `ownerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `secondaryChainName` | type: `string public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbEth` | type: `WethWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbUsdc` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbUsds` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbUsdt` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbWbtc` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `wethWormholeImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `ADDRESS_ZERO` | type: `address private constant` | vis: `private` | flags: `constant` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol` = `address(0)`
- `customTokenApprovalRequired` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `delegateAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbUsds` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `lzEndpoint` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `ownerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `proxyAdminOwnerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `secondaryChainName` | type: `string public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsds` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdsOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdsOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `ADDRESS_ZERO` | type: `address private constant` | vis: `private` | flags: `constant` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol` = `address(0)`
- `delegateAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbUsds` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `lzEndpoint` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `ownerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `primaryChainName` | type: `string public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `proxyAdminOwnerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEthOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdcOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsds` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdsOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdsOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdtOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtcOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `REVERTING_CONTRACT_CREATION_CODE` | type: `bytes public constant` | vis: `public` | flags: `constant` | `DeployRevertingContract` @ `script/etc/DeployRevertingContract.s.sol` = `hex"6005600c60003960056000f360006000fd"`
- `REVERTING_CONTRACT_RUNTIME_CODE` | type: `bytes public constant` | vis: `public` | flags: `constant` | `DeployRevertingContract` @ `script/etc/DeployRevertingContract.s.sol` = `hex"60006000fd"`
- `chainName` | type: `string public` | vis: `public` | flags: `-` | `DeployRevertingContract` @ `script/etc/DeployRevertingContract.s.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `DeployRevertingContract` @ `script/etc/DeployRevertingContract.s.sol`
- `_PERMIT_SELECTOR_DAI` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `ERC20PermitUser` @ `src/etc/ERC20PermitUser.sol` = `hex"8fcbaf0c"`
- `_PERMIT_SELECTOR_ERC_2612` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `ERC20PermitUser` @ `src/etc/ERC20PermitUser.sol` = `hex"d505accf"`
- `existingGenericCustomTokenAgglayerProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `genericCustomTokenAgglayer` | type: `GenericCustomTokenAgglayer internal` | vis: `internal` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `genericCustomTokenAgglayerImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `mockNativeConverter` | type: `MockNativeConverter internal` | vis: `internal` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `existingGenericCustomTokenLayerZeroProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `genericCustomTokenLayerZero` | type: `GenericCustomTokenLayerZero internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `genericCustomTokenLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `oftAdapter` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol` = `makeAddr("OftAdapter")`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol` = `18`
- `childChainManager` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol` = `makeAddr("ChildChainManager")`
- `existingGenericCustomTokenPolygonProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `genericCustomTokenPolygon` | type: `GenericCustomTokenPolygon internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `genericCustomTokenPolygonImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol` = `18`
- `existingGenericCustomTokenWormholeProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `genericCustomTokenWormhole` | type: `GenericCustomTokenWormhole internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `genericCustomTokenWormholeImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `nttManager` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol` = `makeAddr("NttManager")`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol` = `18`
- `vbTokenHarness` | type: `VaultBridgeTokenHarness internal` | vis: `internal` | flags: `-` | `GenericVaultBridgeTokenFuzzTest` @ `test/fuzz/GenericVaultBridgeTokenFuzz.t.sol`
- `FIRST_INCREMENT` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `InitializationCounterTestBase` @ `test/base/InitializationCounterTestBase.sol` = `1`
- `INITIAL_COUNTER_VALUE` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `InitializationCounterTestBase` @ `test/base/InitializationCounterTestBase.sol` = `0`
- `SECOND_INCREMENT` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `InitializationCounterTestBase` @ `test/base/InitializationCounterTestBase.sol` = `2`
- `THIRD_INCREMENT` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `InitializationCounterTestBase` @ `test/base/InitializationCounterTestBase.sol` = `3`
- `initCounter` | type: `MockInitializationCounterUpgradeable internal` | vis: `internal` | flags: `-` | `InitializationCounterTestBase` @ `test/base/InitializationCounterTestBase.sol`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `MigrationManager` @ `src/primary-chain/MigrationManager.sol` = `keccak256("PAUSER_ROLE")`
- `migrationManager` | type: `MigrationManager internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `migrationManagerImpl` | type: `address internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `vbToken` | type: `MockVbToken internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `wrappedGasToken` | type: `MockWETH internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `depositCount` | type: `uint32 public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `gasTokenAddress` | type: `address public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `gasTokenNetwork` | type: `uint32 public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `globalExitRootManager` | type: `address public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `networkID` | type: `uint32 public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `isTokenMapped` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockChildChainManager` @ `test/utils/mocks/MockChildChainManager.sol`
- `rootToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `MockChildChainManager` @ `test/utils/mocks/MockChildChainManager.sol`
- `_decimals` | type: `uint8 private` | vis: `private` | flags: `-` | `MockERC20` @ `test/utils/mocks/MockERC20.sol`
- `DOMAIN_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`
- `PERMIT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `VERSION` | type: `string public constant` | vis: `public` | flags: `constant` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol` = `"1"`
- `_DEPLOYMENT_DOMAIN_SEPARATOR` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol`
- `_decimals` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol`
- `bridgeAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol`
- `deploymentChainId` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockLxlyBridgeWrappedToken` @ `test/utils/mocks/MockLxlyBridgeWrappedToken.sol`
- `delegates` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `MockLzEndpoint` @ `test/utils/mocks/MockLzEndpoint.sol`
- `peers` | type: `mapping(address => mapping(uint32 => bytes32)) public` | vis: `public` | flags: `-` | `MockLzEndpoint` @ `test/utils/mocks/MockLzEndpoint.sol`
- `removeMigrationInProgressAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `MockNativeConverter` @ `test/utils/mocks/MockNativeConverter.sol`
- `isTokenMapped` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockRootChainManager` @ `test/utils/mocks/MockRootChainManager.sol`
- `rootToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `MockRootChainManager` @ `test/utils/mocks/MockRootChainManager.sol`
- `_maxDeposit` | type: `uint256 private` | vis: `private` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `_maxWithdraw` | type: `uint256 private` | vis: `private` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `slippage` | type: `bool public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `slippageAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `underlyingToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockVbToken` @ `test/utils/mocks/MockVbToken.sol`
- `MIGRATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `NativeConverter` @ `src/secondary-chain/NativeConverter.sol` = `keccak256("MIGRATOR_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `NativeConverter` @ `src/secondary-chain/NativeConverter.sol` = `keccak256("PAUSER_ROLE")`
- `nativeConverter` | type: `TestHarnessNativeConverter internal` | vis: `internal` | flags: `-` | `NativeConverterTestBase` @ `test/base/secondary-chain/NativeConverterTestBase.sol`
- `nativeConverterImpl` | type: `address internal` | vis: `internal` | flags: `-` | `NativeConverterTestBase` @ `test/base/secondary-chain/NativeConverterTestBase.sol`
- `_originalUnderlyingTokenDecimals` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `NonDefaultMintBurnOftAdapter` @ `src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol`
- `approvalRequired` | type: `bool internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol` = `false`
- `customTokenLayerZero` | type: `GenericCustomTokenLayerZero internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `customTokenLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `customTokenLayerZeroProxy` | type: `TransparentUpgradeableProxy internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `delegate` | type: `address internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol` = `makeAddr("Delegate")`
- `lzEndpoint` | type: `MockLzEndpoint internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `nonDefaultMintBurnOftAdapter` | type: `TestHarnessNonDefaultMintBurnOftAdapter internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `nonDefaultMintBurnOftAdapterImpl` | type: `address internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `nonDefaultMintBurnOftAdapterProxy` | type: `TransparentUpgradeableProxy internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol` = `18`
- `customToken` | type: `GenericCustomTokenPolygon` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `migrationManager` | type: `MigrationManager` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `mockAgglayerBridge` | type: `MockAgglayerBridge` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `mockChildChainManager` | type: `MockChildChainManager` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `mockRootChainManager` | type: `MockRootChainManager` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol` = `makeAddr("owner")`
- `sender` | type: `address` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol` = `vm.addr(senderPrivateKey)`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbToken` | type: `GenericVaultBridgeToken` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `VAULT_BRIDGE_PROTOCOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol` = `"1.0.0"`
- `agglayerBridge` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `initializer` | type: `VaultBridgeTokenInitializer internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `migrationManagerAddr` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `migrationManagerInitialBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `minimumReservePercentage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `nativeConverter` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `owner` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `recipient` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `sender` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `stateBeforeInitialize` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenDecimals` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenMetadata` | type: `bytes internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenName` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingToken` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `vbTokenPart2Implementation` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldRecipient` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVault` | type: `MockVault internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVaultMaxDeposit` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `yieldVaultMaxWithdraw` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `NATIVE_CONVERTER_PROTOCOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol` = `"1.0.0"`
- `calculatedNativeConverter` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customToken` | type: `MockTokenWrappedBridgeUpgradeable internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `dummyNativeConverter` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `maxNonMigratableBackingPercentage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `maxNonMigratableGasBackingPercentage` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `migrationManager` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `mockAgglayerBridge` | type: `MockAgglayerBridge internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `originUnderlyingToken` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `owner` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `primaryChainAgglayerId` | type: `uint32 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `proxyAdmin` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `recipient` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `sender` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `stateBeforeInitialize` | type: `uint256 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingToken` | type: `MockERC20Upgradeable internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenMetadata` | type: `bytes internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `ADDRESS_ZERO` | type: `address private constant` | vis: `private` | flags: `constant` | `SetBridge` @ `script/etc/SetBridge.s.sol` = `address(0)`
- `chainName` | type: `string public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `executorAddress` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbEth` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbUsds` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbEthBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbEthTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdcBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdcTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdsBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdsTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdtBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdtTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbWbtcBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbWbtcTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `customTokenStorage` | type: `CustomToken.CustomTokenStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `migrationManagerStorage` | type: `MigrationManager.MigrationManagerStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `nativeConverterStorage` | type: `NativeConverter.NativeConverterStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `vaultBridgeTokenStorage` | type: `VaultBridgeToken.VaultBridgeTokenStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `wETHNativeConverterStorage` | type: `WETHNativeConverter.WETHNativeConverterStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `ADMIN_SLOT` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `BRIDGE_MANAGER` | type: `address internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xAb3506507449bF1880f3337825efd19ac89E235E`
- `BW_UNDERLYING_ASSET_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `BW_UNDERLYING_ASSET_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Bridge Wrapped Underlying Asset"`
- `BW_UNDERLYING_ASSET_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"BWUAT"`
- `BW_VBTOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `BW_VBTOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Bridge Wrapped VbToken"`
- `BW_VBTOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"BWVBTK"`
- `CUSTOM_TOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `CUSTOM_TOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Custom Token"`
- `CUSTOM_TOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"CT"`
- `GER_X` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xAd1490c248c5d3CbAE399Fd529b79B42984277DF`
- `GER_Y` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xa40D5f56745a118D0906a34E69aeC8C0Db1cB8fA`
- `GER_Y_UPDATER` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0x2caeD842621FF58AaaeC1A06e487d9975F9bFe8A`
- `LEAF_TYPE_ASSET` | type: `uint8 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0`
- `LEAF_TYPE_MESSAGE` | type: `uint8 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1`
- `LXLY_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe`
- `LXLY_BRIDGE_X` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0x528e26b25a34a4A5d0dbDa1d57D318153d2ED582`
- `LXLY_BRIDGE_Y` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0x528e26b25a34a4A5d0dbDa1d57D318153d2ED582`
- `MAX_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `10e18`
- `MAX_NON_MIGRATABLE_BACKING_PERCENTAGE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e17`
- `MAX_NON_MIGRATABLE_GAS_BACKING_PERCENTAGE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e17`
- `MAX_RESERVE_PERCENTAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e18`
- `MAX_WITHDRAW` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `10e18`
- `MIGRATION_MANAGER_INITIAL_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1000000e18`
- `MINIMUM_RESERVE_PERCENTAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e17`
- `MINIMUM_YIELD_VAULT_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e12`
- `MINIMUM_YIELD_VAULT_DEPOSIT_INTEGRATION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e18`
- `NETWORK_ID_L1` | type: `uint32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0`
- `NETWORK_ID_L2` | type: `uint32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1`
- `NETWORK_ID_X` | type: `uint32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0`
- `NETWORK_ID_Y` | type: `uint32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `37`
- `PERMIT_SIGNATURE` | type: `bytes4 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xd505accf`
- `PERMIT_TYPEHASH` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `RESERVE_ASSET_STORAGE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44702"`
- `ROLLUP_MANAGER` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0x32d33D5137a7cFFb54c5Bf8371172bcEc5f310ff`
- `SOVEREIGN_BRIDGE_BYTECODE` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `hex"6101006040523480156200001257600080fd5b5060405162001b6638038062001b6683398101604081905262000035916200028d565b82826003620000458382620003a1565b506004620000548282620003a1565b50503360c0525060ff811660e052466080819052620000739062000080565b60a052506200046d915050565b60007f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f620000ad6200012e565b805160209182012060408051808201825260018152603160f81b90840152805192830193909352918101919091527fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc66060820152608081018390523060a082015260c001604051602081830303815290604052805190602001209050919050565b6060600380546200013f9062000312565b80601f01602080910402602001604051908101604052809291908181526020018280546200016d9062000312565b8015620001be5780601f106200019257610100808354040283529160200191620001be565b820191906000526020600020905b815481529060010190602001808311620001a057829003601f168201915b5050505050905090565b634e487b7160e01b600052604160045260246000fd5b600082601f830112620001f057600080fd5b81516001600160401b03808211156200020d576200020d620001c8565b604051601f8301601f19908116603f01168101908282118183101715620002385762000238620001c8565b816040528381526020925086838588010111156200025557600080fd5b600091505b838210156200027957858201830151818301840152908201906200025a565b600093810190920192909252949350505050565b600080600060608486031215620002a357600080fd5b83516001600160401b0380821115620002bb57600080fd5b620002c987838801620001de565b94506020860151915080821115620002e057600080fd5b50620002ef86828701620001de565b925050604084015160ff811681146200030757600080fd5b809150509250925092565b600181811c908216806200032757607f821691505b6020821081036200034857634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156200039c57600081815260208120601f850160051c81016020861015620003775750805b601f850160051c820191505b81811015620003985782815560010162000383565b5050505b505050565b81516001600160401b03811115620003bd57620003bd620001c8565b620003d581620003ce845462000312565b846200034e565b602080601f8311600181146200040d5760008415620003f45750858301515b600019600386901b1c1916600185901b17855562000398565b600085815260208120601f198616915b828110156200043e578886015182559484019460019091019084016200041d565b50858210156200045d5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b60805160a05160c05160e0516116aa620004bc6000396000610237015260008181610307015281816105c001526106a70152600061053a015260008181610379015261050401526116aa6000f3fe608060405234801561001057600080fd5b50600436106101775760003560e01c806370a08231116100d8578063a457c2d71161008c578063d505accf11610066578063d505accf1461039b578063dd62ed3e146103ae578063ffa1ad74146103f457600080fd5b8063a457c2d71461034e578063a9059cbb14610361578063cd0d00961461037457600080fd5b806395d89b41116100bd57806395d89b41146102e75780639dc29fac146102ef578063a3c573eb1461030257600080fd5b806370a08231146102915780637ecebe00146102c757600080fd5b806330adf81f1161012f5780633644e515116101145780633644e51514610261578063395093511461026957806340c10f191461027c57600080fd5b806330adf81f14610209578063313ce5671461023057600080fd5b806318160ddd1161016057806318160ddd146101bd57806320606b70146101cf57806323b872dd146101f657600080fd5b806306fdde031461017c578063095ea7b31461019a575b600080fd5b610184610430565b60405161019191906113e4565b60405180910390f35b6101ad6101a8366004611479565b6104c2565b6040519015158152602001610191565b6002545b604051908152602001610191565b6101c17f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f81565b6101ad6102043660046114a3565b6104dc565b6101c17f6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c981565b60405160ff7f0000000000000000000000000000000000000000000000000000000000000000168152602001610191565b6101c1610500565b6101ad610277366004611479565b61055c565b61028f61028a366004611479565b6105a8565b005b6101c161029f3660046114df565b73ffffffffffffffffffffffffffffffffffffffff1660009081526020819052604090205490565b6101c16102d53660046114df565b60056020526000908152604090205481565b610184610680565b61028f6102fd366004611479565b61068f565b6103297f000000000000000000000000000000000000000000000000000000000000000081565b60405173ffffffffffffffffffffffffffffffffffffffff9091168152602001610191565b6101ad61035c366004611479565b61075e565b6101ad61036f366004611479565b61082f565b6101c17f000000000000000000000000000000000000000000000000000000000000000081565b61028f6103a9366004611501565b61083d565b6101c16103bc366004611574565b73ffffffffffffffffffffffffffffffffffffffff918216600090815260016020908152604080832093909416825291909152205490565b6101846040518060400160405280600181526020017f310000000000000000000000000000000000000000000000000000000000000081525081565b60606003805461043f906115a7565b80601f016020809104026020016040519081016040528092919081815260200182805461046b906115a7565b80156104b85780601f1061048d576101008083540402835291602001916104b8565b820191906000526020600020905b81548152906001019060200180831161049b57829003601f168201915b5050505050905090565b6000336104d0818585610b73565b60019150505b92915050565b6000336104ea858285610d27565b6104f5858585610dfe565b506001949350505050565b60007f00000000000000000000000000000000000000000000000000000000000000004614610537576105324661106d565b905090565b507f000000000000000000000000000000000000000000000000000000000000000090565b33600081815260016020908152604080832073ffffffffffffffffffffffffffffffffffffffff871684529091528120549091906104d090829086906105a3908790611629565b610b73565b3373ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001614610672576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603060248201527f546f6b656e577261707065643a3a6f6e6c794272696467653a204e6f7420506f60448201527f6c79676f6e5a6b45564d4272696467650000000000000000000000000000000060648201526084015b60405180910390fd5b61067c8282611135565b5050565b60606004805461043f906115a7565b3373ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000001614610754576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603060248201527f546f6b656e577261707065643a3a6f6e6c794272696467653a204e6f7420506f60448201527f6c79676f6e5a6b45564d427269646765000000000000000000000000000000006064820152608401610669565b61067c8282611228565b33600081815260016020908152604080832073ffffffffffffffffffffffffffffffffffffffff8716845290915281205490919083811015610822576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f7760448201527f207a65726f0000000000000000000000000000000000000000000000000000006064820152608401610669565b6104f58286868403610b73565b6000336104d0818585610dfe565b834211156108cc576040517f08c379a0000000000000000000000000000000000000000000000000000000008152602060048201526024808201527f546f6b656e577261707065643a3a7065726d69743a204578706972656420706560448201527f726d6974000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff8716600090815260056020526040812080547f6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9918a918a918a9190866109268361163c565b9091555060408051602081019690965273ffffffffffffffffffffffffffffffffffffffff94851690860152929091166060840152608083015260a082015260c0810186905260e0016040516020818303038152906040528051906020012090506000610991610500565b6040517f19010000000000000000000000000000000000000000000000000000000000006020820152602281019190915260428101839052606201604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181528282528051602091820120600080855291840180845281905260ff89169284019290925260608301879052608083018690529092509060019060a0016020604051602081039080840390855afa158015610a55573d6000803e3d6000fd5b50506040517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0015191505073ffffffffffffffffffffffffffffffffffffffff811615801590610ad057508973ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16145b610b5c576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602760248201527f546f6b656e577261707065643a3a7065726d69743a20496e76616c696420736960448201527f676e6174757265000000000000000000000000000000000000000000000000006064820152608401610669565b610b678a8a8a610b73565b50505050505050505050565b73ffffffffffffffffffffffffffffffffffffffff8316610c15576040517f08c379a0000000000000000000000000000000000000000000000000000000008152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f2061646460448201527f72657373000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff8216610cb8576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f20616464726560448201527f73730000000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff83811660008181526001602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92591015b60405180910390a3505050565b73ffffffffffffffffffffffffffffffffffffffff8381166000908152600160209081526040808320938616835292905220547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8114610df85781811015610deb576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601d60248201527f45524332303a20696e73756666696369656e7420616c6c6f77616e63650000006044820152606401610669565b610df88484848403610b73565b50505050565b73ffffffffffffffffffffffffffffffffffffffff8316610ea1576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f20616460448201527f64726573730000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff8216610f44576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201527f65737300000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff831660009081526020819052604090205481811015610ffa576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e742065786365656473206260448201527f616c616e636500000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff848116600081815260208181526040808320878703905593871680835291849020805487019055925185815290927fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef910160405180910390a3610df8565b60007f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f611098610430565b8051602091820120604080518082018252600181527f310000000000000000000000000000000000000000000000000000000000000090840152805192830193909352918101919091527fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc66060820152608081018390523060a082015260c001604051602081830303815290604052805190602001209050919050565b73ffffffffffffffffffffffffffffffffffffffff82166111b2576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f2061646472657373006044820152606401610669565b80600260008282546111c49190611629565b909155505073ffffffffffffffffffffffffffffffffffffffff8216600081815260208181526040808320805486019055518481527fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef910160405180910390a35050565b73ffffffffffffffffffffffffffffffffffffffff82166112cb576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f2061646472657360448201527f73000000000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff821660009081526020819052604090205481811015611381576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e60448201527f63650000000000000000000000000000000000000000000000000000000000006064820152608401610669565b73ffffffffffffffffffffffffffffffffffffffff83166000818152602081815260408083208686039055600280548790039055518581529192917fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9101610d1a565b600060208083528351808285015260005b81811015611411578581018301518582016040015282016113f5565b5060006040828601015260407fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f8301168501019250505092915050565b803573ffffffffffffffffffffffffffffffffffffffff8116811461147457600080fd5b919050565b6000806040838503121561148c57600080fd5b61149583611450565b946020939093013593505050565b6000806000606084860312156114b857600080fd5b6114c184611450565b92506114cf60208501611450565b9150604084013590509250925092565b6000602082840312156114f157600080fd5b6114fa82611450565b9392505050565b600080600080600080600060e0888a03121561151c57600080fd5b61152588611450565b965061153360208901611450565b95506040880135945060608801359350608088013560ff8116811461155757600080fd5b9699959850939692959460a0840135945060c09093013592915050565b6000806040838503121561158757600080fd5b61159083611450565b915061159e60208401611450565b90509250929050565b600181811c908216806115bb57607f821691505b6020821081036115f4577f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b50919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b808201808211156104d6576104d66115fa565b60007fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff820361166d5761166d6115fa565b506001019056fea26469706673582212208d88fee561cff7120d381c345cfc534cef8229a272dc5809d4bbb685ad67141164736f6c63430008110033a2646970667358221220ca7a7fd14ec73edf6b3d053ef2133e4a8110a83daf9abb364c35f9d9eb2a083564736f6c63430008140033"`
- `UNDERLYING_ASSET_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `UNDERLYING_ASSET_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Underlying Asset"`
- `UNDERLYING_ASSET_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"UAT"`
- `VBTOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `VBTOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Vault Bridge Token"`
- `VBTOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"VBTK"`
- `WETH` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `YIELD_VAULT_ALLOWED_SLIPPAGE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `1e16`
- `senderPrivateKey` | type: `uint256` | vis: `default` | flags: `-` | `TestConstants` @ `test/base/TestConstants.sol` = `0xBEEF`
- `_maxDeposit` | type: `uint256 private` | vis: `private` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `_maxWithdraw` | type: `uint256 private` | vis: `private` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `slippage` | type: `bool public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol` = `false`
- `slippageAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `INITIAL_DOMAIN_SEPARATOR` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `_allowance` | type: `mapping(address => mapping(address => uint256)) internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `_balanceOf` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `_decimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `_name` | type: `string internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `_symbol` | type: `string internal` | vis: `internal` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `initialized` | type: `bool private` | vis: `private` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `TokenMock` @ `certora/mocks/TokenMock.sol`
- `ADDRESS_ZERO` | type: `address private constant` | vis: `private` | flags: `constant` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol` = `address(0)`
- `ADMIN_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `lzEndpoint` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `secondaryChainName` | type: `string public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbEth` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbUsds` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsds` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdsOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdsOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `keccak256("PAUSER_ROLE")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `src/primary-chain/VaultBridgeToken.sol` = `keccak256("PAUSER_ROLE")`
- `REBALANCER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `keccak256("REBALANCER_ROLE")`
- `YIELD_COLLECTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `keccak256("YIELD_COLLECTOR_ROLE")`
- `YIELD_COLLECTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `VaultBridgeToken` @ `src/primary-chain/VaultBridgeToken.sol` = `keccak256("YIELD_COLLECTOR_ROLE")`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `src/primary-chain/VaultBridgeToken.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenInitializer` @ `src/primary-chain/VaultBridgeTokenInitializer.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenPart2` @ `src/primary-chain/VaultBridgeTokenPart2.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `vbToken` | type: `TestHarnessVaultBridgeToken internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbTokenImplementation` | type: `address internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbETH` | type: `VbEth internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `vbETHImplementation` | type: `address internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `vbETHPart2` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `wethAgglayer` | type: `WethAgglayer internal` | vis: `internal` | flags: `-` | `WethAgglayerTestBase` @ `test/base/secondary-chain/WethAgglayerTestBase.sol`
- `wethAgglayerImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethAgglayerTestBase` @ `test/base/secondary-chain/WethAgglayerTestBase.sol`
- `existingWethLayerZeroProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `gasTokenIsEth` | type: `bool internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol` = `true`
- `oftAdapter` | type: `address internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol` = `makeAddr("OftAdapter")`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol` = `18`
- `wethLayerZero` | type: `WethLayerZero internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `wethLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `nativeConverter` | type: `WethNativeConverterAgglayer internal` | vis: `internal` | flags: `-` | `WethNativeConverterAgglayerTestBase` @ `test/base/secondary-chain/WethNativeConverterAgglayerTestBase.sol`
- `nativeConverterImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethNativeConverterAgglayerTestBase` @ `test/base/secondary-chain/WethNativeConverterAgglayerTestBase.sol`
- `existingWethWormholeProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`
- `gasTokenIsEth` | type: `bool internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol` = `true`
- `nttManager` | type: `address internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol` = `makeAddr("NttManager")`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol` = `18`
- `wethWormhole` | type: `WethWormhole internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`
- `wethWormholeImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`
- `MERKLE_TREE_HEIGHT` | type: `string constant` | vis: `default` | flags: `constant` | `ZkEVMCommon` @ `test/utils/ZkEVMCommon.sol` = `"32"`

### Tokens Added / Token State Values
Detected token-related variables:
- `bwUnderlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `bwVbToken` | type: `MockLxlyBridgeWrappedToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `bwVbTokenMetaData` | type: `bytes` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `abi.encode("", "", 18)`
- `customToken` | type: `GenericCustomToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbToken` | type: `GenericVaultBridgeToken` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbTokenMetaData` | type: `bytes` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol` = `abi.encode(VBTOKEN_NAME, VBTOKEN_SYMBOL, VBTOKEN_DECIMALS)`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `wrappedGasToken` | type: `MockWETH` | vis: `default` | flags: `-` | `AgglayerIntegrationTest` @ `test/integration/AgglayerIntegrationTest.t.sol`
- `customTokenHarness` | type: `TestHarnessCustomToken internal` | vis: `internal` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `customTokenImpl` | type: `address internal` | vis: `internal` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `existingCustomTokenProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `CustomTokenTestBase` @ `test/base/secondary-chain/CustomTokenTestBase.sol`
- `genericCustomTokenPolygonImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `vbUsdc` | type: `GenericCustomTokenPolygon public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `vbUsdt` | type: `GenericCustomTokenPolygon public` | vis: `public` | flags: `-` | `DeployCustomTokensPolygon` @ `script/polygon/DeployCustomTokensPolygon.s.sol`
- `gasTokenIsEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `genericCustomTokenWormholeImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbEth` | type: `WethWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbUsdc` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbUsdt` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `vbWbtc` | type: `GenericCustomTokenWormhole public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `wethWormholeImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployCustomTokensWormhole` @ `script/wormhole/DeployCustomTokensWormhole.s.sol`
- `customTokenApprovalRequired` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapter` | type: `NonDefaultMintBurnOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultMintBurnOFTAdapters` @ `script/layerzero/DeployNonDefaultMintBurnOftAdapters.s.sol`
- `deployForVbEth` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `deployForVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEthOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdcOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdtOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtcOftAdapter` | type: `NonDefaultOftAdapter public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `DeployNonDefaultOFTAdapters` @ `script/layerzero/DeployNonDefaultOftAdapters.s.sol`
- `_PERMIT_SELECTOR_DAI` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `ERC20PermitUser` @ `src/etc/ERC20PermitUser.sol` = `hex"8fcbaf0c"`
- `existingGenericCustomTokenAgglayerProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `genericCustomTokenAgglayer` | type: `GenericCustomTokenAgglayer internal` | vis: `internal` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `genericCustomTokenAgglayerImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenAgglayerTestBase` @ `test/base/secondary-chain/GenericCustomTokenAgglayerTestBase.sol`
- `existingGenericCustomTokenLayerZeroProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `genericCustomTokenLayerZero` | type: `GenericCustomTokenLayerZero internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `genericCustomTokenLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenLayerZeroTestBase` @ `test/base/secondary-chain/GenericCustomTokenLayerZeroTestBase.sol` = `18`
- `existingGenericCustomTokenPolygonProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `genericCustomTokenPolygon` | type: `GenericCustomTokenPolygon internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `genericCustomTokenPolygonImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenPolygonTestBase` @ `test/base/secondary-chain/GenericCustomTokenPolygonTestBase.sol` = `18`
- `existingGenericCustomTokenWormholeProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `genericCustomTokenWormhole` | type: `GenericCustomTokenWormhole internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `genericCustomTokenWormholeImpl` | type: `address internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `GenericCustomTokenWormholeTestBase` @ `test/base/secondary-chain/GenericCustomTokenWormholeTestBase.sol` = `18`
- `vbTokenHarness` | type: `VaultBridgeTokenHarness internal` | vis: `internal` | flags: `-` | `GenericVaultBridgeTokenFuzzTest` @ `test/fuzz/GenericVaultBridgeTokenFuzz.t.sol`
- `vbToken` | type: `MockVbToken internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `wrappedGasToken` | type: `MockWETH internal` | vis: `internal` | flags: `-` | `MigrationManagerTestBase` @ `test/base/primary-chain/MigrationManagerTestBase.sol`
- `gasTokenAddress` | type: `address public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `gasTokenNetwork` | type: `uint32 public` | vis: `public` | flags: `-` | `MockAgglayerBridge` @ `test/utils/mocks/MockAgglayerBridge.sol`
- `isTokenMapped` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockChildChainManager` @ `test/utils/mocks/MockChildChainManager.sol`
- `rootToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `MockChildChainManager` @ `test/utils/mocks/MockChildChainManager.sol`
- `isTokenMapped` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockRootChainManager` @ `test/utils/mocks/MockRootChainManager.sol`
- `rootToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `MockRootChainManager` @ `test/utils/mocks/MockRootChainManager.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockVault` @ `test/utils/mocks/MockVault.sol`
- `underlyingToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockVbToken` @ `test/utils/mocks/MockVbToken.sol`
- `_originalUnderlyingTokenDecimals` | type: `uint8 private immutable` | vis: `private` | flags: `immutable` | `NonDefaultMintBurnOftAdapter` @ `src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol`
- `customTokenLayerZero` | type: `GenericCustomTokenLayerZero internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `customTokenLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `customTokenLayerZeroProxy` | type: `TransparentUpgradeableProxy internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `NonDefaultMintBurnOftAdapterTestBase` @ `test/base/secondary-chain/NonDefaultMintBurnOftAdapterTestBase.sol` = `18`
- `customToken` | type: `GenericCustomTokenPolygon` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `underlyingAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbToken` | type: `GenericVaultBridgeToken` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `vbTokenVault` | type: `MockVault` | vis: `default` | flags: `-` | `PolygonIntegrationTest` @ `test/integration/PolygonIntegrationTest.t.sol`
- `tokenDecimals` | type: `uint256 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenMetadata` | type: `bytes internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenName` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `tokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingToken` | type: `address internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `underlyingTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `vbTokenPart2Implementation` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `PrimaryChainBase` @ `test/base/primary-chain/PrimaryChainBase.sol`
- `customToken` | type: `MockTokenWrappedBridgeUpgradeable internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `customTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `originUnderlyingToken` | type: `address internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingToken` | type: `MockERC20Upgradeable internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenMetadata` | type: `bytes internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenName` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `underlyingTokenSymbol` | type: `string internal` | vis: `internal` | flags: `-` | `SecondaryChainBase` @ `test/base/secondary-chain/SecondaryChainBase.sol`
- `updateVbEth` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `updateVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbEthBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbEthTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdcBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdcTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdsTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdtBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbUsdtTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbWbtcBridge` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `vbWbtcTokenL2` | type: `address public` | vis: `public` | flags: `-` | `SetBridge` @ `script/etc/SetBridge.s.sol`
- `customTokenStorage` | type: `CustomToken.CustomTokenStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `vaultBridgeTokenStorage` | type: `VaultBridgeToken.VaultBridgeTokenStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `wETHNativeConverterStorage` | type: `WETHNativeConverter.WETHNativeConverterStorage` | vis: `default` | flags: `-` | `StorageExtension` @ `certora/harnesses/StorageExtension.sol`
- `BW_VBTOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `BW_VBTOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Bridge Wrapped VbToken"`
- `BW_VBTOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"BWVBTK"`
- `CUSTOM_TOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `CUSTOM_TOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Custom Token"`
- `CUSTOM_TOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"CT"`
- `VBTOKEN_DECIMALS` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `18`
- `VBTOKEN_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"Vault Bridge Token"`
- `VBTOKEN_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `"VBTK"`
- `WETH` | type: `address constant` | vis: `default` | flags: `constant` | `TestConstants` @ `test/base/TestConstants.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `TestVault` @ `certora/mocks/TestVault.sol`
- `upgradeVbEth` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbUsdc` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbUsdt` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `upgradeVbWbtc` | type: `bool public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEth` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbEthOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdc` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdcOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdt` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbUsdtOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtc` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `vbWbtcOftAdapterProxy` | type: `address public` | vis: `public` | flags: `-` | `UpgradeNonDefaultMintBurnOFTAdapters` @ `script/layerzero/UpgradeNonDefaultMintBurnOftAdapters.s.sol`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `certora/patches/VaultBridgeToken_patched.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeToken` @ `src/primary-chain/VaultBridgeToken.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenInitializer` @ `src/primary-chain/VaultBridgeTokenInitializer.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `_VAULT_BRIDGE_TOKEN_STORAGE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `VaultBridgeTokenPart2` @ `src/primary-chain/VaultBridgeTokenPart2.sol` = `hex"f082fbc4cfb4d172ba00d34227e208a31ceb0982bc189440d519185302e44700"`
- `vbToken` | type: `TestHarnessVaultBridgeToken internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbTokenImplementation` | type: `address internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbTokenPart2` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `VaultBridgeTokenTestBase` @ `test/base/primary-chain/VaultBridgeTokenTestBase.sol`
- `vbETH` | type: `VbEth internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `vbETHImplementation` | type: `address internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `vbETHPart2` | type: `VaultBridgeTokenPart2 internal` | vis: `internal` | flags: `-` | `VbETHTestBase` @ `test/base/primary-chain/VbETHTestBase.sol`
- `wethAgglayer` | type: `WethAgglayer internal` | vis: `internal` | flags: `-` | `WethAgglayerTestBase` @ `test/base/secondary-chain/WethAgglayerTestBase.sol`
- `wethAgglayerImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethAgglayerTestBase` @ `test/base/secondary-chain/WethAgglayerTestBase.sol`
- `existingWethLayerZeroProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `gasTokenIsEth` | type: `bool internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol` = `true`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol` = `18`
- `wethLayerZero` | type: `WethLayerZero internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `wethLayerZeroImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethLayerZeroTestBase` @ `test/base/secondary-chain/WethLayerZeroTestBase.sol`
- `existingWethWormholeProxy` | type: `TransparentUpgradeableProxy` | vis: `default` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`
- `gasTokenIsEth` | type: `bool internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol` = `true`
- `originalUnderlyingTokenDecimals` | type: `uint8 internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol` = `18`
- `wethWormhole` | type: `WethWormhole internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`
- `wethWormholeImpl` | type: `address internal` | vis: `internal` | flags: `-` | `WethWormholeTestBase` @ `test/base/secondary-chain/WethWormholeTestBase.sol`

Hardcoded token addresses found:
- `WETH` @ `test/base/TestConstants.sol` = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`

### Struct Values (All Parsed Struct Fields)
- `ClaimPayload` (test/integration/AgglayerIntegrationTest.t.sol): bytes32[32] proofPrimaryChain, bytes32[32] proofSecondaryChain, uint256 globalIndex, bytes32 exitRootPrimaryChain, bytes32 exitRootSecondaryChain, uint32 originNetwork, address originAddress, uint32 destinationNetwork, address destinationAddress, uint256 amount, bytes metadata
- `CustomTokenStorage` (src/secondary-chain/CustomToken.sol): uint8 decimals, address bridge, address nativeConverter, uint256 _secondaryChainBalance, mapping(address => uint256) _netMintedByAdditionalMintersBurners, uint256 totalNetMintedByAdditionalMintersBurners
- `CustomTokenWethExtensionStorage` (src/secondary-chain/CustomTokenWethExtension.sol): bool _gasTokenIsEth, uint256 gasBackingOnSecondaryChain, bool wethFunctionalityEnabled
- `InitializationCounterUpgradeableStorage` (src/etc/InitializationCounterUpgradeable.sol): uint64 _localInitializationCounter, mapping(Extension => uint64) _extensionInitializationCounter, uint64 globalInitializationCounter, bool _unlocked
- `InitializationParameters` (certora/patches/VaultBridgeToken_patched.sol): address owner, string name, string symbol, address underlyingToken, uint256 minimumReservePercentage, address yieldVault, address yieldRecipient, address lxlyBridge, uint256 minimumYieldVaultDeposit, address migrationManager, uint256 yieldVaultMaximumSlippagePercentage, address vaultBridgeTokenPart2
- `InitializationParameters` (src/primary-chain/VaultBridgeToken.sol): address owner, string name, string symbol, address underlyingToken, uint256 minimumReservePercentage, address yieldVault, address yieldRecipient, address agglayerBridge, uint256 minimumYieldVaultDeposit, address migrationManager, uint256 yieldVaultMaximumSlippagePercentage, address vaultBridgeTokenPart2
- `LeafPayload` (test/integration/AgglayerIntegrationTest.t.sol): uint8 leafType, uint32 originNetwork, address originAddress, uint32 destinationNetwork, address destinationAddress, uint256 amount, bytes metadata
- `MigrationManagerStorage` (src/primary-chain/MigrationManager.sol): IAgglayerBridge agglayerBridge, uint32 _agglayerId, mapping(uint32 secondaryChainAgglayerId => mapping(address nativeConverter => TokenPair tokenPair)) nativeConvertersConfiguration, IWETH9 _wrappedGasToken
- `NativeConverterStorage` (src/secondary-chain/NativeConverter.sol): CustomToken customToken, IERC20 underlyingToken, uint256 backingOnSecondaryChain, uint32 agglayerId, IAgglayerBridge bridge, uint32 primaryChainAgglayerId, uint256 nonMigratableBackingPercentage, address migrationManager, bool _underlyingTokenIsNotMintable, mapping(uint256 migratedBacking => uint256 times) _migrationsInProgress, uint256 _migrationsInProgressCount, uint256 _totalMigratedBackingInProgress
- `NonDefaultMintBurnOftAdapterStorage` (src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol): IERC20 token, bool approvalRequired, uint256 secondaryChainBalance
- `TokenPair` (src/primary-chain/MigrationManager.sol): VaultBridgeToken vbToken, IERC20 underlyingToken
- `TokenWrappedBridgeUpgradeableStorage` (test/utils/mocks/MockTokenWrappedBridgeUpgradeable.sol): uint8 decimals, address bridgeAddress
- `VaultBridgeTokenStorage` (certora/patches/VaultBridgeToken_patched.sol): IERC20 underlyingToken, uint8 decimals, uint256 minimumReservePercentage, uint256 reservedAssets, IERC4626 yieldVault, address yieldRecipient, uint256 _netCollectedYield, uint32 lxlyId, ILxLyBridge lxlyBridge, uint256 migrationFeesFund, uint256 minimumYieldVaultDeposit, address migrationManager, uint256 yieldVaultMaximumSlippagePercentage, address _vaultBridgeTokenPart2
- `VaultBridgeTokenStorage` (src/primary-chain/VaultBridgeToken.sol): IERC20 underlyingToken, uint8 decimals, uint256 minimumReservePercentage, uint256 reservedAssets, IERC4626 yieldVault, address yieldRecipient, uint256 _netCollectedYield, uint32 agglayerId, IAgglayerBridge agglayerBridge, uint256 migrationFeesFund, uint256 minimumYieldVaultDeposit, address migrationManager, uint256 yieldVaultMaximumSlippagePercentage, address _vaultBridgeTokenPart2
- `WETHNativeConverterStorage` (src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol): WethAgglayer __DEPRECATED___weth, bool _gasTokenIsEth, uint256 nonMigratableGasBackingPercentage

### Enum State Values
- `CrossChainInstruction` (src/primary-chain/MigrationManager.sol): _0_COMPLETE_MIGRATION, _1_WRAP_GAS_TOKEN_AND_COMPLETE_MIGRATION
- `Extension` (src/etc/InitializationCounterUpgradeable.sol): WETH

### Invariant Values (Variable-Tied)
- Key accounting vars (`vaultBridgeTokenStorage`, `asset`, `balanceOf`, `_balanceOf`, `REBALANCER_ROLE`, `_VAULT_BRIDGE_TOKEN_STORAGE`, `_VAULT_BRIDGE_TOKEN_STORAGE`, `_VAULT_BRIDGE_TOKEN_STORAGE`) must only change through authorized accounting paths
- Every token address/handle variable must be non-zero and immutable or governance-gated
- Struct fields representing amounts/indexes/nonces must remain monotonic or strictly validated per lifecycle transition

### Full Raw State Inventory
- `AUDIT_STATE_VALUES_FULL.json` includes:
  - all state variables
  - all total/balance variables
  - all token variables
  - all structs and fields
  - enum values
<!-- AUDIT_DOSSIER_END -->
