# 22_stellaswap

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:58Z`  
Project: `22_stellaswap`  
Solidity files: `34`

### Structure
Top Solidity directories:
- `amm`: 18 `.sol` files
- `gasless`: 6 `.sol` files
- `forwarder`: 2 `.sol` files
- `helpers`: 2 `.sol` files
- `utils`: 2 `.sol` files
- `farms`: 1 `.sol` files
- `token`: 1 `.sol` files
- `vault`: 1 `.sol` files
- `weth`: 1 `.sol` files

Pragmas:
- `=0.6.12`
- `=0.6.6`
- `>=0.5.0`
- `>=0.6.0`
- `>=0.6.2`
- `^0.8.0`
- `^0.8.2`
- `^0.8.7`

Contracts/Libraries/Interfaces detected: `44`

### Life Total / Balance Values
Detected accounting/state total variables:
- `_initialSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `Stella` @ `token/Stella.sol` = `100_000e18`
- `maxSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Stella` @ `token/Stella.sol` = `500_000_000e18`
- `poolInfo` | type: `PoolInfo[] public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `totalAllocPoint` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `0`
- `totalLockedUpRewards` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `totalStellaInPools` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `0`
- `balanceOf` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `MINIMUM_LIQUIDITY` | type: `uint public constant` | vis: `public` | flags: `constant` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `10**3`
- `reserve0` | type: `uint112 private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `reserve1` | type: `uint112 private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `poolInfo` | type: `PoolInfo[] public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `timeStakeInfo` | type: `mapping(uint256 => mapping(address => TimedStake))` | vis: `default` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `totalAllocPoint` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol` = `0`
- `totalLockedUpRewards` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `totalStellaInPools` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol` = `0`
- `balanceOf` | type: `mapping (address => uint) public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol`

