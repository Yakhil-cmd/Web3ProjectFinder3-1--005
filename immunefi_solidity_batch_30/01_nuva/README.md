# Nuva EVM Contracts

This repository contains a set of smart contracts for the Nuva protocol, including token management, depositing, and withdrawal functionality with AML (Anti-Money Laundering) verification.

## Contracts Overview

### Core Contracts
- **CustomToken**: An ERC20 token with additional features like minting, burning, and permit functionality.
- **Depositor**: Handles token deposits with AML verification.
- **Withdrawal**: Manages token withdrawals with AML verification.
- **DepositorFactory/WithdrawalFactory**: Factory contracts for deploying Depositor and Withdrawal instances.
- **CrossChainVault**: Cross-chain token bridge using Wormhole infrastructure.
- **CrossChainManager**: AML-compliant cross-chain token management system.
- **Remotevault**: AML-compliant remote vault token management system (Vault V2).

### Cross-Chain Contracts
- **[CrossChainVault Documentation](docs/CrossChainVault.md)**: Comprehensive guide for the cross-chain token vault contract
- **[CrossChainManager Documentation](docs/CrossChainManager.md)**: Detailed documentation for the AML-compliant cross-chain manager
- **[RemoteVault Documentation](docs/RemoteVault.md)**: Detailed documentation for the AML-compliant remote vault

## Prerequisites

- Node.js (v16 or later)
- npm or yarn
- Hardhat

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd nuva-evm-contracts
   ```

2. Install dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```

## Testing

Run the test suite:

```bash
# Run all tests
npm test

# Run tests with gas reporting
REPORT_GAS=true npm test

# Run specific test file
npx hardhat test test/Depositor.js

# Run tests with detailed output
npx hardhat test --verbose
```

## Development

### Available Scripts

- `npm run lint`: Check code style
- `npm run lint:fix`: Automatically fix code style issues
- `npm run lint:solfix`: Format Solidity code style
- `npm run lint:solcheck`: Check Solidity code style
- `npx hardhat compile`: Compile contracts
- `npx hardhat clean`: Clean cache and artifacts
- `npx hardhat node`: Start local Ethereum node
- `npx hardhat coverage`: Generate test coverage report
- `npx hardhat verify --network sepolia <contract_address>`: Verify contract on Etherscan

## Security

