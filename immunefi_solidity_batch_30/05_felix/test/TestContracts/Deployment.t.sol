// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import { TroveManager } from "../../src/TroveManager.sol";
import { AddressesRegistry } from "../../src/AddressesRegistry.sol";
import { ActivePool } from "../../src/ActivePool.sol";
import { feUSDToken } from "../../src/feUSDToken.sol";
import { BorrowerOperations } from "../../src/BorrowerOperations.sol";
import { CollSurplusPool } from "../../src/CollSurplusPool.sol";
import { DefaultPool } from "../../src/DefaultPool.sol";
import { GasPool } from "../../src/GasPool.sol";
import { HintHelpers } from "../../src/HintHelpers.sol";
import { MultiTroveGetter } from "../../src/MultiTroveGetter.sol";
import { SortedTroves } from "../../src/SortedTroves.sol";
import { StabilityPool } from "../../src/StabilityPool.sol";
import { BorrowerOperationsTester, IBorrowerOperationsTester } from "./BorrowerOperationsTester.t.sol";
import { TroveManagerTester, ITroveManagerTester } from "./TroveManagerTester.t.sol";
import { TroveNFT } from "../../src/TroveNFT.sol";
import { MetadataNFT } from "../../src/NFTMetadata/MetadataNFT.sol";
import { CollateralRegistry } from "../../src/CollateralRegistry.sol";
import { MockInterestRouter } from "../../src/MockInterestRouter.sol";
import { PriceFeedTestnet, IPriceFeedTestnet } from "./PriceFeedTestnet.sol";
import { MetadataDeployment } from "./MetadataDeployment.sol";
import "../../src/Zappers/WHYPEZapper.sol";
import "../../src/Zappers/GasCompZapper.sol";
import "../../src/Zappers/LeverageLSTZapper.sol";
import "../../src/Zappers/LeverageWHYPEZapper.sol";
import "../../src/Zappers/Modules/FlashLoans/BalancerFlashLoan.sol";
import "../../src/Zappers/Interfaces/IFlashLoanProvider.sol";
import "../../src/Zappers/Interfaces/IExchange.sol";
import "../../src/Zappers/Modules/Exchanges/Curve/ICurveFactory.sol";
import "../../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGFactory.sol";
import "../../src/Zappers/Modules/Exchanges/Curve/ICurvePool.sol";
import "../../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGPool.sol";
import "../../src/Zappers/Modules/Exchanges/CurveExchange.sol";
import "../../src/Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol";
import "../../src/Zappers/Modules/Exchanges/UniV3Exchange.sol";
import "../../src/Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol";
import "../../src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol";
import { WHYPETester } from "./WHYPETester.sol";
import { ERC20Faucet } from "./ERC20Faucet.sol";
import { ActivePoolTester, IActivePoolTester } from "./ActivePoolTester.sol";
import { StabilityPoolTester, IStabilityPoolTester } from "./StabilityPoolTester.sol";
import {
    HL_ETH_FEED_L1_INDEX,
    HL_ETH_FEED_SZ_DECIMALS
} from "../../src/Dependencies/Constants.sol";

import "../../src/PriceFeeds/WHYPEPriceFeed.sol";
import "../../src/PriceFeeds/WSTETHPriceFeed.sol";
import "../../src/PriceFeeds/RETHPriceFeed.sol";
import "../../src/PriceFeeds/OSETHPriceFeed.sol";
import "../../src/PriceFeeds/ETHXPriceFeed.sol";
import "../../src/PriceFeeds/HLPriceFeed.sol";

import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

import "forge-std/console2.sol";

uint256 constant _24_HOURS = 86400;
uint256 constant _48_HOURS = 172800;

