<!-- markdownlint-disable MD041 -->

<p align="center">
  <a href="https://thegraph.com/"><img src="https://storage.thegraph.com/logos/grt.png" alt="The Graph" width="200"></a>
</p>

<h3 align="center">The Graph Protocol</h3>
<h4 align="center">A decentralized network for querying and indexing blockchain data.</h4>

<p align="center">
  <a href="https://github.com/graphprotocol/contracts/actions/workflows/build.yml">
    <img src="https://github.com/graphprotocol/contracts/actions/workflows/build.yml/badge.svg" alt="Build">
  </a>
  <a href="https://github.com/graphprotocol/contracts/actions/workflows/lint.yml">
    <img src="https://github.com/graphprotocol/contracts/actions/workflows/lint.yml/badge.svg" alt="Lint">
  </a>
</p>

<p align="center">
  <a href="#packages">Packages</a> •
  <a href="#development">Development</a> •
  <a href="#documentation">Docs</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#security">Security</a> •
  <a href="#license">License</a>
</p>

---

[The Graph](https://thegraph.com/) is an indexing protocol for querying networks like Ethereum, IPFS, Polygon, and other blockchains. Anyone can build and Publish open APIs, called subgraphs, making data easily accessible.

## Packages

This repository is a pnpm workspaces monorepo containing the following packages:

| Package                                                     | Latest version                                                                                                                                   | Description                                                                                       |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| [contracts](./packages/contracts)                           | [![npm version](https://badge.fury.io/js/@graphprotocol%2Fcontracts.svg)](https://badge.fury.io/js/@graphprotocol%2Fcontracts)                   | Contracts enabling the open and permissionless decentralized network known as The Graph protocol. |
| [data-edge](./packages/data-edge)                           | [![npm version](https://badge.fury.io/js/@graphprotocol%2Fdata-edge.svg)](https://badge.fury.io/js/@graphprotocol%2Fdata-edge)                   | Data edge testing and utilities for The Graph protocol.                                           |
| [hardhat-graph-protocol](./packages/hardhat-graph-protocol) | [![npm version](https://badge.fury.io/js/hardhat-graph-protocol.svg)](https://badge.fury.io/js/hardhat-graph-protocol)                           | A Hardhat plugin that extends the runtime environment with functionality for The Graph protocol.  |
| [horizon](./packages/horizon)                               | [![npm version](https://badge.fury.io/js/@graphprotocol%2Fhorizon.svg)](https://badge.fury.io/js/@graphprotocol%2Fhorizon)                       | Contracts for Graph Horizon, the next iteration of The Graph protocol.                            |
| [interfaces](./packages/interfaces)                         | [![npm version](https://badge.fury.io/js/@graphprotocol%2Finterfaces.svg)](https://badge.fury.io/js/@graphprotocol%2Finterfaces)                 | Contract interfaces for The Graph protocol contracts.                                             |
| [issuance](./packages/issuance)                             | [![npm version](https://badge.fury.io/js/@graphprotocol%2Fissuance.svg)](https://badge.fury.io/js/@graphprotocol%2Fissuance)                     | Smart contracts for The Graph's token issuance functionality                                      |
| [subgraph-service](./packages/subgraph-service)             | [![npm version](https://badge.fury.io/js/@graphprotocol%2Fsubgraph-service.svg)](https://badge.fury.io/js/@graphprotocol%2Fsubgraph-service)     | Contracts for the Subgraph data service in Graph Horizon.                                         |
| [token-distribution](./packages/token-distribution)         | [![npm version](https://badge.fury.io/js/@graphprotocol%2Ftoken-distribution.svg)](https://badge.fury.io/js/@graphprotocol%2Ftoken-distribution) | Contracts managing token locks for network participants.                                          |
| [toolshed](./packages/toolshed)                             | [![npm version](https://badge.fury.io/js/@graphprotocol%2Ftoolshed.svg)](https://badge.fury.io/js/@graphprotocol%2Ftoolshed)                     | A collection of tools and utilities for the Graph Protocol TypeScript components.                 |

## Development

### Setup

To set up this project you'll need [git](https://git-scm.com) and [pnpm](https://pnpm.io/) installed.

From your command line:

```bash
corepack enable
pnpm set version stable

# Clone this repository
$ git clone https://github.com/graphprotocol/contracts

# Go into the repository
$ cd contracts

# Install dependencies
$ pnpm install

# Build projects
$ pnpm build

# Run tests
$ pnpm test
```

### Script Patterns

This monorepo follows consistent script patterns across all packages to ensure reliable builds and tests:

#### Build Scripts

- **`pnpm build`** (root) - Builds all packages by calling `build:self` on each
- **`pnpm build`** (package) - Builds dependencies first, then the package itself
- **`pnpm build:self`** - Builds only the current package (no dependencies)
- **`pnpm build:dep`** - Builds workspace dependencies needed by the current package

#### Test Scripts

- **`pnpm test`** (root) - Builds everything once, then runs `test:self` on all packages
- **`pnpm test`** (package) - Builds dependencies first, then runs tests
- **`pnpm test:self`** - Runs only the package's tests (no building)
- **`pnpm test:coverage`** (root) - Builds everything once, then runs `test:coverage:self` on all packages
- **`pnpm test:coverage`** (package) - Builds dependencies first, then runs coverage
- **`pnpm test:coverage:self`** - Runs only the package's coverage tests (no building)

#### Key Benefits

- **Efficiency**: Root `pnpm test` builds once, then tests all packages
- **Reliability**: Individual package tests always ensure dependencies are built
- **Consistency**: Same patterns work at any level (root or package)
- **Child Package Support**: Packages with child packages delegate testing appropriately

#### Examples

```bash
# Build everything from root
pnpm build

# Test everything from root (builds once, tests all)
pnpm test

# Test a specific package (builds its dependencies, then tests)
cd packages/horizon && pnpm test

# Test without building (assumes dependencies already built)
cd packages/horizon && pnpm test:self
```

### Versioning and publishing packages

We use [changesets](https://github.com/changesets/changesets) to manage package versioning, this ensures that all packages are versioned together in a consistent manner and helps with generating changelogs.

#### Step 1: Creating a changeset

A changeset is a file that describes the changes that have been made to the packages in the repository. To create a changeset, run the following command from the root of the repository:

```bash
pnpm changeset
```

Changeset files are stored in the `.changeset` directory until they are packaged into a release. You can commit these files and even merge them into your main branch without publishing a release.

#### Step 2: Creating a package release

When you are ready to create a new package release, run the following command to package all changesets, this will also bump package versions and dependencies:

```bash
pnpm changeset version
```

### Step 3: Tagging the release

**Note**: this step is meant to be run on the main branch.

After creating a package release, you will need to tag the release commit with the version number. To do this, run the following command from the root of the repository:

```bash
pnpm changeset tag
git push --follow-tags
```

#### Step 4: Publishing a package release

**Note**: this step is meant to be run on the main branch.

The [`Publish package to NPM`](.github/workflows/publish.yml) workflow is the standard publish path. It uses OIDC trusted publishing — no `NPM_TOKEN` is involved, and SLSA provenance is attached automatically. Anyone with `workflow_dispatch` permission on the repo can run it; no local npm credentials needed. The workflow also creates and pushes the package's git tag after a successful publish (so Step 3 can be skipped when using this path).

Dispatch from the Actions tab, or via `gh`:

```bash
gh workflow run publish.yml -f package=interfaces -f tag=latest -f dry_run=false
```

Inputs:

- `package` — the workspace package to publish (one of `address-book`, `contracts`, `interfaces`, `toolshed`).
- `tag` — npm dist-tag. Use `latest` for stable releases; use a custom tag (`dips`, `sepolia`, `next`, …) for pre-releases so the stable channel isn't overwritten.
- `dry_run` — when `true`, validates the workflow without consuming a version or pushing a git tag.

The workflow publishes one package per dispatch; for a multi-package release, dispatch once per package.

**Prerequisite:** each package on the choice list must have a Trusted Publisher entry on npmjs.com (Settings → Publishing access) with owner `graphprotocol`, repo `contracts`, workflow `publish.yml`, environment blank. Adding a new package to the workflow's `package` input without configuring its npm-side entry first will 403 at the publish step.

#### Alternative: local publish

For maintainers with publish rights on `@graphprotocol/*` — useful as a fallback if OIDC is unavailable, or for packages not on the workflow's choice list. Run from the root of a clean checkout:

```bash
# Publish the packages
pnpm changeset publish

# Alternatively use
pnpm publish --recursive
```

## Linting

This monorepo uses multiple linting tools: ESLint, Prettier, Solhint, Forge Lint, Markdownlint, and YAML Lint.

```bash
pnpm lint          # Run all linters
pnpm lint:staged   # Lint only staged files
```

See [docs/Linting.md](docs/Linting.md) for detailed configuration, inline suppression syntax, and troubleshooting.

## Documentation

- [Deployment Strategy](DEPLOYMENT.md) — Branching model and deployment workflow for Solidity contracts
- [Linting](docs/Linting.md) — Linting configuration and troubleshooting

Each package also has its own README with package-specific documentation.

## Contributing

Contributions are welcomed and encouraged! You can do so by:

- Creating an issue
- Opening a PR

If you are opening a PR, it is a good idea to first go to [The Graph Discord](https://discord.com/invite/vtvv7FP) or [The Graph Forum](https://forum.thegraph.com/) and discuss your idea! Discussions on the forum or Discord are another great way to contribute.

## Security

If you find a bug or security issue please go through the official channel, [The Graph Security Bounties on Immunefi](https://immunefi.com/bounty/thegraph/). Responsible disclosure procedures must be followed to receive bounties.

## License

Copyright &copy; 2021 The Graph Foundation

Licensed under [GPL license](LICENSE).

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T17:00:00Z`  
Project: `25_thegraph`  
Solidity files: `503`

### Structure
Top Solidity directories:
- `packages`: 503 `.sol` files

Pragmas:
- `^0.7.3`
- `^0.7.3 || ^0.8.0`
- `^0.7.6`
- `^0.7.6 || ^0.8.0`
- `^0.7.6 || ^0.8.27`
- `^0.8.0`
- `^0.8.12`
- `^0.8.22`
- `^0.8.24`
- `^0.8.27`

Contracts/Libraries/Interfaces detected: `525`

### Life Total / Balance Values
Detected accounting/state total variables:
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol` = `10_000 ether`
- `indexer` | type: `IndexerSetup internal` | vis: `internal` | flags: `-` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol`
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol` = `10_000 ether`
- `indexer` | type: `IndexerSetup internal` | vis: `internal` | flags: `-` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol`
- `STAKING` | type: `IStaking private immutable` | vis: `private` | flags: `immutable` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `messageIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/contracts/contracts/tests/arbitrum/BridgeMock.sol`
- `messageIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/token-distribution/contracts/tests/BridgeMock.sol`
- `MAX_STAKING_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `10_000_000_000 ether`
- `STAKE_TO_FEES_RATIO` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `2`
- `defaultReserveRatio` | type: `uint32 public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `pools` | type: `mapping(bytes32 => CurationPool) public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `STAKE_TO_FEES_RATIO` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpFees` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpFees.sol` = `1000`
- `STAKE_TO_FEES_RATIO` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `2`
- `staking` | type: `IHorizonStaking internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `fixedReserveRatio` | type: `uint32 internal immutable` | vis: `internal` | flags: `immutable` | `GNS` @ `packages/contracts/contracts/discovery/GNS.sol` = `MAX_PPM`
- `staking` | type: `IHorizonStaking public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `stakingBase` | type: `HorizonStaking private` | vis: `private` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `GRAPH_STAKING` | type: `IHorizonStaking private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address assetHolder => bool allowed) private` | vis: `private` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_counterpartStakingAddress` | type: `address internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_minimumIndexerStake` | type: `uint256 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_delegationPools` | type: `mapping(address serviceProvider => mapping(address verifier => IHorizonStakingTypes.DelegationPoolInternal delegationPool)) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_legacyDelegationPools` | type: `mapping(address serviceProvider => IHorizonStakingTypes.DelegationPoolInternal delegationPool) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `totalMintedFromL2` | type: `uint256 public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `staking` | type: `address payable public immutable` | vis: `public` | flags: `immutable,payable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `tokenLockETHBalances` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `indexerTransferredToL2` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1StakingV1Storage` @ `packages/contracts/contracts/staking/L1StakingStorage.sol`
- `fixedReserveRatio` | type: `uint32 private immutable` | vis: `private` | flags: `immutable` | `L2Curation` @ `packages/contracts/contracts/l2/curation/L2Curation.sol` = `MAX_PPM`
- `STAKING` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("Staking")`
- `_horizonStakingMock` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `ProvisionManagerTest` @ `packages/horizon/test/unit/data-service/utilities/ProvisionManager.t.sol`
- `indexer` | type: `address internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `staking` | type: `HorizonStakingStub internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperAuditTest` @ `packages/issuance/test/unit/agreement-manager/helperAudit.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperCleanupTest` @ `packages/issuance/test/unit/agreement-manager/helperCleanup.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementLifecycleTest` @ `packages/issuance/test/unit/agreement-manager/lifecycle.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerEscrowEdgeCasesTest` @ `packages/issuance/test/unit/agreement-manager/escrowEdgeCases.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerFundingModesTest` @ `packages/issuance/test/unit/agreement-manager/fundingModes.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerMultiIndexerTest` @ `packages/issuance/test/unit/agreement-manager/multiIndexer.t.sol`
- `indexer3` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerMultiIndexerTest` @ `packages/issuance/test/unit/agreement-manager/multiIndexer.t.sol`
- `indexer` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `_horizonStaking` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_horizonStaking` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `INDEXER_INELIGIBLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("INDEXER_INELIGIBLE")`
- `DEFAULT_INDEXER_RETENTION_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `365 days`
- `indexer1` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `__DEPRECATED_tokenSupplySnapshot` | type: `uint256 private` | vis: `private` | flags: `-` | `RewardsManagerV3Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `minimumIndexerStake` | type: `uint256 public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol` = `100e18`
- `stakes` | type: `mapping(address => Stakes.Indexer) public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__delegationPools` | type: `mapping(address => IStakingData.DelegationPool) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__minimumIndexerStake` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__stakes` | type: `mapping(address => IStakes.Indexer) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `counterpartStakingAddress` | type: `address internal` | vis: `internal` | flags: `-` | `StakingV3Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `staking` | type: `IHorizonStaking` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `stakingBase` | type: `HorizonStaking private` | vis: `private` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `indexers` | type: `mapping(address indexer => ISubgraphService.Indexer details) public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `indexingFeesCut` | type: `uint256 public` | vis: `public` | flags: `-` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `stakeToFeesRatio` | type: `uint256 public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`

All detected state variables (full list):
- `offset` | type: `uint160 internal constant` | vis: `internal` | flags: `constant` | `AddressAliasHelper` @ `packages/contracts/contracts/arbitrum/AddressAliasHelper.sol` = `uint160(0x1111000000000000000000000000000000001111)`
- `offset` | type: `uint160 internal constant` | vis: `internal` | flags: `constant` | `AddressAliasHelper` @ `packages/token-distribution/contracts/tests/arbitrum/AddressAliasHelper.sol` = `uint160(0x1111000000000000000000000000000000001111)`
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol` = `10_000 ether`
- `SUBGRAPH_DEPLOYMENT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol` = `keccak256("test-subgraph-deployment")`
- `indexer` | type: `IndexerSetup internal` | vis: `internal` | flags: `-` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol`
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol` = `10_000 ether`
- `SUBGRAPH_DEPLOYMENT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol` = `keccak256("test-subgraph-deployment")`
- `indexer` | type: `IndexerSetup internal` | vis: `internal` | flags: `-` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol`
- `GRAPH_TOKEN` | type: `IGraphToken private immutable` | vis: `private` | flags: `immutable` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `SIGNATURE_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol` = `65`
- `STAKING` | type: `IStaking private immutable` | vis: `private` | flags: `immutable` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `allocationsRedeemed` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `authority` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `_allocations` | type: `mapping(address => IAllocation.State) private` | vis: `private` | flags: `-` | `AllocationHarness` @ `packages/subgraph-service/test/unit/mocks/AllocationHarness.sol`
- `allocationId` | type: `address private` | vis: `private` | flags: `-` | `AllocationLibraryTest` @ `packages/subgraph-service/test/unit/libraries/AllocationLibrary.t.sol`
- `harness` | type: `AllocationHarness private` | vis: `private` | flags: `-` | `AllocationLibraryTest` @ `packages/subgraph-service/test/unit/libraries/AllocationLibrary.t.sol`
- `EIP712_ALLOCATION_ID_PROOF_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AllocationManager` @ `packages/subgraph-service/contracts/utilities/AllocationManager.sol` = `keccak256("AllocationIdProof(address indexer,address allocationId)")`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `_allocations` | type: `mapping(address allocationId => IAllocation.State allocation) internal` | vis: `internal` | flags: `-` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `_legacyAllocations` | type: `mapping(address allocationId => ILegacyAllocation.State allocation) internal` | vis: `internal` | flags: `-` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `_subgraphAllocatedTokens` | type: `mapping(bytes32 subgraphDeploymentId => uint256 tokens) internal` | vis: `internal` | flags: `-` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `allocationProvisionTracker` | type: `mapping(address indexer => uint256 tokens) public override` | vis: `public` | flags: `override` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `maxPOIStaleness` | type: `uint256 public override` | vis: `public` | flags: `override` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `ATTESTATION_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `RECEIPT_SIZE_BYTES + SIG_SIZE_BYTES`
- `BYTES32_BYTE_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `32`
- `RECEIPT_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `96`
- `SIG_R_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `32`
- `SIG_R_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `RECEIPT_SIZE_BYTES`
- `SIG_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `SIG_R_LENGTH + SIG_S_LENGTH + SIG_V_LENGTH`
- `SIG_S_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `32`
- `SIG_S_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `RECEIPT_SIZE_BYTES + SIG_R_LENGTH`
- `SIG_V_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `1`
- `SIG_V_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `RECEIPT_SIZE_BYTES + SIG_R_LENGTH + SIG_S_LENGTH`
- `UINT8_BYTE_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Attestation` @ `packages/subgraph-service/contracts/libraries/Attestation.sol` = `1`
- `DOMAIN_NAME_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AttestationManager` @ `packages/subgraph-service/contracts/utilities/AttestationManager.sol` = `keccak256("Graph Protocol")`
- `DOMAIN_SALT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AttestationManager` @ `packages/subgraph-service/contracts/utilities/AttestationManager.sol` = `0xa070ffb1cd7409649bf77822cce74495468e06dbfaef09556838bf188679b9c2`
- `DOMAIN_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AttestationManager` @ `packages/subgraph-service/contracts/utilities/AttestationManager.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)")`
- `DOMAIN_VERSION_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AttestationManager` @ `packages/subgraph-service/contracts/utilities/AttestationManager.sol` = `keccak256("0")`
- `RECEIPT_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `AttestationManager` @ `packages/subgraph-service/contracts/utilities/AttestationManager.sol` = `keccak256("Receipt(bytes32 requestCID,bytes32 responseCID,bytes32 subgraphDeploymentID)")`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `AttestationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AttestationManagerStorage.sol`
- `_domainSeparator` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `AttestationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AttestationManagerStorage.sol`
- `REVOKE_AUTHORIZATION_THAWING_PERIOD` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `Authorizable` @ `packages/horizon/contracts/utilities/Authorizable.sol`
- `authorizable` | type: `IAuthorizable internal` | vis: `internal` | flags: `-` | `AuthorizableHelper` @ `packages/horizon/test/unit/utilities/Authorizable.t.sol`
- `revokeAuthorizationThawingPeriod` | type: `uint256 public` | vis: `public` | flags: `-` | `AuthorizableHelper` @ `packages/horizon/test/unit/utilities/Authorizable.t.sol`
- `authHelper` | type: `AuthorizableHelper` | vis: `default` | flags: `-` | `AuthorizableTest` @ `packages/horizon/test/unit/utilities/Authorizable.t.sol`
- `authorizable` | type: `IAuthorizable public` | vis: `public` | flags: `-` | `AuthorizableTest` @ `packages/horizon/test/unit/utilities/Authorizable.t.sol`
- `FIXED_1` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x080000000000000000000000000000000`
- `FIXED_2` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x100000000000000000000000000000000`
- `LN2_DENOMINATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x5b9de1d10bf4103d647b0955897ba80`
- `LN2_NUMERATOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x3f80fe03f80fe03f80fe03f80fe03f8`
- `MAX_NUM` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x200000000000000000000000000000000`
- `MAX_PRECISION` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `127`
- `MAX_RATIO` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `1000000`
- `MIN_PRECISION` | type: `uint8 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `32`
- `ONE` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `1`
- `OPT_EXP_MAX_VAL` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x800000000000000000000000000000000`
- `OPT_LOG_MAX_VAL` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `0x15bf0a8b1457695355fb8ac404e7a79e3`
- `maxExpArray` | type: `uint256[128] private` | vis: `private` | flags: `-` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol`
- `version` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `BancorFormula` @ `packages/contracts/contracts/bancor/BancorFormula.sol` = `6`
- `ALPHABET` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `Base58Encoder` @ `packages/contracts/contracts/libraries/Base58Encoder.sol` = `"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"`
- `sha256MultiHash` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `Base58Encoder` @ `packages/contracts/contracts/libraries/Base58Encoder.sol` = `hex"1220"`
- `GOVERNOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol` = `keccak256("GOVERNOR_ROLE")`
- `GRAPH_TOKEN` | type: `IGraphToken internal immutable` | vis: `internal` | flags: `immutable` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol`
- `MILLION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol` = `1_000_000`
- `OPERATOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol` = `keccak256("PAUSE_ROLE")`
- `SECP256K1_CURVE_ORDER` | type: `uint256 constant` | vis: `default` | flags: `constant` | `Bounder` @ `packages/horizon/test/unit/utils/Bounder.t.sol` = `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141`
- `inbox` | type: `address public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/contracts/contracts/tests/arbitrum/BridgeMock.sol`
- `inbox` | type: `address public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/token-distribution/contracts/tests/BridgeMock.sol`
- `inboxAccs` | type: `bytes32[] public override` | vis: `public` | flags: `override` | `BridgeMock` @ `packages/contracts/contracts/tests/arbitrum/BridgeMock.sol`
- `inboxAccs` | type: `bytes32[] public override` | vis: `public` | flags: `override` | `BridgeMock` @ `packages/token-distribution/contracts/tests/BridgeMock.sol`
- `messageIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/contracts/contracts/tests/arbitrum/BridgeMock.sol`
- `messageIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/token-distribution/contracts/tests/BridgeMock.sol`
- `outbox` | type: `address public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/contracts/contracts/tests/arbitrum/BridgeMock.sol`
- `outbox` | type: `address public` | vis: `public` | flags: `-` | `BridgeMock` @ `packages/token-distribution/contracts/tests/BridgeMock.sol`
- `CALLBACK_GAS_OVERHEAD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CallbackGasProbe` @ `packages/horizon/contracts/mocks/CallbackGasProbe.sol` = `3_000`
- `MAX_PAYER_CALLBACK_GAS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CallbackGasProbe` @ `packages/horizon/contracts/mocks/CallbackGasProbe.sol` = `1_500_000`
- `GAS_THRESHOLD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CallbackGasTest` @ `packages/testing/test/gas/CallbackGas.t.sol` = `MAX_PAYER_CALLBACK_GAS / 2`
- `MAX_PAYER_CALLBACK_GAS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `CallbackGasTest` @ `packages/testing/test/gas/CallbackGas.t.sol` = `1_500_000`
- `ALLOCATIONS_REWARD_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `100 ether`
- `CURATION_CUT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `10000`
- `DELEGATION_FEE_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `100000`
- `DELEGATION_RATIO` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `16`
- `DISPUTE_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `100 ether`
- `DISPUTE_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `7 days`
- `EPOCH_LENGTH` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `1`
- `EPOCH_LENGTH` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1`
- `FISHERMAN_REWARD_PERCENTAGE` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `500000`
- `MAXIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `type(uint256).max`
- `MAX_POI_STALENESS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `28 days`
- `MAX_PPM` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `1000000`
- `MAX_PPM` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1_000_000`
- `MAX_SLASHING_PERCENTAGE` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `100000`
- `MAX_STAKING_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `10_000_000_000 ether`
- `MAX_THAWING_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `28 days`
- `MAX_THAW_REQUESTS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `1_000`
- `MAX_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `10_000_000_000 ether`
- `MAX_WAIT_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `28 days`
- `MINIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1000 ether`
- `MIN_DELEGATION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `1e18`
- `MIN_DELEGATION` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1 ether`
- `MIN_DISPUTE_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1 ether`
- `PROTOCOL_PAYMENT_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `10000`
- `PROTOCOL_PAYMENT_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `10000`
- `REVOKE_SIGNER_THAWING_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `7 days`
- `REVOKE_SIGNER_THAWING_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `7 days`
- `REWARDS_PER_SIGNAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `10000`
- `REWARDS_PER_SUBGRAPH_ALLOCATION_UPDATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1000`
- `STAKE_TO_FEES_RATIO` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `2`
- `THAWING_PERIOD_IN_BLOCKS` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `300`
- `WITHDRAW_ESCROW_THAWING_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `60`
- `WITHDRAW_ESCROW_THAWING_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `60`
- `_registry` | type: `mapping(bytes32 => address) private` | vis: `private` | flags: `-` | `Controller` @ `packages/contracts/contracts/governance/Controller.sol`
- `_partialPaused` | type: `bool internal` | vis: `internal` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `_pauseGuardian` | type: `address internal` | vis: `internal` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `_paused` | type: `bool internal` | vis: `internal` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `_registry` | type: `mapping(bytes32 contractName => address contractAddress) private` | vis: `private` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `governor` | type: `address public` | vis: `public` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `_dummy` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ControllerStub` @ `packages/testing/test/mocks/ControllerStub.sol`
- `_registry` | type: `mapping(bytes32 => address) private` | vis: `private` | flags: `-` | `ControllerStub` @ `packages/testing/test/mocks/ControllerStub.sol`
- `MAX_PPM` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `Curation` @ `packages/contracts/contracts/curation/Curation.sol` = `1000000`
- `SIGNAL_PER_MINIMUM_DEPOSIT` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `Curation` @ `packages/contracts/contracts/curation/Curation.sol` = `1e18`
- `curation` | type: `mapping(bytes32 subgraphDeploymentId => uint256 tokens) public` | vis: `public` | flags: `-` | `CurationMock` @ `packages/horizon/contracts/mocks/CurationMock.sol`
- `bondingCurve` | type: `address public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `curationTokenMaster` | type: `address public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `defaultReserveRatio` | type: `uint32 public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `minimumCurationDeposit` | type: `uint256 public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `pools` | type: `mapping(bytes32 => CurationPool) public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `subgraphService` | type: `address public` | vis: `public` | flags: `-` | `CurationV3Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `DELEGATION_RATIO` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `100`
- `PROVISION_TOKENS_MAX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `5000`
- `PROVISION_TOKENS_MIN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `50`
- `THAWING_PERIOD_MAX` | type: `uint64 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `76`
- `THAWING_PERIOD_MIN` | type: `uint64 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `15`
- `VERIFIER_CUT_MAX` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `100000`
- `VERIFIER_CUT_MIN` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `5`
- `dataService` | type: `DataServiceImpFees` | vis: `default` | flags: `-` | `DataServiceFeesTest` @ `packages/horizon/test/unit/data-service/extensions/DataServiceFees.t.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `DataServiceFeesV1Storage` @ `packages/horizon/contracts/data-service/extensions/DataServiceFeesStorage.sol`
- `claims` | type: `mapping(bytes32 claimId => StakeClaims.StakeClaim claim) public` | vis: `public` | flags: `-` | `DataServiceFeesV1Storage` @ `packages/horizon/contracts/data-service/extensions/DataServiceFeesStorage.sol`
- `claimsLists` | type: `mapping(address serviceProvider => ILinkedList.List list) public` | vis: `public` | flags: `-` | `DataServiceFeesV1Storage` @ `packages/horizon/contracts/data-service/extensions/DataServiceFeesStorage.sol`
- `feesProvisionTracker` | type: `mapping(address serviceProvider => uint256 tokens) public` | vis: `public` | flags: `-` | `DataServiceFeesV1Storage` @ `packages/horizon/contracts/data-service/extensions/DataServiceFeesStorage.sol`
- `LOCK_DURATION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpFees` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpFees.sol` = `1 minutes`
- `STAKE_TO_FEES_RATIO` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpFees` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpFees.sol` = `1000`
- `DELEGATION_RATIO` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `100`
- `PROVISION_TOKENS_MAX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `5000`
- `PROVISION_TOKENS_MIN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `50`
- `THAWING_PERIOD_MAX` | type: `uint64 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `76`
- `THAWING_PERIOD_MIN` | type: `uint64 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `15`
- `VERIFIER_CUT_MAX` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `100000`
- `VERIFIER_CUT_MIN` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `5`
- `pauseGuardians` | type: `mapping(address pauseGuardian => bool allowed) public override` | vis: `public` | flags: `override` | `DataServicePausable` @ `packages/horizon/contracts/data-service/extensions/DataServicePausable.sol`
- `dataService` | type: `DataServiceImpPausable` | vis: `default` | flags: `-` | `DataServicePausableTest` @ `packages/horizon/test/unit/data-service/extensions/DataServicePausable.t.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `DataServicePausableUpgradeable` @ `packages/horizon/contracts/data-service/extensions/DataServicePausableUpgradeable.sol`
- `pauseGuardians` | type: `mapping(address pauseGuardian => bool allowed) public override` | vis: `public` | flags: `override` | `DataServicePausableUpgradeable` @ `packages/horizon/contracts/data-service/extensions/DataServicePausableUpgradeable.sol`
- `dataService` | type: `DataServiceImpPausableUpgradeable private` | vis: `private` | flags: `-` | `DataServicePausableUpgradeableTest` @ `packages/horizon/test/unit/data-service/extensions/DataServicePausableUpgradeable.t.sol`
- `dataService` | type: `DataServiceBase` | vis: `default` | flags: `-` | `DataServiceTest` @ `packages/horizon/test/unit/data-service/DataService.t.sol`
- `dataServiceOverride` | type: `DataServiceOverride` | vis: `default` | flags: `-` | `DataServiceTest` @ `packages/horizon/test/unit/data-service/DataService.t.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `DataServiceV1Storage` @ `packages/horizon/contracts/data-service/DataServiceStorage.sol`
- `DIRECT_ALLOCATION_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DirectAllocation` @ `packages/issuance/contracts/allocate/DirectAllocation.sol` = `keccak256(abi.encode(uint256(keccak256("graphprotocol.storage.DirectAllocation")) - 1)) & ~bytes32(uint256(0xff))`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol` = `keccak256("PAUSE_ROLE")`
- `directAlloc` | type: `DirectAllocation internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `unauthorized` | type: `address internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `user` | type: `address internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `CURATION` | type: `ICuration private immutable` | vis: `private` | flags: `immutable` | `Directory` @ `packages/subgraph-service/contracts/utilities/Directory.sol`
- `DISPUTE_MANAGER` | type: `IDisputeManager private immutable` | vis: `private` | flags: `immutable` | `Directory` @ `packages/subgraph-service/contracts/utilities/Directory.sol`
- `GRAPH_TALLY_COLLECTOR` | type: `IGraphTallyCollector private immutable` | vis: `private` | flags: `immutable` | `Directory` @ `packages/subgraph-service/contracts/utilities/Directory.sol`
- `RECURRING_COLLECTOR` | type: `IRecurringCollector private immutable` | vis: `private` | flags: `immutable` | `Directory` @ `packages/subgraph-service/contracts/utilities/Directory.sol`
- `SUBGRAPH_SERVICE` | type: `ISubgraphService private immutable` | vis: `private` | flags: `immutable` | `Directory` @ `packages/subgraph-service/contracts/utilities/Directory.sol`
- `ATTESTATION_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `RECEIPT_SIZE_BYTES + SIG_SIZE_BYTES`
- `BYTES32_BYTE_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `32`
- `DOMAIN_NAME_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `keccak256("Graph Protocol")`
- `DOMAIN_SALT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `0xa070ffb1cd7409649bf77822cce74495468e06dbfaef09556838bf188679b9c2`
- `DOMAIN_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)")`
- `DOMAIN_VERSION_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `keccak256("0")`
- `MAX_FISHERMAN_REWARD_CUT` | type: `uint32 public constant` | vis: `public` | flags: `constant` | `DisputeManager` @ `packages/subgraph-service/contracts/DisputeManager.sol` = `500000`
- `MAX_PPM` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `1000000`
- `MIN_DISPUTE_DEPOSIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DisputeManager` @ `packages/subgraph-service/contracts/DisputeManager.sol` = `1e18`
- `RECEIPT_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `96`
- `RECEIPT_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `keccak256("Receipt(bytes32 requestCID,bytes32 responseCID,bytes32 subgraphDeploymentID)")`
- `SIG_R_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `32`
- `SIG_R_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `RECEIPT_SIZE_BYTES`
- `SIG_SIZE_BYTES` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `SIG_R_LENGTH + SIG_S_LENGTH + SIG_V_LENGTH`
- `SIG_S_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `32`
- `SIG_S_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `RECEIPT_SIZE_BYTES + SIG_R_LENGTH`
- `SIG_V_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `1`
- `SIG_V_OFFSET` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `RECEIPT_SIZE_BYTES + SIG_R_LENGTH + SIG_S_LENGTH`
- `UINT8_BYTE_LENGTH` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `DisputeManager` @ `packages/contracts/contracts/disputes/DisputeManager.sol` = `1`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/accept.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/accept.t.sol` = `keccak256(abi.encodePacked("Response CID"))`
- `subgraphDeploymentId` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/accept.t.sol` = `keccak256(abi.encodePacked("Subgraph Deployment ID"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/cancel.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/cancel.t.sol` = `keccak256(abi.encodePacked("Response CID"))`
- `subgraphDeploymentId` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/cancel.t.sol` = `keccak256(abi.encodePacked("Subgraph Deployment ID"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/accept.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid1` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/accept.t.sol` = `keccak256(abi.encodePacked("Response CID 1"))`
- `responseCid2` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictAcceptDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/accept.t.sol` = `keccak256(abi.encodePacked("Response CID 2"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/cancel.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid1` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/cancel.t.sol` = `keccak256(abi.encodePacked("Response CID 1"))`
- `responseCid2` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCancelDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/cancel.t.sol` = `keccak256(abi.encodePacked("Response CID 2"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/create.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid1` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/create.t.sol` = `keccak256(abi.encodePacked("Response CID 1"))`
- `responseCid2` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/create.t.sol` = `keccak256(abi.encodePacked("Response CID 2"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/draw.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid1` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/draw.t.sol` = `keccak256(abi.encodePacked("Response CID 1"))`
- `responseCid2` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryConflictDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/queryConflict/draw.t.sol` = `keccak256(abi.encodePacked("Response CID 2"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/create.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/create.t.sol` = `keccak256(abi.encodePacked("Response CID"))`
- `subgraphDeploymentId` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryCreateDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/create.t.sol` = `keccak256(abi.encodePacked("Subgraph Deployment ID"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/draw.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/draw.t.sol` = `keccak256(abi.encodePacked("Response CID"))`
- `subgraphDeploymentId` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryDrawDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/draw.t.sol` = `keccak256(abi.encodePacked("Subgraph Deployment ID"))`
- `requestCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryRejectDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/reject.t.sol` = `keccak256(abi.encodePacked("Request CID"))`
- `responseCid` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryRejectDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/reject.t.sol` = `keccak256(abi.encodePacked("Response CID"))`
- `subgraphDeploymentId` | type: `bytes32 private` | vis: `private` | flags: `-` | `DisputeManagerQueryRejectDisputeTest` @ `packages/subgraph-service/test/unit/disputeManager/disputes/query/reject.t.sol` = `keccak256(abi.encodePacked("Subgraph Deployment ID"))`
- `DOMAIN_SEPARATOR` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `arbitrator` | type: `address public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `arbitrator` | type: `address public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `disputeDeposit` | type: `uint256 public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `disputePeriod` | type: `uint64 public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `disputes` | type: `mapping(bytes32 => IDisputeManager.Dispute) public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `disputes` | type: `mapping(bytes32 disputeId => IDisputeManager.Dispute dispute) public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `fishermanRewardCut` | type: `uint32 public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `fishermanRewardPercentage` | type: `uint32 public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `idxSlashingPercentage` | type: `uint32 public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `maxSlashingCut` | type: `uint32 public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `minimumDeposit` | type: `uint256 public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `qrySlashingPercentage` | type: `uint32 public` | vis: `public` | flags: `-` | `DisputeManagerV1Storage` @ `packages/contracts/contracts/disputes/DisputeManagerStorage.sol`
- `subgraphService` | type: `ISubgraphService public override` | vis: `public` | flags: `override` | `DisputeManagerV1Storage` @ `packages/subgraph-service/contracts/DisputeManagerStorage.sol`
- `_addresses` | type: `EnumerableSet.AddressSet private` | vis: `private` | flags: `-` | `EnumerableSetUtilHarness` @ `packages/issuance/test/unit/mocks/EnumerableSetUtilHarness.sol`
- `_bytes32s` | type: `EnumerableSet.Bytes32Set private` | vis: `private` | flags: `-` | `EnumerableSetUtilHarness` @ `packages/issuance/test/unit/mocks/EnumerableSetUtilHarness.sol`
- `harness` | type: `EnumerableSetUtilHarness internal` | vis: `internal` | flags: `-` | `EnumerableSetUtilTest` @ `packages/issuance/test/unit/common/enumerableSetUtil.t.sol`
- `epochLength` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerMock` @ `packages/horizon/contracts/mocks/EpochManagerMock.sol`
- `lastLengthUpdateBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerMock` @ `packages/horizon/contracts/mocks/EpochManagerMock.sol`
- `lastLengthUpdateEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerMock` @ `packages/horizon/contracts/mocks/EpochManagerMock.sol`
- `lastRunEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerMock` @ `packages/horizon/contracts/mocks/EpochManagerMock.sol`
- `epochLength` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerV1Storage` @ `packages/contracts/contracts/epochs/EpochManagerStorage.sol`
- `lastLengthUpdateBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerV1Storage` @ `packages/contracts/contracts/epochs/EpochManagerStorage.sol`
- `lastLengthUpdateEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerV1Storage` @ `packages/contracts/contracts/epochs/EpochManagerStorage.sol`
- `lastRunEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `EpochManagerV1Storage` @ `packages/contracts/contracts/epochs/EpochManagerStorage.sol`
- `changed` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `EthereumDIDRegistry` @ `packages/contracts/contracts/discovery/erc1056/EthereumDIDRegistry.sol`
- `delegates` | type: `mapping(address => mapping(bytes32 => mapping(address => uint256))) public` | vis: `public` | flags: `-` | `EthereumDIDRegistry` @ `packages/contracts/contracts/discovery/erc1056/EthereumDIDRegistry.sol`
- `nonce` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `EthereumDIDRegistry` @ `packages/contracts/contracts/discovery/erc1056/EthereumDIDRegistry.sol`
- `owners` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `EthereumDIDRegistry` @ `packages/contracts/contracts/discovery/erc1056/EthereumDIDRegistry.sol`
- `AGREEMENT_MANAGER_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `keccak256("AGREEMENT_MANAGER_ROLE")`
- `COLLECTOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `keccak256("COLLECTOR_ROLE")`
- `CURATION_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `10000`
- `DATA_SERVICE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `keccak256("DATA_SERVICE_ROLE")`
- `DELEGATION_RATIO` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `16`
- `DISPUTE_DEPOSIT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `100 ether`
- `DISPUTE_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `7 days`
- `EPOCH_LENGTH` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `1`
- `FISHERMAN_REWARD_PERCENTAGE` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `500000`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `MAX_POI_STALENESS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `28 days`
- `MAX_SLASHING_PERCENTAGE` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `100000`
- `MAX_WAIT_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `28 days`
- `MINIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `1000 ether`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `keccak256("OPERATOR_ROLE")`
- `PROTOCOL_PAYMENT_CUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `10000`
- `REVOKE_SIGNER_THAWING_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `7 days`
- `REWARDS_PER_SIGNAL` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `10000`
- `REWARDS_PER_SUBGRAPH_ALLOCATION_UPDATE` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `1000`
- `STAKE_TO_FEES_RATIO` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `2`
- `WITHDRAW_ESCROW_THAWING_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `60`
- `arbitrator` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `controller` | type: `Controller internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `curation` | type: `MockCuration internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `deployer` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `disputeManager` | type: `DisputeManager internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `epochManager` | type: `MockEpochManager internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `escrow` | type: `PaymentsEscrow internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `graphPayments` | type: `GraphPayments internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `issuanceAllocator` | type: `IssuanceAllocator internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `pauseGuardian` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `proxyAdmin` | type: `GraphProxyAdmin internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `ram` | type: `RecurringAgreementManager internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `ramHelper` | type: `RecurringAgreementHelper internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `rcHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `recurringCollector` | type: `RecurringCollector internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `recurringCollectorProxyAdmin` | type: `address internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `rewardsManager` | type: `MockRewardsManager internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `staking` | type: `IHorizonStaking internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `subgraphService` | type: `SubgraphService internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `token` | type: `MockGRTToken internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `MAX_PPM` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `GNS` @ `packages/contracts/contracts/discovery/GNS.sol` = `1000000`
- `fixedReserveRatio` | type: `uint32 internal immutable` | vis: `internal` | flags: `immutable` | `GNS` @ `packages/contracts/contracts/discovery/GNS.sol` = `MAX_PPM`
- `__DEPRECATED_bondingCurve` | type: `address private` | vis: `private` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `__DEPRECATED_erc1056Registry` | type: `IEthereumDIDRegistry private` | vis: `private` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `legacySubgraphData` | type: `mapping(address => mapping(uint256 => IGNS.SubgraphData)) public` | vis: `public` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `legacySubgraphs` | type: `mapping(address => mapping(uint256 => bytes32)) internal` | vis: `internal` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `nextAccountSeqID` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `ownerTaxPercentage` | type: `uint32 public` | vis: `public` | flags: `-` | `GNSV1Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `legacySubgraphKeys` | type: `mapping(uint256 => IGNS.LegacySubgraphKey) public` | vis: `public` | flags: `-` | `GNSV2Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `subgraphNFT` | type: `ISubgraphNFT public` | vis: `public` | flags: `-` | `GNSV2Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `subgraphs` | type: `mapping(uint256 => IGNS.SubgraphData) public` | vis: `public` | flags: `-` | `GNSV2Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `GNSV3Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `counterpartGNSAddress` | type: `address public` | vis: `public` | flags: `-` | `GNSV3Storage` @ `packages/contracts/contracts/discovery/GNSStorage.sol`
- `MIN_REQUIRED_GASLEFT` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `GasReportingEligibilityMock` @ `packages/horizon/contracts/mocks/GasReportingEligibilityMock.sol`
- `governor` | type: `address public` | vis: `public` | flags: `-` | `Governed` @ `packages/contracts/contracts/governance/Governed.sol`
- `pendingGovernor` | type: `address public` | vis: `public` | flags: `-` | `Governed` @ `packages/contracts/contracts/governance/Governed.sol`
- `controller` | type: `Controller public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `curation` | type: `CurationMock public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `epochManager` | type: `EpochManagerMock public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `escrow` | type: `PaymentsEscrow public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `graphTallyCollector` | type: `GraphTallyCollector` | vis: `default` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `graphTokenGatewayAddress` | type: `address` | vis: `default` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol` = `makeAddr("GraphTokenGateway")`
- `payments` | type: `GraphPayments public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `proxyAdmin` | type: `GraphProxyAdmin public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `rewardsManager` | type: `RewardsManagerMock public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `staking` | type: `IHorizonStaking public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `stakingBase` | type: `HorizonStaking private` | vis: `private` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `subgraphDataServiceAddress` | type: `address` | vis: `default` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol` = `makeAddr("subgraphDataServiceAddress")`
- `subgraphDataServiceLegacyAddress` | type: `address` | vis: `default` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol` = `makeAddr("subgraphDataServiceLegacyAddress")`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `users` | type: `Users internal` | vis: `internal` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `GRAPH_CONTROLLER` | type: `IController private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_EPOCH_MANAGER` | type: `IEpochManager private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_PAYMENTS` | type: `IGraphPayments private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_PAYMENTS_ESCROW` | type: `IPaymentsEscrow private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_PROXY_ADMIN` | type: `IGraphProxyAdmin private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_REWARDS_MANAGER` | type: `IRewardsManager private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_STAKING` | type: `IHorizonStaking private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_TOKEN` | type: `IGraphToken private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_TOKEN_GATEWAY` | type: `ITokenGateway private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `controller` | type: `Controller public` | vis: `public` | flags: `-` | `GraphEscrowConstructorTest` @ `packages/horizon/test/unit/escrow/constructor.t.sol`
- `PROTOCOL_PAYMENT_CUT` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `GraphPayments` @ `packages/horizon/contracts/payments/GraphPayments.sol`
- `ADMIN_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `GraphProxyStorage` @ `packages/contracts/contracts/upgrades/GraphProxyStorage.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `GraphProxyStorage` @ `packages/contracts/contracts/upgrades/GraphProxyStorage.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `PENDING_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `GraphProxyStorage` @ `packages/contracts/contracts/upgrades/GraphProxyStorage.sol` = `0x9e5eddc59e0b171f57125ab86bee043d9128098c3a6b9adb4f2e86333c2f6f8c`
- `SECP256K1_CURVE_ORDER` | type: `uint256 constant` | vis: `default` | flags: `constant` | `GraphTallyAuthorizeSignerTest` @ `packages/horizon/test/unit/payments/graph-tally-collector/signer/authorizeSigner.t.sol` = `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141`
- `EIP712_RAV_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphTallyCollector` @ `packages/horizon/contracts/payments/collectors/GraphTallyCollector.sol` = `keccak256( "ReceiptAggregateVoucher(bytes32 collectionId,address payer,address serviceProvider,address dataService,uint64 timestampNs,uint128 valueAggregate,bytes metadata)" )`
- `tokensCollected` | type: `mapping(address dataService => mapping(bytes32 collectionId => mapping(address receiver => mapping(address payer => uint256 tokens)))) public` | vis: `public` | flags: `-` | `GraphTallyCollector` @ `packages/horizon/contracts/payments/collectors/GraphTallyCollector.sol`
- `signer` | type: `address` | vis: `default` | flags: `-` | `GraphTallyTest` @ `packages/horizon/test/unit/payments/graph-tally-collector/GraphTallyCollector.t.sol`
- `signerPrivateKey` | type: `uint256` | vis: `default` | flags: `-` | `GraphTallyTest` @ `packages/horizon/test/unit/payments/graph-tally-collector/GraphTallyCollector.t.sol`
- `DOMAIN_NAME_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol` = `keccak256("Graph Token")`
- `DOMAIN_SALT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol` = `0x51f3d585afe6dfeb2af01bba0889a36c1db03beec88c6a4d0c53817069026afa`
- `DOMAIN_TYPE_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)")`
- `DOMAIN_VERSION_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol` = `keccak256("0")`
- `PERMIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `_minters` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol`
- `domainSeparator` | type: `bytes32 private` | vis: `private` | flags: `-` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `GraphToken` @ `packages/contracts/contracts/token/GraphToken.sol`
- `beneficiaries` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `GraphTokenDistributor` @ `packages/token-distribution/contracts/GraphTokenDistributor.sol`
- `locked` | type: `bool public` | vis: `public` | flags: `-` | `GraphTokenDistributor` @ `packages/token-distribution/contracts/GraphTokenDistributor.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `GraphTokenDistributor` @ `packages/token-distribution/contracts/GraphTokenDistributor.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `GraphTokenGateway` @ `packages/contracts/contracts/gateway/GraphTokenGateway.sol`
- `MIN_PERIOD` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol` = `1`
- `beneficiary` | type: `address public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `endTime` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `isAccepted` | type: `bool public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `isInitialized` | type: `bool public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `isRevoked` | type: `bool public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `managedAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `periods` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `releaseStartTime` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `releasedAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `revocable` | type: `IGraphTokenLock.Revocability public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `revokedAmount` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `startTime` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `vestingCliffTime` | type: `uint256 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `_token` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `_tokenDestinations` | type: `EnumerableSet.AddressSet private` | vis: `private` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `authFnCalls` | type: `mapping(bytes4 => address) public` | vis: `public` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `masterCopy` | type: `address public` | vis: `public` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `manager` | type: `IGraphTokenLockManager public` | vis: `public` | flags: `-` | `GraphTokenLockWallet` @ `packages/token-distribution/contracts/GraphTokenLockWallet.sol`
- `DOMAIN_NAME_HASH` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol` = `keccak256("Graph Token")`
- `DOMAIN_SALT` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol` = `0xe33842a7acd1d5a1d28f25a931703e5605152dc48d64dc4716efdae1f5659591`
- `DOMAIN_SEPARATOR` | type: `bytes32 private` | vis: `private` | flags: `-` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol`
- `DOMAIN_TYPE_HASH` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol` = `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)")`
- `DOMAIN_VERSION_HASH` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol` = `keccak256("0")`
- `PERMIT_TYPEHASH` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol` = `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`
- `__gap` | type: `uint256[47] private` | vis: `private` | flags: `-` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol`
- `_minters` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `GraphTokenUpgradeable` @ `packages/contracts/contracts/l2/token/GraphTokenUpgradeable.sol`
- `IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `GraphUpgradeable` @ `packages/contracts/contracts/upgrades/GraphUpgradeable.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `_HEX_SYMBOLS` | type: `bytes16 private constant` | vis: `private` | flags: `constant` | `HexStrings` @ `packages/contracts/contracts/libraries/HexStrings.sol` = `"0123456789abcdef"`
- `MAX_THAW_REQUESTS` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `HorizonStaking` @ `packages/horizon/contracts/staking/HorizonStaking.sol` = `1_000`
- `MIN_DELEGATION` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `HorizonStaking` @ `packages/horizon/contracts/staking/HorizonStaking.sol` = `1e18`
- `SUBGRAPH_DATA_SERVICE_ADDRESS` | type: `address internal immutable` | vis: `internal` | flags: `immutable` | `HorizonStakingBase` @ `packages/horizon/contracts/staking/HorizonStakingBase.sol`
- `authorizations` | type: `mapping(address => mapping(address => mapping(address => bool))) public` | vis: `public` | flags: `-` | `HorizonStakingMock` @ `packages/horizon/test/unit/mocks/HorizonStakingMock.t.sol`
- `provisions` | type: `mapping(address => mapping(address => IHorizonStakingTypes.Provision)) public` | vis: `public` | flags: `-` | `HorizonStakingMock` @ `packages/horizon/test/unit/mocks/HorizonStakingMock.t.sol`
- `newDataService` | type: `address private` | vis: `private` | flags: `-` | `HorizonStakingReprovisionTest` @ `packages/horizon/test/unit/staking/provision/reprovision.t.sol` = `makeAddr("newDataService")`
- `_allocationId` | type: `address internal` | vis: `internal` | flags: `-` | `HorizonStakingSharedTest` @ `packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol` = `makeAddr("allocationId")`
- `provisions` | type: `mapping(address => mapping(address => IHorizonStakingTypes.Provision)) public` | vis: `public` | flags: `-` | `HorizonStakingStub` @ `packages/testing/test/mocks/HorizonStakingStub.sol`
- `__DEPRECATED_allocations` | type: `mapping(address allocationId => IHorizonStakingTypes.LegacyAllocation allocation) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_alphaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_alphaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address assetHolder => bool allowed) private` | vis: `private` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_channelDisputeEpochs` | type: `uint32 private` | vis: `private` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_counterpartStakingAddress` | type: `address internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_curationPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_delegationParametersCooldown` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_delegationRatio` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_delegationTaxPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_delegationUnbondingPeriod` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_extensionImpl` | type: `address internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_lambdaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_lambdaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_maxAllocationEpochs` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_minimumIndexerStake` | type: `uint256 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_protocolPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_rebates` | type: `mapping(uint256 epoch => uint256 rebates) private` | vis: `private` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_rewardsDestination` | type: `mapping(address serviceProvider => address rewardsDestination) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_slashers` | type: `mapping(address slasher => bool allowed) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_subgraphAllocations` | type: `mapping(bytes32 subgraphDeploymentId => uint256 tokens) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_thawingPeriod` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_allowedLockedVerifiers` | type: `mapping(address verifier => bool allowed) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_delegationFeeCut` | type: `mapping(address serviceProvider => mapping(address verifier => mapping(IGraphPayments.PaymentTypes paymentType => uint256 feeCut))) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_delegationPools` | type: `mapping(address serviceProvider => mapping(address verifier => IHorizonStakingTypes.DelegationPoolInternal delegationPool)) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_delegationSlashingEnabled` | type: `bool internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_legacyDelegationPools` | type: `mapping(address serviceProvider => IHorizonStakingTypes.DelegationPoolInternal delegationPool) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_legacyOperatorAuth` | type: `mapping(address serviceProvider => mapping(address legacyOperator => bool authorized)) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_maxThawingPeriod` | type: `uint64 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_operatorAuth` | type: `mapping(address serviceProvider => mapping(address verifier => mapping(address operator => bool authorized))) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_provisions` | type: `mapping(address serviceProvider => mapping(address verifier => IHorizonStakingTypes.Provision provision)) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_serviceProviders` | type: `mapping(address serviceProvider => IHorizonStakingTypes.ServiceProviderInternal details) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_thawRequestLists` | type: `mapping(IHorizonStakingTypes.ThawRequestType thawRequestType => mapping(address serviceProvider => mapping(address verifier => mapping(address owner => ILinkedList.List list)))) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `_thawRequests` | type: `mapping(IHorizonStakingTypes.ThawRequestType thawRequestType => mapping(bytes32 thawRequestId => IHorizonStakingTypes.ThawRequest thawRequest)) internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `returnBytes` | type: `uint256 public` | vis: `public` | flags: `-` | `HugeReturnPayer` @ `packages/horizon/test/unit/payments/recurring-collector/returndataBomb.t.sol` = `500_000`
- `L1MessageType_submitRetryableTx` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `InboxMock` @ `packages/contracts/contracts/tests/arbitrum/InboxMock.sol` = `9`
- `L1MessageType_submitRetryableTx` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `InboxMock` @ `packages/token-distribution/contracts/tests/InboxMock.sol` = `9`
- `L2_MSG` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `InboxMock` @ `packages/contracts/contracts/tests/arbitrum/InboxMock.sol` = `3`
- `L2_MSG` | type: `uint8 internal constant` | vis: `internal` | flags: `constant` | `InboxMock` @ `packages/token-distribution/contracts/tests/InboxMock.sol` = `3`
- `bridge` | type: `IBridge public override` | vis: `public` | flags: `override` | `InboxMock` @ `packages/contracts/contracts/tests/arbitrum/InboxMock.sol`
- `bridge` | type: `IBridge public override` | vis: `public` | flags: `override` | `InboxMock` @ `packages/token-distribution/contracts/tests/InboxMock.sol`
- `_mockCollector` | type: `address private` | vis: `private` | flags: `-` | `IndexingAgreementTest` @ `packages/subgraph-service/test/unit/libraries/IndexingAgreement.t.sol`
- `_storageManager` | type: `IndexingAgreement.StorageManager private` | vis: `private` | flags: `-` | `IndexingAgreementTest` @ `packages/subgraph-service/test/unit/libraries/IndexingAgreement.t.sol`
- `ISSUANCE_ALLOCATOR_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `IssuanceAllocator` @ `packages/issuance/contracts/allocate/IssuanceAllocator.sol` = `keccak256(abi.encode(uint256(keccak256("graphprotocol.storage.IssuanceAllocator")) - 1)) & ~bytes32(uint256(0xff))`
- `harness` | type: `IssuanceAllocatorTestHarness internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorDefensiveChecksTest` @ `packages/issuance/test/unit/allocator/defensiveChecks.t.sol`
- `B0` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `IssuanceAllocatorDistributionAccountingTest` @ `packages/issuance/test/unit/allocator/distributionAccounting.t.sol` = `1_000_000`
- `target3` | type: `address internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorDistributionAccountingTest` @ `packages/issuance/test/unit/allocator/distributionAccounting.t.sol`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `ISSUANCE_PER_BLOCK` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol` = `100 ether`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol` = `keccak256("OPERATOR_ROLE")`
- `PAUSE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol` = `keccak256("PAUSE_ROLE")`
- `allocator` | type: `IssuanceAllocator internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `nonTarget` | type: `MockERC165 internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `reentrantTarget` | type: `MockReentrantTarget internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `revertingTarget` | type: `MockRevertingTarget internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `simpleTarget` | type: `MockSimpleTarget internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `trackerTarget` | type: `MockNotificationTracker internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `unauthorized` | type: `address internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `L1GNSV1Storage` @ `packages/contracts/contracts/discovery/L1GNSStorage.sol`
- `subgraphTransferredToL2` | type: `mapping(uint256 => bool) public` | vis: `public` | flags: `-` | `L1GNSV1Storage` @ `packages/contracts/contracts/discovery/L1GNSStorage.sol`
- `accumulatedL2MintAllowanceSnapshot` | type: `uint256 public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `callhookAllowlist` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `escrow` | type: `address public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `inbox` | type: `address public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `l1Router` | type: `address public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `l2Counterpart` | type: `address public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `l2GRT` | type: `address public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `l2MintAllowancePerBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `lastL2MintAllowanceUpdateBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `totalMintedFromL2` | type: `uint256 public` | vis: `public` | flags: `-` | `L1GraphTokenGateway` @ `packages/contracts/contracts/gateway/L1GraphTokenGateway.sol`
- `graphToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l1Gateway` | type: `ITokenGateway public immutable` | vis: `public` | flags: `immutable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2Beneficiary` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2Implementation` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2LockManager` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2WalletAddress` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2WalletAddressSetManually` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2WalletOwner` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `staking` | type: `address payable public immutable` | vis: `public` | flags: `immutable,payable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `tokenLockETHBalances` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l2WalletAddress` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferToolBadMock` @ `packages/contracts/contracts/tests/L1GraphTokenLockTransferToolBadMock.sol`
- `l2WalletAddress` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferToolMock` @ `packages/contracts/contracts/tests/L1GraphTokenLockTransferToolMock.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `L1StakingV1Storage` @ `packages/contracts/contracts/staking/L1StakingStorage.sol`
- `indexerTransferredToL2` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L1StakingV1Storage` @ `packages/contracts/contracts/staking/L1StakingStorage.sol`
- `l1GraphTokenLockTransferTool` | type: `IL1GraphTokenLockTransferTool internal` | vis: `internal` | flags: `-` | `L1StakingV1Storage` @ `packages/contracts/contracts/staking/L1StakingStorage.sol`
- `nextSeqNum` | type: `uint256 public` | vis: `public` | flags: `-` | `L1TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L1TokenGatewayMock.sol`
- `ARB_SYS_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `L2ArbitrumMessenger` @ `packages/contracts/contracts/arbitrum/L2ArbitrumMessenger.sol` = `address(100)`
- `MAX_PPM` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `L2Curation` @ `packages/contracts/contracts/l2/curation/L2Curation.sol` = `1000000`
- `SIGNAL_PER_MINIMUM_DEPOSIT` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `L2Curation` @ `packages/contracts/contracts/l2/curation/L2Curation.sol` = `1`
- `fixedReserveRatio` | type: `uint32 private immutable` | vis: `private` | flags: `immutable` | `L2Curation` @ `packages/contracts/contracts/l2/curation/L2Curation.sol` = `MAX_PPM`
- `MAX_PPM` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `L2GNS` @ `packages/contracts/contracts/l2/discovery/L2GNS.sol` = `1000000`
- `MAX_ROUNDING_ERROR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `L2GNS` @ `packages/contracts/contracts/l2/discovery/L2GNS.sol` = `1000`
- `SUBGRAPH_ID_ALIAS_OFFSET` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `L2GNS` @ `packages/contracts/contracts/l2/discovery/L2GNS.sol` = `uint256(0x1111000000000000000000000000000000000000000000000000000000001111)`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `L2GNSV1Storage` @ `packages/contracts/contracts/l2/discovery/L2GNSStorage.sol`
- `subgraphL2TransferData` | type: `mapping(uint256 => IL2GNS.SubgraphL2TransferData) public` | vis: `public` | flags: `-` | `L2GNSV1Storage` @ `packages/contracts/contracts/l2/discovery/L2GNSStorage.sol`
- `gateway` | type: `address public` | vis: `public` | flags: `-` | `L2GraphToken` @ `packages/contracts/contracts/l2/token/L2GraphToken.sol`
- `l1Address` | type: `address public override` | vis: `public` | flags: `override` | `L2GraphToken` @ `packages/contracts/contracts/l2/token/L2GraphToken.sol`
- `l1Counterpart` | type: `address public` | vis: `public` | flags: `-` | `L2GraphTokenGateway` @ `packages/contracts/contracts/l2/gateway/L2GraphTokenGateway.sol`
- `l1GRT` | type: `address public` | vis: `public` | flags: `-` | `L2GraphTokenGateway` @ `packages/contracts/contracts/l2/gateway/L2GraphTokenGateway.sol`
- `l2Router` | type: `address public` | vis: `public` | flags: `-` | `L2GraphTokenGateway` @ `packages/contracts/contracts/l2/gateway/L2GraphTokenGateway.sol`
- `l1TransferTool` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockManager` @ `packages/token-distribution/contracts/L2GraphTokenLockManager.sol`
- `l1WalletToL2Wallet` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L2GraphTokenLockManager` @ `packages/token-distribution/contracts/L2GraphTokenLockManager.sol`
- `l2WalletToL1Wallet` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `L2GraphTokenLockManager` @ `packages/token-distribution/contracts/L2GraphTokenLockManager.sol`
- `graphToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L2GraphTokenLockTransferTool.sol`
- `l1GraphToken` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L2GraphTokenLockTransferTool.sol`
- `l2Gateway` | type: `ITokenGateway public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L2GraphTokenLockTransferTool.sol`
- `MINIMUM_DELEGATION` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `L2Staking` @ `packages/contracts/contracts/l2/staking/L2Staking.sol` = `1e18`
- `l1Token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L2TokenGatewayMock.sol`
- `l2Token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L2TokenGatewayMock.sol`
- `nextId` | type: `uint256 public` | vis: `public` | flags: `-` | `L2TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L2TokenGatewayMock.sol`
- `MAX_EXPONENT` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `LibExponential` @ `packages/contracts/contracts/staking/libs/Exponential.sol` = `15`
- `EXP_MAX_VAL` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `0`
- `EXP_MIN_VAL` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `-int256(0x0000000000000000000000000000001ff0000000000000000000000000000000)`
- `FIXED_1` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `int256(0x0000000000000000000000000000000080000000000000000000000000000000)`
- `FIXED_1_SQUARED` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `int256(0x4000000000000000000000000000000000000000000000000000000000000000)`
- `LN_MAX_VAL` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `FIXED_1`
- `LN_MIN_VAL` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `int256(0x0000000000000000000000000000000000000000000000000000000733048c5a)`
- `MIN_FIXED_VAL` | type: `int256 private constant` | vis: `private` | flags: `constant` | `LibFixedMath` @ `packages/contracts/contracts/staking/libs/LibFixedMath.sol` = `int256(0x8000000000000000000000000000000000000000000000000000000000000000)`
- `MAX_ITEMS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `LinkedList` @ `packages/horizon/contracts/libraries/LinkedList.sol` = `10_000`
- `NULL_BYTES` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `LinkedList` @ `packages/horizon/contracts/libraries/LinkedList.sol` = `bytes("")`
- `LIST_LENGTH` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ListImplementation` @ `packages/horizon/test/unit/libraries/ListImplementation.sol` = `100`
- `ids` | type: `bytes32[LIST_LENGTH] public` | vis: `public` | flags: `-` | `ListImplementation` @ `packages/horizon/test/unit/libraries/ListImplementation.sol`
- `items` | type: `mapping(bytes32 id => Item data) public` | vis: `public` | flags: `-` | `ListImplementation` @ `packages/horizon/test/unit/libraries/ListImplementation.sol`
- `returnMalformed` | type: `bool public` | vis: `public` | flags: `-` | `MalformedEligibilityPayer` @ `packages/horizon/test/unit/payments/recurring-collector/coverageGaps.t.sol`
- `CURATION` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("Curation")`
- `EPOCH_MANAGER` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("EpochManager")`
- `GNS` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("GNS")`
- `GRAPH_TOKEN` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("GraphToken")`
- `GRAPH_TOKEN_GATEWAY` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("GraphTokenGateway")`
- `REWARDS_MANAGER` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("RewardsManager")`
- `STAKING` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("Staking")`
- `__DEPRECATED_addressCache` | type: `mapping(bytes32 contractName => address contractAddress) private` | vis: `private` | flags: `-` | `Managed` @ `packages/horizon/contracts/staking/utilities/Managed.sol`
- `__DEPRECATED_controller` | type: `address private` | vis: `private` | flags: `-` | `Managed` @ `packages/horizon/contracts/staking/utilities/Managed.sol`
- `__gap` | type: `uint256[10] private` | vis: `private` | flags: `-` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol`
- `__gap` | type: `uint256[10] private` | vis: `private` | flags: `-` | `Managed` @ `packages/horizon/contracts/staking/utilities/Managed.sol`
- `_addressCache` | type: `mapping(bytes32 => address) private` | vis: `private` | flags: `-` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol`
- `controller` | type: `IController public override` | vis: `public` | flags: `override` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol`
- `ineligibleProviders` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `lastBeforeCollectionTokens` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `lastCollectedTokens` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `recordedAfterCollectionGasleft` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `recordedBeforeCollectionGasleft` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `shouldRevert` | type: `bool public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `shouldRevertOnBeforeCollection` | type: `bool public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `shouldRevertOnCollected` | type: `bool public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `cancelCalled` | type: `bool public` | vis: `public` | flags: `-` | `MockDataServiceForCancel` @ `packages/horizon/test/unit/payments/recurring-collector/coverageGaps.t.sol`
- `canceledAgreementId` | type: `bytes16 public` | vis: `public` | flags: `-` | `MockDataServiceForCancel` @ `packages/horizon/test/unit/payments/recurring-collector/coverageGaps.t.sol`
- `_defaultEligible` | type: `bool private` | vis: `private` | flags: `-` | `MockEligibilityOracle` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol` = `true`
- `_eligible` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `MockEligibilityOracle` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol`
- `defaultEligible` | type: `bool public` | vis: `public` | flags: `-` | `MockEligibilityOracle` @ `packages/issuance/test/unit/agreement-manager/mocks/MockEligibilityOracle.sol`
- `eligible` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `MockEligibilityOracle` @ `packages/issuance/test/unit/agreement-manager/mocks/MockEligibilityOracle.sol`
- `epochLength` | type: `uint256 public` | vis: `public` | flags: `-` | `MockEpochManager` @ `packages/subgraph-service/test/unit/mocks/MockEpochManager.sol`
- `lastLengthUpdateBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `MockEpochManager` @ `packages/subgraph-service/test/unit/mocks/MockEpochManager.sol`
- `lastLengthUpdateEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `MockEpochManager` @ `packages/subgraph-service/test/unit/mocks/MockEpochManager.sol`
- `lastRunEpoch` | type: `uint256 public` | vis: `public` | flags: `-` | `MockEpochManager` @ `packages/subgraph-service/test/unit/mocks/MockEpochManager.sol`
- `_targetIssuance` | type: `mapping(address => TargetIssuancePerBlock) private` | vis: `private` | flags: `-` | `MockIssuanceAllocator` @ `packages/contracts/contracts/tests/MockIssuanceAllocator.sol`
- `distributeCallCount` | type: `uint256 public` | vis: `public` | flags: `-` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `graphToken` | type: `MockGraphToken public immutable` | vis: `public` | flags: `immutable` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `lastDistributedBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `mintPerDistribution` | type: `uint256 public` | vis: `public` | flags: `-` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `shouldRevert` | type: `bool public` | vis: `public` | flags: `-` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `target` | type: `address public immutable` | vis: `public` | flags: `immutable` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `lastNotificationBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `MockNotificationTracker` @ `packages/issuance/contracts/test/allocate/MockNotificationTracker.sol`
- `notificationCount` | type: `uint256 public` | vis: `public` | flags: `-` | `MockNotificationTracker` @ `packages/issuance/contracts/test/allocate/MockNotificationTracker.sol`
- `THAWING_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockPaymentsEscrow` @ `packages/issuance/test/unit/agreement-manager/mocks/MockPaymentsEscrow.sol` = `1 days`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockPaymentsEscrow` @ `packages/issuance/test/unit/agreement-manager/mocks/MockPaymentsEscrow.sol`
- `actionToPerform` | type: `ReentrantAction public` | vis: `public` | flags: `-` | `MockReentrantTarget` @ `packages/issuance/contracts/test/allocate/MockReentrantTarget.sol`
- `issuanceAllocator` | type: `address public` | vis: `public` | flags: `-` | `MockReentrantTarget` @ `packages/issuance/contracts/test/allocate/MockReentrantTarget.sol`
- `shouldAttemptReentrancy` | type: `bool public` | vis: `public` | flags: `-` | `MockReentrantTarget` @ `packages/issuance/contracts/test/allocate/MockReentrantTarget.sol`
- `defaultResponse` | type: `bool private` | vis: `private` | flags: `-` | `MockRewardsEligibilityOracle` @ `packages/contracts/contracts/tests/MockRewardsEligibilityOracle.sol`
- `eligible` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `MockRewardsEligibilityOracle` @ `packages/contracts/contracts/tests/MockRewardsEligibilityOracle.sol`
- `ineligible` | type: `mapping(address indexer => bool isIneligible) private` | vis: `private` | flags: `-` | `MockRewardsEligibilityOracle` @ `packages/issuance/contracts/eligibility/mocks/MockRewardsEligibilityOracle.sol`
- `isSet` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `MockRewardsEligibilityOracle` @ `packages/contracts/contracts/tests/MockRewardsEligibilityOracle.sol`
- `FIXED_POINT_SCALING_FACTOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol` = `1e18`
- `rewardsPerSignal` | type: `uint256 public` | vis: `public` | flags: `-` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol`
- `rewardsPerSubgraphAllocationUpdate` | type: `uint256 public` | vis: `public` | flags: `-` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol`
- `subgraphs` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol`
- `cancelCallCount` | type: `mapping(bytes16 => uint256) public` | vis: `public` | flags: `-` | `MockSubgraphService` @ `packages/issuance/test/unit/agreement-manager/mocks/MockSubgraphService.sol`
- `canceled` | type: `mapping(bytes16 => bool) public` | vis: `public` | flags: `-` | `MockSubgraphService` @ `packages/issuance/test/unit/agreement-manager/mocks/MockSubgraphService.sol`
- `revertMessage` | type: `string public` | vis: `public` | flags: `-` | `MockSubgraphService` @ `packages/issuance/test/unit/agreement-manager/mocks/MockSubgraphService.sol`
- `shouldRevert` | type: `bool public` | vis: `public` | flags: `-` | `MockSubgraphService` @ `packages/issuance/test/unit/agreement-manager/mocks/MockSubgraphService.sol`
- `subgraphAllocatedTokens` | type: `mapping(bytes32 => uint256) private` | vis: `private` | flags: `-` | `MockSubgraphService` @ `packages/contracts/contracts/tests/MockSubgraphService.sol`
- `bridge` | type: `IBridge public` | vis: `public` | flags: `-` | `OutboxMock` @ `packages/contracts/contracts/tests/arbitrum/OutboxMock.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `Ownable` @ `packages/token-distribution/contracts/Ownable.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `packages/token-distribution/contracts/Ownable.sol`
- `MAX_PPM` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `PPMMath` @ `packages/horizon/contracts/libraries/PPMMath.sol` = `1_000_000`
- `MAX_PPM` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `PPMMathTest` @ `packages/horizon/test/unit/libraries/PPMMath.t.sol` = `1000000`
- `_contracts` | type: `Entry[] private` | vis: `private` | flags: `-` | `PartialControllerMock` @ `packages/horizon/test/unit/mocks/PartialControllerMock.t.sol`
- `_partialPaused` | type: `bool internal` | vis: `internal` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `_paused` | type: `bool internal` | vis: `internal` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `lastPartialPauseTime` | type: `uint256 public` | vis: `public` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `lastPauseTime` | type: `uint256 public` | vis: `public` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `pauseGuardian` | type: `address public` | vis: `public` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `MAX_WAIT_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `PaymentsEscrow` @ `packages/horizon/contracts/payments/PaymentsEscrow.sol` = `90 days`
- `WITHDRAW_ESCROW_THAWING_PERIOD` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `PaymentsEscrow` @ `packages/horizon/contracts/payments/PaymentsEscrow.sol`
- `escrowAccounts` | type: `mapping(address payer => mapping(address collector => mapping(address receiver => IPaymentsEscrow.EscrowAccount escrowAccount))) public override` | vis: `public` | flags: `override` | `PaymentsEscrow` @ `packages/horizon/contracts/payments/PaymentsEscrow.sol`
- `DEFAULT_DELEGATION_RATIO` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint32).max`
- `DEFAULT_MAX_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint256).max`
- `DEFAULT_MAX_THAWING_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint64).max`
- `DEFAULT_MAX_VERIFIER_CUT` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `uint32(PPMMath.MAX_PPM)`
- `DEFAULT_MIN_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint256).min`
- `DEFAULT_MIN_THAWING_PERIOD` | type: `uint64 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint64).min`
- `DEFAULT_MIN_VERIFIER_CUT` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint32).min`
- `_horizonStakingMock` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `ProvisionManagerTest` @ `packages/horizon/test/unit/data-service/utilities/ProvisionManager.t.sol`
- `_provisionManager` | type: `ProvisionManagerImpl internal` | vis: `internal` | flags: `-` | `ProvisionManagerTest` @ `packages/horizon/test/unit/data-service/utilities/ProvisionManager.t.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_delegationRatio` | type: `uint32 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_maximumProvisionTokens` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_maximumThawingPeriod` | type: `uint64 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_maximumVerifierCut` | type: `uint32 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_minimumProvisionTokens` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_minimumThawingPeriod` | type: `uint64 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_minimumVerifierCut` | type: `uint32 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `provisionTracker` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `ProvisionTrackerImplementation` @ `packages/horizon/test/unit/data-service/libraries/ProvisionTrackerImplementation.sol`
- `AGREEMENT_MANAGER_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol` = `keccak256("AGREEMENT_MANAGER_ROLE")`
- `COLLECTOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol` = `keccak256("COLLECTOR_ROLE")`
- `DATA_SERVICE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol` = `keccak256("DATA_SERVICE_ROLE")`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol` = `keccak256("OPERATOR_ROLE")`
- `controller` | type: `ControllerStub internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `dataService` | type: `address internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `indexer` | type: `address internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `issuanceAllocator` | type: `IssuanceAllocator internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `paymentsEscrow` | type: `PaymentsEscrow internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `ram` | type: `RecurringAgreementManager internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `recurringCollector` | type: `RecurringCollector internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `staking` | type: `HorizonStakingStub internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `token` | type: `GraphTokenMock internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `AGREEMENTS` | type: `IRecurringAgreements public immutable` | vis: `public` | flags: `immutable` | `RecurringAgreementHelper` @ `packages/issuance/contracts/agreement/RecurringAgreementHelper.sol`
- `GRAPH_TOKEN` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `RecurringAgreementHelper` @ `packages/issuance/contracts/agreement/RecurringAgreementHelper.sol`
- `MANAGER` | type: `IRecurringAgreementManagement public immutable` | vis: `public` | flags: `immutable` | `RecurringAgreementHelper` @ `packages/issuance/contracts/agreement/RecurringAgreementHelper.sol`
- `collector2` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperAuditTest` @ `packages/issuance/test/unit/agreement-manager/helperAudit.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperAuditTest` @ `packages/issuance/test/unit/agreement-manager/helperAudit.t.sol`
- `collector2` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperCleanupTest` @ `packages/issuance/test/unit/agreement-manager/helperCleanup.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementHelperCleanupTest` @ `packages/issuance/test/unit/agreement-manager/helperCleanup.t.sol`
- `THAW_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementLifecycleTest` @ `packages/issuance/test/unit/agreement-manager/lifecycle.t.sol` = `1 days`
- `collector2` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementLifecycleTest` @ `packages/issuance/test/unit/agreement-manager/lifecycle.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementLifecycleTest` @ `packages/issuance/test/unit/agreement-manager/lifecycle.t.sol`
- `AGREEMENT_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RecurringAgreementManager` @ `packages/issuance/contracts/agreement/RecurringAgreementManager.sol` = `keccak256("AGREEMENT_MANAGER_ROLE")`
- `COLLECTOR_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RecurringAgreementManager` @ `packages/issuance/contracts/agreement/RecurringAgreementManager.sol` = `keccak256("COLLECTOR_ROLE")`
- `DATA_SERVICE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RecurringAgreementManager` @ `packages/issuance/contracts/agreement/RecurringAgreementManager.sol` = `keccak256("DATA_SERVICE_ROLE")`
- `PAYMENTS_ESCROW` | type: `IPaymentsEscrow public immutable` | vis: `public` | flags: `immutable` | `RecurringAgreementManager` @ `packages/issuance/contracts/agreement/RecurringAgreementManager.sol`
- `PAUSE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerBranchCoverageTest` @ `packages/issuance/test/unit/agreement-manager/branchCoverage.t.sol` = `keccak256("PAUSE_ROLE")`
- `GAS_ALARM_THRESHOLD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerCallbackGasTest` @ `packages/issuance/test/unit/agreement-manager/callbackGas.t.sol` = `MAX_CALLBACK_GAS / 10`
- `MAX_CALLBACK_GAS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerCallbackGasTest` @ `packages/issuance/test/unit/agreement-manager/callbackGas.t.sol` = `1_500_000`
- `mockAllocator` | type: `MockIssuanceAllocator internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerCallbackGasTest` @ `packages/issuance/test/unit/agreement-manager/callbackGas.t.sol`
- `collector2` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerCascadeCleanupTest` @ `packages/issuance/test/unit/agreement-manager/cascadeCleanup.t.sol`
- `NO_ORACLE` | type: `IProviderEligibility internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerEligibilityTest` @ `packages/issuance/test/unit/agreement-manager/eligibility.t.sol` = `IProviderEligibility(address(0))`
- `oracle` | type: `MockEligibilityOracle internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerEligibilityTest` @ `packages/issuance/test/unit/agreement-manager/eligibility.t.sol`
- `mockAllocator` | type: `MockIssuanceAllocator internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerEnsureDistributedTest` @ `packages/issuance/test/unit/agreement-manager/ensureDistributed.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerEscrowEdgeCasesTest` @ `packages/issuance/test/unit/agreement-manager/escrowEdgeCases.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerFundingModesTest` @ `packages/issuance/test/unit/agreement-manager/fundingModes.t.sol`
- `collector2` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerMultiCollectorTest` @ `packages/issuance/test/unit/agreement-manager/multiCollector.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerMultiIndexerTest` @ `packages/issuance/test/unit/agreement-manager/multiIndexer.t.sol`
- `indexer3` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerMultiIndexerTest` @ `packages/issuance/test/unit/agreement-manager/multiIndexer.t.sol`
- `AGREEMENT_MANAGER_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol` = `keccak256("AGREEMENT_MANAGER_ROLE")`
- `COLLECTOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol` = `keccak256("COLLECTOR_ROLE")`
- `DATA_SERVICE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol` = `keccak256("DATA_SERVICE_ROLE")`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol` = `keccak256("OPERATOR_ROLE")`
- `agreementHelper` | type: `RecurringAgreementHelper internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `agreementManager` | type: `RecurringAgreementManager internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `dataService` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `indexer` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `paymentsEscrow` | type: `MockPaymentsEscrow internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `recurringCollector` | type: `MockRecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `CALLBACK_GAS_OVERHEAD` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `3_000`
- `CONDITION_AGREEMENT_OWNER` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `1 << 1`
- `CONDITION_ELIGIBILITY_CHECK` | type: `uint16 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `1 << 0`
- `EIP712_RCAU_TYPEHASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `keccak256( "RecurringCollectionAgreementUpdate(bytes16 agreementId,uint64 deadline,uint64 endsAt,uint256 maxInitialTokens,uint256 maxOngoingTokensPerSecond,uint32 minSecondsPerCollection,uint32 maxSecondsPerCollection,uint16 conditions,uint32 nonce,bytes metadata)" )`
- `EIP712_RCA_TYPEHASH` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `keccak256( "RecurringCollectionAgreement(uint64 deadline,uint64 endsAt,address payer,address dataService,address serviceProvider,uint256 maxInitialTokens,uint256 maxOngoingTokensPerSecond,uint32 minSecondsPerCollection,uint32 maxSecondsPerCollection,uint16 conditions,uint256 nonce,bytes metadata)" )`
- `MAX_PAYER_CALLBACK_GAS` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `1_500_000`
- `MIN_SECONDS_COLLECTION_WINDOW` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollector` @ `packages/horizon/contracts/payments/collectors/RecurringCollector.sol` = `600`
- `SIGNER_KEY` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RecurringCollectorAcceptValidationTest` @ `packages/horizon/test/unit/payments/recurring-collector/acceptValidation.t.sol` = `0xBEEF`
- `_proxyAdmin` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorAuthorizableTest` @ `packages/horizon/test/unit/payments/recurring-collector/RecurringCollectorAuthorizableTest.t.sol`
- `_approver` | type: `MockAgreementOwner internal` | vis: `internal` | flags: `-` | `RecurringCollectorHashRoundTripTest` @ `packages/horizon/test/unit/payments/recurring-collector/hashRoundTrip.t.sol`
- `collector` | type: `RecurringCollector public` | vis: `public` | flags: `-` | `RecurringCollectorHelper` @ `packages/horizon/test/unit/payments/recurring-collector/RecurringCollectorHelper.t.sol`
- `proxyAdmin` | type: `address public` | vis: `public` | flags: `-` | `RecurringCollectorHelper` @ `packages/horizon/test/unit/payments/recurring-collector/RecurringCollectorHelper.t.sol`
- `guardian` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorPauseTest` @ `packages/horizon/test/unit/payments/recurring-collector/pause.t.sol` = `makeAddr("guardian")`
- `_horizonStaking` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_paymentsEscrow` | type: `PaymentsEscrowMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_proxyAdmin` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_controller` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_horizonStaking` | type: `HorizonStakingMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_paymentsEscrow` | type: `PaymentsEscrowMock internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_proxyAdminAddr` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_proxyAdminOwner` | type: `address internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_recurringCollector` | type: `RecurringCollector internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `ALLOCATION_TOO_YOUNG` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("ALLOCATION_TOO_YOUNG")`
- `ALTRUISTIC_ALLOCATION` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("ALTRUISTIC_ALLOCATION")`
- `BELOW_MINIMUM_SIGNAL` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("BELOW_MINIMUM_SIGNAL")`
- `CLOSE_ALLOCATION` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("CLOSE_ALLOCATION")`
- `INDEXER_INELIGIBLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("INDEXER_INELIGIBLE")`
- `NONE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `bytes32(0)`
- `NO_ALLOCATED_TOKENS` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("NO_ALLOCATED_TOKENS")`
- `NO_SIGNAL` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("NO_SIGNAL")`
- `STALE_POI` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("STALE_POI")`
- `SUBGRAPH_DENIED` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("SUBGRAPH_DENIED")`
- `ZERO_POI` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("ZERO_POI")`
- `ORACLE` | type: `address public immutable` | vis: `public` | flags: `immutable` | `RewardsEligibilityHelper` @ `packages/issuance/contracts/eligibility/RewardsEligibilityHelper.sol`
- `helper` | type: `RewardsEligibilityHelper internal` | vis: `internal` | flags: `-` | `RewardsEligibilityHelperTest` @ `packages/issuance/test/unit/eligibility/helper.t.sol`
- `ORACLE_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsEligibilityOracle` @ `packages/issuance/contracts/eligibility/RewardsEligibilityOracle.sol` = `keccak256("ORACLE_ROLE")`
- `REWARDS_ELIGIBILITY_ORACLE_STORAGE_LOCATION` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RewardsEligibilityOracle` @ `packages/issuance/contracts/eligibility/RewardsEligibilityOracle.sol` = `keccak256(abi.encode(uint256(keccak256("graphprotocol.storage.RewardsEligibilityOracle")) - 1)) & ~bytes32(uint256(0xff))`
- `DEFAULT_ELIGIBILITY_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `14 days`
- `DEFAULT_INDEXER_RETENTION_PERIOD` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `365 days`
- `DEFAULT_ORACLE_TIMEOUT` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `7 days`
- `GOVERNOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `keccak256("GOVERNOR_ROLE")`
- `OPERATOR_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `keccak256("OPERATOR_ROLE")`
- `ORACLE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `keccak256("ORACLE_ROLE")`
- `PAUSE_ROLE` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol` = `keccak256("PAUSE_ROLE")`
- `governor` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `indexer1` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `indexer2` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `operator` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `oracle` | type: `RewardsEligibilityOracle internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `oracleAccount` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `unauthorized` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `FIXED_POINT_SCALING_FACTOR` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `RewardsManager` @ `packages/contracts/contracts/rewards/RewardsManager.sol` = `1e18`
- `_rewards` | type: `uint256 private` | vis: `private` | flags: `-` | `RewardsManagerMock` @ `packages/horizon/contracts/mocks/RewardsManagerMock.sol`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `RewardsManagerMock` @ `packages/horizon/contracts/mocks/RewardsManagerMock.sol`
- `__DEPRECATED_issuanceRate` | type: `uint256 private` | vis: `private` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `accRewardsPerSignal` | type: `uint256 public` | vis: `public` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `accRewardsPerSignalLastBlockUpdated` | type: `uint256 public` | vis: `public` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `denylist` | type: `mapping(bytes32 => uint256) public` | vis: `public` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `subgraphAvailabilityOracle` | type: `address public` | vis: `public` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `subgraphs` | type: `mapping(bytes32 => IRewardsManager.Subgraph) public` | vis: `public` | flags: `-` | `RewardsManagerV1Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `minimumSubgraphSignal` | type: `uint256 public` | vis: `public` | flags: `-` | `RewardsManagerV2Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `__DEPRECATED_tokenSupplySnapshot` | type: `uint256 private` | vis: `private` | flags: `-` | `RewardsManagerV3Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `issuancePerBlock` | type: `uint256 public override` | vis: `public` | flags: `override` | `RewardsManagerV4Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `subgraphService` | type: `IRewardsIssuer public override` | vis: `public` | flags: `override` | `RewardsManagerV5Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `defaultReclaimAddress` | type: `address internal` | vis: `internal` | flags: `-` | `RewardsManagerV6Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `issuanceAllocator` | type: `IIssuanceAllocationDistribution internal` | vis: `internal` | flags: `-` | `RewardsManagerV6Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `reclaimAddresses` | type: `mapping(bytes32 => address) internal` | vis: `internal` | flags: `-` | `RewardsManagerV6Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `revertOnIneligible` | type: `bool internal` | vis: `internal` | flags: `-` | `RewardsManagerV6Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `rewardsEligibilityOracle` | type: `IProviderEligibility internal` | vis: `internal` | flags: `-` | `RewardsManagerV6Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `services` | type: `mapping(address => IServiceRegistry.IndexerService) public` | vis: `public` | flags: `-` | `ServiceRegistryV1Storage` @ `packages/contracts/contracts/discovery/ServiceRegistryStorage.sol`
- `claims` | type: `mapping(bytes32 claimId => StakeClaims.StakeClaim claim) public` | vis: `public` | flags: `-` | `StakeClaimsHarness` @ `packages/horizon/test/unit/data-service/extensions/DataServiceFees.t.sol`
- `feesProvisionTracker` | type: `mapping(address serviceProvider => uint256 tokens) public` | vis: `public` | flags: `-` | `StakeClaimsHarness` @ `packages/horizon/test/unit/data-service/extensions/DataServiceFees.t.sol`
- `MAX_PPM` | type: `uint32 internal constant` | vis: `internal` | flags: `constant` | `Staking` @ `packages/contracts/contracts/staking/Staking.sol` = `1000000`
- `MAX_PPM` | type: `uint32 private constant` | vis: `private` | flags: `constant` | `StakingExtension` @ `packages/contracts/contracts/staking/StakingExtension.sol` = `1000000`
- `MINIMUM_DELEGATION` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `StakingExtension` @ `packages/contracts/contracts/staking/StakingExtension.sol` = `1e18`
- `minimumIndexerStake` | type: `uint256 public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol` = `100e18`
- `stakes` | type: `mapping(address => Stakes.Indexer) public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol`
- `thawingPeriod` | type: `uint256 public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol` = `10`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__DEPRECATED_channelDisputeEpochs` | type: `uint32 private` | vis: `private` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__DEPRECATED_delegationParametersCooldown` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__DEPRECATED_rebates` | type: `mapping(uint256 => uint256) private` | vis: `private` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__allocations` | type: `mapping(address => IStakingData.Allocation) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__alphaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__alphaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__curationPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__delegationPools` | type: `mapping(address => IStakingData.DelegationPool) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__delegationRatio` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__delegationTaxPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__delegationUnbondingPeriod` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__maxAllocationEpochs` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__minimumIndexerStake` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__operatorAuth` | type: `mapping(address => mapping(address => bool)) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__protocolPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__slashers` | type: `mapping(address => bool) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__stakes` | type: `mapping(address => IStakes.Indexer) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__subgraphAllocations` | type: `mapping(bytes32 => uint256) internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__thawingPeriod` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__rewardsDestination` | type: `mapping(address => address) internal` | vis: `internal` | flags: `-` | `StakingV2Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `counterpartStakingAddress` | type: `address internal` | vis: `internal` | flags: `-` | `StakingV3Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `extensionImpl` | type: `address internal` | vis: `internal` | flags: `-` | `StakingV3Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `StakingV4Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__lambdaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV4Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__lambdaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV4Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `NUM_ORACLES` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol` = `5`
- `currentNonce` | type: `uint256 public` | vis: `public` | flags: `-` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `executionThreshold` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `lastAllowVote` | type: `mapping(uint256 => mapping(bytes32 => uint256[NUM_ORACLES])) public` | vis: `public` | flags: `-` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `lastDenyVote` | type: `mapping(uint256 => mapping(bytes32 => uint256[NUM_ORACLES])) public` | vis: `public` | flags: `-` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `oracles` | type: `address[NUM_ORACLES] public` | vis: `public` | flags: `-` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `rewardsManager` | type: `IRewardsManager private immutable` | vis: `private` | flags: `immutable` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `voteTimeLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `SubgraphAvailabilityManager` @ `packages/contracts/contracts/rewards/SubgraphAvailabilityManager.sol`
- `controller` | type: `Controller` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `curation` | type: `MockCuration` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `disputeManager` | type: `DisputeManager` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `epochManager` | type: `MockEpochManager` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `escrow` | type: `IPaymentsEscrow` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `graphPayments` | type: `GraphPayments` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `graphTallyCollector` | type: `GraphTallyCollector` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `proxyAdmin` | type: `GraphProxyAdmin` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `recurringCollector` | type: `RecurringCollector` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `recurringCollectorProxyAdmin` | type: `address` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `rewardsManager` | type: `MockRewardsManager` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `staking` | type: `IHorizonStaking` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `stakingBase` | type: `HorizonStaking private` | vis: `private` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `subgraphService` | type: `SubgraphService` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `token` | type: `MockGRTToken` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `users` | type: `Users internal` | vis: `internal` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `_subgraphMetadataHashes` | type: `mapping(uint256 => bytes32) private` | vis: `private` | flags: `-` | `SubgraphNFT` @ `packages/contracts/contracts/discovery/SubgraphNFT.sol`
- `minter` | type: `address public` | vis: `public` | flags: `-` | `SubgraphNFT` @ `packages/contracts/contracts/discovery/SubgraphNFT.sol`
- `tokenDescriptor` | type: `ISubgraphNFTDescriptor public` | vis: `public` | flags: `-` | `SubgraphNFT` @ `packages/contracts/contracts/discovery/SubgraphNFT.sol`
- `DEFAULT` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `SubgraphService` @ `packages/subgraph-service/contracts/SubgraphService.sol` = `0`
- `REGISTERED` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `SubgraphService` @ `packages/subgraph-service/contracts/SubgraphService.sol` = `1 << 1`
- `VALID_PROVISION` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `SubgraphService` @ `packages/subgraph-service/contracts/SubgraphService.sol` = `1 << 0`
- `permissionlessBob` | type: `address private` | vis: `private` | flags: `-` | `SubgraphServiceAllocationForceCloseTest` @ `packages/subgraph-service/test/unit/subgraphService/allocation/forceClose.t.sol` = `makeAddr("permissionlessBob")`
- `GRAPH_PROXY_ADMIN_ADDRESS` | type: `address internal constant` | vis: `internal` | flags: `constant` | `SubgraphServiceIndexingAgreementSharedTest` @ `packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol` = `0x15c603B7eaA8eE1a272a69C4af3462F926de777F`
- `TRANSPARENT_UPGRADEABLE_PROXY_ADMIN_ADDRESS_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `SubgraphServiceIndexingAgreementSharedTest` @ `packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `SubgraphServiceIndexingAgreementSharedTest` @ `packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol`
- `signer` | type: `address` | vis: `default` | flags: `-` | `SubgraphServiceRegisterTest` @ `packages/subgraph-service/test/unit/subgraphService/collect/query/query.t.sol`
- `signerPrivateKey` | type: `uint256` | vis: `default` | flags: `-` | `SubgraphServiceRegisterTest` @ `packages/subgraph-service/test/unit/subgraphService/collect/query/query.t.sol`
- `allocationId` | type: `address` | vis: `default` | flags: `-` | `SubgraphServiceSharedTest` @ `packages/subgraph-service/test/unit/shared/SubgraphServiceShared.t.sol`
- `allocationIdPrivateKey` | type: `uint256` | vis: `default` | flags: `-` | `SubgraphServiceSharedTest` @ `packages/subgraph-service/test/unit/shared/SubgraphServiceShared.t.sol`
- `subgraphDeployment` | type: `bytes32` | vis: `default` | flags: `-` | `SubgraphServiceSharedTest` @ `packages/subgraph-service/test/unit/shared/SubgraphServiceShared.t.sol`
- `curationFeesCut` | type: `uint256 public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `indexers` | type: `mapping(address indexer => ISubgraphService.Indexer details) public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `indexingFeesCut` | type: `uint256 public` | vis: `public` | flags: `-` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `paymentsDestination` | type: `mapping(address indexer => address destination) public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `stakeToFeesRatio` | type: `uint256 public override` | vis: `public` | flags: `override` | `SubgraphServiceV1Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `blockClosingAllocationWithActiveAgreement` | type: `bool internal` | vis: `internal` | flags: `-` | `SubgraphServiceV2Storage` @ `packages/subgraph-service/contracts/SubgraphServiceStorage.sol`
- `isAccepted` | type: `bool public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`
- `isInitialized` | type: `bool public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`
- `manager` | type: `address public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`
- `target` | type: `address public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`
- `token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`
- `_dataService` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ZeroIdCollector` @ `packages/issuance/test/unit/agreement-manager/branchCoverage.t.sol`
- `_payer` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ZeroIdCollector` @ `packages/issuance/test/unit/agreement-manager/branchCoverage.t.sol`
- `_serviceProvider` | type: `address private immutable` | vis: `private` | flags: `immutable` | `ZeroIdCollector` @ `packages/issuance/test/unit/agreement-manager/branchCoverage.t.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleAdvancedTest` @ `packages/testing/test/integration/AgreementLifecycleAdvanced.t.sol` = `10_000 ether`
- `INDEXER_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `AgreementLifecycleTest` @ `packages/testing/test/integration/AgreementLifecycle.t.sol` = `10_000 ether`
- `GRAPH_TOKEN` | type: `IGraphToken private immutable` | vis: `private` | flags: `immutable` | `AllocationExchange` @ `packages/contracts/contracts/payments/AllocationExchange.sol`
- `_subgraphAllocatedTokens` | type: `mapping(bytes32 subgraphDeploymentId => uint256 tokens) internal` | vis: `internal` | flags: `-` | `AllocationManagerV1Storage` @ `packages/subgraph-service/contracts/utilities/AllocationManagerStorage.sol`
- `authHelper` | type: `AuthorizableHelper` | vis: `default` | flags: `-` | `AuthorizableTest` @ `packages/horizon/test/unit/utilities/Authorizable.t.sol`
- `ALPHABET` | type: `bytes internal constant` | vis: `internal` | flags: `constant` | `Base58Encoder` @ `packages/contracts/contracts/libraries/Base58Encoder.sol` = `"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"`
- `GRAPH_TOKEN` | type: `IGraphToken internal immutable` | vis: `internal` | flags: `immutable` | `BaseUpgradeable` @ `packages/issuance/contracts/common/BaseUpgradeable.sol`
- `MAXIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `type(uint256).max`
- `MAX_STAKING_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/horizon/test/unit/utils/Constants.sol` = `10_000_000_000 ether`
- `MAX_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `10_000_000_000 ether`
- `MINIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `Constants` @ `packages/subgraph-service/test/unit/utils/Constants.sol` = `1000 ether`
- `_partialPaused` | type: `bool internal` | vis: `internal` | flags: `-` | `ControllerMock` @ `packages/horizon/contracts/mocks/ControllerMock.sol`
- `curationTokenMaster` | type: `address public` | vis: `public` | flags: `-` | `CurationV1Storage` @ `packages/contracts/contracts/curation/CurationStorage.sol`
- `PROVISION_TOKENS_MAX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `5000`
- `PROVISION_TOKENS_MIN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceBase` @ `packages/horizon/test/unit/data-service/implementations/DataServiceBase.sol` = `50`
- `PROVISION_TOKENS_MAX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `5000`
- `PROVISION_TOKENS_MIN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DataServiceImpPausable` @ `packages/horizon/test/unit/data-service/implementations/DataServiceImpPausable.sol` = `50`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `DirectAllocationTest` @ `packages/issuance/test/unit/direct-allocation/DirectAllocation.t.sol`
- `MINIMUM_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol` = `1000 ether`
- `ramHelper` | type: `RecurringAgreementHelper internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `rcHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `token` | type: `MockGRTToken internal` | vis: `internal` | flags: `-` | `FullStackHarness` @ `packages/testing/test/harness/FullStackHarness.t.sol`
- `graphTokenGatewayAddress` | type: `address` | vis: `default` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol` = `makeAddr("GraphTokenGateway")`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `GraphBaseTest` @ `packages/horizon/test/unit/GraphBase.t.sol`
- `GRAPH_TOKEN` | type: `IGraphToken private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `GRAPH_TOKEN_GATEWAY` | type: `ITokenGateway private immutable` | vis: `private` | flags: `immutable` | `GraphDirectory` @ `packages/horizon/contracts/utilities/GraphDirectory.sol`
- `tokensCollected` | type: `mapping(address dataService => mapping(bytes32 collectionId => mapping(address receiver => mapping(address payer => uint256 tokens)))) public` | vis: `public` | flags: `-` | `GraphTallyCollector` @ `packages/horizon/contracts/payments/collectors/GraphTallyCollector.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `GraphTokenDistributor` @ `packages/token-distribution/contracts/GraphTokenDistributor.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `GraphTokenLock` @ `packages/token-distribution/contracts/GraphTokenLock.sol`
- `_token` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `_tokenDestinations` | type: `EnumerableSet.AddressSet private` | vis: `private` | flags: `-` | `GraphTokenLockManager` @ `packages/token-distribution/contracts/GraphTokenLockManager.sol`
- `__DEPRECATED_alphaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_alphaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address assetHolder => bool allowed) private` | vis: `private` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `__DEPRECATED_protocolPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `HorizonStakingV1Storage` @ `packages/horizon/contracts/staking/HorizonStakingStorage.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `IssuanceAllocatorSharedTest` @ `packages/issuance/test/unit/allocator/shared.t.sol`
- `graphToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `tokenLockETHBalances` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `L1GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L1GraphTokenLockTransferTool.sol`
- `l1GraphTokenLockTransferTool` | type: `IL1GraphTokenLockTransferTool internal` | vis: `internal` | flags: `-` | `L1StakingV1Storage` @ `packages/contracts/contracts/staking/L1StakingStorage.sol`
- `graphToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L2GraphTokenLockTransferTool.sol`
- `l1GraphToken` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2GraphTokenLockTransferTool` @ `packages/token-distribution/contracts/L2GraphTokenLockTransferTool.sol`
- `l1Token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L2TokenGatewayMock.sol`
- `l2Token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `L2TokenGatewayMock` @ `packages/token-distribution/contracts/tests/L2TokenGatewayMock.sol`
- `GRAPH_TOKEN` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("GraphToken")`
- `GRAPH_TOKEN_GATEWAY` | type: `bytes32 private immutable` | vis: `private` | flags: `immutable` | `Managed` @ `packages/contracts/contracts/governance/Managed.sol` = `keccak256("GraphTokenGateway")`
- `lastBeforeCollectionTokens` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `lastCollectedTokens` | type: `uint256 public` | vis: `public` | flags: `-` | `MockAgreementOwner` @ `packages/horizon/test/unit/payments/recurring-collector/MockAgreementOwner.t.sol`
- `graphToken` | type: `MockGraphToken public immutable` | vis: `public` | flags: `immutable` | `MockIssuanceAllocator` @ `packages/issuance/test/unit/agreement-manager/mocks/MockIssuanceAllocator.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `MockPaymentsEscrow` @ `packages/issuance/test/unit/agreement-manager/mocks/MockPaymentsEscrow.sol`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `MockRewardsManager` @ `packages/subgraph-service/test/unit/mocks/MockRewardsManager.sol`
- `subgraphAllocatedTokens` | type: `mapping(bytes32 => uint256) private` | vis: `private` | flags: `-` | `MockSubgraphService` @ `packages/contracts/contracts/tests/MockSubgraphService.sol`
- `_partialPaused` | type: `bool internal` | vis: `internal` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `lastPartialPauseTime` | type: `uint256 public` | vis: `public` | flags: `-` | `Pausable` @ `packages/contracts/contracts/governance/Pausable.sol`
- `DEFAULT_MAX_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint256).max`
- `DEFAULT_MIN_PROVISION_TOKENS` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `ProvisionManager` @ `packages/horizon/contracts/data-service/utilities/ProvisionManager.sol` = `type(uint256).min`
- `_maximumProvisionTokens` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `_minimumProvisionTokens` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ProvisionManagerV1Storage` @ `packages/horizon/contracts/data-service/utilities/ProvisionManagerStorage.sol`
- `token` | type: `GraphTokenMock internal` | vis: `internal` | flags: `-` | `RealStackHarness` @ `packages/testing/test/harness/RealStackHarness.t.sol`
- `GRAPH_TOKEN` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `RecurringAgreementHelper` @ `packages/issuance/contracts/agreement/RecurringAgreementHelper.sol`
- `agreementHelper` | type: `RecurringAgreementHelper internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `RecurringAgreementManagerSharedTest` @ `packages/issuance/test/unit/agreement-manager/shared.t.sol`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `RecurringCollectorSharedTest` @ `packages/horizon/test/unit/payments/recurring-collector/shared.t.sol`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `RecurringCollectorUpgradeScenarioTest` @ `packages/horizon/test/unit/payments/recurring-collector/upgradeScenario.t.sol`
- `NO_ALLOCATED_TOKENS` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `RewardsCondition` @ `packages/interfaces/contracts/contracts/rewards/RewardsCondition.sol` = `keccak256("NO_ALLOCATED_TOKENS")`
- `helper` | type: `RewardsEligibilityHelper internal` | vis: `internal` | flags: `-` | `RewardsEligibilityHelperTest` @ `packages/issuance/test/unit/eligibility/helper.t.sol`
- `token` | type: `MockGraphToken internal` | vis: `internal` | flags: `-` | `RewardsEligibilityOracleSharedTest` @ `packages/issuance/test/unit/eligibility/shared.t.sol`
- `token` | type: `MockGRTToken public` | vis: `public` | flags: `-` | `RewardsManagerMock` @ `packages/horizon/contracts/mocks/RewardsManagerMock.sol`
- `__DEPRECATED_tokenSupplySnapshot` | type: `uint256 private` | vis: `private` | flags: `-` | `RewardsManagerV3Storage` @ `packages/contracts/contracts/rewards/RewardsManagerStorage.sol`
- `token` | type: `IERC20 public` | vis: `public` | flags: `-` | `StakingMock` @ `packages/token-distribution/contracts/tests/StakingMock.sol`
- `__DEPRECATED_assetHolders` | type: `mapping(address => bool) private` | vis: `private` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__alphaDenominator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__alphaNumerator` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `__protocolPercentage` | type: `uint32 internal` | vis: `internal` | flags: `-` | `StakingV1Storage` @ `packages/contracts/contracts/staking/StakingStorage.sol`
- `token` | type: `MockGRTToken` | vis: `default` | flags: `-` | `SubgraphBaseTest` @ `packages/subgraph-service/test/unit/SubgraphBaseTest.t.sol`
- `tokenDescriptor` | type: `ISubgraphNFTDescriptor public` | vis: `public` | flags: `-` | `SubgraphNFT` @ `packages/contracts/contracts/discovery/SubgraphNFT.sol`
- `_recurringCollectorHelper` | type: `RecurringCollectorHelper internal` | vis: `internal` | flags: `-` | `SubgraphServiceIndexingAgreementSharedTest` @ `packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol`
- `token` | type: `address public immutable` | vis: `public` | flags: `immutable` | `WalletMock` @ `packages/token-distribution/contracts/tests/WalletMock.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `AcceptIndexingAgreementMetadata` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): bytes32 subgraphDeploymentId, IIndexingAgreement.IndexingAgreementVersion version, bytes terms
- `Account` (packages/issuance/test/unit/agreement-manager/mocks/MockPaymentsEscrow.sol): uint256 balance, uint256 tokensThawing, uint256 thawEndTimestamp
- `AfterValuesWithdrawDelegated` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): DelegationPoolInternalTest pool, DelegationPoolInternalTest newPool, DelegationInternal newDelegation, ILinkedList.List thawRequestList, uint256 senderBalance, uint256 stakingBalance
- `AgreementData` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): address dataService, uint64 acceptedAt, uint32 minSecondsPerCollection, address payer, uint64 lastCollectionAt, uint32 maxSecondsPerCollection, address serviceProvider, uint64 endsAt, uint32 updateNonce, uint256 maxInitialTokens, uint256 maxOngoingTokensPerSecond, bytes32 activeTermsHash, uint64 canceledAt, uint16 conditions, AgreementState state
- `AgreementDetails` (packages/interfaces/contracts/horizon/IAgreementCollector.sol): bytes16 agreementId, address payer, address dataService, address serviceProvider, bytes32 versionHash, uint16 state
- `AgreementInfo` (packages/interfaces/contracts/issuance/agreement/IRecurringAgreements.sol): address provider, uint256 maxNextClaim
- `AgreementStaleness` (packages/interfaces/contracts/issuance/agreement/IRecurringAgreementHelper.sol): bytes16 agreementId, uint256 cachedMaxNextClaim, uint256 liveMaxNextClaim, bool stale
- `AgreementStorage` (packages/issuance/test/unit/agreement-manager/mocks/MockRecurringCollector.sol): address dataService, uint64 acceptedAt, uint32 updateNonce, address payer, uint64 lastCollectionAt, uint16 state, address serviceProvider, uint64 collectableUntil, MockTerms activeTerms, MockTerms pendingTerms
- `AgreementWrapper` (packages/interfaces/contracts/subgraph-service/internal/IIndexingAgreement.sol): State agreement, IRecurringCollector.AgreementData collectorAgreement
- `AllocateParams` (packages/subgraph-service/contracts/libraries/AllocationHandler.sol): uint256 currentEpoch, IHorizonStaking graphStaking, IRewardsManager graphRewardsManager, bytes32 _encodeAllocationProof, address _indexer, uint32 _delegationRatio, address _allocationId, bytes32 _subgraphDeploymentId, uint256 _tokens, bytes _allocationProof
- `Allocation` (packages/contracts/contracts/tests/MockSubgraphService.sol): bool isActive, address indexer, bytes32 subgraphDeploymentId, uint256 tokens, uint256 accRewardsPerAllocatedToken, uint256 accRewardsPending
- `Allocation` (packages/interfaces/contracts/contracts/staking/IStakingData.sol): address indexer, bytes32 subgraphDeploymentID, uint256 tokens, uint256 createdAtEpoch, uint256 closedAtEpoch, uint256 collectedFees, uint256 __DEPRECATED_effectiveAllocation, uint256 accRewardsPerAllocatedToken, uint256 distributedRebates
- `Allocation` (packages/interfaces/contracts/issuance/allocate/IIssuanceAllocatorTypes.sol): uint256 totalAllocationRate, uint256 allocatorMintingRate, uint256 selfMintingRate
- `AllocationTarget` (packages/interfaces/contracts/issuance/allocate/IIssuanceAllocatorTypes.sol): uint256 allocatorMintingRate, uint256 selfMintingRate, uint256 lastChangeNotifiedBlock
- `AllocationVoucher` (packages/contracts/contracts/payments/AllocationExchange.sol): address allocationID, uint256 amount, bytes signature
- `Attestation` (packages/interfaces/contracts/contracts/disputes/IDisputeManager.sol): bytes32 requestCID, bytes32 responseCID, bytes32 subgraphDeploymentID, bytes32 r, bytes32 s, uint8 v
- `AuthorizableStorage` (packages/horizon/contracts/utilities/Authorizable.sol): mapping(address signer => Authorization authorization) authorizations
- `Authorization` (packages/interfaces/contracts/horizon/IAuthorizable.sol): address authorizer, uint256 thawEndTimestamp, bool revoked
- `BeforeValuesCreateQueryDisputeConflict` (packages/subgraph-service/test/unit/disputeManager/DisputeManager.t.sol): IAttestation.State attestation1, IAttestation.State attestation2, address indexer1, address indexer2, uint256 stakeSnapshot1, uint256 stakeSnapshot2, uint256 disputeDeposit
- `BeforeValuesReprovision` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): Provision provision, Provision provisionNewVerifier, ServiceProviderInternal serviceProvider, ILinkedList.List thawRequestList
- `BeforeValuesSlash` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): Provision provision, DelegationPoolInternalTest pool, ServiceProviderInternal serviceProvider, uint256 stakingBalance, uint256 verifierBalance
- `BeforeValuesUndelegate` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): DelegationPoolInternalTest pool, DelegationInternal delegation, ILinkedList.List thawRequestList, uint256 delegatedTokens
- `BeforeValuesWithdrawDelegated` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): DelegationPoolInternalTest pool, DelegationPoolInternalTest newPool, DelegationInternal newDelegation, ILinkedList.List thawRequestList, uint256 senderBalance, uint256 stakingBalance
- `CalcValuesLockStake` (packages/horizon/test/unit/data-service/extensions/DataServiceFees.t.sol): uint256 unlockTimestamp, uint256 stakeToLock, bytes32 predictedClaimId
- `CalcValuesReleaseStake` (packages/horizon/test/unit/data-service/extensions/DataServiceFees.t.sol): uint256 claimsCount, uint256 tokensReleased, bytes32 head
- `CalcValuesSlash` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): uint256 tokensToSlash, uint256 providerTokensSlashed, uint256 delegationTokensSlashed
- `CalcValuesThawRequestData` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): uint256 tokensThawed, uint256 tokensThawing, uint256 sharesThawed, uint256 sharesThawing, ThawRequest[] thawRequestsFulfilledList, bytes32[] thawRequestsFulfilledListIds, uint256[] thawRequestsFulfilledListTokens
- `CalcValuesUndelegate` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): uint256 tokens, uint256 thawingShares, uint64 thawingUntil, bytes32 thawRequestId
- `CollectIndexingFeeDataV1` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): uint256 entities, bytes32 poi, uint256 poiBlockNumber, bytes metadata, uint256 maxSlippage
- `CollectParams` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): bytes16 agreementId, bytes32 collectionId, uint256 tokens, uint256 dataServiceCut, address receiverDestination, uint256 maxSlippage
- `CollectParams` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): address indexer, bytes16 agreementId, uint256 currentEpoch, address receiverDestination, bytes data, uint256 indexingFeesCut
- `CollectPaymentData` (packages/horizon/test/unit/escrow/GraphEscrow.t.sol): uint256 escrowBalance, uint256 paymentsBalance, uint256 receiverBalance, uint256 delegationPoolBalance, uint256 dataServiceBalance, uint256 payerEscrowBalance
- `CollectPaymentData` (packages/horizon/test/unit/payments/GraphPayments.t.sol): uint256 escrowBalance, uint256 paymentsBalance, uint256 receiverBalance, uint256 receiverDestinationBalance, uint256 delegationPoolBalance, uint256 dataServiceBalance, uint256 receiverStake
- `CollectPaymentData` (packages/subgraph-service/test/unit/subgraphService/SubgraphService.t.sol): uint256 rewardsDestinationBalance, uint256 indexerProvisionBalance, uint256 delegationPoolBalance, uint256 indexerBalance, uint256 curationBalance, uint256 lockedTokens, uint256 indexerStake
- `CollectTestParams` (packages/horizon/test/unit/payments/graph-tally-collector/collect/collect.t.sol): uint256 tokens, address allocationId, address payer, address indexer, address collector
- `CollectTokensData` (packages/horizon/test/unit/escrow/GraphEscrow.t.sol): uint256 tokensProtocol, uint256 tokensDataService, uint256 tokensDelegation, uint256 receiverExpectedPayment
- `CollectTokensData` (packages/horizon/test/unit/payments/GraphPayments.t.sol): uint256 tokensProtocol, uint256 tokensDataService, uint256 tokensDelegation, uint256 receiverExpectedPayment
- `CollectorData` (packages/issuance/contracts/agreement/RecurringAgreementManager.sol): mapping(bytes16 agreementId => AgreementInfo) agreements, mapping(address provider => CollectorProviderData) providers, EnumerableSet.AddressSet providerSet
- `CollectorProviderData` (packages/issuance/contracts/agreement/RecurringAgreementManager.sol): uint256 sumMaxNextClaim, uint256 escrowSnap, EnumerableSet.Bytes32Set agreements
- `Context` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): PayerState payer, IndexerState[] indexers, mapping(address allocationId => address indexer) allocations, ContextInternal ctxInternal
- `ContextInternal` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): IndexerSeed[] indexers, Seed seed, bool initialized
- `CurationPool` (packages/contracts/contracts/curation/CurationStorage.sol): uint256 tokens, uint32 reserveRatio, IGraphCurationToken gcs
- `Delegation` (packages/interfaces/contracts/contracts/staking/IStakingData.sol): uint256 shares, uint256 tokensLocked, uint256 tokensLockedUntil
- `Delegation` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 shares
- `DelegationInternal` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 shares, uint256 __DEPRECATED_tokensLocked, uint256 __DEPRECATED_tokensLockedUntil
- `DelegationPool` (packages/interfaces/contracts/contracts/staking/IStakingData.sol): uint32 __DEPRECATED_cooldownBlocks, uint32 indexingRewardCut, uint32 queryFeeCut, uint256 updatedAtBlock, uint256 tokens, uint256 shares, mapping(address => Delegation) delegators
- `DelegationPool` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 tokens, uint256 shares, uint256 tokensThawing, uint256 sharesThawing, uint256 thawingNonce
- `DelegationPoolInternal` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint32 __DEPRECATED_cooldownBlocks, uint32 __DEPRECATED_indexingRewardCut, uint32 __DEPRECATED_queryFeeCut, uint256 __DEPRECATED_updatedAtBlock, uint256 tokens, uint256 shares, mapping(address delegator => DelegationInternal delegation) delegators, uint256 tokensThawing, uint256 sharesThawing, uint256 thawingNonce
- `DelegationPoolInternalTest` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): uint32 __DEPRECATED_cooldownBlocks, uint32 __DEPRECATED_indexingRewardCut, uint32 __DEPRECATED_queryFeeCut, uint256 __DEPRECATED_updatedAtBlock, uint256 tokens, uint256 shares, uint256 _gap_delegators_mapping, uint256 tokensThawing, uint256 sharesThawing, uint256 thawingNonce
- `DelegationPoolReturn` (packages/interfaces/contracts/contracts/staking/IStakingExtension.sol): uint32 __DEPRECATED_cooldownBlocks, uint32 indexingRewardCut, uint32 queryFeeCut, uint256 updatedAtBlock, uint256 tokens, uint256 shares
- `DirectAllocationData` (packages/issuance/contracts/allocate/DirectAllocation.sol): IIssuanceAllocationDistribution issuanceAllocator
- `Dispute` (packages/interfaces/contracts/contracts/disputes/IDisputeManager.sol): address indexer, address fisherman, uint256 deposit, bytes32 relatedDisputeID, DisputeType disputeType, DisputeStatus status
- `Dispute` (packages/interfaces/contracts/subgraph-service/IDisputeManager.sol): address indexer, address fisherman, uint256 deposit, bytes32 relatedDisputeId, DisputeType disputeType, DisputeStatus status, uint256 createdAt, uint256 cancellableAt, uint256 stakeSnapshot
- `DistributionState` (packages/interfaces/contracts/issuance/allocate/IIssuanceAllocatorTypes.sol): uint256 lastDistributionBlock, uint256 lastSelfMintingBlock, uint256 selfMintingOffset
- `Entry` (packages/horizon/test/unit/mocks/PartialControllerMock.t.sol): string name, address addr
- `EscrowAccount` (packages/interfaces/contracts/horizon/IPaymentsEscrow.sol): uint256 balance, uint256 tokensThawing, uint256 thawEndTimestamp
- `ExpectedTokens` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/integration.t.sol): uint256 expectedTotalTokensCollected, uint256 expectedTokensLocked, uint256 expectedProtocolTokensBurnt, uint256 expectedIndexerTokensCollected
- `FulfillThawRequestsParams` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): ThawRequestType requestType, address serviceProvider, address verifier, address owner, uint256 tokensThawing, uint256 sharesThawing, uint256 nThawRequests, uint256 thawingNonce
- `FuzzyTestAccept` (packages/horizon/test/unit/payments/recurring-collector/shared.t.sol): IRecurringCollector.RecurringCollectionAgreement rca, uint256 unboundedSignerKey
- `FuzzyTestCollect` (packages/horizon/test/unit/payments/recurring-collector/shared.t.sol): FuzzyTestAccept fuzzyTestAccept, uint8 unboundedPaymentType, IRecurringCollector.CollectParams collectParams
- `FuzzyTestUpdate` (packages/horizon/test/unit/payments/recurring-collector/shared.t.sol): FuzzyTestAccept fuzzyTestAccept, IRecurringCollector.RecurringCollectionAgreementUpdate rcau
- `GlobalAudit` (packages/interfaces/contracts/issuance/agreement/IRecurringAgreementHelper.sol): uint256 tokenBalance, uint256 sumMaxNextClaimAll, uint256 totalEscrowDeficit, IRecurringEscrowManagement.EscrowBasis escrowBasis, uint8 minOnDemandBasisThreshold, uint8 minFullBasisMargin, uint256 collectorCount
- `Indexer` (packages/interfaces/contracts/contracts/staking/libs/IStakes.sol): uint256 tokensStaked, uint256 tokensAllocated, uint256 tokensLocked, uint256 tokensLockedUntil
- `Indexer` (packages/interfaces/contracts/subgraph-service/ISubgraphService.sol): string url, string geoHash
- `Indexer` (packages/token-distribution/contracts/tests/Stakes.sol): uint256 tokensStaked, uint256 tokensAllocated, uint256 tokensLocked, uint256 tokensLockedUntil
- `IndexerSeed` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): address addr, string label, uint256 unboundedProvisionTokens, uint256 unboundedAllocationPrivateKey, bytes32 subgraphDeploymentId
- `IndexerService` (packages/interfaces/contracts/contracts/discovery/IServiceRegistry.sol): string url, string geohash
- `IndexerSetup` (packages/testing/test/harness/FullStackHarness.t.sol): address addr, address allocationId, uint256 allocationKey, bytes32 subgraphDeploymentId, uint256 provisionTokens
- `IndexerState` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): address addr, address allocationId, bytes32 subgraphDeploymentId, uint256 tokens
- `IndexingAgreementTermsV1` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): uint256 tokensPerSecond, uint256 tokensPerEntityPerSecond
- `IndexingRewardsData` (packages/subgraph-service/test/unit/subgraphService/SubgraphService.t.sol): bytes32 poi, bytes poiMetadata, uint256 tokensIndexerRewards, uint256 tokensDelegationRewards
- `IssuanceAllocatorData` (packages/issuance/contracts/allocate/IssuanceAllocator.sol): uint256 issuancePerBlock, uint256 lastDistributionBlock, uint256 lastSelfMintingBlock, uint256 selfMintingOffset, mapping(address => AllocationTarget) allocationTargets, address[] targetAddresses, uint256 totalSelfMintingRate, SelfMintingEventMode selfMintingEventMode
- `Item` (packages/horizon/test/unit/libraries/ListImplementation.sol): uint256 data, bytes32 next
- `L2GasParams` (packages/contracts/contracts/arbitrum/L1ArbitrumMessenger.sol): uint256 _maxSubmissionCost, uint256 _maxGas, uint256 _gasPriceBid
- `L2ToL1Context` (packages/contracts/contracts/tests/arbitrum/OutboxMock.sol): uint128 l2Block, uint128 l1Block, uint128 timestamp, uint128 batchNum, bytes32 outputId, address sender
- `LegacyAllocation` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): address indexer, bytes32 subgraphDeploymentID, uint256 tokens, uint256 createdAtEpoch, uint256 closedAtEpoch, uint256 collectedFees, uint256 __DEPRECATED_effectiveAllocation, uint256 accRewardsPerAllocatedToken, uint256 distributedRebates
- `LegacySubgraphKey` (packages/interfaces/contracts/contracts/discovery/IGNS.sol): address account, uint256 accountSeqID
- `List` (packages/interfaces/contracts/horizon/internal/ILinkedList.sol): bytes32 head, bytes32 tail, uint256 nonce, uint256 count
- `MockTerms` (packages/issuance/test/unit/agreement-manager/mocks/MockRecurringCollector.sol): uint64 deadline, uint64 endsAt, uint32 minSecondsPerCollection, uint32 maxSecondsPerCollection, uint16 conditions, uint256 maxInitialTokens, uint256 maxOngoingTokensPerSecond, bytes32 hash
- `OutboundCalldata` (packages/contracts/contracts/l2/gateway/L2GraphTokenGateway.sol): address from, bytes extraData
- `OutboundCalldata` (packages/interfaces/contracts/contracts/l2/gateway/IL2GraphTokenGateway.sol): address from, bytes extraData
- `ParamsCalcThawRequestData` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): IHorizonStakingTypes.ThawRequestType thawRequestType, address serviceProvider, address verifier, address owner, uint256 iterations, bool delegation
- `ParamsWithdrawDelegated` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): IHorizonStakingTypes.ThawRequestType thawRequestType, address serviceProvider, address verifier, address newServiceProvider, address newVerifier, uint256 minSharesForNewProvider, uint256 nThawRequests, bool legacy
- `PayerSeed` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): uint256 unboundedSignerPrivateKey
- `PayerState` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): address signer, uint256 signerPrivateKey
- `PresentParams` (packages/subgraph-service/contracts/libraries/AllocationHandler.sol): uint256 maxPOIStaleness, IEpochManager graphEpochManager, IHorizonStaking graphStaking, IRewardsManager graphRewardsManager, IGraphToken graphToken, address dataService, address _allocationId, bytes32 _poi, bytes _poiMetadata, uint32 _delegationRatio, address _paymentsDestination
- `ProviderAudit` (packages/interfaces/contracts/issuance/agreement/IRecurringAgreementHelper.sol): IAgreementCollector collector, address provider, uint256 agreementCount, uint256 sumMaxNextClaim, uint256 escrowSnap, IPaymentsEscrow.EscrowAccount escrow
- `Provision` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 tokens, uint256 tokensThawing, uint256 sharesThawing, uint32 maxVerifierCut, uint64 thawingPeriod, uint64 createdAt, uint32 maxVerifierCutPending, uint64 thawingPeriodPending, uint256 lastParametersStagedAt, uint256 thawingNonce
- `QueryFeeData` (packages/subgraph-service/test/unit/subgraphService/SubgraphService.t.sol): uint256 curationCut, uint256 protocolPaymentCut
- `RebatesParameters` (packages/interfaces/contracts/contracts/staking/IStakingData.sol): uint32 alphaNumerator, uint32 alphaDenominator, uint32 lambdaNumerator, uint32 lambdaDenominator
- `Receipt` (packages/interfaces/contracts/contracts/disputes/IDisputeManager.sol): bytes32 requestCID, bytes32 responseCID, bytes32 subgraphDeploymentID
- `Receipt` (packages/interfaces/contracts/subgraph-service/internal/IAttestation.sol): bytes32 requestCID, bytes32 responseCID, bytes32 subgraphDeploymentId
- `ReceiptAggregateVoucher` (packages/interfaces/contracts/horizon/IGraphTallyCollector.sol): bytes32 collectionId, address payer, address serviceProvider, address dataService, uint64 timestampNs, uint128 valueAggregate, bytes metadata
- `ReceiveDelegationData` (packages/interfaces/contracts/contracts/l2/staking/IL2StakingTypes.sol): address indexer, address delegator
- `ReceiveIndexerStakeData` (packages/interfaces/contracts/contracts/l2/staking/IL2StakingTypes.sol): address indexer
- `RecurringAgreementManagerStorage` (packages/issuance/contracts/agreement/RecurringAgreementManager.sol): mapping(address collector => CollectorData) collectors, EnumerableSet.AddressSet collectorSet, uint256 sumMaxNextClaimAll, uint256 totalEscrowDeficit, IIssuanceAllocationDistribution issuanceAllocator, uint32 ensuredIncomingDistributedToBlock, EscrowBasis escrowBasis, uint8 minOnDemandBasisThreshold, uint8 minFullBasisMargin, uint8 minThawFraction, uint8 minResidualEscrowFactor, IProviderEligibility providerEligibilityOracle
- `RecurringCollectionAgreement` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): uint64 deadline, uint64 endsAt, address payer, address dataService, address serviceProvider, uint256 maxInitialTokens, uint256 maxOngoingTokensPerSecond, uint32 minSecondsPerCollection, uint32 maxSecondsPerCollection, uint16 conditions, uint256 nonce, bytes metadata
- `RecurringCollectionAgreementUpdate` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): bytes16 agreementId, uint64 deadline, uint64 endsAt, uint256 maxInitialTokens, uint256 maxOngoingTokensPerSecond, uint32 minSecondsPerCollection, uint32 maxSecondsPerCollection, uint16 conditions, uint32 nonce, bytes metadata
- `RecurringCollectorStorage` (packages/horizon/contracts/payments/collectors/RecurringCollector.sol): mapping(address pauseGuardian => bool allowed) pauseGuardians, mapping(bytes16 agreementId => AgreementData data) agreements, mapping(bytes16 agreementId => StoredOffer offer) rcaOffers, mapping(bytes16 agreementId => StoredOffer offer) rcauOffers, mapping(address signer => mapping(bytes32 hash => bytes16 agreementId)) cancelledOffers
- `RewardsEligibilityOracleData` (packages/issuance/contracts/eligibility/RewardsEligibilityOracle.sol): mapping(address => uint256) indexerEligibilityTimestamps, uint256 eligibilityPeriod, uint256 oracleUpdateTimeout, uint256 lastOracleUpdateTime, EnumerableSet.AddressSet trackedIndexers, uint256 indexerRetentionPeriod, bool eligibilityValidationEnabled
- `Seed` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/shared.t.sol): IndexerSeed indexer0, IndexerSeed indexer1, IRecurringCollector.RecurringCollectionAgreement rca, IRecurringCollector.RecurringCollectionAgreementUpdate rcau, IndexingAgreement.IndexingAgreementTermsV1 termsV1, PayerSeed payer
- `ServiceProvider` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 tokensStaked, uint256 tokensProvisioned
- `ServiceProviderInternal` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 tokensStaked, uint256 __DEPRECATED_tokensAllocated, uint256 __DEPRECATED_tokensLocked, uint256 __DEPRECATED_tokensLockedUntil, uint256 tokensProvisioned
- `SignedRAV` (packages/interfaces/contracts/horizon/IGraphTallyCollector.sol): ReceiptAggregateVoucher rav, bytes signature
- `StakeClaim` (packages/horizon/contracts/data-service/libraries/StakeClaims.sol): uint256 tokens, uint256 createdAt, uint256 releasableAt, bytes32 nextClaim
- `State` (packages/interfaces/contracts/subgraph-service/internal/IAllocation.sol): address indexer, bytes32 subgraphDeploymentId, uint256 tokens, uint256 createdAt, uint256 closedAt, uint256 lastPOIPresentedAt, uint256 accRewardsPerAllocatedToken, uint256 accRewardsPending, uint256 createdAtEpoch
- `State` (packages/interfaces/contracts/subgraph-service/internal/IAttestation.sol): bytes32 requestCID, bytes32 responseCID, bytes32 subgraphDeploymentId, bytes32 r, bytes32 s, uint8 v
- `State` (packages/interfaces/contracts/subgraph-service/internal/IIndexingAgreement.sol): address allocationId, IndexingAgreementVersion version
- `State` (packages/interfaces/contracts/subgraph-service/internal/ILegacyAllocation.sol): address indexer, bytes32 subgraphDeploymentId
- `StorageManager` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): mapping(bytes16 agreementId => IIndexingAgreement.State) agreements, mapping(bytes16 agreementId => IndexingAgreementTermsV1 data) termsV1, mapping(address allocationId => bytes16 agreementId) allocationToActiveAgreementId
- `StoredOffer` (packages/horizon/contracts/payments/collectors/RecurringCollector.sol): bytes32 offerHash, bytes data
- `Subgraph` (packages/interfaces/contracts/contracts/rewards/IRewardsManager.sol): uint256 accRewardsForSubgraph, uint256 accRewardsForSubgraphSnapshot, uint256 accRewardsPerSignalSnapshot, uint256 accRewardsPerAllocatedToken
- `SubgraphData` (packages/interfaces/contracts/contracts/discovery/IGNS.sol): uint256 vSignal, uint256 nSignal, mapping(address => uint256) curatorNSignal, bytes32 subgraphDeploymentID, uint32 __DEPRECATED_reserveRatio, bool disabled, uint256 withdrawableGRT
- `SubgraphL2TransferData` (packages/interfaces/contracts/contracts/l2/discovery/IL2GNS.sol): uint256 tokens, mapping(address => bool) curatorBalanceClaimed, bool l2Done, uint256 subgraphReceivedOnL2BlockNumber
- `TargetIssuancePerBlock` (packages/interfaces/contracts/issuance/allocate/IIssuanceAllocatorTypes.sol): uint256 allocatorIssuanceRate, uint256 allocatorIssuanceBlockAppliedTo, uint256 selfIssuanceRate, uint256 selfIssuanceBlockAppliedTo
- `TestState` (packages/subgraph-service/test/unit/subgraphService/indexing-agreement/integration.t.sol): uint256 escrowBalance, uint256 indexerBalance, uint256 indexerTokensLocked
- `ThawRequest` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 shares, uint64 thawingUntil, bytes32 nextRequest, uint256 thawingNonce
- `ThawingData` (packages/horizon/test/unit/shared/horizon-staking/HorizonStakingShared.t.sol): uint256 tokensThawed, uint256 tokensThawing, uint256 sharesThawing, uint256 thawRequestsFulfilled
- `TransferredWalletData` (packages/token-distribution/contracts/L2GraphTokenLockManager.sol): address l1Address, address owner, address beneficiary, uint256 managedAmount, uint256 startTime, uint256 endTime
- `TraverseThawRequestsResults` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): uint256 requestsFulfilled, uint256 tokensThawed, uint256 tokensThawing, uint256 sharesThawing
- `UpdateIndexingAgreementMetadata` (packages/subgraph-service/contracts/libraries/IndexingAgreement.sol): IIndexingAgreement.IndexingAgreementVersion version, bytes terms
- `Users` (packages/horizon/test/unit/utils/Users.sol): address governor, address deployer, address indexer, address operator, address gateway, address verifier, address delegator
- `Users` (packages/subgraph-service/test/unit/utils/Users.sol): address governor, address deployer, address indexer, address operator, address gateway, address verifier, address delegator, address arbitrator, address fisherman, address rewardsDestination, address pauseGuardian

### Enum State Values
- `AgreementNotCollectableReason` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): None, InvalidAgreementState, ZeroCollectionSeconds, InvalidTemporalWindow
- `AgreementRejectionReason` (packages/interfaces/contracts/issuance/agreement/IRecurringAgreementManagement.sol): UnauthorizedCollector, UnknownAgreement, PayerMismatch, UnauthorizedDataService
- `AgreementState` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): NotAccepted, Accepted, CanceledByServiceProvider, CanceledByPayer
- `AllocationState` (packages/interfaces/contracts/contracts/staking/IStakingBase.sol): Null, Active, Closed
- `CancelAgreementBy` (packages/interfaces/contracts/horizon/IRecurringCollector.sol): ServiceProvider, Payer, ThirdParty
- `DisputeStatus` (packages/interfaces/contracts/contracts/disputes/IDisputeManager.sol): Null, Accepted, Rejected, Drawn, Pending
- `DisputeStatus` (packages/interfaces/contracts/subgraph-service/IDisputeManager.sol): Null, Accepted, Rejected, Drawn, Pending, Cancelled
- `DisputeType` (packages/interfaces/contracts/contracts/disputes/IDisputeManager.sol): Null, IndexingDispute, QueryDispute
- `DisputeType` (packages/interfaces/contracts/subgraph-service/IDisputeManager.sol): Null, IndexingDispute, QueryDispute, __DEPRECATED_LegacyDispute, IndexingFeeDispute
- `EscrowBasis` (packages/interfaces/contracts/issuance/agreement/IRecurringEscrowManagement.sol): JustInTime, OnDemand, Full
- `IndexingAgreementVersion` (packages/interfaces/contracts/subgraph-service/internal/IIndexingAgreement.sol): V1
- `L1MessageCodes` (packages/interfaces/contracts/contracts/l2/discovery/IL2GNS.sol): RECEIVE_SUBGRAPH_CODE, RECEIVE_CURATOR_BALANCE_CODE
- `L1MessageCodes` (packages/interfaces/contracts/contracts/l2/staking/IL2StakingTypes.sol): RECEIVE_INDEXER_STAKE_CODE, RECEIVE_DELEGATION_CODE
- `LegacyAllocationState` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): Null, Active, Closed
- `PayerCallbackStage` (packages/interfaces/contracts/horizon/IAgreementCollector.sol): EligibilityCheck, BeforeCollection, AfterCollection
- `PaymentTypes` (packages/interfaces/contracts/horizon/IGraphPayments.sol): QueryFee, IndexingFee, IndexingRewards
- `ReentrantAction` (packages/issuance/contracts/test/allocate/MockReentrantTarget.sol): None, DistributeIssuance, SetTargetAllocation1Param, SetTargetAllocation2Param, SetTargetAllocation3Param, SetIssuancePerBlock, SetIssuancePerBlock2Param, NotifyTarget, SetDefaultTarget1Param, SetDefaultTarget2Param, DistributePendingIssuance0Param, DistributePendingIssuance1Param
- `Revocability` (packages/interfaces/contracts/token-distribution/IGraphTokenLockWallet.sol): NotSet, Enabled, Disabled
- `Revocability` (packages/token-distribution/contracts/IGraphTokenLock.sol): NotSet, Enabled, Disabled
- `SelfMintingEventMode` (packages/interfaces/contracts/issuance/allocate/IIssuanceAllocatorTypes.sol): None, Aggregate, PerTarget
- `ThawRequestType` (packages/interfaces/contracts/horizon/internal/IHorizonStakingTypes.sol): Provision, Delegation

### Invariant Values (Variable-Tied)
- Key accounting vars (`defaultReserveRatio`, `pools`, `fixedReserveRatio`, `totalMintedFromL2`, `STAKING`, `fixedReserveRatio`, `STAKING`, `__DEPRECATED_tokenSupplySnapshot`) must only change through authorized accounting paths
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