All detected state variables (full list):
- `domainSeparator` | type: `bytes32 internal` | vis: `internal` | flags: `-` | `EIP712Base` @ `gasless/EIP712Base.sol`
- `META_TRANSACTION_TYPEHASH` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `EIP712MetaTransaction` @ `gasless/EIP712MetaTransaction.sol` = `keccak256( bytes( "MetaTransaction(uint256 nonce,address from,bytes functionSignature)" ) )`
- `nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `EIP712MetaTransaction` @ `gasless/EIP712MetaTransaction.sol`
- `EIP712_DOMAIN_TYPE` | type: `string public constant` | vis: `public` | flags: `constant` | `Forwarder` @ `forwarder/Forwarder.sol` = `"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"`
- `GENERIC_PARAMS` | type: `string public constant` | vis: `public` | flags: `constant` | `Forwarder` @ `forwarder/Forwarder.sol` = `"address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,uint256 validUntil"`
- `domains` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Forwarder` @ `forwarder/Forwarder.sol`
- `nonces` | type: `mapping(address => uint256) private` | vis: `private` | flags: `-` | `Forwarder` @ `forwarder/Forwarder.sol`
- `typeHashes` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Forwarder` @ `forwarder/Forwarder.sol`
- `WGLMR` | type: `address public immutable` | vis: `public` | flags: `immutable` | `GasSwap` @ `gasless/GasSwap.sol` = `0x98878B06940aE243284CA214f92Bb71a2b032B8A`
- `feeAddress` | type: `address public` | vis: `public` | flags: `-` | `GasSwap` @ `gasless/GasSwap.sol`
- `feePercent` | type: `uint256 public` | vis: `public` | flags: `-` | `GasSwap` @ `gasless/GasSwap.sol` = `100`
- `tokenWhitelist` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `GasSwap` @ `gasless/GasSwap.sol`
- `DELEGATION_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Stella` @ `token/Stella.sol` = `keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)")`
- `DOMAIN_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Stella` @ `token/Stella.sol` = `keccak256( "EIP712Domain(string name,uint256 chainId,address verifyingContract)" )`
- `MINTER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `Stella` @ `token/Stella.sol` = `keccak256("MINTER_ROLE")`
- `_initialSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `Stella` @ `token/Stella.sol` = `100_000e18`
- `maxSupply` | type: `uint256 public` | vis: `public` | flags: `-` | `Stella` @ `token/Stella.sol` = `500_000_000e18`
- `nonces` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `Stella` @ `token/Stella.sol`
- `numCheckpoints` | type: `mapping(address => uint32) public` | vis: `public` | flags: `-` | `Stella` @ `token/Stella.sol`
- `MAXIMUM_DEPOSIT_FEE_RATE` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `1000`
- `MAXIMUM_HARVEST_INTERVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `90 days`
- `_operator` | type: `address private` | vis: `private` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `_trustedForwarder` | type: `address constant` | vis: `default` | flags: `constant` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `0x24eE59Fe03Cbc71e71bb05F6E66ffd49D6800363`
- `investorAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `investorPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `metaTxnsEnabled` | type: `bool public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `false`
- `poolInfo` | type: `PoolInfo[] public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `startBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `stellaPerBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `teamAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `teamPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `totalAllocPoint` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `0`
- `totalLockedUpRewards` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `totalStellaInPools` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol` = `0`
- `treasuryAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `treasuryPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `userInfo` | type: `mapping(uint256 => mapping(address => UserInfo)) public` | vis: `public` | flags: `-` | `StellaDistributor` @ `farms/StellaDistributor.sol`
- `DOMAIN_SEPARATOR` | type: `bytes32 public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `PERMIT_TYPEHASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol` = `0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9`
- `allowance` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `balanceOf` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `decimals` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol` = `18`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol` = `'Stella LP'`
- `nonces` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `symbol` | type: `string public constant` | vis: `public` | flags: `constant` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol` = `'STELLA LP'`
- `totalSupply` | type: `uint public` | vis: `public` | flags: `-` | `StellaSwapV2ERC20` @ `amm/StellaSwapV2ERC20.sol`
- `INIT_CODE_PAIR_HASH` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol` = `keccak256(abi.encodePacked(type(StellaSwapV2Pair).creationCode))`
- `allPairs` | type: `address[] public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `feeTo` | type: `address public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `feeToSetter` | type: `address public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `getPair` | type: `mapping(address => mapping(address => address)) public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `migrator` | type: `address public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `MINIMUM_LIQUIDITY` | type: `uint public constant` | vis: `public` | flags: `constant` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `10**3`
- `SELECTOR` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `bytes4(keccak256(bytes('transfer(address,uint256)')))`
- `blockTimestampLast` | type: `uint32 private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `devFee` | type: `uint32 public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `5`
- `factory` | type: `address public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `kLast` | type: `uint public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `price0CumulativeLast` | type: `uint public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `price1CumulativeLast` | type: `uint public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `reserve0` | type: `uint112 private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `reserve1` | type: `uint112 private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `swapFee` | type: `uint32 public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `25`
- `token0` | type: `address public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `token1` | type: `address public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `unlocked` | type: `uint private` | vis: `private` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol` = `1`
- `WETH` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router` @ `amm/StellaSwapV2Router.sol`
- `factory` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router` @ `amm/StellaSwapV2Router.sol`
- `WETH` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router02` @ `amm/StellaSwapV2Router02.sol`
- `factory` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router02` @ `amm/StellaSwapV2Router02.sol`
- `MAXIMUM_DEPOSIT_FEE_RATE` | type: `uint16 public constant` | vis: `public` | flags: `constant` | `StellaVault` @ `vault/StellaVault.sol` = `1000`
- `MAXIMUM_HARVEST_INTERVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StellaVault` @ `vault/StellaVault.sol` = `90 days`
- `_operator` | type: `address private` | vis: `private` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `_trustedForwarder` | type: `address constant` | vis: `default` | flags: `constant` | `StellaVault` @ `vault/StellaVault.sol` = `0x24eE59Fe03Cbc71e71bb05F6E66ffd49D6800363`
- `investorAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `investorPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `metaTxnsEnabled` | type: `bool public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol` = `false`
- `poolInfo` | type: `PoolInfo[] public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `startBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `stellaPerBlock` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `teamAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `teamPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `timeStakeInfo` | type: `mapping(uint256 => mapping(address => TimedStake))` | vis: `default` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `totalAllocPoint` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol` = `0`
- `totalLockedUpRewards` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `totalStellaInPools` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol` = `0`
- `treasuryAddress` | type: `address public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `treasuryPercent` | type: `uint256 public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `userInfo` | type: `mapping(uint256 => mapping(address => UserInfo)) public` | vis: `public` | flags: `-` | `StellaVault` @ `vault/StellaVault.sol`
- `GRACE_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Timelock` @ `helpers/Timelock.sol` = `14 days`
- `MAXIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Timelock` @ `helpers/Timelock.sol` = `30 days`
- `MINIMUM_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Timelock` @ `helpers/Timelock.sol` = `6 hours`
- `admin` | type: `address public` | vis: `public` | flags: `-` | `Timelock` @ `helpers/Timelock.sol`
- `admin_initialized` | type: `bool public` | vis: `public` | flags: `-` | `Timelock` @ `helpers/Timelock.sol`
- `delay` | type: `uint256 public` | vis: `public` | flags: `-` | `Timelock` @ `helpers/Timelock.sol`
- `pendingAdmin` | type: `address public` | vis: `public` | flags: `-` | `Timelock` @ `helpers/Timelock.sol`
- `queuedTransactions` | type: `mapping(bytes32 => bool) public` | vis: `public` | flags: `-` | `Timelock` @ `helpers/Timelock.sol`
- `Q112` | type: `uint224 constant` | vis: `default` | flags: `constant` | `UQ112x112` @ `amm/libraries/UQ112x112.sol` = `2**112`
- `allowance` | type: `mapping (address => mapping (address => uint)) public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol`
- `balanceOf` | type: `mapping (address => uint) public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol` = `18`
- `name` | type: `string public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol` = `"Wrapped GLMR"`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `WETH` @ `weth/weth.sol` = `"WGLMR"`

