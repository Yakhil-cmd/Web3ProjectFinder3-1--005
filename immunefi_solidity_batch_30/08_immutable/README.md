# Immutable Token Bridge

The Immutable token bridge facilitates the transfer of assets between two chains, namely Ethereum (the Root chain) and the Immutable chain (the Child chain). At present, the bridge only supports the transfer of standard ERC20 tokens originating from Ethereum, as well as native assets (ETH and IMX). Other types of assets (such as ERC721) and assets originating from the Child chain are not currently supported.

## Contents
<!-- TOC -->
* [Features](#features)
* [Build and Test](#build-and-test)
* [Contract Deployment](#contract-deployment)
* [Deployed Contract Addresses](#deployed-contract-addresses)
* [Flow Rate Parameters](#flow-rate-parameters)
* [Manual Bridging Guide](#manual-bridging-guide)
* [Audits](#audits)
<!-- TOC -->

## Features
### Core Features
The bridge provides two key functions, **deposits** and **withdrawals**.

#### Deposit Assets (Root Chain → Child Chain)
When a user wishes to transfer assets from Ethereum to Immutable, they initiate a deposit. This deposit moves an asset from the Root chain to the Child chain. It does so by first transferring the user's asset to the bridge (Root chain), then minting and transferring corresponding representation tokens of that asset to the user, on the Child chain. The following types of asset deposits flows are supported:
1. Native ETH on Ethereum  → Wrapped ETH on Immutable zkEVM (ERC20 token)
2. Wrapped ETH on Ethereum → Wrapped ETH on Immutable zkEVM (ERC20 token)
3. ERC20 IMX on Ethereum   → Native IMX on Immutable zkEVM. IMX is represented on Immutable zkEVM as the native gas token, see [here](https://etherscan.io/token/0xf57e7e7c23978c3caec3c3548e3d615c346e79ff)
4. Standard ERC20 tokens   → Wrapped equivalents on Immutable zkEVM (ERC20 token)

#### Withdraw Assets (Child Chain → Root Chain)
When a user wants to transfer bridged assets from Immutable back to Ethereum, they start a withdrawal. This process moves an asset from the Child chain to the Root chain. It includes burning the user's bridged tokens on the child chain and unlocking the corresponding asset on the Root chain. Only assets that were bridged using the deposit flow described above can be withdrawn. Therefore, the available withdrawal flows are as follows:
1. Native IMX on Immutable zkEVM →  for ERC20 IMX on Ethereum.
2. Wrapped ETH on Immutable zkEVM →  Native ETH on Ethereum
3. Wrapped IMX on Immutable zkEVM →  for ERC20 IMX on Ethereum
4. Wrapped ERC20 on Immutable zkEVM →  Original ERC20 on Ethereum

**Not supported:**
The following capabilities are not currently supported by the Immutable bridge:
- Bridging of tokens that were originally deployed on the Child chain (i.e. ones that do not originate from the Root chain).
- Bridging of non-standard ERC20 tokens
- Bridging of ERC721 or other tokens standards

### Security Features
The bridge employs a number of security features to mitigate the likelihood and impact of potential exploits. These are discussed further in subsections below.

#### IMX Deposit Limit
The total amount of IMX that can be deposited (i.e. sent from the Root chain to the Child chain), is capped at a configurable threshold. In addition to mitigating the potential impact of an exploit, this limit serves to reduce the likelihood of scenarios where the bridge might not have sufficient native IMX to process the deposits on the child chain.

#### Withdrawal Delays
To mitigate the impact of potential exploits, withdrawal transactions (token transfers from the Child chain to the Root chain) may be automatically delayed under certain conditions. By default, this delay is one day. The delay is implemented as a withdrawal queue, which is an array of withdrawal transactions for each user. Once the required delay has passed, a user can finalize a queued withdrawal. The conditions that trigger a withdrawal delay are as follows:
- Specific flow rates can be set for individual tokens. These rates regulate the amount that can be withdrawn over a period of time. If a token's withdrawal rate exceeds its specific threshold, all subsequent withdrawals from the bridge are queued.
- Any withdrawal that exceeds a token-specific amount is queued. This only affects the individual withdrawal in question and does not impact other withdrawals by the same user or others.
- If no thresholds are defined for a given token, all withdrawals relating to that token are queued.

For further details, see the [withdrawal delay mechanism section](#withdrawal-delay-mechanism).

#### Emergency Pause
In the event of an emergency, the bridge can be paused to mitigate the potential impact of an incident. This suspends all user-accessible capabilities, including token mapping, deposits, and withdrawals, until the bridge is resumed. However, this doesn't restrict privileged functions accessible by accounts with certain roles. It allows administrators to perform necessary operations that can address the incident (e.g., bridge parameter changes, upgrades). The specific functions that are halted by the emergency pause mechanism for each contract are listed below:
- **Root Chain**
    - `RootERC20Bridge`: `mapToken()`, `deposit()`, `depositTo()`, `depositETH()`, `depositToETH()`, `onMessageReceive()`
    - `RootERC20BridgeFlowRate` contract: `finaliseQueuedWithdrawal()`, `finaliseQueuedWithdrawalsAggregated()`, as well as all functions from `RootERC20Bridge`.
- **Child Chain:**
    - `ChildERC20Bridge`: `withdraw()`, `withdrawTo()`, `withdrawIMX()`, `withdrawIMXTo()`, `withdrawWIMX()`, `withdrawWIMXTo()`,`onMessageReceive()`

#### Role-Based-Access-Control
The bridge employs fine-grained Role-Based-Access-Controls (RBAC), for privileged operations that control various parameters of the bridge. These include:
- `DEFAULT_ADMIN_ROLE`: Can manage granting and revoking of roles to accounts.
- `VARIABLE_MANAGER_ROLE`: Can update the cumulative IMX deposit limit.
- `RATE_MANAGER_ROLE`: Can enable or disable the withdrawal queue, and configure parameter for each token related to the withdrawal queue.
- `BRIDGE_MANAGER_ROLE`: Can update the bridge used by the adaptor.
- `ADAPTOR_MANAGER_ROLE`: Can update the bridge adaptor.
- `TARGET_MANAGER_ROLE`: Can update targeted bridge used by the adaptor (e.g. target is child chain on root adaptors).
- `GAS_SERVICE_MANAGER_ROLE`: Role identifier for those who can update the gas service used by the adaptor.
- `PAUSER_ROLE`: Role identifier for those who can pause functionanlity.
- `UNPAUSER_ROLE`: Role identifier for those who can unpause functionality

## Build and Test
### Install Dependencies
```shell
$ yarn install
$ forge install
```
### Build

```shell
$ forge build
```

### Testing
To run unit, integration and fuzz tests execute the following command:
```shell
$ forge test --no-match-path "test/{fork,invariant}/**"
```

**Fork Tests**

The fork tests run a suite of tests against one or more deployments of the bridge.
To run these tests copy [`.env.example`](.env.example) file to a `.env` file and set the `MAINNET_RPC_URL` and `TESTNET_RPC_URL` environment variables. Set or update any other environment variables as required. 
Then run the following command to run the fork tests. 

```shell
$ forge test --match-path "test/fork/**"
```

## Contract Deployment
### Local Deployment
To set up the contracts on two separate local networks, we need to start running the local networks, then deploy and initialize the contracts.

1. Set up the two local networks and axelar network
```
yarn local:start
```

2. Run the deployment of contracts
```
yarn local:setup
```

3. Get contract addresses from `./scripts/localdev/.child.bridge.contracts.json` and `./scripts/localdev/.root.bridge.contracts.json`.

4. (Optional) Run end-to-end tests
```
yarn local:test
```

### Remote Deployment

When deploying these contracts on remote networks (i.e. testnet or mainnet), refer to the documentation in [deployment](./scripts/deploy/README.md) or [bootstrap](./scripts/bootstrap/README.md).

## Deployed Contract Addresses
Addresses for the core bridge contracts are listed below. For a full list of deployed contracts see [deployments/](./deployments) directory.
ABIs for contracts can be obtained from the blockchain explorer links for each contract provided below.

### Root Chain
#### Core Contracts

|                        | Mainnet (Ethereum)                                                                                                      | Testnet (Sepolia)                                                                                                                    |
|------------------------|-------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| Bridge Proxy           | [`0xBa5E35E26Ae59c7aea6F029B68c6460De2d13eB6`](https://etherscan.io/address/0xBa5E35E26Ae59c7aea6F029B68c6460De2d13eB6) | [`0x0D3C59c779Fd552C27b23F723E80246c840100F5`](https://sepolia.etherscan.io/address/0x0d3c59c779fd552c27b23f723e80246c840100f5)      |
| Bridge Implementation  | [`0x177EaFe0f1F3359375B1728dae0530a75C83E154`](https://etherscan.io/address/0x177EaFe0f1F3359375B1728dae0530a75C83E154) | [`0xac88a57943b5BBa1ecd931F8494cAd0B7F717590`](https://sepolia.etherscan.io/address/0xac88a57943b5bba1ecd931f8494cad0b7f717590#code) |
| Adaptor Proxy          | [`0x4f49B53928A71E553bB1B0F66a5BcB54Fd4E8932`](https://etherscan.io/address/0x4f49b53928a71e553bb1b0f66a5bcb54fd4e8932) | [`0x6328Ac88ba8D466a0F551FC7C42C61d1aC7f92ab`](https://sepolia.etherscan.io/address/0x6328Ac88ba8D466a0F551FC7C42C61d1aC7f92ab)      |
| Adaptor Implementation | [`0xE2E91C1Ae2873720C3b975a8034e887A35323345`](https://etherscan.io/address/0xE2E91C1Ae2873720C3b975a8034e887A35323345) | [`0xe9ec55e1fC90AB69B2Fb4C029d24a4622B94042e`](https://sepolia.etherscan.io/address/0x6328Ac88ba8D466a0F551FC7C42C61d1aC7f92ab)      |

#### Token Addresses
|             | Mainnet (Ethereum)                                                                                                    | Testnet (Sepolia)                                                                                                               |
|-------------|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| Wrapped ETH | [`0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2`](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2) | [`0x7b79995e5f793a07bc00c21412e50ecae098e7f9`](https://sepolia.etherscan.io/address/0x7b79995e5f793a07bc00c21412e50ecae098e7f9) |
| IMX         | [`0xf57e7e7c23978c3caec3c3548e3d615c346e79ff`](https://etherscan.io/token/0xf57e7e7c23978c3caec3c3548e3d615c346e79ff) | [`0xe2629e08f4125d14e446660028bd98ee60ee69f2`](https://sepolia.etherscan.io/address/0xe2629e08f4125d14e446660028bd98ee60ee69f2) |
| USDC        | [`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`](https://etherscan.io/token/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) | [`0x40b87d235A5B010a20A241F15797C9debf1ecd01`](https://sepolia.etherscan.io/address/0x40b87d235A5B010a20A241F15797C9debf1ecd01) |

### Child Chain
#### Core Contracts
|                        | Mainnet                                                                                                                           | Testnet                                                                                                                                   |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| Bridge Proxy           | [`0xBa5E35E26Ae59c7aea6F029B68c6460De2d13eB6`](https://explorer.immutable.com/address/0xBa5E35E26Ae59c7aea6F029B68c6460De2d13eB6) | [`0x0D3C59c779Fd552C27b23F723E80246c840100F5`](https://explorer.testnet.immutable.com/address/0x0D3C59c779Fd552C27b23F723E80246c840100F5) |
| Bridge Implementation  | [`0xb4c3597e6b090A2f6117780cEd103FB16B071A84`](https://explorer.immutable.com/address/0xb4c3597e6b090A2f6117780cEd103FB16B071A84) | [`0xA554Cf58b9524d43F1dee2fE1b0C928f18A93FE9`](https://explorer.testnet.immutable.com/address/0xA554Cf58b9524d43F1dee2fE1b0C928f18A93FE9) |
| Adaptor Proxy          | [`0x4f49B53928A71E553bB1B0F66a5BcB54Fd4E8932`](https://explorer.immutable.com/address/0x4f49B53928A71E553bB1B0F66a5BcB54Fd4E8932) | [`0x6328Ac88ba8D466a0F551FC7C42C61d1aC7f92ab`](https://explorer.testnet.immutable.com/address/0x6328Ac88ba8D466a0F551FC7C42C61d1aC7f92ab) |
| Adaptor Implementation | [`0x1d49c44dc4BbDE68D8D51a9C5732f3a24e48EFA6`](https://explorer.immutable.com/address/0x1d49c44dc4BbDE68D8D51a9C5732f3a24e48EFA6) | [`0xac88a57943b5BBa1ecd931F8494cAd0B7F717590`](https://explorer.testnet.immutable.com/address/0xac88a57943b5BBa1ecd931F8494cAd0B7F717590) |

#### Token Addresses
|                          | Mainnet                                                                                                                           | Testnet                                                                                                                                   |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| Wrapped ETH              | [`0x52a6c53869ce09a731cd772f245b97a4401d3348`](https://explorer.immutable.com/address/0x52a6c53869ce09a731cd772f245b97a4401d3348) | [`0xe9E96d1aad82562b7588F03f49aD34186f996478`](https://explorer.testnet.immutable.com/address/0xe9E96d1aad82562b7588F03f49aD34186f996478) |
| Wrapped IMX              | [`0x3a0c2ba54d6cbd3121f01b96dfd20e99d1696c9d`](https://explorer.immutable.com/address/0x3a0c2ba54d6cbd3121f01b96dfd20e99d1696c9d) | [`0x1CcCa691501174B4A623CeDA58cC8f1a76dc3439`](https://explorer.testnet.immutable.com/address/0x1CcCa691501174B4A623CeDA58cC8f1a76dc3439) | TBA    |
| USDC                     | [`0x6de8aCC0D406837030CE4dd28e7c08C5a96a30d2`](https://explorer.immutable.com/address/0x6de8aCC0D406837030CE4dd28e7c08C5a96a30d2) | [`0x3B2d8A1931736Fc321C24864BceEe981B11c3c57`](https://explorer.testnet.immutable.com/address/0x3B2d8A1931736Fc321C24864BceEe981B11c3c57) |
| USDT                     | [`0x68bcc7F1190AF20e7b572BCfb431c3Ac10A936Ab`](https://explorer.immutable.com/address/0x68bcc7F1190AF20e7b572BCfb431c3Ac10A936Ab) | TBA                                                                                                                                       |
| Wrapped BTC              | [`0x235F9A2Dc29E51cE7D103bcC5Dfb4F5c9c3371De`](https://explorer.immutable.com/address/0x235F9A2Dc29E51cE7D103bcC5Dfb4F5c9c3371De) | TBA                                                                                                                                       |
| Gods Unchained (GODS)    | [`0xE0e0981D19eF2E0a57Cc48CA60D9454eD2D53fEB`](https://explorer.immutable.com/address/0xE0e0981D19eF2E0a57Cc48CA60D9454eD2D53fEB) | TBA                                                                                                                                       |
| Guild of Guardians (GOG) | [`0xb00ed913aAFf8280C17BfF33CcE82fE6D79e85e8`](https://explorer.immutable.com/address/0xb00ed913aAFf8280C17BfF33CcE82fE6D79e85e8) | TBA                                                                                                                                       |

## Flow Rate Parameters
The [flow rate parameters](./docs/high-level-architecture.md#flow-rate-detection) configured for assets on the Immutable zkEVM mainnet bridge are listed below.
- The *Flow Rate Capacity* is the maximum cumulative amount of a token that can be withdrawn within a 4-hour window. If the total amount of tokens withdrawn within this time window exceeds this threshold, the global withdrawal queue is activated. Consequently, all subsequent withdrawals for all tokens will be queued for 24 hours until the queue is manually deactivated.
- The *Large Withdrawal Threshold* is the size threshold for any single withdrawal of a token. If a withdrawal exceeds this amount, that particular withdrawal is queued for 24 hours on the bridge before it can be redeemed. This queuing does not affect other withdrawals by the same user or other users.

| Token Name                                                                            | Flow-Rate Capacity (4-Hour Window) | Large Withdrawal Threshold |
|---------------------------------------------------------------------------------------|------------------------------------|----------------------------|
| Ethereum                                                                              | 148                                | 29.60                      |
| [IMX](https://etherscan.io/token/0xF57e7e7C23978C3cAEC3C3548E3D615c346e79fF)          | 539,052                            | 107,230                    |
| [USDC](https://etherscan.io/token/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)         | 372,000                            | 74,000                     |
| [USDT](https://etherscan.io/token/0xdAC17F958D2ee523a2206206994597C13D831ec7)         | 372,000                            | 74,000                     |
| [wBTC](https://etherscan.io/token/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)         | 3.37                               | 0.67                       |
| [GODS](https://etherscan.io/token/0xccC8cb5229B0ac8069C51fd58367Fd1e622aFD97)         | 2,310,559                          | 459,627                    |
| [GOG](https://etherscan.io/token/0x9AB7bb7FdC60f4357ECFef43986818A2A3569c62)          | 9,386,828                          | 1,867,272                  |
| [Space Nation](https://etherscan.io/token/0x6e7f11641c1ec71591828e531334192d622703f7) | 15,000,000                         | 220,000                    |

These parameters can also be queried from the L1 bridge contract using a block explorer ([mainnet](https://etherscan.io/address/0xBa5E35E26Ae59c7aea6F029B68c6460De2d13eB6#readProxyContract), [testnet](https://sepolia.etherscan.io/address/0x0d3c59c779fd552c27b23f723e80246c840100f5#readProxyContract)). The `flowRateBuckets()` function provides the bucket capacity and refill rate, while the `largeTransferThreshold()` function provides the withdrawal size threshold configured for a token.
The L1 address of the token to query parameters for needs to be provided as input to both functions.
If flow rate parameters have not been configured for a token, these functions will return zero values.

## Manual Bridging Guide
The process to manually bridge funds from Ethereum to Immutable zkEVM by directly interacting with the bridge contracts is documented [here](docs/manual-bridging.md). However, the recommended method for bridging to and from the Immutable zkEVM is to use the [Immutable Toolkit](https://toolkit.immutable.com/bridge/) user interface.

## Audits
The Immutable token bridge has been audited by [Trail of Bits](https://www.trailofbits.com/). The audit report can be found [here](./audits/Trail-of-Bits-2023-12-14.pdf).
Additionally, the bridge has undergone comprehensive fuzzing and invariant testing conducted by [Perimeter](https://www.perimetersec.io/). The report can be found [here](./audits/Perimeter-Fuzzing-2024-09-10.pdf).

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:51Z`  
Project: `08_immutable`  
Solidity files: `110`

### Structure
Top Solidity directories:
- `test`: 85 `.sol` files
- `src`: 25 `.sol` files

Pragmas:
- `0.8.19`
- `^0.8.0`
- `^0.8.19`

Contracts/Libraries/Interfaces detected: `136`

### Life Total / Balance Values
Detected accounting/state total variables:
- `totalGas` | type: `uint256 public` | vis: `public` | flags: `-` | `ChildHelper` @ `test/invariant/child/ChildHelper.sol`
- `INITIAL_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `INITIAL_WETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `MAX_ERC20_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `1_000_000_000`
- `totalGas` | type: `uint256 public` | vis: `public` | flags: `-` | `RootHelper` @ `test/invariant/root/RootHelper.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol`

All detected state variables (full list):
- `BRIDGE_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdaptorRoles` @ `src/common/AdaptorRoles.sol` = `keccak256("BRIDGE_MANAGER")`
- `GAS_SERVICE_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdaptorRoles` @ `src/common/AdaptorRoles.sol` = `keccak256("GAS_SERVICE_MANAGER")`
- `TARGET_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdaptorRoles` @ `src/common/AdaptorRoles.sol` = `keccak256("TARGET_MANAGER")`
- `ADAPTOR_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRoles` @ `src/common/BridgeRoles.sol` = `keccak256("ADAPTOR_MANAGER")`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRoles` @ `src/common/BridgeRoles.sol` = `keccak256("PAUSER")`
- `UNPAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BridgeRoles` @ `src/common/BridgeRoles.sol` = `keccak256("UNPAUSER")`
- `childBridge` | type: `IChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `gasService` | type: `IAxelarGasService public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `initializerAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `rootBridgeAdaptor` | type: `string public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `rootChainId` | type: `string public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `ROOT_BRIDGE_ADAPTOR` | type: `string public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol` = `Strings.toHexString(address(4))`
- `ROOT_CHAIN_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol` = `"root"`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildAxelarGasService` | type: `MockChildAxelarGasService public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildAxelarGateway` | type: `MockChildAxelarGateway public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildERC20Bridge` | type: `MockChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol`
- `GATEWAY_ADDRESS` | type: `address public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `address(1)`
- `ROOT_BRIDGE_ADAPTOR` | type: `string public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `Strings.toHexString(address(4))`
- `ROOT_CHAIN_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `"root"`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `keccak256("WITHDRAW")`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `bridgeManager` | type: `address` | vis: `default` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `makeAddr("bridgeManager")`
- `gasServiceManager` | type: `address` | vis: `default` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `makeAddr("gasServiceManager")`
- `mockChildAxelarGasService` | type: `MockChildAxelarGasService public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildAxelarGateway` | type: `MockChildAxelarGateway public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildERC20Bridge` | type: `MockChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `roles` | type: `IChildAxelarBridgeAdaptor.InitializationRoles` | vis: `default` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `IChildAxelarBridgeAdaptor.InitializationRoles({})`
- `targetManager` | type: `address` | vis: `default` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol` = `makeAddr("targetManager")`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `_bridge` | type: `address private` | vis: `private` | flags: `-` | `ChildERC20` @ `src/child/ChildERC20.sol`
- `_decimals` | type: `uint8 private` | vis: `private` | flags: `-` | `ChildERC20` @ `src/child/ChildERC20.sol`
- `_rootToken` | type: `address private` | vis: `private` | flags: `-` | `ChildERC20` @ `src/child/ChildERC20.sol`
- `DEPOSIT_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `keccak256("DEPOSIT")`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `address(0xfff)`
- `PRIVILEGED_DEPOSITOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `keccak256("PRIVILEGED_DEPOSITOR")`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `keccak256("WITHDRAW")`
- `childBridgeAdaptor` | type: `IChildBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `childTokenTemplate` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `initializerAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `rootIMXToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `rootTokenToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `wIMXToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `MAX_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol` = `10000`
- `MAX_GAS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol` = `100`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `childId` | type: `uint256` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `rootId` | type: `uint256` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `users` | type: `address[]` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xeee)`
- `ROOT_ADAPTOR_ADDRESS` | type: `string public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `Strings.toHexString(address(1))`
- `ROOT_CHAIN_NAME` | type: `string public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `"ROOT_CHAIN"`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xabc)`
- `childAxelarBridgeAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `childERC20` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `childERC20Bridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `mockChildAxelarGasService` | type: `MockChildAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `mockChildAxelarGateway` | type: `MockChildAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `DEPOSIT_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `keccak256("DEPOSIT")`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `address(0xfff)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `address(0xccc)`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `keccak256("WITHDRAW")`
- `bridge` | type: `ChildERC20Bridge` | vis: `default` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `wIMX` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `CHILD_WIMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xabc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xeee)`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xccc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `initialDepositor` | type: `address` | vis: `default` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `makeAddr("initialDepositor")`
- `roles` | type: `IChildERC20Bridge.InitializationRoles` | vis: `default` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `IChildERC20Bridge.InitializationRoles({})`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `treasuryManager` | type: `address` | vis: `default` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `makeAddr("treasuryManager")`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol` = `address(0xeee)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `mockAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol` = `address(0xeee)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `mockAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xeee)`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(3)`
- `CHILD_BRIDGE_ADAPTOR` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(4)`
- `CHILD_CHAIN_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `"test"`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(555555)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(0xddd)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xeee)`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `mockAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `receiver` | type: `address` | vis: `default` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol` = `address(0xabcd)`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `withdrawAmount` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol` = `99999999999`
- `withdrawFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol` = `200`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `mockAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `receiver` | type: `address` | vis: `default` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol` = `address(0xabcd)`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `withdrawAmount` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol` = `99999999999`
- `withdrawFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol` = `200`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xeee)`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xeee)`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol` = `address(555555)`
- `WRAPPED_IMX` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol` = `address(0xabc)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `mockAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol` = `address(555555)`
- `WRAPPED_IMX` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol` = `address(0xabc)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `ROOT_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol` = `address(3)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol` = `address(0xccc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `mockAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(3)`
- `CHILD_BRIDGE_ADAPTOR` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(4)`
- `CHILD_CHAIN_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `"test"`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(555555)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(0xddd)`
- `axelarAdaptor` | type: `ChildAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `DEFAULT_CHILDERC20_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol` = `address(111)`
- `DEFAULT_CHILDERC20_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol` = `18`
- `DEFAULT_CHILDERC20_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol` = `"Child ERC20"`
- `DEFAULT_CHILDERC20_SYMBOL` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol` = `"CERC"`
- `DEFAULT_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol` = `18`
- `DEFAULT_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol` = `"Test ERC20"`
- `DEFAULT_ROOT_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol` = `address(111)`
- `DEFAULT_SYMBOL` | type: `string constant` | vis: `default` | flags: `constant` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol` = `"TEST"`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildHelper` @ `test/invariant/child/ChildHelper.sol`
- `totalGas` | type: `uint256 public` | vis: `public` | flags: `-` | `ChildHelper` @ `test/invariant/child/ChildHelper.sol`
- `META_TRANSACTION_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `EIP712MetaTransaction` @ `src/lib/EIP712MetaTransaction.sol` = `keccak256(bytes("MetaTransaction(uint256 nonce,address from,bytes functionSignature)"))`
- `nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `EIP712MetaTransaction` @ `src/lib/EIP712MetaTransaction.sol`
- `_CACHED_CHAIN_ID` | type: `uint256 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `_CACHED_DOMAIN_SEPARATOR` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `_CACHED_THIS` | type: `address private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `_HASHED_NAME` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `_HASHED_VERSION` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `_TYPE_HASH` | type: `bytes32 private` | vis: `private` | flags: `-` | `EIP712Upgradeable` @ `src/lib/EIP712Upgradeable.sol`
- `withdrawalQueueActivated` | type: `bool public` | vis: `public` | flags: `-` | `FlowRateDetection` @ `src/root/flowrate/FlowRateDetection.sol`
- `CAPACITY` | type: `uint256 public` | vis: `public` | flags: `-` | `FlowRateDetectionTests` @ `test/unit/root/flowrate/FlowRateDetection.t.sol` = `10000`
- `REFILL_RATE` | type: `uint256 public` | vis: `public` | flags: `-` | `FlowRateDetectionTests` @ `test/unit/root/flowrate/FlowRateDetection.t.sol` = `50`
- `TOKEN` | type: `address public` | vis: `public` | flags: `-` | `FlowRateDetectionTests` @ `test/unit/root/flowrate/FlowRateDetection.t.sol` = `address(1000)`
- `flowRateDetection` | type: `FlowRateDetectionT` | vis: `default` | flags: `-` | `FlowRateDetectionTests` @ `test/unit/root/flowrate/FlowRateDetection.t.sol`
- `DEFAULT_WITHDRAW_DELAY` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `FlowRateWithdrawalQueue` @ `src/root/flowrate/FlowRateWithdrawalQueue.sol` = `1 days`
- `DEFAULT_WITHDRAW_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `FlowRateWithdrawalQueueT` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `60 * 60 * 24`
- `flowRateWithdrawalQueue` | type: `FlowRateWithdrawalQueueT` | vis: `default` | flags: `-` | `FlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol`
- `COVERAGE_GAP` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `1000`
- `DEPOSIT_SIG` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `keccak256("DEPOSIT")`
- `EXECUTE_WHEN_PAUSED_ODDS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `100`
- `IMX_DEPOSIT_LIMIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `INITIAL_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `INITIAL_WETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `MAX_ERC20_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `1_000_000_000`
- `MAX_IN_QUEUE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `20`
- `MAX_REFILL_RATE_GAP` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `3600`
- `MAX_WITHDRAWAL_DELAY` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `1209600`
- `NATIVE_ETH` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0xfff)`
- `NOTHING_SIG` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `keccak256("NOTHING")`
- `USER1` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0x10001)`
- `USER2` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0x20001)`
- `USER3` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0x30001)`
- `USERS` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `[USER1, USER2, USER3]`
- `WITHDRAW_SIG` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `keccak256("WITHDRAW")`
- `DEBUG` | type: `bool internal constant` | vis: `internal` | flags: `constant` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol` = `false`
- `OPTIMIZATION_ENABLED` | type: `bool internal constant` | vis: `internal` | flags: `constant` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol` = `false`
- `_setActor` | type: `bool internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol` = `true`
- `allTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childERC20Bridge` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childETHToken` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childEightDecimalGenerated` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childEighteenDecimalGenerated` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childSixDecimalGenerated` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `currentActor` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `mockAdaptorChild` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `mockAdaptorRoot` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootERC20BridgeFlowRate` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootEightDecimalInitial` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootEighteenDecimalInitial` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootIMXToken` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootSixDecimalInitial` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `targets` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `tokenTemplate` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `wETH` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `wIMX` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `ADMIN` | type: `address public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `address(0x111)`
- `CHAIN_URL` | type: `string public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `"http: uint256 public constant IMX_DEPOSIT_LIMIT = 10000 ether`
- `MAX_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `10000`
- `NO_OF_TOKENS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `10`
- `NO_OF_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `20`
- `childAdaptor` | type: `MockAdaptor` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childBridge` | type: `ChildERC20Bridge` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childBridgeHandler` | type: `ChildERC20BridgeHandler` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childId` | type: `uint256` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `mappingGas` | type: `uint256` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `resetId` | type: `uint256` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootAdaptor` | type: `MockAdaptor` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootBridge` | type: `RootERC20BridgeFlowRate` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootBridgeHandler` | type: `RootERC20BridgeFlowRateHandler` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootId` | type: `uint256` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `users` | type: `address[]` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `bridge` | type: `MessageReceiver` | vis: `default` | flags: `-` | `MockAdaptor` @ `test/fuzzing/mocks/MockAdaptor.sol`
- `chainManager` | type: `IChainManager` | vis: `default` | flags: `-` | `MockAdaptor` @ `test/invariant/MockAdaptor.sol`
- `messageReceiver` | type: `MessageReceiver` | vis: `default` | flags: `-` | `MockAdaptor` @ `test/invariant/MockAdaptor.sol`
- `otherChainId` | type: `uint256` | vis: `default` | flags: `-` | `MockAdaptor` @ `test/fuzzing/mocks/MockAdaptor.sol`
- `otherChainId` | type: `uint256` | vis: `default` | flags: `-` | `MockAdaptor` @ `test/invariant/MockAdaptor.sol`
- `RUSER1` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(12345)`
- `RUSER2` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(12346)`
- `TOKEN1` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(1000012)`
- `TOKEN2` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(100123)`
- `TOKEN3` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(100456)`
- `WUSER1` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(12223345)`
- `WUSER2` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(11112346)`
- `withdrawalDelay` | type: `uint256 public` | vis: `public` | flags: `-` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol`
- `BAL_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-01: The WETH balance of the root bridge should always be 0"`
- `BAL_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-02: The WIMX balance of the child bridge should always be 0"`
- `BAL_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-03: The native balance of the root adaptor increases by exactly the gas fees paid by the users"`
- `BAL_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-04: The native balance of the child adaptor increases by exactly the gas fees paid by the users"`
- `BAL_05` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-05: The token balance, excluding WETH, of the root bridge increases by exactly the amount of tokens deposited by the user"`
- `BAL_06` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-06: The native balance of the root bridge increases by exactly the amount of WETH deposited by the user"`
- `BAL_07` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-07: When depositing ETH, the native balance of the root bridge increases by exactly the amount deposited by the user, minus the gas fees"`
- `BAL_08` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-08: When withdrawing IMX, the native balance of the child bridge increases by exactly the amount withdrawn by the user, minus the gas fees"`
- `BAL_09` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"BAL-09: The native balance of the child bridge decreases by exactly the amount of root ERC20 IMX deposited by the user"`
- `CLDREV_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-01: onMessageReceive for the child bridge never reverts unexpectedly"`
- `CLDREV_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-02: pause for the child bridge never reverts"`
- `CLDREV_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-03: unpause for the child bridge never reverts"`
- `CLDREV_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-04: withdraw never reverts unexpectedly"`
- `CLDREV_05` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-05: withdrawETH never reverts unexpectedly"`
- `CLDREV_06` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-06: withdrawETHTo never reverts unexpectedly"`
- `CLDREV_07` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-07: withdrawIMX never reverts unexpectedly"`
- `CLDREV_08` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-08: withdrawIMXTo never reverts unexpectedly"`
- `CLDREV_09` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-09: withdrawTo never reverts unexpectedly"`
- `CLDREV_10` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-10: withdrawWIMX never reverts unexpectedly"`
- `CLDREV_11` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"CLDREV-11: withdrawWIMXTo never reverts unexpectedly"`
- `FLRT_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-01: If imxCumulativeDepositLimit is not 0, the rootIMX token balance of the root bridge should always be less than or equal to imxCumulativeDepositLimit"`
- `FLRT_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-02: If the withdrawal amount is greater than the largeTransferThreshold, the withdrawal must be added to the user's withdrawal queue"`
- `FLRT_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-03: If the bucket capacity for a token is 0, then any withdrawal of that token must be added to the user's withdrawal queue"`
- `FLRT_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-04: If withdrawalQueueActivated is true, then any withdrawal of any token must be added to the user's withdrawal queue"`
- `FLRT_05` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-05: If finaliseQueuedWithdrawal is successfully called, then the queued withdrawal initiated timestamp plus the withdrawal delay must be less than or equal to the current block timestamp"`
- `FLRT_06` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-06: After a successful withdrawal of a non-zero amount on the root bridge, if the bucket capacity is not zero, then the token bucket depth is never equal to the bucket capacity"`
- `FLRT_07` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-07: After a successful withdraw on the root bridge, if the withdrawn amount is less than the minimum of the refill rate multiplied by the time elapsed since last withdrawal and the bucket capacity minus the prior real bucket depth, then the bucket depth strictly increases"`
- `FLRT_08` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-08: After a successful withdraw on the root bridge, the bucket depth is always less than or equal to the bucket capacity"`
- `FLRT_09` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-09: When the withdrawalQueue is not activated, after a successful withdrawal of an amount less than the largeTransferThreshold on the root bridge and a withdrawal was added to the user's withdrawal queue, the bucket depth is always 0"`
- `FLRT_10` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-10: When the withdrawalQueue is not activated, after a successful withdrawal of an amount less than the largeTransferThreshold on the root bridge, if the withdrawn amount is greater or equal to minimum of the refill rate multiplied by the time elapsed since last withdrawal plus the prior real bucket depth and the bucket capacity, then the withdrawal must be added to the user's withdrawal queue"`
- `FLRT_11` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-11: If the depth of the token bucket is non-zero before a successful withdrawal on the root bridge and the depth of the token bucket is zero after the withdrawal, then the withdrawal queue must be activated"`
- `FLRT_12` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"FLRT-12: After each successful withdrawal on the root bridge for a token with a non-zero capacity, the bucket refillTime is always updated to the current block timestamp"`
- `PAUSE_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-01: deposit always reverts when the root bridge is paused"`
- `PAUSE_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-02: depositETH always reverts when the root bridge is paused"`
- `PAUSE_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-03: depositTo always reverts when the root bridge is paused"`
- `PAUSE_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-04: depositToETH always reverts when the root bridge is paused"`
- `PAUSE_05` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-05: finaliseQueuedWithdrawal always reverts when the root bridge is paused"`
- `PAUSE_06` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-06: finaliseQueuedWithdrawalAggregated always reverts when the root bridge is paused"`
- `PAUSE_07` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-07: onMessageReceive for the root bridge always reverts when the root bridge is paused"`
- `PAUSE_08` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-08: withdraw always reverts when the child bridge is paused"`
- `PAUSE_09` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-09: withdrawETH always reverts when the child bridge is paused"`
- `PAUSE_10` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-10: withdrawETHTo always reverts when the child bridge is paused"`
- `PAUSE_11` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-11: withdrawIMX always reverts when the child bridge is paused"`
- `PAUSE_12` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-12: withdrawIMXTo always reverts when the child bridge is paused"`
- `PAUSE_13` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-13: withdrawTo always reverts when the child bridge is paused"`
- `PAUSE_14` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-14: withdrawWIMX always reverts when the child bridge is paused"`
- `PAUSE_15` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-15: withdrawWIMXTo always reverts when the child bridge is paused"`
- `PAUSE_16` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"PAUSE-16: onMessageReceive for the child bridge always reverts when the child bridge is paused"`
- `RTREV_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-01: activateWithdrawalQueue never reverts"`
- `RTREV_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-02: deactivateWithdrawalQueue never reverts"`
- `RTREV_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-03: deposit never reverts unexpectedly"`
- `RTREV_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-04: depositETH never reverts unexpectedly"`
- `RTREV_05` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-05: depositTo never reverts unexpectedly"`
- `RTREV_06` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-06: depositToETH never reverts unexpectedly"`
- `RTREV_07` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-07: finaliseQueuedWithdrawal never reverts unexpectedly"`
- `RTREV_08` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-08: finaliseQueuedWithdrawalAggregated never reverts unexpectedly"`
- `RTREV_09` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-09: onMessageReceive for the root bridge never reverts unexpectedly"`
- `RTREV_10` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-10: pause for the root bridge never reverts"`
- `RTREV_11` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-11: setRateControlThreshold never reverts"`
- `RTREV_12` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-12: setWithdrawalDelay never reverts"`
- `RTREV_13` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-13: unpause for the root bridge never reverts"`
- `RTREV_14` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"RTREV-14: updateImxCumulativeDepositLimit never reverts unexpectedly"`
- `SPLY_01` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"SPLY-01: The sum of the token balances of each user and the bridges should be exactly equal to the token total supply"`
- `SPLY_02` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"SPLY-02: The total supply of root WETH must be decreased by the amount of WETH deposited by the user"`
- `SPLY_03` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"SPLY-03: The total supply of child ERC20s must be increased by exactly the amount of tokens deposited by the user"`
- `SPLY_04` | type: `string internal constant` | vis: `internal` | flags: `constant` | `PropertiesDescriptions` @ `test/fuzzing/properties/PropertiesDescriptions.sol` = `"SPLY-04: The total supply of child ERC20s must be decreased by exactly the amount of tokens withdrawn by the user"`
- `bridge` | type: `IRootERC20Bridge` | vis: `default` | flags: `-` | `ReentrancyAttackDeposit` @ `test/unit/root/RootERC20Bridge.t.sol`
- `attackWithdrawal` | type: `bool` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `bridge` | type: `RootERC20BridgeFlowRate` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `idx` | type: `uint256` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `idxs` | type: `uint256[]` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `rerun` | type: `uint256` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `0`
- `bridgeContract` | type: `IChildERC20Bridge` | vis: `default` | flags: `-` | `ReentrancyAttackWithdraw` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `childBridgeAdaptor` | type: `string public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `childChainId` | type: `string public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `gasService` | type: `IAxelarGasService public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `initializerAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `rootBridge` | type: `IRootERC20Bridge public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `address(3)`
- `CHILD_BRIDGE_ADAPTOR` | type: `string public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol` = `Strings.toHexString(address(4))`
- `CHILD_BRIDGE_ADAPTOR` | type: `address constant` | vis: `default` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `address(4)`
- `CHILD_BRIDGE_ADAPTOR_STRING` | type: `string` | vis: `default` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `Strings.toHexString(CHILD_BRIDGE_ADAPTOR)`
- `CHILD_CHAIN_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol` = `"child"`
- `CHILD_CHAIN_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `"test"`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `keccak256("MAP_TOKEN")`
- `axelarAdaptor` | type: `RootAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol`
- `axelarAdaptor` | type: `RootAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `bridgeManager` | type: `address` | vis: `default` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `makeAddr("bridgeManager")`
- `gasServiceManager` | type: `address` | vis: `default` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `makeAddr("gasServiceManager")`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `mockRootAxelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol`
- `mockRootAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol`
- `mockRootERC20Bridge` | type: `StubRootBridge public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/fuzz/root/RootAxelarBridgeAdaptor.t.sol`
- `roles` | type: `IRootAxelarBridgeAdaptor.InitializationRoles public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `IRootAxelarBridgeAdaptor.InitializationRoles({})`
- `stubRootBridge` | type: `StubRootBridge public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `targetManager` | type: `address` | vis: `default` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `makeAddr("targetManager")`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `DEPOSIT_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `keccak256("DEPOSIT")`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `address(0xfff)`
- `UNLIMITED_DEPOSIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `0`
- `VARIABLE_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `keccak256("VARIABLE_MANAGER")`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `keccak256("WITHDRAW")`
- `childERC20Bridge` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `childTokenTemplate` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `imxCumulativeDepositLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `initializerAddress` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootBridgeAdaptor` | type: `IRootBridgeAdaptor public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootIMXToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootTokenToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootWETHToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `RATE_CONTROL_ROLE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RootERC20BridgeFlowRate` @ `src/root/flowrate/RootERC20BridgeFlowRate.sol` = `keccak256("RATE")`
- `largeTransferThresholds` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRate` @ `src/root/flowrate/RootERC20BridgeFlowRate.sol`
- `ETH` | type: `address private constant` | vis: `private` | flags: `constant` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `bridgeInEnv` | type: `mapping(string => RootERC20BridgeFlowRate) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `deployment` | type: `string private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `deployments` | type: `string[] private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol` = `vm.envString("DEPLOYMENTS", ",")`
- `forkIdForEnv` | type: `mapping(string => uint256) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `rpcURLForEnv` | type: `mapping(string => string) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `tokensForEnv` | type: `mapping(string => address[]) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `MAX_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol` = `10000`
- `MAX_GAS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol` = `100`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `childId` | type: `uint256` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `rootId` | type: `uint256` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `users` | type: `address[]` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(3)`
- `CHILD_BRIDGE_ADAPTOR` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(4)`
- `CHILD_CHAIN_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `"test"`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `UNLIMITED_DEPOSIT_LIMIT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `0`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xddd)`
- `axelarAdaptor` | type: `RootAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `depositFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `200`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `300`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `BANK_OF_CHARLIE_TREASURY` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `BRIDGED_VALUE + CHARLIE_REMAINDER`
- `BRIDGED_VALUE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `CAPACITY * 100`
- `BRIDGED_VALUE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `CAPACITY_ETH * 100`
- `CAPACITY` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `1000000`
- `CAPACITY_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `1000000 ether`
- `CHARLIE_REMAINDER` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `17`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(3)`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xccc)`
- `LARGE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `100000`
- `LARGE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `100000 ether`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `PAUSER_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `keccak256("PAUSER")`
- `RATE_CONTROL_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `keccak256("RATE")`
- `REFILL_RATE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `277`
- `REFILL_RATE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `277 ether`
- `UNLIMITED_IMX_DEPOSITS` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `0`
- `UNPAUSER_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `keccak256("UNPAUSER")`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xddd)`
- `alice` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `bob` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `charlie` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `mockAxelarAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `nonAdmin` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `pauseAdmin` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `rateAdmin` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `superAdmin` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `unpauseAdmin` | type: `address` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `withdrawalDelay` | type: `uint256` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(3)`
- `CHILD_BRIDGE_ADAPTOR` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(4)`
- `CHILD_CHAIN_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `"CHILD"`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xfff)`
- `UNLIMITED_DEPOSIT_LIMIT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `0`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xddd)`
- `axelarAdaptor` | type: `RootAxelarBridgeAdaptor public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `withdrawAmount` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `0.5 ether`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `address(3)`
- `DEPOSIT_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `keccak256("DEPOSIT")`
- `IMX_DEPOSITS_LIMIT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `10000 ether`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `keccak256("MAP_TOKEN")`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `keccak256("WITHDRAW")`
- `bridge` | type: `RootERC20Bridge` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `imxToken` | type: `ChildERC20` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `mockAdaptor` | type: `MockAdaptor` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `wETH` | type: `WETH` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(3)`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xeee)`
- `UNLIMITED_IMX_DEPOSITS` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `0`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xddd)`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `depositFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `200`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `300`
- `mockAxelarAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `rootBridge` | type: `RootERC20Bridge public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `CHILD_BRIDGE` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(3)`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xeee)`
- `NATIVE_IMX` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xfff)`
- `UNLIMITED_IMX_DEPOSIT_LIMIT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `0`
- `UnmappedToken` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xbbb)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xddd)`
- `axelarGasService` | type: `MockAxelarGasService public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `300`
- `mockAxelarAdaptor` | type: `MockAdaptor public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `mockAxelarGateway` | type: `MockAxelarGateway public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `rootBridge` | type: `RootERC20Bridge public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `withdrawAmount` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `0.5 ether`
- `admin` | type: `address` | vis: `default` | flags: `-` | `RootHelper` @ `test/invariant/root/RootHelper.sol`
- `rootBridge` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootHelper` @ `test/invariant/root/RootHelper.sol`
- `totalGas` | type: `uint256 public` | vis: `public` | flags: `-` | `RootHelper` @ `test/invariant/root/RootHelper.sol`
- `adaptorManager` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/BridgeRoles.t.sol` = `makeAddr("adaptorManager")`
- `admin` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/AdaptorRoles.t.sol` = `makeAddr("admin")`
- `admin` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/BridgeRoles.t.sol` = `makeAddr("admin")`
- `bridgeManager` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/AdaptorRoles.t.sol` = `makeAddr("bridgeManager")`
- `gasServiceManager` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/AdaptorRoles.t.sol` = `makeAddr("gasServiceManager")`
- `mockAdaptorRoles` | type: `MockAdaptorRoles` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/AdaptorRoles.t.sol`
- `mockBridgeRoles` | type: `MockBridgeRoles` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/BridgeRoles.t.sol`
- `pauser` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/BridgeRoles.t.sol` = `makeAddr("pauser")`
- `targetManager` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/AdaptorRoles.t.sol` = `makeAddr("targetManager")`
- `unpauser` | type: `address` | vis: `default` | flags: `-` | `Setup` @ `test/unit/common/BridgeRoles.t.sol` = `makeAddr("unpauser")`
- `TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `UninitializedFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(126)`
- `USER` | type: `address constant` | vis: `default` | flags: `constant` | `UninitializedFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(125)`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Utils` @ `test/utils.t.sol` = `keccak256("MAP_TOKEN")`
- `WITHDRAW_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Utils` @ `test/utils.t.sol` = `keccak256("WITHDRAW")`
- `pauser` | type: `address` | vis: `default` | flags: `-` | `Utils` @ `test/utils.t.sol` = `makeAddr("pauser")`
- `unpauser` | type: `address` | vis: `default` | flags: `-` | `Utils` @ `test/utils.t.sol` = `makeAddr("unpauser")`
- `allowance` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol` = `18`
- `name` | type: `string public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol` = `"Wrapped ETH"`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `WETH` @ `src/lib/WETH.sol` = `"WETH"`
- `allowance` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol` = `18`
- `name` | type: `string public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol` = `"Wrapped IMX"`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `WIMX` @ `src/child/WIMX.sol` = `"WIMX"`
- `DEFAULT_WIMX_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `WIMXTest` @ `test/unit/child/WIMX.t.sol` = `"Wrapped IMX"`
- `DEFAULT_WIMX_SYMBOL` | type: `string constant` | vis: `default` | flags: `constant` | `WIMXTest` @ `test/unit/child/WIMX.t.sol` = `"WIMX"`
- `wIMX` | type: `WIMX public` | vis: `public` | flags: `-` | `WIMXTest` @ `test/fuzz/child/WIMX.t.sol`
- `wIMX` | type: `WIMX public` | vis: `public` | flags: `-` | `WIMXTest` @ `test/unit/child/WIMX.t.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `childBridge` | type: `IChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptor` @ `src/child/ChildAxelarBridgeAdaptor.sol`
- `mockChildERC20Bridge` | type: `MockChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorTest` @ `test/fuzz/child/ChildAxelarBridgeAdaptor.t.sol`
- `mockChildERC20Bridge` | type: `MockChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `ChildAxelarBridgeAdaptorUnitTest` @ `test/unit/child/ChildAxelarBridgeAdaptor.t.sol`
- `_rootToken` | type: `address private` | vis: `private` | flags: `-` | `ChildERC20` @ `src/child/ChildERC20.sol`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol` = `address(0xeee)`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `childTokenTemplate` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `rootIMXToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `rootTokenToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `wIMXToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20Bridge` @ `src/child/ChildERC20Bridge.sol`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `ChildERC20BridgeHandler` @ `test/invariant/child/ChildERC20BridgeHandler.sol`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xeee)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol` = `address(0xabc)`
- `childERC20` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `childERC20Bridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeIntegrationTest` @ `test/integration/child/ChildAxelarBridge.t.sol`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol` = `address(0xccc)`
- `bridge` | type: `ChildERC20Bridge` | vis: `default` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeTest` @ `test/fuzz/child/ChildERC20Bridge.t.sol`
- `CHILD_WIMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xabc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `address(0xccc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `roles` | type: `IChildERC20Bridge.InitializationRoles` | vis: `default` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol` = `IChildERC20Bridge.InitializationRoles({})`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeUnitTest` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol` = `address(0xeee)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETH.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol` = `address(0xeee)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawETHTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETHTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `childETHToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawETHUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawETH.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(555555)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol` = `address(0xddd)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawIMX.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMXTo.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawIMX.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdraw.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawTo.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `rootToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdraw.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol` = `address(555555)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMX.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol` = `address(555555)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawWIMXTo.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol` = `address(0xccc)`
- `WIMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol` = `address(0xabc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXToUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMXTo.t.sol`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol` = `address(0xccc)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `wIMXToken` | type: `WIMX public` | vis: `public` | flags: `-` | `ChildERC20BridgeWithdrawWIMXUnitTest` @ `test/unit/child/withdrawals/ChildERC20BridgeWithdrawWIMX.t.sol`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(0xeee)`
- `ROOT_IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(555555)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol` = `address(0xddd)`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `childTokenTemplate` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `rootImxToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `rootToken` | type: `address public` | vis: `public` | flags: `-` | `ChildERC20BridgewithdrawIMXToIntegrationTest` @ `test/integration/child/withdrawals/ChildAxelarBridgeWithdrawToIMX.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20Test` @ `test/fuzz/child/ChildERC20.t.sol`
- `childToken` | type: `ChildERC20 public` | vis: `public` | flags: `-` | `ChildERC20Test` @ `test/unit/child/ChildERC20.t.sol`
- `childBridge` | type: `ChildERC20Bridge public` | vis: `public` | flags: `-` | `ChildHelper` @ `test/invariant/child/ChildHelper.sol`
- `TOKEN` | type: `address public` | vis: `public` | flags: `-` | `FlowRateDetectionTests` @ `test/unit/root/flowrate/FlowRateDetection.t.sol` = `address(1000)`
- `INITIAL_WETH_BALANCE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `500_000 ether`
- `NATIVE_ETH` | type: `address internal constant` | vis: `internal` | flags: `constant` | `FuzzConstants` @ `test/fuzzing/util/FuzzConstants.sol` = `address(0xeee)`
- `allTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childETHToken` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `childTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootIMXToken` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `rootTokens` | type: `address[] internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `tokenTemplate` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `wETH` | type: `address internal` | vis: `internal` | flags: `-` | `FuzzStorageVariables` @ `test/fuzzing/helper/FuzzStorageVariables.sol`
- `NO_OF_TOKENS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol` = `10`
- `childBridge` | type: `ChildERC20Bridge` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childBridgeHandler` | type: `ChildERC20BridgeHandler` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootBridge` | type: `RootERC20BridgeFlowRate` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootBridgeHandler` | type: `RootERC20BridgeFlowRateHandler` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `InvariantBridge` @ `test/invariant/InvariantBridge.t.sol`
- `TOKEN1` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(1000012)`
- `TOKEN2` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(100123)`
- `TOKEN3` | type: `address constant` | vis: `default` | flags: `constant` | `OperationalFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(100456)`
- `bridge` | type: `IRootERC20Bridge` | vis: `default` | flags: `-` | `ReentrancyAttackDeposit` @ `test/unit/root/RootERC20Bridge.t.sol`
- `bridge` | type: `RootERC20BridgeFlowRate` | vis: `default` | flags: `-` | `ReentrancyAttackERC20` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `bridgeContract` | type: `IChildERC20Bridge` | vis: `default` | flags: `-` | `ReentrancyAttackWithdraw` @ `test/unit/child/ChildERC20Bridge.t.sol`
- `rootBridge` | type: `IRootERC20Bridge public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptor` @ `src/root/RootAxelarBridgeAdaptor.sol`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol` = `keccak256("MAP_TOKEN")`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootAxelarBridgeAdaptorTest` @ `test/unit/root/RootAxelarBridgeAdaptor.t.sol`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `keccak256("MAP_TOKEN")`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol` = `address(0xeee)`
- `childETHToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `childTokenTemplate` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootIMXToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootTokenToChildToken` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `rootWETHToken` | type: `address public` | vis: `public` | flags: `-` | `RootERC20Bridge` @ `src/root/RootERC20Bridge.sol`
- `ETH` | type: `address private constant` | vis: `private` | flags: `constant` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `bridgeInEnv` | type: `mapping(string => RootERC20BridgeFlowRate) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `tokensForEnv` | type: `mapping(string => address[]) private` | vis: `private` | flags: `-` | `RootERC20BridgeFlowRateForkTest` @ `test/fork/root/RootERC20BridgeFlowRate.t.sol`
- `childHelper` | type: `ChildHelper` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `rootHelper` | type: `RootHelper` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `rootTokens` | type: `address[]` | vis: `default` | flags: `-` | `RootERC20BridgeFlowRateHandler` @ `test/invariant/root/RootERC20BridgeFlowRateHandler.sol`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `address(0xddd)`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol` = `300`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateIntegrationTest` @ `test/integration/root/RootERC20BridgeFlowRate.t.sol`
- `BRIDGED_VALUE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `CAPACITY_ETH * 100`
- `CAPACITY_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `1000000 ether`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xccc)`
- `LARGE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `100000 ether`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xeee)`
- `REFILL_RATE_ETH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `277 ether`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol` = `address(0xddd)`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateUnitTest` @ `test/unit/root/flowrate/RootERC20BridgeFlowRate.t.sol`
- `IMX_TOKEN_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xeee)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol` = `address(0xddd)`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `rootBridgeFlowRate` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeFlowRateWithdrawIntegrationTest` @ `test/integration/root/withdrawals/RootERC20BridgeFlowRateWithdraw.t.sol`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol` = `keccak256("MAP_TOKEN")`
- `bridge` | type: `RootERC20Bridge` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `childTokenTemplate` | type: `ChildERC20` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `imxToken` | type: `ChildERC20` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `wETH` | type: `WETH` | vis: `default` | flags: `-` | `RootERC20BridgeTest` @ `test/fuzz/root/RootERC20Bridge.t.sol`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xeee)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `address(0xddd)`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol` = `300`
- `rootBridge` | type: `RootERC20Bridge public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeUnitTest` @ `test/unit/root/RootERC20Bridge.t.sol`
- `IMX_TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xccc)`
- `NATIVE_ETH` | type: `address public constant` | vis: `public` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xeee)`
- `UnmappedToken` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xbbb)`
- `WRAPPED_ETH` | type: `address constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `address(0xddd)`
- `imxToken` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `mapTokenFee` | type: `uint256 constant` | vis: `default` | flags: `constant` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol` = `300`
- `rootBridge` | type: `RootERC20Bridge public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `token` | type: `ERC20PresetMinterPauser public` | vis: `public` | flags: `-` | `RootERC20BridgeWithdrawUnitTest` @ `test/unit/root/withdrawals/RootERC20BridgeWithdraw.t.sol`
- `rootBridge` | type: `RootERC20BridgeFlowRate public` | vis: `public` | flags: `-` | `RootHelper` @ `test/invariant/root/RootHelper.sol`
- `TOKEN` | type: `address constant` | vis: `default` | flags: `constant` | `UninitializedFlowRateWithdrawalQueueTests` @ `test/unit/root/flowrate/FlowRateWithdrawalQueue.t.sol` = `address(126)`
- `MAP_TOKEN_SIG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Utils` @ `test/utils.t.sol` = `keccak256("MAP_TOKEN")`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `ActorStates` (test/fuzzing/helper/BeforeAfter.sol): uint256 queueLength
- `Bucket` (src/root/flowrate/FlowRateDetection.sol): uint256 capacity, uint256 depth, uint256 refillTime, uint256 refillRate
- `DepositETHParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): uint256 amount, uint256 value
- `DepositParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address rootToken, uint256 amount, uint256 value
- `DepositToETHParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address receiver, uint256 amount, uint256 value
- `DepositToParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address rootToken, address receiver, uint256 amount, uint256 value
- `FinaliseQueuedWithdrawalParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address receiver, uint256 index
- `FinaliseQueuedWithdrawalsAggregatedParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address receiver, address token, uint256[] indices
- `FindPendingWithdrawal` (src/root/flowrate/FlowRateWithdrawalQueue.sol): uint256 index, uint256 amount, uint256 timestamp
- `InitializationRoles` (src/interfaces/child/IChildAxelarBridgeAdaptor.sol): address defaultAdmin, address bridgeManager, address gasServiceManager, address targetManager
- `InitializationRoles` (src/interfaces/child/IChildERC20Bridge.sol): address defaultAdmin, address pauser, address unpauser, address adaptorManager, address initialDepositor, address treasuryManager
- `InitializationRoles` (src/interfaces/root/IRootAxelarBridgeAdaptor.sol): address defaultAdmin, address bridgeManager, address gasServiceManager, address targetManager
- `InitializationRoles` (src/interfaces/root/IRootERC20Bridge.sol): address defaultAdmin, address pauser, address unpauser, address variableManager, address adaptorManager
- `MetaTransaction` (src/lib/EIP712MetaTransaction.sol): uint256 nonce, address from, bytes functionSignature
- `OnMessageReceiveChildParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): bytes data, address rootToken, uint256 amount, address sender, address receiver
- `OnMessageReceiveRootParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): bytes data, address rootToken, address receiver, uint256 amount
- `PendingWithdrawal` (src/root/flowrate/FlowRateWithdrawalQueue.sol): address withdrawer, address token, uint256 amount, uint256 timestamp
- `RootIntegration` (test/utils.t.sol): ERC20PresetMinterPauser imxToken, ERC20PresetMinterPauser token, RootERC20BridgeFlowRate rootBridgeFlowRate, RootAxelarBridgeAdaptor axelarAdaptor, MockAxelarGateway mockAxelarGateway, MockAxelarGasService axelarGasService
- `SetRateControlThresholdParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address token, uint256 capacity, uint256 refillRate, uint256 largeTransferThreshold
- `SetWithdrawalDelayParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): uint256 delay
- `State` (test/fuzzing/helper/BeforeAfter.sol): mapping(address => ActorStates) actorStates, mapping(address => TokenState) tokenStates, uint256 imxCumulativeDepositLimit, uint256 rootIMXTokenBalOfRootBridge, uint256 rootWETHBalOfRootBridge, uint256 childWIMXBalOfChildBridge, uint256 nativeBalanceOfRootAdaptor, uint256 nativeBalanceOfChildAdaptor, uint256 nativeBalanceOfRootBridge, uint256 nativeBalanceOfChildBridge, uint256 withdrawalDelay, bool rootBridgePaused, bool childBridgePaused, bool withdrawalQueueActivated
- `TokenState` (test/fuzzing/helper/BeforeAfter.sol): mapping(address => uint256) balances, uint256 totalSupply, uint256 capacity, uint256 depth, uint256 refillTime, uint256 refillRate, uint256 largeTransferThresholds
- `UpdateImxCumulativeDepositLimitParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): uint256 newImxCumulativeDepositLimit
- `UpdateRootBridgeAdaptorParams` (test/fuzzing/helper/preconditions/PreconditionsRootERC20BridgeFlowRate.sol): address newRootBridgeAdaptor
- `WithdrawETHParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): uint256 amount, uint256 value
- `WithdrawETHToParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): address receiver, uint256 amount, uint256 value
- `WithdrawIMXParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): uint256 amount, uint256 value
- `WithdrawIMXToParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): address receiver, uint256 amount, uint256 value
- `WithdrawParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): address childToken, uint256 amount, uint256 value
- `WithdrawToParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): address childToken, address receiver, uint256 amount, uint256 value
- `WithdrawWIMXParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): uint256 amount, uint256 value
- `WithdrawWIMXToParams` (test/fuzzing/helper/preconditions/PreconditionsChildERC20Bridge.sol): address receiver, uint256 amount, uint256 value

### Enum State Values
- None detected

### Invariant Values (Variable-Tied)
- Key accounting vars (`balanceOf`, `balanceOf`, `MAX_ERC20_BALANCE`, `INITIAL_BALANCE`, `INITIAL_WETH_BALANCE`, `totalGas`, `totalGas`) must only change through authorized accounting paths
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