// TODO: Split dev and mainnet
contract TestDeployer is MetadataDeployment {
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IWETH constant WETH_MAINNET = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Curve
    ICurveFactory constant curveFactory = ICurveFactory(0x98EE851a00abeE0d95D08cF4CA2BdCE32aeaAF7F);
    ICurveStableswapNGFactory constant curveStableswapFactory =
        ICurveStableswapNGFactory(0x6A8cbed756804B16E05E741eDaBd5cB544AE21bf);
    uint128 constant feUSD_TOKEN_INDEX = 0;
    uint256 constant COLL_TOKEN_INDEX = 1;
    uint128 constant USDC_INDEX = 1;

    // UniV3
    ISwapRouter constant uniV3Router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    INonfungiblePositionManager constant uniV3PositionManager =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    IWHYPE constant WHYPE_MAINNET = IWHYPE(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint24 constant UNIV3_FEE = 3000; // 0.3%
    uint24 constant UNIV3_FEE_USDC_WETH = 500; // 0.05%
    uint24 constant UNIV3_FEE_WETH_COLL = 100; // 0.01%

    bytes32 constant SALT = keccak256("LiquityV2");
    ProxyAdmin public proxyAdmin = new ProxyAdmin();

    HintHelpers hintHelpersImpl = new HintHelpers();
    MultiTroveGetter multiTroveGetterImpl = new MultiTroveGetter();
    IAddressesRegistry addressesRegistryImpl = new AddressesRegistry();
    SortedTroves sortedTrovesImpl = new SortedTroves();
    CollSurplusPool collSurplusPoolImpl = new CollSurplusPool();
    GasPool gasPoolImpl = new GasPool();
    DefaultPool defaultPoolImpl = new DefaultPool();
    IActivePoolTester activePoolImpl = new ActivePoolTester();
    TroveManager troveManagerImpl = new TroveManager();
    IStabilityPoolTester stabilityPoolImpl = new StabilityPoolTester();
    BorrowerOperations borrowerOperationsImpl = new BorrowerOperations();
    WHYPEZapper whypeZapperImpl = new WHYPEZapper();
    GasCompZapper gasCompZapperImpl = new GasCompZapper();
    LeverageLSTZapper leverageLSTZapperImpl = new LeverageLSTZapper();
    LeverageWHYPEZapper leverageWHYPEZapperImpl = new LeverageWHYPEZapper();
    BorrowerOperationsTester borrowerOperationsTesterImpl = new BorrowerOperationsTester();
    TroveManagerTester troveManagerTesterImpl = new TroveManagerTester();
    TroveNFT troveNFTImpl = new TroveNFT();
    MetadataNFT metadataNFTImpl = new MetadataNFT();
    feUSDToken feUSDTokenImpl = new feUSDToken();
    MockInterestRouter mockInterestRouterImpl = new MockInterestRouter();
    CollateralRegistry collateralRegistryImpl = new CollateralRegistry();
    HLPriceFeed hlPriceFeedImpl = new HLPriceFeed();
    uint256 SP_YIELD_SPLIT = vm.envUint("SP_YIELD_SPLIT");

    struct LiquityContractsDevPools {
        IDefaultPool defaultPool;
        ICollSurplusPool collSurplusPool;
        GasPool gasPool;
    }


    struct LiquityContractsDev {
        IAddressesRegistry addressesRegistry;
        IActivePoolTester activePool; // Tester
        IBorrowerOperationsTester borrowerOperations; // Tester
        ICollSurplusPool collSurplusPool;
        ISortedTroves sortedTroves;
        IStabilityPoolTester stabilityPool; // Tester
        ITroveManagerTester troveManager; // Tester
        ITroveNFT troveNFT;
        IPriceFeedTestnet priceFeed; // Tester
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
        LiquityContractsDevPools pools;
        address proxyAdmin;
    }

    struct LiquityContracts {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        IPriceFeed priceFeed;
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
    }

    struct Zappers {
        WHYPEZapper whypeZapper;
        GasCompZapper gasCompZapper;
        ILeverageZapper leverageZapperCurve;
        ILeverageZapper leverageZapperUniV3;
        ILeverageZapper leverageZapperHybrid;
    }

    struct LiquityContractAddresses {
        address activePool;
        address borrowerOperations;
        address collSurplusPool;
        address defaultPool;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        address metadataNFT;
        address priceFeed;
        address gasPool;
        address interestRouter;
    }

    struct TroveManagerParams {
        uint256 CCR;
        uint256 MCR;
        uint256 SCR;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
        uint256 maxDebtCap;
    }

    struct DeploymentVarsDev {
        uint256 numCollaterals;
        IERC20Metadata[] collaterals;
        IAddressesRegistry[] addressesRegistries;
        ITroveManager[] troveManagers;
        bytes bytecode;
        address feUSDTokenAddress;
        uint256 i;
    }

    struct DeploymentResultMainnet {
        LiquityContracts[] contractsArray;
        ExternalAddresses externalAddresses;
        ICollateralRegistry collateralRegistry;
        IfeUSDToken feUSDToken;
        HintHelpers hintHelpers;
        MultiTroveGetter multiTroveGetter;
        Zappers[] zappersArray;
    }

    struct DeploymentVarsMainnet {
        OracleParams oracleParams;
        uint256 numCollaterals;
        IERC20Metadata[] collaterals;
        IAddressesRegistry[] addressesRegistries;
        ITroveManager[] troveManagers;
        IPriceFeed[] priceFeeds;
        bytes bytecode;
        address feUSDTokenAddress;
        uint256 i;
    }

    struct DeploymentParamsMainnet {
        IERC20Metadata collToken;
        IPriceFeed priceFeed;
        IfeUSDToken feUSDToken;
        ICollateralRegistry collateralRegistry;
        IWHYPE whype;
        IAddressesRegistry addressesRegistry;
        address troveManagerAddress;
        IHintHelpers hintHelpers;
        IMultiTroveGetter multiTroveGetter;
        ICurveStableswapNGPool usdcCurvePool;
    }

    struct ExternalAddresses {
        address ETHOracle;
        address STETHOracle;
        address RETHOracle;
        address ETHXOracle;
        address OSETHOracle;
        address WSTETHToken;
        address RETHToken;
        address StaderOracle; // "StaderOracle" is the ETHX contract that manages the canonical exchange rate. Not a market pricacle.
        address OsTokenVaultController;
    }

    struct OracleParams {
        uint256 ethUsdStalenessThreshold;
        uint256 stEthUsdStalenessThreshold;
        uint256 rEthEthStalenessThreshold;
        uint256 ethXEthStalenessThreshold;
        uint256 osEthEthStalenessThreshold;
    }

    function deployProxy(address _impl, bytes memory _data) public returns (address) {
        return address(new TransparentUpgradeableProxy{salt: SALT}(_impl, address(proxyAdmin), _data));
    }

    function deployProxyNoSalt(address _impl, bytes memory _data) public returns (address) {
        return address(new TransparentUpgradeableProxy(_impl, address(proxyAdmin), _data));
    }

    // See: https://solidity-by-example.org/app/create2/
    function getBytecode(bytes memory _creationCode, address _addressesRegistry) public pure returns (bytes memory) {
        return abi.encodePacked(_creationCode, abi.encode(_addressesRegistry));
    }

    function getBytecodeProxy(address _impl, bytes memory _data) public view returns (bytes memory) {
        return abi.encodePacked(type(TransparentUpgradeableProxy).creationCode, abi.encode(_impl, address(proxyAdmin), _data));
    }

    function getAddress(address _deployer, bytes memory _bytecode, bytes32 _salt) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), _deployer, _salt, keccak256(_bytecode)));

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function deployAndConnectContracts()
        external
        returns (
            LiquityContractsDev memory contracts,
            ICollateralRegistry collateralRegistry,
            IfeUSDToken feUSDToken,
            HintHelpers hintHelpers,
            MultiTroveGetter multiTroveGetter,
            IWHYPE WHYPE, // for gas compensation
            Zappers memory zappers
        )
    {
        return deployAndConnectContracts(TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16, type(uint256).max));
    }

    function deployAndConnectContracts(TroveManagerParams memory troveManagerParams)
        public
        returns (
            LiquityContractsDev memory contracts,
            ICollateralRegistry collateralRegistry,
            IfeUSDToken feUSDToken,
            HintHelpers hintHelpers,
            MultiTroveGetter multiTroveGetter,
            IWHYPE WHYPE, // for gas compensation
            Zappers memory zappers
        )
    {
        LiquityContractsDev[] memory contractsArray;
        TroveManagerParams[] memory troveManagerParamsArray = new TroveManagerParams[](1);
        Zappers[] memory zappersArray;

        troveManagerParamsArray[0] = troveManagerParams;

        (contractsArray, collateralRegistry, feUSDToken, hintHelpers, multiTroveGetter, WHYPE, zappersArray) =
            deployAndConnectContractsMultiColl(troveManagerParamsArray);
        contracts = contractsArray[0];
        zappers = zappersArray[0];
    }

    function deployAndConnectContractsMultiColl(TroveManagerParams[] memory troveManagerParamsArray)
        public
        returns (
            LiquityContractsDev[] memory contractsArray,
            ICollateralRegistry collateralRegistry,
            IfeUSDToken feUSDToken,
            HintHelpers hintHelpers,
            MultiTroveGetter multiTroveGetter,
            IWHYPE WHYPE, // for gas compensation
            Zappers[] memory zappersArray
        )
    {
        // used for gas compensation and as collateral of the first branch
        WHYPE = new WHYPETester(
            100 ether, //     _tapAmount
            1 days //         _tapPeriod
        );
        (contractsArray, collateralRegistry, feUSDToken, hintHelpers, multiTroveGetter, zappersArray) =
            deployAndConnectContracts(troveManagerParamsArray, WHYPE);
    }

    function _nameToken(uint256 _index) internal pure returns (string memory) {
        if (_index == 1) return "Wrapped Staked Ether";
        if (_index == 2) return "Rocket Pool ETH";
        return "LST Tester";
    }

    function _symboltoken(uint256 _index) internal pure returns (string memory) {
        if (_index == 1) return "wstETH";
        if (_index == 2) return "rETH";
        return "LST";
    }

    function deployAndConnectContracts(TroveManagerParams[] memory troveManagerParamsArray, IWHYPE _WHYPE)
        public
        returns (
            LiquityContractsDev[] memory contractsArray,
            ICollateralRegistry collateralRegistry,
            IfeUSDToken feUSDToken,
            HintHelpers hintHelpers,
            MultiTroveGetter multiTroveGetter,
            Zappers[] memory zappersArray
        )
    {
        DeploymentVarsDev memory vars;
        vars.numCollaterals = troveManagerParamsArray.length;
        // Deploy feUSD
        vars.bytecode = getBytecodeProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        );
        vars.feUSDTokenAddress = getAddress(address(this), vars.bytecode, SALT);
        feUSDToken = IfeUSDToken(deployProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        ));
        assert(address(feUSDToken) == vars.feUSDTokenAddress);

        contractsArray = new LiquityContractsDev[](vars.numCollaterals);
        zappersArray = new Zappers[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);

        // Deploy the first branch with WHYPE collateral
        vars.collaterals[0] = _WHYPE;
        (IAddressesRegistry addressesRegistry, address troveManagerAddress) =
            _deployAddressesRegistryDev(troveManagerParamsArray[0]);
        vars.addressesRegistries[0] = addressesRegistry;
        vars.troveManagers[0] = ITroveManager(troveManagerAddress);
        for (vars.i = 1; vars.i < vars.numCollaterals; vars.i++) {
            IERC20Metadata collToken = new ERC20Faucet(
                _nameToken(vars.i), // _name
                _symboltoken(vars.i), // _symbol
                100 ether, //     _tapAmount
                1 days //         _tapPeriod
            );
            vars.collaterals[vars.i] = collToken;
            // Addresses registry and TM address
            (addressesRegistry, troveManagerAddress) = _deployAddressesRegistryDev(troveManagerParamsArray[vars.i]);
            vars.addressesRegistries[vars.i] = addressesRegistry;
            vars.troveManagers[vars.i] = ITroveManager(troveManagerAddress);
        }

        collateralRegistry = ICollateralRegistry(
            deployProxyNoSalt(
                address(collateralRegistryImpl),
                abi.encodeWithSelector(
                    CollateralRegistry.initialize.selector,
                    feUSDToken,
                    vars.collaterals,
                    vars.troveManagers,
                    address(this)
                )
            )
        );

        feUSDToken.setCollateralRegistry(address(collateralRegistry));

        hintHelpers = HintHelpers(
            deployProxy(
                address(hintHelpersImpl),
                abi.encodeWithSelector(HintHelpers.initialize.selector, collateralRegistry)
            )
        );

        multiTroveGetter = MultiTroveGetter(
            deployProxy(
                address(multiTroveGetterImpl),
                abi.encodeWithSelector(MultiTroveGetter.initialize.selector, collateralRegistry)
            )
        );

        (contractsArray[0], zappersArray[0]) = _deployAndConnectCollateralContractsDev(
            _WHYPE,
            feUSDToken,
            collateralRegistry,
            _WHYPE,
            vars.addressesRegistries[0],
            address(vars.troveManagers[0]),
            hintHelpers,
            multiTroveGetter
        );

        // Deploy the remaining branches with LST collateral
        for (vars.i = 1; vars.i < vars.numCollaterals; vars.i++) {
            (contractsArray[vars.i], zappersArray[vars.i]) = _deployAndConnectCollateralContractsDev(
                vars.collaterals[vars.i],
                feUSDToken,
                collateralRegistry,
                _WHYPE,
                vars.addressesRegistries[vars.i],
                address(vars.troveManagers[vars.i]),
                hintHelpers,
                multiTroveGetter
            );
        }

    }

    function _deployAddressesRegistryDev(TroveManagerParams memory _troveManagerParams)
        internal
        returns (IAddressesRegistry, address)
    {
        bytes memory data = abi.encodeWithSelector(
            IAddressesRegistry.initialize.selector,
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION,
            _troveManagerParams.maxDebtCap // _maxDebtCap
        );

        IAddressesRegistry addressesRegistry = IAddressesRegistry(
            deployProxyNoSalt(address(addressesRegistryImpl), data)
        );

        address troveManagerAddress = getAddress(
            address(this),
            getBytecodeProxy(
                address(troveManagerTesterImpl),
                abi.encodeWithSelector(troveManagerTesterImpl.initialize.selector, addressesRegistry)
            ),
            SALT
        );

        return (addressesRegistry, troveManagerAddress);
    }

    function _deployAndConnectCollateralContractsDev(
        IERC20Metadata _collToken,
        IfeUSDToken _feUSDToken,
        ICollateralRegistry _collateralRegistry,
        IWHYPE _whype,
        IAddressesRegistry _addressesRegistry,
        address _troveManagerAddress,
        IHintHelpers _hintHelpers,
        IMultiTroveGetter _multiTroveGetter
    ) internal returns (LiquityContractsDev  memory contracts, Zappers memory zappers) {
        LiquityContractAddresses memory addresses;
        contracts.collToken = _collToken;

        // Deploy all contracts, using testers for TM and PriceFeed
        contracts.addressesRegistry = _addressesRegistry;
        contracts.priceFeed = new PriceFeedTestnet();
        contracts.interestRouter = IInterestRouter(deployProxyNoSalt(
            address(mockInterestRouterImpl),
            abi.encodeWithSelector(mockInterestRouterImpl.initialize.selector, address(0), address(0))
        ));

        // Deploy Metadata
        MetadataNFT metadataNFT = deployMetadata(SALT, address(proxyAdmin), address(metadataNFTImpl));

        // Pre-calc addresses
        addresses.metadataNFT = getAddress(
            address(this), 
            getBytecodeProxy(
                address(metadataNFTImpl),
                abi.encodeWithSelector(MetadataNFT.initialize.selector, initializedFixedAssetReader)
            ),
            SALT
        );

        addresses.borrowerOperations = getAddress(
            address(this), 
            getBytecodeProxy(
                address(borrowerOperationsTesterImpl), 
                abi.encodeWithSelector(borrowerOperationsTesterImpl.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.troveManager = _troveManagerAddress;
        addresses.troveNFT = getAddress(
            address(this),
            getBytecodeProxy(
                address(troveNFTImpl), 
                abi.encodeWithSelector(TroveNFT.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.stabilityPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(stabilityPoolImpl), 
                abi.encodeWithSelector(StabilityPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.activePool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(activePoolImpl), 
                abi.encodeWithSelector(ActivePool.initialize.selector, contracts.addressesRegistry, SP_YIELD_SPLIT, address(this))
            ),
            SALT
        );
        addresses.defaultPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(defaultPoolImpl), 
                abi.encodeWithSelector(DefaultPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.gasPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(gasPoolImpl),
                abi.encodeWithSelector(GasPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.collSurplusPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(collSurplusPoolImpl), 
                abi.encodeWithSelector(CollSurplusPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.sortedTroves = getAddress(
            address(this), 
            getBytecodeProxy(
                address(sortedTrovesImpl),
                abi.encodeWithSelector(SortedTroves.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );

        // Deploy contracts
        IAddressesRegistry.AddressVars memory addressVars = IAddressesRegistry.AddressVars({
            collToken: _collToken,
            borrowerOperations: IBorrowerOperations(addresses.borrowerOperations),
            troveManager: ITroveManager(addresses.troveManager),
            troveNFT: ITroveNFT(addresses.troveNFT),
            metadataNFT: IMetadataNFT(addresses.metadataNFT),
            stabilityPool: IStabilityPool(addresses.stabilityPool),
            priceFeed: contracts.priceFeed,
            activePool: IActivePool(addresses.activePool),
            defaultPool: IDefaultPool(addresses.defaultPool),
            gasPoolAddress: addresses.gasPool,
            collSurplusPool: ICollSurplusPool(addresses.collSurplusPool),
            sortedTroves: ISortedTroves(addresses.sortedTroves),
            interestRouter: contracts.interestRouter,
            hintHelpers: _hintHelpers,
            multiTroveGetter: _multiTroveGetter,
            collateralRegistry: _collateralRegistry,
            feUSDToken: _feUSDToken,
            WHYPE: _whype
        });
        contracts.addressesRegistry.setAddresses(addressVars);

        contracts.borrowerOperations = IBorrowerOperationsTester(
            deployProxy(
                address(borrowerOperationsTesterImpl),
                abi.encodeWithSelector(borrowerOperationsTesterImpl.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.troveManager = ITroveManagerTester(
            deployProxy(
                address(troveManagerTesterImpl),
                abi.encodeWithSelector(troveManagerTesterImpl.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.troveNFT = ITroveNFT(
            deployProxy(
                address(troveNFTImpl),
                abi.encodeWithSelector(TroveNFT.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.stabilityPool = IStabilityPoolTester(
            deployProxy(
                address(stabilityPoolImpl),
                abi.encodeWithSelector(IStabilityPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.activePool = IActivePoolTester(
            deployProxy(
                address(activePoolImpl),
                abi.encodeWithSelector(IActivePool.initialize.selector, contracts.addressesRegistry, SP_YIELD_SPLIT, address(this))
            )
        );

        contracts.pools.defaultPool = IDefaultPool(
            deployProxy(
                address(defaultPoolImpl),
                abi.encodeWithSelector(IDefaultPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.pools.gasPool = GasPool(
            deployProxy(
                address(gasPoolImpl),
                abi.encodeWithSelector(GasPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.pools.collSurplusPool = ICollSurplusPool(
            deployProxy(
                address(collSurplusPoolImpl),
                abi.encodeWithSelector(ICollSurplusPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.sortedTroves = ISortedTroves(
            deployProxy(
                address(sortedTrovesImpl),
                abi.encodeWithSelector(ISortedTroves.initialize.selector, contracts.addressesRegistry)
            )
        );

        assert(address(metadataNFT) == addresses.metadataNFT);
        assert(address(contracts.borrowerOperations) == addresses.borrowerOperations);
        assert(address(contracts.troveManager) == addresses.troveManager);
        assert(address(contracts.troveNFT) == addresses.troveNFT);
        assert(address(contracts.stabilityPool) == addresses.stabilityPool);
        assert(address(contracts.activePool) == addresses.activePool);
        assert(address(contracts.pools.defaultPool) == addresses.defaultPool);
        assert(address(contracts.pools.gasPool) == addresses.gasPool);
        assert(address(contracts.pools.collSurplusPool) == addresses.collSurplusPool);
        assert(address(contracts.sortedTroves) == addresses.sortedTroves);

        // Connect contracts
        _feUSDToken.setBranchAddresses(
            address(contracts.troveManager),
            address(contracts.stabilityPool),
            address(contracts.borrowerOperations),
            address(contracts.activePool)
        );

        // deploy zappers
        _deployZappers(
            contracts.addressesRegistry,
            contracts.collToken,
            _feUSDToken,
            _whype,
            contracts.priceFeed,
            ICurveStableswapNGPool(address(0)),
            false,
            zappers
        );
    }

    // Creates individual PriceFeed contracts based on oracle addresses.
    // Still uses mock collaterals rather than real mainnet WETH and LST addresses.

    function deployAndConnectContractsMainnet(TroveManagerParams[] memory _troveManagerParamsArray)
        public
        returns (DeploymentResultMainnet memory result)
    {
        DeploymentVarsMainnet memory vars;

        result.externalAddresses.ETHOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        result.externalAddresses.RETHOracle = 0x536218f9E9Eb48863970252233c8F271f554C2d0;
        result.externalAddresses.STETHOracle = 0xCfE54B5cD566aB89272946F602D76Ea879CAb4a8;
        result.externalAddresses.ETHXOracle = 0xC5f8c4aB091Be1A899214c0C3636ca33DcA0C547;
        result.externalAddresses.WSTETHToken = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
        // Redstone Oracle with CL interface
        // TODO: obtain the Chainlink market price feed and use that, when it's ready
        result.externalAddresses.OSETHOracle = 0x66ac817f997Efd114EDFcccdce99F3268557B32C;

        result.externalAddresses.RETHToken = 0xae78736Cd615f374D3085123A210448E74Fc6393;
        result.externalAddresses.StaderOracle = 0xF64bAe65f6f2a5277571143A24FaaFDFC0C2a737;
        result.externalAddresses.OsTokenVaultController = 0x2A261e60FB14586B474C208b1B7AC6D0f5000306;

        vars.oracleParams.ethUsdStalenessThreshold = _24_HOURS;
        vars.oracleParams.stEthUsdStalenessThreshold = _24_HOURS;
        vars.oracleParams.rEthEthStalenessThreshold = _48_HOURS;
        vars.oracleParams.ethXEthStalenessThreshold = _48_HOURS;
        vars.oracleParams.osEthEthStalenessThreshold = _48_HOURS;

        vars.numCollaterals = 5;
        result.contractsArray = new LiquityContracts[](vars.numCollaterals);
        result.zappersArray = new Zappers[](vars.numCollaterals);
        vars.priceFeeds = new IPriceFeed[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);
        address troveManagerAddress;

        // Price feeds
        // ETH
        vars.priceFeeds[0] = new WHYPEPriceFeed(
            address(this), result.externalAddresses.ETHOracle, vars.oracleParams.ethUsdStalenessThreshold
        );

        // RETH
        vars.priceFeeds[1] = new RETHPriceFeed(
            address(this),
            result.externalAddresses.ETHOracle,
            result.externalAddresses.RETHOracle,
            result.externalAddresses.RETHToken,
            vars.oracleParams.ethUsdStalenessThreshold,
            vars.oracleParams.rEthEthStalenessThreshold
        );

        // wstETH
        vars.priceFeeds[2] = new WSTETHPriceFeed(
            address(this),
            result.externalAddresses.STETHOracle,
            vars.oracleParams.stEthUsdStalenessThreshold,
            result.externalAddresses.WSTETHToken
        );

        // ETHx
        vars.priceFeeds[3] = new ETHXPriceFeed(
            address(this),
            result.externalAddresses.ETHOracle,
            result.externalAddresses.ETHXOracle,
            result.externalAddresses.StaderOracle,
            vars.oracleParams.ethUsdStalenessThreshold,
            vars.oracleParams.ethXEthStalenessThreshold
        );

        // osETH
        vars.priceFeeds[4] = new OSETHPriceFeed(
            address(this),
            result.externalAddresses.ETHOracle,
            result.externalAddresses.OSETHOracle,
            result.externalAddresses.OsTokenVaultController,
            vars.oracleParams.ethUsdStalenessThreshold,
            vars.oracleParams.osEthEthStalenessThreshold
        );

        // Deploy feUSD
        vars.bytecode = getBytecodeProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        );
        vars.feUSDTokenAddress = getAddress(address(this), vars.bytecode, SALT);
        result.feUSDToken = IfeUSDToken(deployProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        ));
        assert(address(result.feUSDToken) == vars.feUSDTokenAddress);

        // WETH
        vars.collaterals[0] = WHYPE_MAINNET;
        (vars.addressesRegistries[0], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[0]);
        vars.troveManagers[0] = ITroveManager(troveManagerAddress);

        // RETH
        vars.collaterals[1] = IERC20Metadata(0xae78736Cd615f374D3085123A210448E74Fc6393);
        (vars.addressesRegistries[1], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[1]);
        vars.troveManagers[1] = ITroveManager(troveManagerAddress);

        // WSTETH
        vars.collaterals[2] = IERC20Metadata(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
        (vars.addressesRegistries[2], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[2]);
        vars.troveManagers[2] = ITroveManager(troveManagerAddress);

        // ETHX
        vars.collaterals[3] = IERC20Metadata(0xA35b1B31Ce002FBF2058D22F30f95D405200A15b);
        (vars.addressesRegistries[3], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[3]);
        vars.troveManagers[3] = ITroveManager(troveManagerAddress);

        // OSETH
        vars.collaterals[4] = IERC20Metadata(0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38);
        (vars.addressesRegistries[4], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[4]);
        vars.troveManagers[4] = ITroveManager(troveManagerAddress);

        // Deploy registry and register the TMs
        result.collateralRegistry = ICollateralRegistry(
            deployProxyNoSalt(
                address(collateralRegistryImpl),
                abi.encodeWithSelector(
                    CollateralRegistry.initialize.selector,
                    result.feUSDToken,
                    vars.collaterals,
                    vars.troveManagers,
                    address(this)
                )
            )
        );

        result.hintHelpers = HintHelpers(
            deployProxy(
                address(hintHelpersImpl),
                abi.encodeWithSelector(HintHelpers.initialize.selector, result.collateralRegistry)
            )
        );

        result.multiTroveGetter = MultiTroveGetter(
            deployProxy(
                address(multiTroveGetterImpl),
                abi.encodeWithSelector(MultiTroveGetter.initialize.selector, result.collateralRegistry)
            )
        );


        ICurveStableswapNGPool usdcCurvePool = _deployCurvefeUSDUsdcPool(result.feUSDToken, true);

        // Deploy each set of core contracts
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            DeploymentParamsMainnet memory params;
            params.collToken = vars.collaterals[vars.i];
            params.priceFeed = vars.priceFeeds[vars.i];
            params.feUSDToken = result.feUSDToken;
            params.collateralRegistry = result.collateralRegistry;
            params.whype = WHYPE_MAINNET;
            params.addressesRegistry = vars.addressesRegistries[vars.i];
            params.troveManagerAddress = address(vars.troveManagers[vars.i]);
            params.hintHelpers = result.hintHelpers;
            params.multiTroveGetter = result.multiTroveGetter;
            params.usdcCurvePool = usdcCurvePool;
            (result.contractsArray[vars.i], result.zappersArray[vars.i]) =
                _deployAndConnectCollateralContractsMainnet(params);
        }

        result.feUSDToken.setCollateralRegistry(address(result.collateralRegistry));
    }

    function deployAndConnectContractsHLTestnet(TroveManagerParams[] memory _troveManagerParamsArray)
        public
        returns (DeploymentResultMainnet memory result)
    {
        DeploymentVarsMainnet memory vars;

        vars.numCollaterals = 1;
        result.contractsArray = new LiquityContracts[](vars.numCollaterals);
        result.zappersArray = new Zappers[](vars.numCollaterals);
        vars.priceFeeds = new IPriceFeed[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);
        address troveManagerAddress;

        // Deploy feUSD
        vars.bytecode = getBytecodeProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        );
        vars.feUSDTokenAddress = getAddress(address(this), vars.bytecode, SALT);
        result.feUSDToken = IfeUSDToken(deployProxy(
            address(feUSDTokenImpl),
            abi.encodeWithSelector(feUSDToken.initialize.selector, address(this))
        ));
        assert(address(result.feUSDToken) == vars.feUSDTokenAddress);
        // WHYPE
        vars.collaterals[0] = new WHYPETester(
            100 ether, //     _tapAmount
            1 days //         _tapPeriod
        );
        (vars.addressesRegistries[0], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[0]);
        vars.troveManagers[0] = ITroveManager(troveManagerAddress);

        // Price feeds
        // ETH
        vars.priceFeeds[0] = IPriceFeed(
            deployProxyNoSalt(
                address(hlPriceFeedImpl),
                abi.encodeWithSelector(
                    HLPriceFeed.initialize.selector,
                    HL_ETH_FEED_L1_INDEX,
                    HL_ETH_FEED_SZ_DECIMALS,
                    getAddress(
                        address(this), 
                        getBytecodeProxy(
                            address(borrowerOperationsTesterImpl), 
                            abi.encodeWithSelector(borrowerOperationsTesterImpl.initialize.selector, vars.addressesRegistries[0])
                        ),
                        SALT
                    )
                )
            )
        );

        // Deploy registry and register the TMs
        result.collateralRegistry = ICollateralRegistry(
            deployProxyNoSalt(
                address(collateralRegistryImpl),
                abi.encodeWithSelector(
                    CollateralRegistry.initialize.selector,
                    result.feUSDToken,
                    vars.collaterals,
                    vars.troveManagers,
                    address(this)
                )
            )
        );

        result.hintHelpers = HintHelpers(
            deployProxy(
                address(hintHelpersImpl),
                abi.encodeWithSelector(HintHelpers.initialize.selector, result.collateralRegistry)
            )
        );

        result.multiTroveGetter = MultiTroveGetter(
            deployProxy(
                address(multiTroveGetterImpl),
                abi.encodeWithSelector(MultiTroveGetter.initialize.selector, result.collateralRegistry)
            )
        );
        
        result.feUSDToken.setCollateralRegistry(address(result.collateralRegistry));

        // Deploy each set of core contracts
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            DeploymentParamsMainnet memory params;
            params.collToken = vars.collaterals[vars.i];
            params.priceFeed = vars.priceFeeds[vars.i];
            params.feUSDToken = result.feUSDToken;
            params.collateralRegistry = result.collateralRegistry;
            params.whype = IWHYPE(address(vars.collaterals[0]));
            params.addressesRegistry = vars.addressesRegistries[vars.i];
            params.troveManagerAddress = address(vars.troveManagers[vars.i]);
            params.hintHelpers = result.hintHelpers;
            params.multiTroveGetter = result.multiTroveGetter;
            (result.contractsArray[vars.i], result.zappersArray[vars.i]) =
                _deployAndConnectCollateralContractsMainnet(params);
        }

    }

    function _deployAddressesRegistryMainnet(TroveManagerParams memory _troveManagerParams)
        internal
        returns (IAddressesRegistry, address)
    {
        bytes memory data = abi.encodeWithSelector(
            IAddressesRegistry.initialize.selector,
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION,
            _troveManagerParams.maxDebtCap
        );

        IAddressesRegistry addressesRegistry = IAddressesRegistry(
            deployProxyNoSalt(address(addressesRegistryImpl), data)
        );

        address troveManagerAddress = getAddress(
            address(this), 
            getBytecodeProxy(
                address(troveManagerImpl), 
                abi.encodeWithSelector(TroveManager.initialize.selector, addressesRegistry)
            ), 
            SALT
        );

        return (addressesRegistry, troveManagerAddress);
    }

    function _deployAndConnectCollateralContractsMainnet(DeploymentParamsMainnet memory _params)
        internal
        returns (LiquityContracts memory contracts, Zappers memory zappers)
    {
        LiquityContractAddresses memory addresses;
        contracts.collToken = _params.collToken;
        contracts.priceFeed = _params.priceFeed;
        contracts.interestRouter = IInterestRouter(deployProxyNoSalt(
            address(mockInterestRouterImpl),
            abi.encodeWithSelector(mockInterestRouterImpl.initialize.selector, address(0), address(0))
        ));

        contracts.addressesRegistry = _params.addressesRegistry;

        // Deploy Metadata
        MetadataNFT metadataNFT = deployMetadata(SALT, address(proxyAdmin), address(metadataNFTImpl));
        
        // Pre-calc addresses
        addresses.metadataNFT = getAddress(
            address(this),
            getBytecodeProxy(
                address(metadataNFTImpl),
                abi.encodeWithSelector(MetadataNFT.initialize.selector, initializedFixedAssetReader)
            ),
            SALT
        );

        addresses.borrowerOperations = getAddress(
            address(this), 
            getBytecodeProxy(
                address(borrowerOperationsTesterImpl), 
                abi.encodeWithSelector(borrowerOperationsTesterImpl.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.troveManager = _params.troveManagerAddress;
        addresses.troveNFT = getAddress(
            address(this),
            getBytecodeProxy(
                address(troveNFTImpl), 
                abi.encodeWithSelector(TroveNFT.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.stabilityPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(stabilityPoolImpl), 
                abi.encodeWithSelector(StabilityPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.activePool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(activePoolImpl), 
                abi.encodeWithSelector(ActivePool.initialize.selector, contracts.addressesRegistry, SP_YIELD_SPLIT, address(this))
            ),
            SALT
        );
        addresses.defaultPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(defaultPoolImpl), 
                abi.encodeWithSelector(DefaultPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.gasPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(gasPoolImpl),
                abi.encodeWithSelector(GasPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.collSurplusPool = getAddress(
            address(this), 
            getBytecodeProxy(
                address(collSurplusPoolImpl), 
                abi.encodeWithSelector(CollSurplusPool.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );
        addresses.sortedTroves = getAddress(
            address(this), 
            getBytecodeProxy(
                address(sortedTrovesImpl),
                abi.encodeWithSelector(SortedTroves.initialize.selector, contracts.addressesRegistry)
            ),
            SALT
        );

        // Deploy contracts
        IAddressesRegistry.AddressVars memory addressVars = IAddressesRegistry.AddressVars({
            collToken: _params.collToken,
            borrowerOperations: IBorrowerOperations(addresses.borrowerOperations),
            troveManager: ITroveManager(addresses.troveManager),
            troveNFT: ITroveNFT(addresses.troveNFT),
            metadataNFT: IMetadataNFT(addresses.metadataNFT),
            stabilityPool: IStabilityPool(addresses.stabilityPool),
            priceFeed: contracts.priceFeed,
            activePool: IActivePool(addresses.activePool),
            defaultPool: IDefaultPool(addresses.defaultPool),
            gasPoolAddress: addresses.gasPool,
            collSurplusPool: ICollSurplusPool(addresses.collSurplusPool),
            sortedTroves: ISortedTroves(addresses.sortedTroves),
            interestRouter: contracts.interestRouter,
            hintHelpers: _params.hintHelpers,
            multiTroveGetter: _params.multiTroveGetter,
            collateralRegistry: _params.collateralRegistry,
            feUSDToken: _params.feUSDToken,
            WHYPE: _params.whype
        });
        contracts.addressesRegistry.setAddresses(addressVars);

        contracts.borrowerOperations = IBorrowerOperationsTester(
            deployProxy(
                address(borrowerOperationsTesterImpl),
                abi.encodeWithSelector(borrowerOperationsTesterImpl.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.troveManager = ITroveManager(
            deployProxy(
                address(troveManagerImpl),
                abi.encodeWithSelector(ITroveManager.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.troveNFT = ITroveNFT(
            deployProxy(
                address(troveNFTImpl),
                abi.encodeWithSelector(TroveNFT.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.stabilityPool = IStabilityPoolTester(
            deployProxy(
                address(stabilityPoolImpl),
                abi.encodeWithSelector(IStabilityPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.activePool = IActivePoolTester(
            deployProxy(
                address(activePoolImpl),
                abi.encodeWithSelector(IActivePool.initialize.selector, contracts.addressesRegistry, SP_YIELD_SPLIT, address(this))
            )
        );

        contracts.defaultPool = IDefaultPool(
            deployProxy(
                address(defaultPoolImpl),
                abi.encodeWithSelector(IDefaultPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.gasPool = GasPool(
            deployProxy(
                address(gasPoolImpl),
                abi.encodeWithSelector(GasPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.collSurplusPool = ICollSurplusPool(
            deployProxy(
                address(collSurplusPoolImpl),
                abi.encodeWithSelector(ICollSurplusPool.initialize.selector, contracts.addressesRegistry)
            )
        );

        contracts.sortedTroves = ISortedTroves(
            deployProxy(
                address(sortedTrovesImpl),
                abi.encodeWithSelector(ISortedTroves.initialize.selector, contracts.addressesRegistry)
            )
        );

        assert(address(metadataNFT) == addresses.metadataNFT);
        assert(address(contracts.borrowerOperations) == addresses.borrowerOperations);
        assert(address(contracts.troveManager) == addresses.troveManager);
        assert(address(contracts.troveNFT) == addresses.troveNFT);
        assert(address(contracts.stabilityPool) == addresses.stabilityPool);
        assert(address(contracts.activePool) == addresses.activePool);
        assert(address(contracts.defaultPool) == addresses.defaultPool);
        assert(address(contracts.gasPool) == addresses.gasPool);
        assert(address(contracts.collSurplusPool) == addresses.collSurplusPool);
        assert(address(contracts.sortedTroves) == addresses.sortedTroves);

        // Connect contracts
        _params.feUSDToken.setBranchAddresses(
            address(contracts.troveManager),
            address(contracts.stabilityPool),
            address(contracts.borrowerOperations),
            address(contracts.activePool)
        );

        // TODO: remove this and set address in constructor as per the CREATE2 approach above
        _params.priceFeed.setAddresses(addresses.borrowerOperations);

        // If _whype is not the mainnet WHYPE, don't deploy zappers
        if (_params.whype == WHYPE_MAINNET) {
            // deploy zappers
            _deployZappers(
                contracts.addressesRegistry,
                contracts.collToken,
                _params.feUSDToken,
                _params.whype,
                contracts.priceFeed,
                _params.usdcCurvePool,
                true,
                zappers
            );
        }
    }

    function _deployZappers(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IfeUSDToken _feUSDToken,
        IWHYPE _whype,
        IPriceFeed _priceFeed,
        ICurveStableswapNGPool _usdcCurvePool,
        bool _mainnet,
        Zappers memory zappers // result
    ) internal {
        IFlashLoanProvider flashLoanProvider = new BalancerFlashLoan();
        IExchange curveExchange = _deployCurveExchange(_collToken, _feUSDToken, _priceFeed, _mainnet);

        // TODO: Deploy base zappers versions with Uni V3 exchange
        bool lst = _collToken != _whype;
        if (lst) {
            zappers.gasCompZapper = GasCompZapper(payable(
                deployProxyNoSalt(
                    address(gasCompZapperImpl),
                    abi.encodeWithSelector(GasCompZapper.initialize.selector, _addressesRegistry, flashLoanProvider, curveExchange)
                )
            ));
        } else {
            zappers.whypeZapper = WHYPEZapper(payable(
                deployProxyNoSalt(
                    address(whypeZapperImpl),
                    abi.encodeWithSelector(WHYPEZapper.initialize.selector, _addressesRegistry, flashLoanProvider, curveExchange)
                )
            ));
        }

        if (_mainnet) {
            _deployLeverageZappers(
                _addressesRegistry,
                _collToken,
                _feUSDToken,
                _priceFeed,
                flashLoanProvider,
                curveExchange,
                _usdcCurvePool,
                lst,
                zappers
            );
        }
    }

    function _deployCurveExchange(IERC20 _collToken, IfeUSDToken _feUSDToken, IPriceFeed _priceFeed, bool _mainnet)
        internal
        returns (IExchange)
    {
        if (!_mainnet) return new CurveExchange(_collToken, _feUSDToken, ICurvePool(address(0)), 1, 0);

        (uint256 price,) = _priceFeed.fetchPrice();

        // deploy Curve Twocrypto NG pool
        address[2] memory coins;
        coins[feUSD_TOKEN_INDEX] = address(_feUSDToken);
        coins[COLL_TOKEN_INDEX] = address(_collToken);
        ICurvePool curvePool = curveFactory.deploy_pool(
            "LST-feUSD pool",
            "LSTfeUSD",
            coins,
            0, // implementation id
            400000, // A
            145000000000000, // gamma
            26000000, // mid_fee
            45000000, // out_fee
            230000000000000, // fee_gamma
            2000000000000, // allowed_extra_profit
            146000000000000, // adjustment_step
            600, // ma_exp_time
            price // initial_price
        );

        IExchange curveExchange = new CurveExchange(_collToken, _feUSDToken, curvePool, 1, 0);

        return curveExchange;
    }

    function _deployLeverageZappers(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IfeUSDToken _feUSDToken,
        IPriceFeed _priceFeed,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _curveExchange,
        ICurveStableswapNGPool _usdcCurvePool,
        bool _lst,
        Zappers memory zappers // result
    ) internal {
        zappers.leverageZapperCurve =
            _deployCurveLeverageZapper(_addressesRegistry, _flashLoanProvider, _curveExchange, _lst);
        zappers.leverageZapperUniV3 =
            _deployUniV3LeverageZapper(_addressesRegistry, _collToken, _feUSDToken, _priceFeed, _flashLoanProvider, _lst);
        zappers.leverageZapperHybrid = _deployHybridLeverageZapper(
            _addressesRegistry, _collToken, _feUSDToken, _flashLoanProvider, _usdcCurvePool, _lst
        );
    }

    function _deployCurveLeverageZapper(
        IAddressesRegistry _addressesRegistry,
        IFlashLoanProvider _flashLoanProvider,
        IExchange _curveExchange,
        bool _lst
    ) internal returns (ILeverageZapper) {
        ILeverageZapper leverageZapperCurve;
        if (_lst) {
            leverageZapperCurve = LeverageLSTZapper(payable(
                deployProxyNoSalt(
                    address(leverageLSTZapperImpl),
                    abi.encodeWithSelector(
                        LeverageLSTZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        _curveExchange
                    )
                )
            ));
        } else {
            leverageZapperCurve = LeverageWHYPEZapper(payable(
                deployProxyNoSalt(
                    address(leverageWHYPEZapperImpl),
                    abi.encodeWithSelector(
                        LeverageWHYPEZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        _curveExchange
                    )
                )
            ));
        }

        return leverageZapperCurve;
    }

    struct UniV3Vars {
        IExchange uniV3Exchange;
        uint256 price;
        address[2] tokens;
    }

    function _deployUniV3LeverageZapper(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IfeUSDToken _feUSDToken,
        IPriceFeed _priceFeed,
        IFlashLoanProvider _flashLoanProvider,
        bool _lst
    ) internal returns (ILeverageZapper leverageZapperUniV3) {
        UniV3Vars memory vars;
        vars.uniV3Exchange = new UniV3Exchange(_collToken, _feUSDToken, UNIV3_FEE, uniV3Router);
        if (_lst) {
            leverageZapperUniV3 = LeverageLSTZapper(payable(
                deployProxyNoSalt(
                    address(leverageLSTZapperImpl),
                    abi.encodeWithSelector(
                        LeverageLSTZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        vars.uniV3Exchange
                    )
                )
            ));
        } else {
            leverageZapperUniV3 = LeverageWHYPEZapper(payable(
                deployProxyNoSalt(
                    address(leverageWHYPEZapperImpl),
                    abi.encodeWithSelector(
                        LeverageWHYPEZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        vars.uniV3Exchange
                    )
                )
            ));
        }

        // Create Uni V3 pool
        (vars.price,) = _priceFeed.fetchPrice();
        if (address(_feUSDToken) < address(_collToken)) {
            //console2.log("b < c");
            vars.tokens[0] = address(_feUSDToken);
            vars.tokens[1] = address(_collToken);
        } else {
            //console2.log("c < b");
            vars.tokens[0] = address(_collToken);
            vars.tokens[1] = address(_feUSDToken);
        }
        uniV3PositionManager.createAndInitializePoolIfNecessary(
            vars.tokens[0], // token0,
            vars.tokens[1], // token1,
            UNIV3_FEE, // fee,
            UniV3Exchange(address(vars.uniV3Exchange)).priceToSqrtPrice(_feUSDToken, _collToken, vars.price) // sqrtPriceX96
        );

        return leverageZapperUniV3;
    }

    function _deployHybridLeverageZapper(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IfeUSDToken _feUSDToken,
        IFlashLoanProvider _flashLoanProvider,
        ICurveStableswapNGPool _usdcCurvePool,
        bool _lst
    ) internal returns (ILeverageZapper) {
        IExchange hybridExchange = new HybridCurveUniV3Exchange(
            _collToken,
            _feUSDToken,
            USDC,
            WETH_MAINNET,
            _usdcCurvePool,
            USDC_INDEX, // USDC Curve pool index
            feUSD_TOKEN_INDEX, // feUSD Curve pool index
            UNIV3_FEE_USDC_WETH,
            UNIV3_FEE_WETH_COLL,
            uniV3Router
        );

        ILeverageZapper leverageZapperHybrid;
        if (_lst) {
            leverageZapperHybrid = LeverageLSTZapper(payable(
                deployProxyNoSalt(
                    address(leverageLSTZapperImpl),
                    abi.encodeWithSelector(
                        LeverageLSTZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        hybridExchange
                    )
                )
            ));
        } else {
            leverageZapperHybrid = LeverageWHYPEZapper(payable(
                deployProxyNoSalt(
                    address(leverageWHYPEZapperImpl),
                    abi.encodeWithSelector(
                        LeverageWHYPEZapper.initialize.selector,
                        _addressesRegistry,
                        _flashLoanProvider,
                        hybridExchange
                    )
                )
            ));
        }

        return leverageZapperHybrid;
    }

    function _deployCurvefeUSDUsdcPool(IfeUSDToken _feUSDToken, bool _mainnet) internal returns (ICurveStableswapNGPool) {
        if (!_mainnet) return ICurveStableswapNGPool(address(0));

        // deploy Curve Stableswap pool
        /*
        address[2] memory coins;
        coins[feUSD_TOKEN_INDEX] = address(_feUSDToken);
        coins[USDC_INDEX] = address(USDC);
        ICurvePool curvePool = curveStableswapFactory.deploy_plain_pool(
            "USDC-feUSD pool",
            "USDCfeUSD",
            coins,
            4000, // A
            0, // asset type: USD
            1000000, // fee
            0 // implementation id
        );
        */
        // deploy Curve StableswapNG pool
        address[] memory coins = new address[](2);
        coins[feUSD_TOKEN_INDEX] = address(_feUSDToken);
        coins[USDC_INDEX] = address(USDC);
        uint8[] memory assetTypes = new uint8[](2); // 0: standard
        bytes4[] memory methodIds = new bytes4[](2);
        address[] memory oracles = new address[](2);
        ICurveStableswapNGPool curvePool = curveStableswapFactory.deploy_plain_pool(
            "USDC-feUSD",
            "USDCfeUSD",
            coins,
            4000, // A
            1000000, // fee
            20000000000, // _offpeg_fee_multiplier
            865, // _ma_exp_time
            0, // implementation id
            assetTypes,
            methodIds,
            oracles
        );

        return curvePool;
    }
}