### Tokens Added / Token State Values
Detected token-related variables:
- `tokenWhitelist` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `GasSwap` @ `gasless/GasSwap.sol`
- `allPairs` | type: `address[] public override` | vis: `public` | flags: `override` | `StellaSwapV2Factory` @ `amm/StellaSwapV2Factory.sol`
- `token0` | type: `address public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `token1` | type: `address public` | vis: `public` | flags: `-` | `StellaSwapV2Pair` @ `amm/StellaSwapV2Pair.sol`
- `WETH` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router` @ `amm/StellaSwapV2Router.sol`
- `WETH` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `StellaSwapV2Router02` @ `amm/StellaSwapV2Router02.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `Call` (helpers/Multicall.sol): address target, bytes callData
- `Checkpoint` (token/Stella.sol): uint32 fromBlock, uint256 votes
- `EIP712Domain` (gasless/EIP712Base.sol): string name, string version, address verifyingContract, bytes32 salt
- `ForwardRequest` (forwarder/IForwarder.sol): address from, address to, uint256 value, uint256 gas, uint256 nonce, bytes data, uint256 validUntil
- `MetaTransaction` (gasless/EIP712MetaTransaction.sol): uint256 nonce, address from, bytes functionSignature
- `PoolInfo` (farms/StellaDistributor.sol): IERC20 lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accStellaPerShare, uint16 depositFeeBP, uint256 harvestInterval, uint256 totalLp
- `PoolInfo` (vault/StellaVault.sol): IERC20 lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accStellaPerShare, uint16 depositFeeBP, uint256 harvestInterval, uint256 totalLp, uint256 lockDownDuration
- `Result` (helpers/Multicall.sol): bool success, bytes returnData
- `TimedStake` (vault/StellaVault.sol): mapping(uint256 => uint256) stakes, uint256[] stakeTimes
- `Transformation` (gasless/GasSwap.sol): uint32 _uint32, bytes _bytes
- `UserInfo` (farms/StellaDistributor.sol): uint256 amount, uint256 rewardDebt, uint256 rewardLockedUp, uint256 nextHarvestUntil
- `UserInfo` (vault/StellaVault.sol): uint256 amount, uint256 rewardDebt, uint256 rewardLockedUp, uint256 nextHarvestUntil

### Enum State Values
- None detected

### Invariant Values (Variable-Tied)
- `sum(balanceOf[*]) == totalSupply` (token balance conservation)
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