This project includes security features such as:
- Access control with OpenZeppelin's AccessControl
- Reentrancy protection
- Input validation
- AML signature verification

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:46Z`  
Project: `01_nuva`  
Solidity files: `28`

### Structure
Top Solidity directories:
- `contracts`: 28 `.sol` files

Pragmas:
- `>=0.8.0 <0.9.0`
- `^0.8.19`
- `^0.8.20`

Contracts/Libraries/Interfaces detected: `31`

### Life Total / Balance Values
Detected accounting/state total variables:
- `addressToIndex` | type: `mapping(address => mapping(uint16 => mapping(uint32 => uint256))) public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `crossChainVault` | type: `CrossChainVault public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `assetVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `nuvaAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `nuvaVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `stakingAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `stakingVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `shareToken` | type: `address public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `assetVault` | type: `IAsyncRedemptionVault public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `nuvaVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `stakingVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `addressToIndex` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`

All detected state variables (full list):
- `addressSize` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `20`
- `bytes12Bits` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `96`
- `freeMemoryPtr` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `0x40`
- `maskModulo32` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `0x1f`
- `memoryWord` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `32`
- `uint128Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `16`
- `uint16Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `2`
- `uint256Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `32`
- `uint32Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `4`
- `uint64Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `8`
- `uint8Size` | type: `uint256 internal constant` | vis: `internal` | flags: `constant` | `BytesLib` @ `contracts/modules/utils/BytesLib.sol` = `1`
- `BURN_ADMIN_ROLE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `CrossChainManager` @ `contracts/CrossChainManager.sol` = `keccak256("BURN_ADMIN_ROLE")`
- `BURN_ROLE` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `CrossChainManager` @ `contracts/CrossChainManager.sol` = `keccak256("BURN_ROLE")`
- `addressToIndex` | type: `mapping(address => mapping(uint16 => mapping(uint32 => uint256))) public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `crossChainVault` | type: `CrossChainVault public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `isDestination` | type: `mapping(address => mapping(uint16 => mapping(uint32 => bool))) public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `token` | type: `CustomToken public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `processingFee` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainManagerV2` @ `contracts/mocks/CrossChainManagerV2.sol`
- `WHITELISTED_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CrossChainVault` @ `contracts/CrossChainVault.sol` = `keccak256("WHITELISTED_ROLE")`
- `executor` | type: `ICCTPv1WithExecutor public` | vis: `public` | flags: `-` | `CrossChainVault` @ `contracts/CrossChainVault.sol`
- `maxTransactionSize` | type: `uint256 public` | vis: `public` | flags: `-` | `CrossChainVaultV2` @ `contracts/mocks/CrossChainVaultV2.sol`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `CustomToken` @ `contracts/CustomToken.sol` = `keccak256("MINTER_ROLE")`
- `_customDecimals` | type: `uint8 private` | vis: `private` | flags: `-` | `CustomToken` @ `contracts/CustomToken.sol`
- `DEPOSIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol` = `keccak256( "Deposit(address sender,uint256 amount,address receiver,uint256 deadline)" )`
- `KEEPER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol` = `keccak256("KEEPER_ROLE")`
- `MAX_DEADLINE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol` = `24 hours`
- `REDEEM_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol` = `keccak256( "Redeem(address sender,uint256 amountNuvaShares,uint256 deadline)" )`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `assetVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `nuvaAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `nuvaVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `redemptionProxyImplementation` | type: `address public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `redemptionProxyToTimestamp` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `redemptionProxyToUser` | type: `mapping(address => address) public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `stakingAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `stakingVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `MAX_ROUTER_FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DedicatedVaultRouterV2` @ `contracts/prime/mocks/DedicatedVaultRouterV2.sol` = `1000`
- `routerFee` | type: `uint256 public` | vis: `public` | flags: `-` | `DedicatedVaultRouterV2` @ `contracts/prime/mocks/DedicatedVaultRouterV2.sol`
- `DESTINATION_MANAGER_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Depositor` @ `contracts/Depositor.sol` = `keccak256("DESTINATION_MANAGER_ADMIN_ROLE")`
- `DESTINATION_MANAGER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Depositor` @ `contracts/Depositor.sol` = `keccak256("DESTINATION_MANAGER_ROLE")`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `depositToken` | type: `CustomToken public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `destinationAddresses` | type: `address[] public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `shareToken` | type: `address public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `depositors` | type: `mapping(address => mapping(address => address)) public` | vis: `public` | flags: `-` | `DepositorFactory` @ `contracts/DepositorFactory.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `DepositorFactory` @ `contracts/DepositorFactory.sol`
- `CANCEL_AUTHORIZATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol` = `0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429`
- `RECEIVE_WITH_AUTHORIZATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol` = `0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8`
- `TRANSFER_WITH_AUTHORIZATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol` = `0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267`
- `_AUTHORIZATION_USED_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol` = `"EIP3009: authorization is used"`
- `_INVALID_SIGNATURE_ERROR` | type: `string internal constant` | vis: `internal` | flags: `constant` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol` = `"EIP3009: invalid signature"`
- `_authorizationStates` | type: `mapping(address => mapping(bytes32 => bool)) internal` | vis: `internal` | flags: `-` | `EIP3009` @ `contracts/modules/eip-3009/EIP3009.sol`
- `EIP712_DOMAIN_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `EIP712` @ `contracts/modules/eip-3009/EIP712.sol` = `0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f`
- `DEPOSIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `NuvaVault` @ `contracts/prime/NuvaVault.sol` = `keccak256( "Deposit(address sender,uint256 assets,address receiver,uint256 deadline)" )`
- `MAX_DEADLINE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `NuvaVault` @ `contracts/prime/NuvaVault.sol` = `24 hours`
- `REDEEM_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `NuvaVault` @ `contracts/prime/NuvaVault.sol` = `keccak256( "Redeem(address sender,uint256 shares,address receiver,address owner,uint256 deadline)" )`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `NuvaVault` @ `contracts/prime/NuvaVault.sol`
- `authorizedCallers` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `NuvaVault` @ `contracts/prime/NuvaVault.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `NuvaVault` @ `contracts/prime/NuvaVault.sol`
- `withdrawalLimit` | type: `uint256 public` | vis: `public` | flags: `-` | `NuvaVaultV2` @ `contracts/prime/mocks/NuvaVaultV2.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `assetVault` | type: `IAsyncRedemptionVault public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `nuvaVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `router` | type: `address public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `stakingVault` | type: `IERC4626 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `user` | type: `address public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `DEPOSIT_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RemoteVault` @ `contracts/RemoteVault.sol` = `keccak256("Deposit")`
- `DEPOSIT_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RemoteVault` @ `contracts/RemoteVault.sol` = `keccak256( "Deposit(address sender,uint256 amount,address destinationAddress,uint256 deadline)" )`
- `DOMAIN_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RemoteVault` @ `contracts/RemoteVault.sol` = `keccak256( "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)" )`
- `WITHDRAW_HASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RemoteVault` @ `contracts/RemoteVault.sol` = `keccak256("Withdraw")`
- `WITHDRAW_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `RemoteVault` @ `contracts/RemoteVault.sol` = `keccak256("Withdraw(address sender,uint256 amount,uint256 deadline)")`
- `addressToIndex` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `destinationAddresses` | type: `address[] public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `isDestination` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `token` | type: `CustomToken public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `BURN_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Withdrawal` @ `contracts/Withdrawal.sol` = `keccak256("BURN_ADMIN_ROLE")`
- `BURN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Withdrawal` @ `contracts/Withdrawal.sol` = `keccak256("BURN_ROLE")`
- `amlSigner` | type: `address public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`
- `paymentToken` | type: `address public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`
- `usedSignatures` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`
- `implementation` | type: `address public` | vis: `public` | flags: `-` | `WithdrawalFactory` @ `contracts/WithdrawalFactory.sol`
- `withdrawals` | type: `mapping(address => mapping(address => address)) public` | vis: `public` | flags: `-` | `WithdrawalFactory` @ `contracts/WithdrawalFactory.sol`

### Tokens Added / Token State Values
Detected token-related variables:
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `token` | type: `CustomToken public` | vis: `public` | flags: `-` | `CrossChainManager` @ `contracts/CrossChainManager.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `nuvaAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `stakingAsset` | type: `IERC20 public` | vis: `public` | flags: `-` | `DedicatedVaultRouter` @ `contracts/prime/DedicatedVaultRouter.sol`
- `depositToken` | type: `CustomToken public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `shareToken` | type: `address public` | vis: `public` | flags: `-` | `Depositor` @ `contracts/Depositor.sol`
- `asset` | type: `IERC20 public` | vis: `public` | flags: `-` | `RedemptionProxy` @ `contracts/prime/RedemptionProxy.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `token` | type: `CustomToken public` | vis: `public` | flags: `-` | `RemoteVault` @ `contracts/RemoteVault.sol`
- `paymentToken` | type: `address public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`
- `shareToken` | type: `ICustomToken public` | vis: `public` | flags: `-` | `Withdrawal` @ `contracts/Withdrawal.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `DestinationConfig` (contracts/CrossChainManager.sol): address destinationAddress, uint16 targetChain, uint32 targetDomain
- `ExecutorArgs` (contracts/modules/wormhole/ICCTPv1WithExecutor.sol): address refundAddress, bytes signedQuote, bytes instructions
- `FeeArgs` (contracts/modules/wormhole/ICCTPv1WithExecutor.sol): uint256 transferTokenFee, uint256 nativeTokenFee, address payee

### Enum State Values
- None detected

### Invariant Values (Variable-Tied)
- Key accounting vars (`crossChainVault`, `shareToken`, `addressToIndex`, `shareToken`, `shareToken`, `addressToIndex`, `shareToken`, `assetVault`) must only change through authorized accounting paths
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
