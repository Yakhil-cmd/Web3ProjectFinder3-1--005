# Onyx (by Enzyme Protocol)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Onyx (by Enzyme Protocol) is a set of EVM-compatible smart contracts to tokenize on- and off-chain value.

For more information, see the Onyx General Spec [link forthcoming]

## Security Issues and Bug Bounty

If you find a vulnerability that may affect live deployments, you can submit a report via:

A. Immunefi (https://immunefi.com/bounty/enzymefinance/), or

B. Direct email to [security@enzyme.finance](mailto:security@enzyme.finance)

Please **DO NOT** open a public issue.

## Using this Repository

### Prerequisites

- [foundry](https://github.com/foundry-rs/foundry)

### Compile Contracts

```
forge build
```

### Run all tests

```
forge test
```

### Utility Scripts

Utility scripts can be found in the `scripts/` folder.

## Deploying contracts

```
make deploy NETWORK=<spec> CONTRACT=<Name>
```

- `<spec>`: single network (`arbitrum`), comma-separated subset (`arbitrum,base`), or `all` (deploys to all networks).
- Supported networks: `mainnet, arbitrum, base, ethereum_sepolia, mega_eth, plume`.
- Optional constructor args: write `deploy/<CONTRACT>/.args.<network>.txt` before deploying (e.g., `deploy/SharesDeployer/.args.ethereum_sepolia.txt`). Omit the file if the contract has no constructor args.
- Defaults: keystore `<network>-deployer` (override via `ACCOUNT=...`); verifier resolved per network (Etherscan v2 via `foundry.toml [etherscan]`, Blockscout for `mega_eth` and `plume`).
- Successful deploys append to `deploy/logs/log.<network>.txt`.
- Multi-network deploys prompt for each keystore password sequentially upfront (deduped by account), then run `forge create` concurrently. Per-chain log lines are prefixed with `[<network>]` in a distinct color; set `NO_COLOR=1` to disable (also auto-disabled when stdout isn't a TTY).
- See `make help` for full options.

## Licensing

- Source-available under Business Source License 1.1 (BUSL-1.1).
- See [LICENSES/BUSL-1.1](LICENSES/BUSL-1.1) for terms and change date.

SPDX identifiers:

- All first-party files: `BUSL-1.1`
- Vendored third-party files retain original identifiers (e.g., `MIT`).

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:50Z`  
Project: `07_enzyme-onyx`  
Solidity files: `104`

### Structure
Top Solidity directories:
- `test`: 56 `.sol` files
- `src`: 46 `.sol` files
- `scripts`: 2 `.sol` files

Pragmas:
- `0.8.28`
- `^0.8.0`

Contracts/Libraries/Interfaces detected: `122`

### Life Total / Balance Values
Detected accounting/state total variables:
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `SHARES_TRANSFER_VALIDATOR_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `AddressListsSharesTransferValidator` @ `src/components/shares-transfer-validators/AddressListsSharesTransferValidator.sol` = `"SharesTransferValidator"`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol`
- `depositAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `expectedShares` | type: `uint256` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `100e18`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `instanceToShares` | type: `mapping(address => address) internal` | vis: `internal` | flags: `-` | `ComponentBeaconFactory` @ `src/factories/ComponentBeaconFactory.sol`
- `SHARES` | type: `address public` | vis: `public` | flags: `-` | `ComponentHarnessMixin` @ `test/harnesses/utils/ComponentHarnessMixin.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeIssuanceBaseTest` @ `test/contracts/ERC7540LikeIssuanceBase.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `LINEAR_CREDIT_DEBT_TRACKER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `LinearCreditDebtTracker` @ `src/components/value/position-trackers/LinearCreditDebtTracker.sol` = `"LinearCreditDebtTracker"`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `LinearCreditDebtTrackerTest` @ `test/contracts/LinearCreditDebtTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `OpenAccessLimitedCallForwarderTest` @ `test/contracts/OpenAccessLimitedCallForwarder.t.sol`
- `SHARES_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `Shares` @ `src/shares/Shares.sol` = `0xbe724a55f726228f14b884d45d89388bc2a03793a0006937116ea1275a51fb00`
- `SHARES_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `Shares` @ `src/shares/Shares.sol` = `"Shares"`
- `ADDRESS_LISTS_SHARES_TRANSFER_VALIDATOR_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `LINEAR_CREDIT_DEBT_TRACKER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `SHARES_OWNED_ADDRESS_LIST_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `SHARES_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `"Onyx Shares"`
- `SHARES_SYMBOL` | type: `string constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `"oSHR"`
- `VALUE_ASSET` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `bytes32("USD")`
- `addressListsSharesTransferValidatorFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `linearCreditDebtTrackerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `sharesFactory` | type: `BeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `sharesOwnedAddressListFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `vaultOwner` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("vaultOwner")`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SharesOwnedAddressListTest` @ `test/contracts/SharesOwnedAddressList.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SharesTest` @ `test/contracts/Shares.t.sol`
- `MAX_SHARE_PRICE_STALENESS_DISABLED` | type: `uint24 internal constant` | vis: `internal` | flags: `constant` | `SyncDepositHandler` @ `src/components/issuance/deposit-handlers/SyncDepositHandler.sol` = `type(uint24).max`
- `ASSET_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol` = `6`
- `depositAsset` | type: `address` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ValuationHandlerTest` @ `test/contracts/ValuationHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`

All detected state variables (full list):
- `ACCOUNT_ERC20_TRACKER_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AccountERC20Tracker` @ `src/components/value/position-trackers/AccountERC20Tracker.sol` = `0x85378e297d6c8e578e867cf1e0cdf12245bc85fa8c2e83002e863bfec07d5e00`
- `ACCOUNT_ERC20_TRACKER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `AccountERC20Tracker` @ `src/components/value/position-trackers/AccountERC20Tracker.sol` = `"AccountERC20Tracker"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol` = `makeAddr("admin")`
- `mockValuationHandler` | type: `address` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol` = `makeAddr("mockValuationHandler")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `trackedAccount` | type: `address` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol` = `makeAddr("trackedAccount")`
- `tracker` | type: `AccountERC20Tracker` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `ADDRESS_LIST_BASE_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AddressListBase` @ `src/infra/lists/address-list/AddressListBase.sol` = `0xbdf8df28b0690daa2b80a9a43d66dc30bfa3557748d06b2e704e1b9747c7f000`
- `ADDRESS_LIST_BASE_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `AddressListBase` @ `src/infra/lists/address-list/AddressListBase.sol` = `"AddressListBase"`
- `authAccount` | type: `address public` | vis: `public` | flags: `-` | `AddressListBaseHarness` @ `test/harnesses/AddressListBaseHarness.sol`
- `addressList` | type: `AddressListBaseHarness` | vis: `default` | flags: `-` | `AddressListBaseTest` @ `test/contracts/AddressListBase.t.sol`
- `authAccount` | type: `address` | vis: `default` | flags: `-` | `AddressListBaseTest` @ `test/contracts/AddressListBase.t.sol`
- `SHARES_TRANSFER_VALIDATOR_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `AddressListsSharesTransferValidator` @ `src/components/shares-transfer-validators/AddressListsSharesTransferValidator.sol` = `"SharesTransferValidator"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol` = `makeAddr("AddressListsSharesTransferValidatorTest.admin")`
- `listAddress` | type: `address` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol`
- `listItem` | type: `address` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol` = `makeAddr("listItem")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol`
- `validator` | type: `AddressListsSharesTransferValidatorHarness` | vis: `default` | flags: `-` | `AddressListsSharesTransferValidatorTest` @ `test/contracts/AddressListsSharesTransferValidator.t.sol`
- `implementation` | type: `address public override` | vis: `public` | flags: `override` | `BeaconFactory` @ `src/factories/BeaconFactory.sol`
- `isInstance` | type: `mapping(address _who => bool) public` | vis: `public` | flags: `-` | `BeaconFactory` @ `src/factories/BeaconFactory.sol`
- `nonce` | type: `uint256 internal` | vis: `internal` | flags: `-` | `BeaconFactory` @ `src/factories/BeaconFactory.sol`
- `factory` | type: `BeaconFactory` | vis: `default` | flags: `-` | `BeaconFactoryTest` @ `test/contracts/BeaconFactory.t.sol`
- `globalOwner` | type: `address` | vis: `default` | flags: `-` | `BeaconFactoryTest` @ `test/contracts/BeaconFactory.t.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `makeAddr("admin")`
- `ccipFee` | type: `uint256` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `0.1 ether`
- `ccipLocalSimulator` | type: `CCIPLocalSimulator` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `chainSelector` | type: `uint64` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `depositAmount` | type: `uint256` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `100e6`
- `depositAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `expectedShares` | type: `uint256` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `100e18`
- `factory` | type: `DeterministicBeaconFactory` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `router` | type: `address` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `user` | type: `address` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol` = `makeAddr("user")`
- `valuationHandler` | type: `ValuationHandlerHarness` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `walletsManager` | type: `WalletsManagerHarness` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `wrappedNative` | type: `address` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `bar` | type: `uint256 public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/OpenAccessLimitedCallForwarder.t.sol`
- `bar` | type: `uint256 public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `bar` | type: `uint256 public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `called` | type: `bool public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `caller` | type: `address public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `value` | type: `uint256 public` | vis: `public` | flags: `-` | `CallTarget` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `implementation` | type: `address public override` | vis: `public` | flags: `override` | `ComponentBeaconFactory` @ `src/factories/ComponentBeaconFactory.sol`
- `instanceToShares` | type: `mapping(address => address) internal` | vis: `internal` | flags: `-` | `ComponentBeaconFactory` @ `src/factories/ComponentBeaconFactory.sol`
- `nonce` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ComponentBeaconFactory` @ `src/factories/ComponentBeaconFactory.sol`
- `factory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `ComponentBeaconFactoryTest` @ `test/contracts/ComponentBeaconFactory.t.sol`
- `globalOwner` | type: `address` | vis: `default` | flags: `-` | `ComponentBeaconFactoryTest` @ `test/contracts/ComponentBeaconFactory.t.sol`
- `SHARES` | type: `address public` | vis: `public` | flags: `-` | `ComponentHarnessMixin` @ `test/harnesses/utils/ComponentHarnessMixin.sol`
- `ARBITRUM_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `408447230`
- `BASE_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `39201030`
- `ETHEREUM_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `23967530`
- `ETHEREUM_SEPOLIA_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `10566500`
- `MEGA_ETH_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `12236830`
- `PLUME_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `41664170`
- `MANAGEMENT_FEE_TRACKER_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ContinuousFlatRateManagementFeeTracker` @ `src/components/fees/management-fee-trackers/ContinuousFlatRateManagementFeeTracker.sol` = `0x25008e61d6a33ea3313338886e9ba1cacec26ac79d05629f9df4b5d62fb2ee00`
- `MANAGEMENT_FEE_TRACKER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `ContinuousFlatRateManagementFeeTracker` @ `src/components/fees/management-fee-trackers/ContinuousFlatRateManagementFeeTracker.sol` = `"ManagementFeeTracker"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol` = `makeAddr("admin")`
- `managementFeeTracker` | type: `ContinuousFlatRateManagementFeeTrackerHarness` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol`
- `mockFeeHandler` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol` = `makeAddr("mockFeeHandler")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ContinuousFlatRateManagementFeeTrackerTest` @ `test/contracts/ContinuousFlatRateManagementFeeTracker.t.sol`
- `PERFORMANCE_FEE_TRACKER_STORAGE_LOCATION` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ContinuousFlatRatePerformanceFeeTracker` @ `src/components/fees/performance-fee-trackers/ContinuousFlatRatePerformanceFeeTracker.sol` = `0x9b5db54aad07ab0d695a15cbe8f6baf30e20bec0d8b73b9bd4ded75e29fae800`
- `PERFORMANCE_FEE_TRACKER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `ContinuousFlatRatePerformanceFeeTracker` @ `src/components/fees/performance-fee-trackers/ContinuousFlatRatePerformanceFeeTracker.sol` = `"PerformanceFeeTracker"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol` = `makeAddr("admin")`
- `mockFeeHandler` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol` = `makeAddr("mockFeeHandler")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol`
- `performanceFeeTracker` | type: `ContinuousFlatRatePerformanceFeeTrackerHarness` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ContinuousFlatRatePerformanceFeeTrackerTest` @ `test/contracts/ContinuousFlatRatePerformanceFeeTracker.t.sol`
- `ALLOWED_WORKFLOW_OWNER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `CreWorkflowConsumer` @ `src/components/automations/chainlink-cre/CreWorkflowConsumer.sol`
- `CHAINLINK_KEYSTONE_FORWARDER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `CreWorkflowConsumer` @ `src/components/automations/chainlink-cre/CreWorkflowConsumer.sol`
- `CRE_WORKFLOW_CONSUMER_STORAGE_LOCATION` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CreWorkflowConsumer` @ `src/components/automations/chainlink-cre/CreWorkflowConsumer.sol` = `0x0e3fe8355c10db856bcbccfa41da7cfb4d5b6dd681a069e0ed1b68eddbef9600`
- `CRE_WORKFLOW_CONSUMER_STORAGE_LOCATION_ID` | type: `string public constant` | vis: `public` | flags: `constant` | `CreWorkflowConsumer` @ `src/components/automations/chainlink-cre/CreWorkflowConsumer.sol` = `"CreWorkflowConsumer"`
- `ALLOWED_WORKFLOW_ID` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol` = `keccak256("workflowId")`
- `ALLOWED_WORKFLOW_NAME` | type: `bytes10 constant` | vis: `default` | flags: `constant` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol` = `bytes10("workflow")`
- `ALLOWED_WORKFLOW_OWNER` | type: `address constant` | vis: `default` | flags: `constant` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol` = `address(0x3)`
- `chainlinkKeystoneForwarder` | type: `IChainlinkKeystoneForwarder` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `limitedAccessForwarder` | type: `LimitedAccessLimitedCallForwarderHarness` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `workflowConsumer` | type: `CreWorkflowConsumerHarness` | vis: `default` | flags: `-` | `CreWorkflowConsumerTestBase` @ `test/contracts/CreWorkflowConsumer.t.sol`
- `ENZYME_DEVELOPERS` | type: `address constant` | vis: `default` | flags: `constant` | `DeployProtocol` @ `scripts/Deploy.s.sol` = `address(0xd24bBcD06C54a5a2A6d22f4AaE25AB511190C7b5)`
- `CCIP_ROUTER` | type: `address public immutable` | vis: `public` | flags: `immutable` | `DepositorWallet` @ `src/ccip/DepositorWallet.sol`
- `DEPOSITOR_WALLET_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `DepositorWallet` @ `src/ccip/DepositorWallet.sol` = `"DepositorWallet"`
- `beacon` | type: `UpgradeableBeacon` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `ccipRouter` | type: `address` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol` = `makeAddr("ccipRouter")`
- `chainSelector` | type: `uint64` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol` = `1`
- `feeToken` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `implementation` | type: `DepositorWallet` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `mockMessageId` | type: `bytes32` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol` = `keccak256("mockMessageId")`
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `user` | type: `bytes` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol` = `abi.encode(makeAddr("user"))`
- `wallet` | type: `DepositorWallet` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `walletsManager` | type: `address` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol` = `makeAddr("walletsManager")`
- `implementation` | type: `address public override` | vis: `public` | flags: `override` | `DeterministicBeaconFactory` @ `src/factories/DeterministicBeaconFactory.sol`
- `isInstance` | type: `mapping(address _who => bool) public` | vis: `public` | flags: `-` | `DeterministicBeaconFactory` @ `src/factories/DeterministicBeaconFactory.sol`
- `factory` | type: `DeterministicBeaconFactory` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol`
- `global` | type: `Global` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol`
- `globalOwner` | type: `address` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol`
- `initData` | type: `bytes` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol` = `abi.encodeWithSelector(MockImplementation.init.selector)`
- `mockImpl` | type: `address` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol`
- `salt` | type: `bytes32` | vis: `default` | flags: `-` | `DeterministicBeaconFactoryTest` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol` = `keccak256("test-salt")`
- `DEPOSIT_QUEUE_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `ERC7540LikeDepositQueue` @ `src/components/issuance/deposit-handlers/ERC7540LikeDepositQueue.sol` = `"DepositQueue"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol` = `makeAddr("admin")`
- `depositQueue` | type: `ERC7540LikeDepositQueueHarness` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol`
- `valuationHandler` | type: `ValuationHandler` | vis: `default` | flags: `-` | `ERC7540LikeDepositQueueTest` @ `test/contracts/ERC7540LikeDepositQueue.t.sol`
- `ERC7540_LIKE_ISSUANCE_BASE_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `ERC7540LikeIssuanceBase` @ `src/components/issuance/utils/ERC7540LikeIssuanceBase.sol` = `0xb6d07fd6f3a90998edd8cc9d24642317ef35db10e62ed4dbf526ac2cdd3b8d00`
- `ERC7540_LIKE_ISSUANCE_BASE_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `ERC7540LikeIssuanceBase` @ `src/components/issuance/utils/ERC7540LikeIssuanceBase.sol` = `"ERC7540LikeIssuanceBase"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeIssuanceBaseTest` @ `test/contracts/ERC7540LikeIssuanceBase.t.sol` = `makeAddr("admin")`
- `issuanceBase` | type: `ERC7540LikeIssuanceBaseHarness` | vis: `default` | flags: `-` | `ERC7540LikeIssuanceBaseTest` @ `test/contracts/ERC7540LikeIssuanceBase.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeIssuanceBaseTest` @ `test/contracts/ERC7540LikeIssuanceBase.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeIssuanceBaseTest` @ `test/contracts/ERC7540LikeIssuanceBase.t.sol`
- `REDEEM_QUEUE_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `ERC7540LikeRedeemQueue` @ `src/components/issuance/redeem-handlers/ERC7540LikeRedeemQueue.sol` = `"RedeemQueue"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol` = `makeAddr("admin")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol`
- `redeemQueue` | type: `ERC7540LikeRedeemQueueHarness` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol`
- `valuationHandler` | type: `ValuationHandler` | vis: `default` | flags: `-` | `ERC7540LikeRedeemQueueTest` @ `test/contracts/ERC7540LikeRedeemQueue.t.sol`
- `HEX_CHARS` | type: `bytes private constant` | vis: `private` | flags: `constant` | `EncodeStringToBytes10` @ `scripts/EncodeStringToBytes10.s.sol` = `"0123456789abcdef"`
- `encoder` | type: `EncodeStringToBytes10` | vis: `default` | flags: `-` | `EncodeStringToBytes10Test` @ `test/contracts/EncodeStringToBytes10.t.sol`
- `FEE_HANDLER_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `FeeHandler` @ `src/components/fees/FeeHandler.sol` = `0xf4d55ff99bda85c3aa25c0487eafd29734b8b8c0e94e473480bb8c25cf2aa300`
- `FEE_HANDLER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `FeeHandler` @ `src/components/fees/FeeHandler.sol` = `"FeeHandler"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol` = `makeAddr("FeeHandlerTest.admin")`
- `feeHandler` | type: `FeeHandlerHarness` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol`
- `valuationHandler` | type: `ValuationHandler` | vis: `default` | flags: `-` | `FeeHandlerTest` @ `test/contracts/FeeHandler.t.sol`
- `GLOBAL` | type: `Global public immutable` | vis: `public` | flags: `immutable` | `GlobalOwnable` @ `src/global/utils/GlobalOwnable.sol`
- `globalOwnable` | type: `GlobalOwnableHarness` | vis: `default` | flags: `-` | `GlobalOwnableTest` @ `test/contracts/GlobalOwnable.t.sol`
- `globalOwner` | type: `address` | vis: `default` | flags: `-` | `GlobalOwnableTest` @ `test/contracts/GlobalOwnable.t.sol`
- `global` | type: `Global` | vis: `default` | flags: `-` | `GlobalTest` @ `test/contracts/Global.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `GlobalTest` @ `test/contracts/Global.t.sol` = `makeAddr("owner")`
- `LIMITED_ACCESS_LIMITED_CALL_FORWARDER` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `LimitedAccessLimitedCallForwarder` @ `src/components/roles/LimitedAccessLimitedCallForwarder.sol` = `0xc79bb6d1c38890e2019fbe15ffb6d894add943a40a60096f4039a45558b86300`
- `LIMITED_ACCESS_LIMITED_CALL_FORWARDER_ID` | type: `string public constant` | vis: `public` | flags: `constant` | `LimitedAccessLimitedCallForwarder` @ `src/components/roles/LimitedAccessLimitedCallForwarder.sol` = `"LimitedAccessLimitedCallForwarder"`
- `authCaller` | type: `address` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol` = `makeAddr("authCaller")`
- `callForwarder` | type: `LimitedAccessLimitedCallForwarderHarness` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `callSelector` | type: `bytes4` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol` = `CallTarget.foo.selector`
- `callTarget` | type: `CallTarget` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `LimitedAccessLimitedCallForwarderTest` @ `test/contracts/LimitedAccessLimitedCallForwarder.t.sol`
- `LINEAR_CREDIT_DEBT_TRACKER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `LinearCreditDebtTracker` @ `src/components/value/position-trackers/LinearCreditDebtTracker.sol` = `"LinearCreditDebtTracker"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `LinearCreditDebtTrackerTest` @ `test/contracts/LinearCreditDebtTracker.t.sol` = `makeAddr("admin")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `LinearCreditDebtTrackerTest` @ `test/contracts/LinearCreditDebtTracker.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `LinearCreditDebtTrackerTest` @ `test/contracts/LinearCreditDebtTracker.t.sol`
- `tracker` | type: `LinearCreditDebtTracker` | vis: `default` | flags: `-` | `LinearCreditDebtTrackerTest` @ `test/contracts/LinearCreditDebtTracker.t.sol`
- `answer` | type: `int256 public` | vis: `public` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol`
- `dummyAnsweredInRound` | type: `uint80` | vis: `default` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol` = `81`
- `dummyRoundId` | type: `uint80` | vis: `default` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol` = `80`
- `dummyStartedAt` | type: `uint256` | vis: `default` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol` = `754982`
- `updatedAt` | type: `uint256 public` | vis: `public` | flags: `-` | `MockChainlinkAggregator` @ `test/mocks/MockChainlinkAggregator.sol`
- `mockDecimals` | type: `uint8` | vis: `default` | flags: `-` | `MockERC20` @ `test/mocks/MockERC20.sol` = `18`
- `initialized` | type: `bool public` | vis: `public` | flags: `-` | `MockImplementation` @ `test/contracts/BeaconFactory.t.sol`
- `initialized` | type: `bool public` | vis: `public` | flags: `-` | `MockImplementation` @ `test/contracts/ComponentBeaconFactory.t.sol`
- `initialized` | type: `bool public` | vis: `public` | flags: `-` | `MockImplementation` @ `test/contracts/GlobalOwnable.t.sol`
- `initialized` | type: `bool public` | vis: `public` | flags: `-` | `MockImplementation` @ `test/contracts/deterministic-beacon-factory/DeterministicBeaconFactory.t.sol`
- `DECIMALS` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `OneToOneAggregator` @ `src/infra/oracles/OneToOneAggregator.sol` = `18`
- `ONE` | type: `int256 private constant` | vis: `private` | flags: `constant` | `OneToOneAggregator` @ `src/infra/oracles/OneToOneAggregator.sol` = `10 ** 18`
- `OPEN_ACCESS_LIMITED_CALL_FORWARDER_ID` | type: `string public constant` | vis: `public` | flags: `constant` | `OpenAccessLimitedCallForwarder` @ `src/components/roles/OpenAccessLimitedCallForwarder.sol` = `"OpenAccessLimitedCallForwarder"`
- `callForwarder` | type: `OpenAccessLimitedCallForwarderHarness` | vis: `default` | flags: `-` | `OpenAccessLimitedCallForwarderTest` @ `test/contracts/OpenAccessLimitedCallForwarder.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `OpenAccessLimitedCallForwarderTest` @ `test/contracts/OpenAccessLimitedCallForwarder.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `OpenAccessLimitedCallForwarderTest` @ `test/contracts/OpenAccessLimitedCallForwarder.t.sol`
- `addressList` | type: `OwnableAddressList` | vis: `default` | flags: `-` | `OwnableAddressListTest` @ `test/contracts/OwnableAddressList.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `OwnableAddressListTest` @ `test/contracts/OwnableAddressList.t.sol`
- `SHARES_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `Shares` @ `src/shares/Shares.sol` = `0xbe724a55f726228f14b884d45d89388bc2a03793a0006937116ea1275a51fb00`
- `SHARES_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `Shares` @ `src/shares/Shares.sol` = `"Shares"`
- `ACCOUNT_ERC20_TRACKER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `ADDRESS_LISTS_SHARES_TRANSFER_VALIDATOR_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `DEPOSIT_QUEUE_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `FEE_HANDLER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `LINEAR_CREDIT_DEBT_TRACKER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `MANAGEMENT_FEE_TRACKER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `OWNABLE_ADDRESS_LIST_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `PERFORMANCE_FEE_TRACKER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `REDEEM_QUEUE_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `SHARES_OWNED_ADDRESS_LIST_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `SYNC_DEPOSIT_HANDLER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `VALUATION_HANDLER_FACTORY` | type: `address public immutable` | vis: `public` | flags: `immutable` | `SharesDeployer` @ `src/infra/deployment/SharesDeployer.sol`
- `SHARES_NAME` | type: `string constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `"Onyx Shares"`
- `SHARES_SYMBOL` | type: `string constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `"oSHR"`
- `VALUE_ASSET` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `bytes32("USD")`
- `accountERC20TrackerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `addressListsSharesTransferValidatorFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `adminA` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("adminA")`
- `adminB` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("adminB")`
- `deployer` | type: `SharesDeployer` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `depositQueueFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `depositorAllowlist` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("depositorAllowlist")`
- `feeHandlerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `feeRecipient` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("feeRecipient")`
- `linearCreditDebtTrackerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `managementFeeTrackerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `ownableAddressListFactory` | type: `BeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `performanceFeeTrackerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `redeemQueueFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `sharesFactory` | type: `BeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `sharesOwnedAddressListFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `syncDepositHandlerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `usdc` | type: `MockERC20` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `validator` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("validator")`
- `valuationHandlerFactory` | type: `ComponentBeaconFactory` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `vaultOwner` | type: `address` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol` = `makeAddr("vaultOwner")`
- `weth` | type: `MockERC20` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `addressList` | type: `SharesOwnedAddressListHarness` | vis: `default` | flags: `-` | `SharesOwnedAddressListTest` @ `test/contracts/SharesOwnedAddressList.t.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `SharesOwnedAddressListTest` @ `test/contracts/SharesOwnedAddressList.t.sol`
- `owner` | type: `address` | vis: `default` | flags: `-` | `SharesOwnedAddressListTest` @ `test/contracts/SharesOwnedAddressList.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SharesOwnedAddressListTest` @ `test/contracts/SharesOwnedAddressList.t.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `SharesTest` @ `test/contracts/Shares.t.sol` = `makeAddr("SharesTest.admin")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `SharesTest` @ `test/contracts/Shares.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SharesTest` @ `test/contracts/Shares.t.sol`
- `MAX_SHARE_PRICE_STALENESS_DISABLED` | type: `uint24 internal constant` | vis: `internal` | flags: `constant` | `SyncDepositHandler` @ `src/components/issuance/deposit-handlers/SyncDepositHandler.sol` = `type(uint24).max`
- `SYNC_DEPOSIT_HANDLER_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `SyncDepositHandler` @ `src/components/issuance/deposit-handlers/SyncDepositHandler.sol` = `0x8a1bf4b6fe0f19db4139bc2fd041277dc03c6329c0bfe0e30c929d0ea93ecb00`
- `SYNC_DEPOSIT_HANDLER_STORAGE_LOCATION_ID` | type: `string private constant` | vis: `private` | flags: `constant` | `SyncDepositHandler` @ `src/components/issuance/deposit-handlers/SyncDepositHandler.sol` = `"SyncDepositHandler"`
- `ASSET_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol` = `6`
- `admin` | type: `address` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol` = `makeAddr("admin")`
- `depositAsset` | type: `address` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `depositHandler` | type: `SyncDepositHandlerHarness` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `depositor` | type: `address` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol` = `makeAddr("depositor")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `valuationHandler` | type: `ValuationHandlerHarness` | vis: `default` | flags: `-` | `SyncDepositHandlerTest` @ `test/contracts/SyncDepositHandler.t.sol`
- `RATE_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ValuationHandler` @ `src/components/value/ValuationHandler.sol` = `10 ** 18`
- `VALUATION_HANDLER_STORAGE_LOCATION_ID` | type: `string public constant` | vis: `public` | flags: `constant` | `ValuationHandler` @ `src/components/value/ValuationHandler.sol` = `"ValuationHandler"`
- `admin` | type: `address` | vis: `default` | flags: `-` | `ValuationHandlerTest` @ `test/contracts/ValuationHandler.t.sol` = `makeAddr("ValuationHandlerTest.admin")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `ValuationHandlerTest` @ `test/contracts/ValuationHandler.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `ValuationHandlerTest` @ `test/contracts/ValuationHandler.t.sol`
- `valuationHandler` | type: `ValuationHandlerHarness` | vis: `default` | flags: `-` | `ValuationHandlerTest` @ `test/contracts/ValuationHandler.t.sol`
- `valueHelpersLib` | type: `ValueHelpersLibHarness` | vis: `default` | flags: `-` | `ValueHelpersLibTest` @ `test/contracts/ValueHelpersLib.t.sol`
- `admin` | type: `address` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `makeAddr("admin")`
- `ccipRouter` | type: `address` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `makeAddr("ccipRouter")`
- `factory` | type: `DeterministicBeaconFactory` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `harness` | type: `WalletsManagerHarness` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `mockFee` | type: `uint256` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `1e18`
- `mockMessageId` | type: `bytes32` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `keccak256("mockMessageId")`
- `owner` | type: `address` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `shares` | type: `Shares` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `sourceChainSelector` | type: `uint64` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `1`
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `user` | type: `bytes` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol` = `abi.encode(makeAddr("user"))`

### Tokens Added / Token State Values
Detected token-related variables:
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `tracker` | type: `AccountERC20Tracker` | vis: `default` | flags: `-` | `AccountERC20TrackerTest` @ `test/contracts/AccountERC20Tracker.t.sol`
- `depositAsset` | type: `MockERC20` | vis: `default` | flags: `-` | `CCIPE2ETest` @ `test/e2e/ccip.t.sol`
- `ETHEREUM_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `23967530`
- `ETHEREUM_SEPOLIA_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `10566500`
- `MEGA_ETH_BLOCK_LATEST` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `test/utils/Constants.sol` = `12236830`
- `feeToken` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `DepositorWalletTest` @ `test/contracts/depositor-wallet/DepositorWallet.t.sol`
- `usdc` | type: `MockERC20` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `weth` | type: `MockERC20` | vis: `default` | flags: `-` | `SharesDeployerTest` @ `test/contracts/infra/SharesDeployer.t.sol`
- `valueHelpersLib` | type: `ValueHelpersLibHarness` | vis: `default` | flags: `-` | `ValueHelpersLibTest` @ `test/contracts/ValueHelpersLib.t.sol`
- `token1` | type: `MockERC20` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`
- `token2` | type: `MockERC20` | vis: `default` | flags: `-` | `WalletsManagerTest` @ `test/contracts/wallets-manager/WalletsManager.t.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `AccountERC20TrackerConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy, address[] assets
- `AccountERC20TrackerStorage` (src/components/value/position-trackers/AccountERC20Tracker.sol): EnumerableSet.AddressSet assets, address account
- `AddressListBaseStorage` (src/infra/lists/address-list/AddressListBase.sol): mapping(address => bool) itemToIsInList
- `AddressListsValidatorListConfig` (src/infra/deployment/SharesDeployer.sol): AddressListsSharesTransferValidator.ListType listType, ExternalListSource externalListSource, address externalListExisting, address externalListOwner, address[] seededAddresses
- `Addrs` (scripts/Deploy.s.sol): ERC1967Proxy globalProxy, Global global, BeaconFactory sharesBeaconFactory, BeaconFactory ownableAddressListFactory, ComponentBeaconFactory feeHandlerBeaconFactory, ComponentBeaconFactory continuousFlatRateManagementFeeTrackerBeaconFactory, ComponentBeaconFactory continuousFlatRatePerformanceFeeTrackerBeaconFactory, ComponentBeaconFactory valuationHandlerBeaconFactory, ComponentBeaconFactory accountERC20TrackerFactory, ComponentBeaconFactory linearCreditDebtTrackerBeaconFactory, ComponentBeaconFactory erc7540LikeDepositQueueBeaconFactory, ComponentBeaconFactory erc7540LikeRedeemQueueBeaconFactory, ComponentBeaconFactory limitedAccessLimitedCallForwarderFactory, ComponentBeaconFactory creWorkflowConsumerFactory, ComponentBeaconFactory sharesOwnedAddressListFactory, ComponentBeaconFactory syncDepositHandlerFactory, Shares shares, FeeHandler feeHandler, ContinuousFlatRateManagementFeeTracker continuousFlatRateManagementFeeTracker, ContinuousFlatRatePerformanceFeeTracker continuousFlatRatePerformanceFeeTracker, ValuationHandler valuationHandler, AccountERC20Tracker accountERC20Tracker, LinearCreditDebtTracker linearCreditDebtTracker, ERC7540LikeDepositQueue erc7540LikeDepositQueue, ERC7540LikeRedeemQueue erc7540LikeRedeemQueue, LimitedAccessLimitedCallForwarder limitedAccessLimitedCallForwarder, CreWorkflowConsumer creWorkflowConsumer, SharesOwnedAddressList sharesOwnedAddressList, OwnableAddressList ownableAddressList, SyncDepositHandler syncDepositHandler
- `AssetRateInfo` (src/components/value/ValuationHandler.sol): uint128 rate, uint40 expiry
- `AssetRateInput` (src/components/value/ValuationHandler.sol): address asset, uint128 rate, uint40 expiry
- `BatchSendParams` (src/components/ccip/WalletsManager.sol): address wallet, address[] tokens, bytes extraArgs
- `Call` (src/ccip/DepositorWallet.sol): address target, bytes data, uint256 value
- `Call` (src/components/roles/OpenAccessLimitedCallForwarder.sol): address target, bytes data, uint256 value
- `ComponentsConfig` (src/infra/deployment/SharesDeployer.sol): FeeHandlerConfig feeHandler, ManagementFeeConfig managementFee, PerformanceFeeConfig performanceFee, ValuationHandlerConfig valuationHandler, AccountERC20TrackerConfig accountERC20Tracker, LinearCreditDebtTrackerConfig linearCreditDebtTracker, QueueDepositHandlerConfig[] queueDepositHandlers, SyncDepositHandlerConfig[] syncDepositHandlers, RedeemHandlerConfig[] redeemHandlers
- `CreWorkflowConsumerStorage` (src/components/automations/chainlink-cre/CreWorkflowConsumer.sol): bytes32 allowedWorkflowId, bytes10 allowedWorkflowName, LimitedAccessLimitedCallForwarder limitedAccessLimitedCallForwarder
- `DeployConfig` (src/infra/deployment/SharesDeployer.sol): SharesConfig shares, address owner, address[] admins, TransferValidatorConfig transferValidator, ComponentsConfig components, PreMintConfig preMint
- `Deployed` (src/infra/deployment/SharesDeployer.sol): address shares, address feeHandler, address valuationHandler, address managementFeeTracker, address performanceFeeTracker, address accountERC20Tracker, address linearCreditDebtTracker, address[] queueDepositHandlers, address[] queueDepositHandlerAllowlists, address[] syncDepositHandlers, address[] syncDepositHandlerAllowlists, address[] redeemHandlers, address transferValidator, address transferValidatorRecipientList, address transferValidatorSenderList
- `DepositQueueStorage` (src/components/issuance/deposit-handlers/ERC7540LikeDepositQueue.sol): uint128 lastId, uint24 minRequestDuration, DepositRestriction depositRestriction, mapping(uint256 => DepositRequestInfo) idToRequest, mapping(address => bool) isAllowedController, IAddressList controllerAllowlist
- `DepositRequestInfo` (src/components/issuance/deposit-handlers/ERC7540LikeDepositQueue.sol): address controller, uint40 canCancelTime, uint256 assetAmount
- `DepositorWalletStorage` (src/ccip/DepositorWallet.sol): address walletsManager, uint64 chainSelector, bytes user
- `ERC7540LikeIssuanceBaseStorage` (src/components/issuance/utils/ERC7540LikeIssuanceBase.sol): address asset
- `ExecuteDepositSetupData` (test/contracts/ERC7540LikeDepositQueue.t.sol): address asset, address request1Controller, address request3Controller, uint256 request1AssetAmount, uint256 request3AssetAmount, uint256 request1ExpectedSharesAmount, uint256 request3ExpectedSharesAmount
- `ExecuteRedeemSetupData` (test/contracts/ERC7540LikeRedeemQueue.t.sol): address asset, address request1Controller, address request3Controller, uint256 request1SharesAmount, uint256 request3SharesAmount, uint256 request1ExpectedAssetAmount, uint256 request3ExpectedAssetAmount
- `Factories` (src/infra/deployment/SharesDeployer.sol): address sharesFactory, address feeHandlerFactory, address valuationHandlerFactory, address managementFeeTrackerFactory, address performanceFeeTrackerFactory, address accountERC20TrackerFactory, address linearCreditDebtTrackerFactory, address depositQueueFactory, address syncDepositHandlerFactory, address redeemQueueFactory, address sharesOwnedAddressListFactory, address ownableAddressListFactory, address addressListsSharesTransferValidatorFactory
- `FeeHandlerConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy, address feeAsset, uint16 entranceFeeBps, address entranceFeeRecipient, uint16 exitFeeBps, address exitFeeRecipient
- `FeeHandlerStorage` (src/components/fees/FeeHandler.sol): address managementFeeTracker, address performanceFeeTracker, address managementFeeRecipient, address performanceFeeRecipient, address entranceFeeRecipient, uint16 entranceFeeBps, address exitFeeRecipient, uint16 exitFeeBps, address feeAsset, uint256 totalFeesOwed, mapping(address => uint256) userFeesOwed
- `Item` (src/components/value/position-trackers/LinearCreditDebtTracker.sol): int128 totalValue, int128 settledValue, uint24 id, uint24 index, uint40 start, uint32 duration
- `LimitedAccessLimitedCallForwarderStorage` (src/components/roles/LimitedAccessLimitedCallForwarder.sol): mapping(address => bool) isUser
- `LinearCreditDebtTrackerConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy
- `LinearCreditDebtTrackerStorage` (src/components/value/position-trackers/LinearCreditDebtTracker.sol): uint24 lastItemId, uint24[] ids, mapping(uint24 => Item) idToItem
- `ManagementFeeConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy, uint16 feeBps, address recipient
- `ManagementFeeTrackerStorage` (src/components/fees/management-fee-trackers/ContinuousFlatRateManagementFeeTracker.sol): uint16 rate, uint64 lastSettled
- `OpenAccessLimitedCallForwarderStorage` (src/components/roles/OpenAccessLimitedCallForwarder.sol): mapping(address => mapping(bytes4 => bool)) targetToSelectorToCanCall
- `PerformanceFeeConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy, uint16 feeBps, int16 hurdleRateBps, address recipient
- `PerformanceFeeTrackerStorage` (src/components/fees/performance-fee-trackers/ContinuousFlatRatePerformanceFeeTracker.sol): uint16 rate, uint128 highWaterMark, uint40 highWaterMarkTimestamp, int16 hurdleRate
- `PreMintConfig` (src/infra/deployment/SharesDeployer.sol): bool enabled, int256 untrackedPositionsValue, PreMintRecipient[] recipients
- `PreMintRecipient` (src/infra/deployment/SharesDeployer.sol): address to, uint256 amount
- `QueueDepositHandlerConfig` (src/infra/deployment/SharesDeployer.sol): address asset, uint24 minRequestDuration, ERC7540LikeDepositQueue.DepositRestriction restriction, ExternalListSource externalListSource, address externalListExisting, address externalListOwner, address[] allowedDepositors
- `RedeemHandlerConfig` (src/infra/deployment/SharesDeployer.sol): address asset, uint24 minRequestDuration
- `RedeemQueueStorage` (src/components/issuance/redeem-handlers/ERC7540LikeRedeemQueue.sol): uint128 lastId, uint24 minRequestDuration, mapping(uint256 => RedeemRequestInfo) idToRequest
- `RedeemRequestInfo` (src/components/issuance/redeem-handlers/ERC7540LikeRedeemQueue.sol): address controller, uint40 canCancelTime, uint256 sharesAmount
- `SharesConfig` (src/infra/deployment/SharesDeployer.sol): string name, string symbol, bytes32 valueAsset
- `SharesStorage` (src/shares/Shares.sol): bytes32 valueAsset, address feeHandler, address sharesTransferValidator, address valuationHandler, mapping(address => bool) isDepositHandler, mapping(address => bool) isRedeemHandler, mapping(address => bool) isAdmin
- `SharesTransferValidatorStorage` (src/components/shares-transfer-validators/AddressListsSharesTransferValidator.sol): address senderList, address recipientList, ListType recipientListType, ListType senderListType
- `SyncDepositHandlerConfig` (src/infra/deployment/SharesDeployer.sol): address asset, uint24 maxSharePriceStaleness, ExternalListSource depositorAllowlistSource, address depositorAllowlistExisting, address depositorAllowlistOwner, address[] allowedDepositors
- `SyncDepositHandlerStorage` (src/components/issuance/deposit-handlers/SyncDepositHandler.sol): address asset, address depositorAllowlist, uint24 maxSharePriceStaleness
- `TestInitParams` (test/contracts/Shares.t.sol): address owner, string name, string symbol, bytes32 valueAsset
- `TransferValidatorConfig` (src/infra/deployment/SharesDeployer.sol): TransferValidatorSource source, address existing, AddressListsValidatorListConfig recipientList, AddressListsValidatorListConfig senderList
- `ValuationHandlerConfig` (src/infra/deployment/SharesDeployer.sol): bool deploy, ValuationHandler.AssetRateInput[] assetRates
- `ValuationHandlerStorage` (src/components/value/ValuationHandler.sol): EnumerableSet.AddressSet positionTrackers, mapping(address => AssetRateInfo) assetToRate, uint128 lastShareValue, uint40 lastShareValueTimestamp

### Enum State Values
- `DepositRestriction` (src/components/issuance/deposit-handlers/ERC7540LikeDepositQueue.sol): None, ControllerAllowlistInternal, ControllerAllowlistExternal
- `ExternalListSource` (src/infra/deployment/SharesDeployer.sol): None, Existing, DeploySharesOwnedAddressList, DeployOwnableAddressList
- `ListType` (src/components/shares-transfer-validators/AddressListsSharesTransferValidator.sol): None, Allow, Disallow
- `TransferValidatorSource` (src/infra/deployment/SharesDeployer.sol): None, Existing, DeployAddressLists

### Invariant Values (Variable-Tied)
- Key accounting vars (`MAX_SHARE_PRICE_STALENESS_DISABLED`, `SHARES_TRANSFER_VALIDATOR_STORAGE_LOCATION_ID`, `LINEAR_CREDIT_DEBT_TRACKER_STORAGE_LOCATION_ID`, `instanceToShares`, `LINEAR_CREDIT_DEBT_TRACKER_FACTORY`, `SHARES_OWNED_ADDRESS_LIST_FACTORY`, `ADDRESS_LISTS_SHARES_TRANSFER_VALIDATOR_FACTORY`, `SHARES_STORAGE_LOCATION`) must only change through authorized accounting paths
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
