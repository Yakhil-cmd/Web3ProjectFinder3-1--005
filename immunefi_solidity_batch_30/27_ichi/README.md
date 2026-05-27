# ICHI oneToken Factory

[![OneToken Tests](https://github.com/ichifarm/ichi-oneToken/actions/workflows/tests.yml/badge.svg)](https://github.com/ichifarm/ichi-oneToken/actions/workflows/tests.yml)

### Mainnet Addresses

- OneTokenFactory: https://etherscan.io/address/0xd0092632b9ac5a7856664eec1abb6e3403a6a36a
- OneTokenV1: https://etherscan.io/address/0x14356bf935d6a62f3b87ab89f729217599bc108d
- Basic Null Controller: https://etherscan.io/address/0x81c9932bd9a87e454710ef83551ac32dd808630e
- Incremental Mint Master: https://etherscan.io/address/0x58254B405E85359Fc7Eb3b8856bA82A4dD7C82E2

### Local Deployment

```
> yarn install
.
.
.
> yarn dev:deployTestToken
yarn run v1.22.4
$ hardhat --network hardhat deploy --tags init,testToken
Compiling 69 files with 0.7.6
Compilation finished successfully
Creating Typechain artifacts in directory types for target ethers-v5
Successfully generated Typechain artifacts!
deploying "OneTokenFactory" (tx: 0xf8996872e81f4e8e8d5d86703912e95ae60ab3642e3df843106074ca5d42dc2c)...: deployed at 0x5FbDB2315678afecb367f032d93F642f64180aa3 with 4175984 gas
deploying "Incremental" (tx: 0xb26b0197d61be039af3146de3125847c9c027c6c2a85342b225bef39058273c0)...: deployed at 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 with 1983710 gas
deploying "NullController" (tx: 0x592674e6aefd480e5b693a4703c91dac328d37cf13e782bcca31233e122179bb)...: deployed at 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 with 304324 gas
deploying "OneTokenV1" (tx: 0xe6afef3d97aa2373d721cf8503f27807dc660c61263e34a0b909af937deea46b)...: deployed at 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707 with 5231421 gas
deploying "Token6" (tx: 0x17d3aa06cec3635a7944a61595811c2f698e0f534061a79131b8ca75782abd8b)...: deployed at 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 with 763350 gas
deploying "Token9" (tx: 0x87311258072225410cc3dafc15db5b7f62faccc9a6c9b30774656320586e7312)...: deployed at 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6 with 763366 gas
deploying "Token18" (tx: 0x84bd8551cfb1c170be722634e89355651ce3431484f6098775629e60a251fc3b)...: deployed at 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318 with 763446 gas
deploying "ICHIPeggedOracle" (tx: 0x829b19221d4800e8c28f00f6f0d05c1e5e5ace67fd080f56ff0591eeb22b77e1)...: deployed at 0x610178dA211FEF7D417bC0e6FeD39F05609AD788 with 883621 gas
deploying "TestOracle" (tx: 0x930c32c4500b855f6dd5e7fb40786abee555245a925fda237b4a95bf592619ae)...: deployed at 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 with 831316 gas
*************************************************************
* oneToken: 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968
*************************************************************
✨  Done in 15.71s.
```

### 🧐 RESOURCES
- Website: https://www.ichi.org/
- App: https://app.ichi.org
- Medium: https://medium.com/ichifarm
- Twitter: https://twitter.com/ichifoundation
- Discord: https://discord.gg/ichi-ichi-org-766688709814124595

### 💻 TECHNICAL
- Docs: https://docs.ichi.org/home/
- GitHub: https://github.com/ichifarm

### Licensing

The primary license for ICHI V2 oneToken is the Business Source License 1.1 (`BUSL-1.1`), see [`LICENSE`](./LICENSE).

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T17:00:00Z`  
Project: `27_ichi`  
Solidity files: `69`

### Structure
Top Solidity directories:
- `contracts`: 69 `.sol` files

Pragmas:
- `0.7.6`
- `=0.7.6`
- `>=0.4.0`
- `>=0.4.22 <0.9.0`
- `>=0.5.0`
- `>=0.6.0 <0.8.0`
- `>=0.6.2 <0.8.0`

Contracts/Libraries/Interfaces detected: `69`

### Life Total / Balance Values
Detected accounting/state total variables:
- `_balances` | type: `mapping (address => uint256) private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `assets` | type: `mapping(address => Asset) public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `collateralTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `indexToken` | type: `address public override` | vis: `public` | flags: `override` | `OracleCommon` @ `contracts/oracle/OracleCommon.sol`
- `MINIMUM_LIQUIDITY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol` = `10 ** 3`
- `reserve0` | type: `uint112 private` | vis: `private` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `reserve1` | type: `uint112 private` | vis: `private` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`

All detected state variables (full list):
- `MODULE_TYPE` | type: `bytes32 constant public override` | vis: `public` | flags: `constant,override` | `ControllerCommon` @ `contracts/controller/ControllerCommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Controller"))`
- `description` | type: `string public override` | vis: `public` | flags: `override` | `ControllerCommon` @ `contracts/controller/ControllerCommon.sol`
- `oneTokenFactory` | type: `address public override` | vis: `public` | flags: `override` | `ControllerCommon` @ `contracts/controller/ControllerCommon.sol`
- `DEFAULT_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `DummyMintMaster` @ `contracts/testToken/DummyMintMaster.sol` = `10 ** 18`
- `MAX_VOLUME` | type: `uint256 constant` | vis: `default` | flags: `constant` | `DummyMintMaster` @ `contracts/testToken/DummyMintMaster.sol` = `1000`
- `LOWER_MASK` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `FixedPoint` @ `contracts/_uniswap/lib/contracts/libraries/FixedPoint.sol` = `0xffffffffffffffffffffffffffff`
- `Q112` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `FixedPoint` @ `contracts/_uniswap/lib/contracts/libraries/FixedPoint.sol` = `0x10000000000000000000000000000`
- `Q224` | type: `uint256 private constant` | vis: `private` | flags: `constant` | `FixedPoint` @ `contracts/_uniswap/lib/contracts/libraries/FixedPoint.sol` = `0x100000000000000000000000000000000000000000000000000000000`
- `COMPONENT_CONTROLLER` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Controller"))`
- `COMPONENT_FACTORY` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI OneToken Factory"))`
- `COMPONENT_MINTMASTER` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 MintMaster Implementation"))`
- `COMPONENT_ORACLE` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Oracle Implementation"))`
- `COMPONENT_STRATEGY` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Strategy Implementation"))`
- `COMPONENT_VERSION` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 OneToken Implementation"))`
- `COMPONENT_VOTERROLL` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `keccak256(abi.encodePacked("ICHI V1 VoterRoll Implementation"))`
- `INFINITE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `uint256(0-1)`
- `NULL_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `address(0)`
- `PRECISION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `ICHICommon` @ `contracts/common/ICHICommon.sol` = `10 ** 18`
- `interimTokens` | type: `address[] public` | vis: `public` | flags: `-` | `ICHICompositeOracle` @ `contracts/oracle/composite/ICHICompositeOracle.sol`
- `oracleContracts` | type: `address[] public` | vis: `public` | flags: `-` | `ICHICompositeOracle` @ `contracts/oracle/composite/ICHICompositeOracle.sol`
- `_allowances` | type: `mapping (address => mapping (address => uint256)) private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_balances` | type: `mapping (address => uint256) private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_decimals` | type: `uint8 private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_name` | type: `string private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_symbol` | type: `string private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_totalSupply` | type: `uint256 private` | vis: `private` | flags: `-` | `ICHIERC20` @ `contracts/oz_modified/ICHIERC20.sol`
- `_initialized` | type: `bool private` | vis: `private` | flags: `-` | `ICHIInitializable` @ `contracts/oz_modified/ICHIInitializable.sol`
- `_initializing` | type: `bool private` | vis: `private` | flags: `-` | `ICHIInitializable` @ `contracts/oz_modified/ICHIInitializable.sol`
- `moduleDescription` | type: `string public override` | vis: `public` | flags: `override` | `ICHIModuleCommon` @ `contracts/common/ICHIModuleCommon.sol`
- `moduleType` | type: `ModuleType public immutable override` | vis: `public` | flags: `immutable,override` | `ICHIModuleCommon` @ `contracts/common/ICHIModuleCommon.sol`
- `oneTokenFactory` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `ICHIModuleCommon` @ `contracts/common/ICHIModuleCommon.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `ICHIOwnable` @ `contracts/oz_modified/ICHIOwnable.sol`
- `DEFAULT_MAX_ORDER_VOLUME` | type: `uint256 constant` | vis: `default` | flags: `constant` | `Incremental` @ `contracts/mintMaster/legacy/Incremental.sol` = `INFINITE`
- `DEFAULT_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `Incremental` @ `contracts/mintMaster/legacy/Incremental.sol` = `10 ** 18`
- `DEFAULT_STEP_SIZE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `Incremental` @ `contracts/mintMaster/legacy/Incremental.sol` = `0`
- `parameters` | type: `mapping(address => Parameters) public` | vis: `public` | flags: `-` | `Incremental` @ `contracts/mintMaster/legacy/Incremental.sol`
- `last_completed_migration` | type: `uint256 public` | vis: `public` | flags: `-` | `Migrations` @ `contracts/Migrations.sol`
- `owner` | type: `address public` | vis: `public` | flags: `-` | `Migrations` @ `contracts/Migrations.sol` = `msg.sender`
- `MODULE_TYPE` | type: `bytes32 constant public override` | vis: `public` | flags: `constant,override` | `MintMasterCommon` @ `contracts/mintMaster/MintMasterCommon.sol` = `keccak256(abi.encodePacked("ICHI V1 MintMaster Implementation"))`
- `oneTokenOracles` | type: `mapping(address => address) public override` | vis: `public` | flags: `override` | `MintMasterCommon` @ `contracts/mintMaster/MintMasterCommon.sol`
- `MODULE_TYPE` | type: `bytes32 public constant override` | vis: `public` | flags: `constant,override` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol` = `keccak256(abi.encodePacked("ICHI OneToken Factory"))`
- `NULL_DATA` | type: `bytes constant` | vis: `default` | flags: `constant` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol` = `""`
- `foreignTokens` | type: `mapping(address => ForeignToken)` | vis: `default` | flags: `-` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `modules` | type: `mapping(address => Module) public` | vis: `public` | flags: `-` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `oneTokenProxyAdmins` | type: `mapping(address => address) public override` | vis: `public` | flags: `override` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `oneTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `liabilities` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `OneTokenV1` @ `contracts/version/v1/OneTokenV1.sol`
- `mintingFee` | type: `uint256 public override` | vis: `public` | flags: `override` | `OneTokenV1` @ `contracts/version/v1/OneTokenV1.sol`
- `redemptionFee` | type: `uint256 public override` | vis: `public` | flags: `override` | `OneTokenV1` @ `contracts/version/v1/OneTokenV1.sol`
- `MODULE_TYPE` | type: `bytes32 public constant override` | vis: `public` | flags: `constant,override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol` = `keccak256(abi.encodePacked("ICHI V1 OneToken Implementation"))`
- `assets` | type: `mapping(address => Asset) public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `collateralTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `controller` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `memberToken` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `mintMaster` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `oneTokenFactory` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `otherTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `MODULE_TYPE` | type: `bytes32 constant public override` | vis: `public` | flags: `constant,override` | `OracleCommon` @ `contracts/oracle/OracleCommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Oracle Implementation"))`
- `NORMAL` | type: `uint256 constant` | vis: `default` | flags: `constant` | `OracleCommon` @ `contracts/oracle/OracleCommon.sol` = `18`
- `indexToken` | type: `address public override` | vis: `public` | flags: `override` | `OracleCommon` @ `contracts/oracle/OracleCommon.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `contracts/_openzeppelin/access/Ownable.sol`
- `set` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `SetTest` @ `contracts/testToken/SetTest.sol`
- `MODULE_TYPE` | type: `bytes32 constant public override` | vis: `public` | flags: `constant,override` | `StrategyCommon` @ `contracts/strategy/StrategyCommon.sol` = `keccak256(abi.encodePacked("ICHI V1 Strategy Implementation"))`
- `oneToken` | type: `address public override` | vis: `public` | flags: `override` | `StrategyCommon` @ `contracts/strategy/StrategyCommon.sol`
- `DEFAULT_RATIO` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestMintMaster` @ `contracts/testToken/TestMintMaster.sol` = `10 ** 18`
- `DEFAULT_STEP_SIZE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestMintMaster` @ `contracts/testToken/TestMintMaster.sol` = `0`
- `MAX_VOLUME` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestMintMaster` @ `contracts/testToken/TestMintMaster.sol` = `1000`
- `adjustUp` | type: `bool private` | vis: `private` | flags: `-` | `TestOracle` @ `contracts/testToken/TestOracle.sol`
- `_ADMIN_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `TransparentUpgradeableProxy` @ `contracts/_openzeppelin/proxy/TransparentUpgradeableProxy.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `Q112` | type: `uint224 constant` | vis: `default` | flags: `constant` | `UQ112x112` @ `contracts/_uniswap/v2-core/contracts/libraries/UQ112x112.sol` = `2**112`
- `PERIOD` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `UniswapOracleSimple` @ `contracts/oracle/uniswap/UniswapOracleSimple.sol`
- `uniswapFactory` | type: `address public immutable` | vis: `public` | flags: `immutable` | `UniswapOracleSimple` @ `contracts/oracle/uniswap/UniswapOracleSimple.sol`
- `allPairs` | type: `address[] public` | vis: `public` | flags: `-` | `UniswapV2Factory` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Factory.sol`
- `feeTo` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Factory` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Factory.sol`
- `feeToSetter` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Factory` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Factory.sol`
- `getPair` | type: `mapping(address => mapping(address => address)) public` | vis: `public` | flags: `-` | `UniswapV2Factory` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Factory.sol`
- `MINIMUM_LIQUIDITY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol` = `10 ** 3`
- `SELECTOR` | type: `bytes4 private constant` | vis: `private` | flags: `constant` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol` = `bytes4(keccak256(bytes('transfer(address,uint256)')))`
- `_price0CumulativeLast` | type: `uint256 public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `_price1CumulativeLast` | type: `uint256 public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `_token0` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `_token1` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `blockTimestampLast` | type: `uint32 private` | vis: `private` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `factory` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `kLast` | type: `uint256 public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `reserve0` | type: `uint112 private` | vis: `private` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `reserve1` | type: `uint112 private` | vis: `private` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 private constant` | vis: `private` | flags: `constant` | `UpgradeableProxy` @ `contracts/_openzeppelin/proxy/UpgradeableProxy.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`

### Tokens Added / Token State Values
Detected token-related variables:
- `oneTokenFactory` | type: `address public override` | vis: `public` | flags: `override` | `ControllerCommon` @ `contracts/controller/ControllerCommon.sol`
- `interimTokens` | type: `address[] public` | vis: `public` | flags: `-` | `ICHICompositeOracle` @ `contracts/oracle/composite/ICHICompositeOracle.sol`
- `oneTokenFactory` | type: `address public immutable override` | vis: `public` | flags: `immutable,override` | `ICHIModuleCommon` @ `contracts/common/ICHIModuleCommon.sol`
- `oneTokenOracles` | type: `mapping(address => address) public override` | vis: `public` | flags: `override` | `MintMasterCommon` @ `contracts/mintMaster/MintMasterCommon.sol`
- `foreignTokens` | type: `mapping(address => ForeignToken)` | vis: `default` | flags: `-` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `oneTokenProxyAdmins` | type: `mapping(address => address) public override` | vis: `public` | flags: `override` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `oneTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenFactory` @ `contracts/OneTokenFactory.sol`
- `collateralTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `memberToken` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `oneTokenFactory` | type: `address public override` | vis: `public` | flags: `override` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `otherTokenSet` | type: `AddressSet.Set` | vis: `default` | flags: `-` | `OneTokenV1Base` @ `contracts/version/v1/OneTokenV1Base.sol`
- `indexToken` | type: `address public override` | vis: `public` | flags: `override` | `OracleCommon` @ `contracts/oracle/OracleCommon.sol`
- `oneToken` | type: `address public override` | vis: `public` | flags: `override` | `StrategyCommon` @ `contracts/strategy/StrategyCommon.sol`
- `allPairs` | type: `address[] public` | vis: `public` | flags: `-` | `UniswapV2Factory` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Factory.sol`
- `_token0` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`
- `_token1` | type: `address public` | vis: `public` | flags: `-` | `UniswapV2Pair` @ `contracts/_uniswap/v2-core/contracts/UniswapV2Pair.sol`

Hardcoded token addresses found:
- None detected

### Struct Values (All Parsed Struct Fields)
- `Asset` (contracts/version/v1/OneTokenV1Base.sol): address oracle, address strategy
- `ForeignToken` (contracts/OneTokenFactory.sol): bool isCollateral, AddressSet.Set oracleSet
- `Module` (contracts/OneTokenFactory.sol): string name, string url, ModuleType moduleType
- `Pair` (contracts/oracle/uniswap/UniswapOracleSimple.sol): address token0, address token1, uint256 price0CumulativeLast, uint256 price1CumulativeLast, uint32 blockTimestampLast, FixedPoint.uq112x112 price0Average, FixedPoint.uq112x112 price1Average
- `Parameters` (contracts/mintMaster/legacy/Incremental.sol): bool set, uint256 minRatio, uint256 maxRatio, uint256 stepSize, uint256 lastRatio, uint256 maxOrderVolume
- `Parameters` (contracts/testToken/TestMintMaster.sol): bool set, uint256 minRatio, uint256 maxRatio, uint256 stepSize, uint256 lastRatio
- `Set` (contracts/lib/AddressSet.sol): mapping(address => uint256) keyPointers, address[] keyList
- `uq112x112` (contracts/_uniswap/lib/contracts/libraries/FixedPoint.sol): uint224 _x
- `uq144x112` (contracts/_uniswap/lib/contracts/libraries/FixedPoint.sol): uint256 _x

### Enum State Values
- `ModuleType` (contracts/interface/InterfaceCommon.sol): Version, Controller, Strategy, MintMaster, Oracle

### Invariant Values (Variable-Tied)
- Key accounting vars (`MINIMUM_LIQUIDITY`, `reserve0`, `reserve1`, `indexToken`, `_balances`, `_totalSupply`, `collateralTokenSet`, `assets`) must only change through authorized accounting paths
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
