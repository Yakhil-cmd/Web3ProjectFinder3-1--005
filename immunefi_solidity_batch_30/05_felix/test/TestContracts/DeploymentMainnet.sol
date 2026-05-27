// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Core contracts
import {ActivePool} from "../../src/ActivePool.sol";
import {AddressesRegistry} from "../../src/AddressesRegistry.sol";
import {AdminController} from "../../src/AdminController.sol";
import {feUSDToken} from "../../src/feUSDToken.sol";
import {BorrowerOperations} from "../../src/BorrowerOperations.sol";
import {CollateralRegistry} from "../../src/CollateralRegistry.sol";
import {CollSurplusPool} from "../../src/CollSurplusPool.sol";
import {DefaultPool} from "../../src/DefaultPool.sol";
import {GasPool} from "../../src/GasPool.sol";
import {HintHelpers} from "../../src/HintHelpers.sol";
import {MultiTroveGetter} from "../../src/MultiTroveGetter.sol";
import {HLPriceFeed} from "../../src/PriceFeeds/HLPriceFeed.sol";
import {WHYPERedStonePriceFeed} from "../../src/PriceFeeds/WHYPERedStonePriceFeed.sol";
import {SortedTroves} from "../../src/SortedTroves.sol";
import {StabilityPool} from "../../src/StabilityPool.sol";
import {TroveManager} from "../../src/TroveManager.sol";
import {TroveNFT} from "../../src/TroveNFT.sol";
import {InterestRouter} from "../../src/InterestRouter.sol";
import {InterestRouterV2} from "../../src/InterestRouterV2.sol";
import {MetadataNFT} from "../../src/NFTMetadata/MetadataNFT.sol";
import {MetadataDeployment} from "../../test/TestContracts/MetadataDeployment.sol";

// Collateral Faucets
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Interfaces
import {ITroveManager} from "../../src/Interfaces/ITroveManager.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {IAddressesRegistry} from "../../src/Interfaces/IAddressesRegistry.sol";
import {IAdminController} from "../../src/Interfaces/IAdminController.sol";
import {IfeUSDToken} from "../../src/Interfaces/IfeUSDToken.sol";
import {IMetadataNFT} from "../../src/NFTMetadata/MetadataNFT.sol";
import {ITroveNFT} from "../../src/Interfaces/ITroveNFT.sol";
import {IHintHelpers} from "../../src/Interfaces/IHintHelpers.sol";
import {IMultiTroveGetter} from "../../src/Interfaces/IMultiTroveGetter.sol";
import {IActivePool} from "../../src/Interfaces/IActivePool.sol";
import {IDefaultPool} from "../../src/Interfaces/IDefaultPool.sol";
import {ICollSurplusPool} from "../../src/Interfaces/ICollSurplusPool.sol";
import {IInterestRouter} from "../../src/Interfaces/IInterestRouter.sol";
import {IInterestRouterV2} from "../../src/Interfaces/IInterestRouterV2.sol";
import {ISortedTroves} from "../../src/Interfaces/ISortedTroves.sol";
import {IStabilityPool} from "../../src/Interfaces/IStabilityPool.sol";
import {IBorrowerOperations} from "../../src/Interfaces/IBorrowerOperations.sol";
import {IHintHelpers} from "../../src/Interfaces/IHintHelpers.sol";
import {IMultiTroveGetter} from "../../src/Interfaces/IMultiTroveGetter.sol";
import {ISortedTroves} from "../../src/Interfaces/ISortedTroves.sol";
import {IWHYPE} from "../../src/Interfaces/IWHYPE.sol";
import {IWHYPERedstonePriceFeed} from "../../src/Interfaces/IWHYPERedstonePriceFeed.sol";
import "../../src/Dependencies/Constants.sol";

// Dependencies
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from
    "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {AccessControlUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../../test/Utils/StringFormatting.sol";
import {Script, console} from "forge-std/Script.sol";

// Curve Dependencies
import {ICurveStableswapNGFactory} from "../../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGFactory.sol";
import {ICurveStableswapNGPool} from "../../src/Zappers/Modules/Exchanges/Curve/ICurveStableswapNGPool.sol";
import {ICurveXChainLiquidityGaugeFactory} from "../../src/Zappers/Modules/Exchanges/Curve/ICurveXChainLiquidityGaugeFactory.sol";
import {IGauge} from "../../src/Zappers/Modules/Exchanges/Curve/IGauge.sol";
import {CurveGaugeDistributor} from "../../src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol";



contract DeploymentMainnet is Script, MetadataDeployment {

    using Strings for *;
    using StringFormatting for *;
    
    enum Collaterals {
        WHYPE,
        COLLATERALS_LENGTH // This is used as a sentinel number
    }

    enum ContractTypes {
        ACTIVE_POOL,
        ADDRESSES_REGISTRY,
        ADMIN_CONTROLLER,
        FEUSD_TOKEN,
        BORROWER_OPERATIONS,
        COLLATERAL_REGISTRY,
        COLL_SURPLUS_POOL,
        DEFAULT_POOL,
        GAS_POOL,
        HINT_HELPERS,
        MULTI_TROVE_GETTER,
        PRICE_FEEDS,
        SORTED_TROVES,
        STABILITY_POOL,
        TROVE_MANAGER,
        TROVE_NFT,
        INTEREST_ROUTER,
        METADATA_NFT
    }

    struct CollateralParams {
        uint256 CCR;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 MCR;
        uint16 PRICE_FEED_L1_INDEX;
        uint8 PRICE_FEED_SZ_DECIMALS;
        uint256 SCR;
        address collToken;
        uint256 maxDebtCap;
        address redStonePriceFeedAddress;
    }

    struct SingletonContractAddresses {
        address feUSDToken;
        address collateralRegistry;
        address adminController;
        address hintHelpers;
        address multiTroveGetter;
        address metadataNFT;
    }

    struct DeployerInfo {
        uint256 deployerPK;
        address deployerAddress;
    }

    struct ProxyAdminAddresses {
        address proxyAdminForCoreContracts;
        address proxyAdminForAdminController;
    }

    struct CurveAddresses {
        address curvePool;
        address coin0;
        address coin1;
        address curveGauge;
        address curveGaugeDistributor;
    }

    uint8 public constant COLLATERALS_LENGTH = uint8(Collaterals.COLLATERALS_LENGTH);

    bytes32 public constant SALT = keccak256("FELIX_MAINNET_DEPLOYMENT");

    // Curve Info

    bytes32 public constant GAUGE_SALT = keccak256("curve.gauge.feUSDUSDC");
    /// @notice This address comes from https://github.com/curvefi/curve-core/blob/main/deployments/prod/hyperliquid.yaml
    ICurveStableswapNGFactory public constant CURVE_STABLESWAP_NG_FACTORY = ICurveStableswapNGFactory(0x604388Bb1159AFd21eB5191cE22b4DeCdEE2Ae22);
    /// @notice This address comes from: https://github.com/curvefi/curve-core/blob/main/deployments/prod/hyperliquid.yaml
    ICurveXChainLiquidityGaugeFactory public constant CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY = ICurveXChainLiquidityGaugeFactory(0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6);
    /// @notice This address comes from https://hyperliquid.cloud.blockscout.com/token/0xdeC702aa5a18129Bd410961215674A7A130A12e5?tab=contract
    /// @dev Double check this address
    address public constant USDC_ADDRESS = 0xdeC702aa5a18129Bd410961215674A7A130A12e5;

    // Curve Pool Infos
    string public constant POOL_NAME = "feUSD/USDC";
    string public constant POOL_SYMBOL = "feUSDCUSDC";

    /// @notice Docs: https://docs.curve.fi/factory/stableswap-ng/deployer-api/#a-fee-off-peg-fee-multiplier-and-ma-exp-time
    uint256 public constant A = 100;
    uint256 public constant FEE = 4000000;
    uint256 public constant OFFPEG_FEE_MULTIPLIER = 20000000000;
    uint256 public constant MA_EXP_TIME = 866;
    uint256 public constant IMPLEMENTATION_ID = 0;

    // Interest Router V2
    uint256 public constant REWARD_DESTINATIONS_LENGTH = 1;
    bytes4 public constant ZERO_BYTES4 = bytes4(0);
    uint256 public constant PERCENTAGE_DENOMINATOR = 1e18;


    // Slot Values
    // @note This is required because if we make those functions public we exceed contract size limit
    uint256 public constant GAS_POOL_SLOT_FOR_TROVE_MANAGER = 56;
    uint256 public constant COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER = 57;
    uint256 public constant FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER = 58;
    uint256 public constant WHYPE_SLOT_FOR_TROVE_MANAGER = 61;
    uint256 public constant MCR_SLOT_FOR_TROVE_MANAGER = 63;
    uint256 public constant SCR_SLOT_FOR_TROVE_MANAGER = 64;
    uint256 public constant LIQUIDATION_PENALTY_SP_SLOT_FOR_TROVE_MANAGER = 65;
    uint256 public constant LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT_FOR_TROVE_MANAGER = 66;

    // Slots for LiquityBase
    uint256 public constant ACTIVE_POOL_SLOT_FOR_LQ_BASE = 0;
    uint256 public constant ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE = 16;
    uint256 public constant DEFAULT_POOL_SLOT_FOR_LQ_BASE = 1;
    uint256 public constant PRICE_FEED_SLOT_FOR_LQ_BASE = 2;

    bool public constant IS_REDSTONE_PRICE_FEED = true;

    uint256 public SP_YIELD_SP;

    DeployerInfo public deployerInfo;
    ProxyAdminAddresses public proxyAdminAddresses;

    address public multiSigWallet;

    // Singleton contracts
    SingletonContractAddresses public singletonContractAddresses;

    // Curve Contracts
    CurveAddresses public curveAddresses;

    // Branch contracts
    mapping(Collaterals => mapping(ContractTypes => address)) public branchContractAddresses;

    mapping(Collaterals => CollateralParams) public collateralParams;
    mapping(ContractTypes => address) public contractImplementationAddresses;

    function run() public {
        _setUpDeployerPkAndAddress();
        _setUpMultiSigWallet();
        _startBroadcasting();
        _setUpCollateralParams();
        _setSPYieldSplit();
        _deployContractImplementation();
        _deployProxyAdmins();
        _deployAddressesRegistries();
        _deploySingletonContracts();
        _setCollateralRegistryForAdminControllerAndfeUSDToken();
        _deployCorrectPriceFeed(); // based on IS_REDSTONE_PRICE_FEED
        // _deployCurvePool();
        // _deployCurveGauge();
        _deployInterestRouters();
        _deployCurveGaugeDistributor();
        // _setCurveGaugeDistributorInterestRouter();
        // _setCurveGaugeReward();
        // _transferCurveGaugeOwnership();
        _setAddressesRegistryAddressesForEachBranch();
        _deployCoreContracts();
        _setBranchAddressesForfeUSDToken();
        _setAddressesRegistriesForAdminController();
        _transferOwnershipOfProxyAdminToAdminControllerAndProxyAdminForAdminControllerToMultiSigWallet();
        _transferOwnershipOfCollateralRegistryToAdminController();
        _setMultiSigAsDefaultAdminForAdminControllerAndRenounceRole();
        _stopBroadcasting();
        _performSanityChecksOnfeUSDToken();
        _performSanityChecksOnCollateralRegistry();
        _performSanityChecksOnCriticalParamsForBorrowerOperations();
        _performSanityChecksOnActivePool();
        _performSanityChecksOnHintHelpers();
        _performSanityChecksOnCollSurplusPool();
        _performSanityChecksOnDefaultPool();
        _performSanityChecksOnGasPool();
        _performSanityChecksOnMultiTroveGetter();
        _performSanityChecksOnSortedTroves();
        _performSanityChecksOnStabilityPool();
        _performSanityChecksOnTroveManager();
        _performSanityChecksOnTroveNFT();
        //_createManifestJson();
    }

    function _setUpDeployerPkAndAddress() internal {
        deployerInfo.deployerPK = vm.envUint("DEPLOYER");
        deployerInfo.deployerAddress = vm.addr(deployerInfo.deployerPK);
    }

    function _setUpMultiSigWallet() internal {
        multiSigWallet = vm.envAddress("MULTI_SIG_WALLET");
    }

    function _setUpCollateralParams() internal {
        CollateralParams[] memory _collateralParams = _readCollateralParams();
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            collateralParams[Collaterals(i)] = _collateralParams[i];
        }
    }

    function _deployContractImplementation() internal {
        contractImplementationAddresses[ContractTypes.ACTIVE_POOL] = address(new ActivePool());
        contractImplementationAddresses[ContractTypes.ADDRESSES_REGISTRY] = address(new AddressesRegistry());
        contractImplementationAddresses[ContractTypes.ADMIN_CONTROLLER] = address(new AdminController());
        contractImplementationAddresses[ContractTypes.FEUSD_TOKEN] = address(new feUSDToken());
        contractImplementationAddresses[ContractTypes.BORROWER_OPERATIONS] = address(new BorrowerOperations());
        contractImplementationAddresses[ContractTypes.COLLATERAL_REGISTRY] = address(new CollateralRegistry());
        contractImplementationAddresses[ContractTypes.COLL_SURPLUS_POOL] = address(new CollSurplusPool());
        contractImplementationAddresses[ContractTypes.DEFAULT_POOL] = address(new DefaultPool());
        contractImplementationAddresses[ContractTypes.GAS_POOL] = address(new GasPool());
        contractImplementationAddresses[ContractTypes.HINT_HELPERS] = address(new HintHelpers());
        contractImplementationAddresses[ContractTypes.MULTI_TROVE_GETTER] = address(new MultiTroveGetter());
        contractImplementationAddresses[ContractTypes.PRICE_FEEDS] = _deployCorrectPriceFeedImplementation();
        contractImplementationAddresses[ContractTypes.SORTED_TROVES] = address(new SortedTroves());
        contractImplementationAddresses[ContractTypes.STABILITY_POOL] = address(new StabilityPool());
        contractImplementationAddresses[ContractTypes.TROVE_MANAGER] = address(new TroveManager());
        contractImplementationAddresses[ContractTypes.TROVE_NFT] = address(new TroveNFT());
        contractImplementationAddresses[ContractTypes.INTEREST_ROUTER] = address(new InterestRouterV2());
        contractImplementationAddresses[ContractTypes.METADATA_NFT] = address(new MetadataNFT());
    }

    function _deployProxyAdmins() internal {
        proxyAdminAddresses.proxyAdminForCoreContracts = address(new ProxyAdmin());
        proxyAdminAddresses.proxyAdminForAdminController = address(new ProxyAdmin());
    }

    function _deployfeUSDToken() internal {
        bytes memory _initDataForfeUSDToken =
            abi.encodeWithSelector(feUSDToken.initialize.selector, deployerInfo.deployerAddress);

        assert(deployerInfo.deployerAddress != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
        assert(contractImplementationAddresses[ContractTypes.FEUSD_TOKEN] != address(0));

        singletonContractAddresses.feUSDToken = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.FEUSD_TOKEN],
                proxyAdminAddresses.proxyAdminForCoreContracts,
                _initDataForfeUSDToken
            )
        );
    }

    function _deployCollateralRegistry() internal {
        IfeUSDToken _feUSDToken = IfeUSDToken(singletonContractAddresses.feUSDToken);
        IERC20Metadata[] memory _tokens = _buildCollateralsArray();
        ITroveManager[] memory _troveManagers = _buildTroveManagerAddressesArray();

        bytes memory _initDataForCollateralRegistry = abi.encodeWithSelector(
            CollateralRegistry.initialize.selector, _feUSDToken, _tokens, _troveManagers, deployerInfo.deployerAddress
        );

        assert(address(_feUSDToken) != address(0));
        assert(contractImplementationAddresses[ContractTypes.COLLATERAL_REGISTRY] != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
        assert(deployerInfo.deployerAddress != address(0));

        singletonContractAddresses.collateralRegistry = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.COLLATERAL_REGISTRY],
                proxyAdminAddresses.proxyAdminForCoreContracts,
                _initDataForCollateralRegistry
            )
        );
    }

    function _deployAdminController() internal {
        bytes memory _initDataForAdminController = abi.encodeWithSelector(
            AdminController.initialize.selector,
            deployerInfo.deployerAddress,
            proxyAdminAddresses.proxyAdminForCoreContracts
        );
        assert(deployerInfo.deployerAddress != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
        assert(contractImplementationAddresses[ContractTypes.ADMIN_CONTROLLER] != address(0));
        assert(proxyAdminAddresses.proxyAdminForAdminController != address(0));

        singletonContractAddresses.adminController = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.ADMIN_CONTROLLER],
                proxyAdminAddresses.proxyAdminForAdminController,
                _initDataForAdminController
            )
        );
    }

    function _deployHintHelpers() internal {
        bytes memory _initDataForHintHelpers =
            abi.encodeWithSelector(HintHelpers.initialize.selector, singletonContractAddresses.collateralRegistry);
        
        assert(singletonContractAddresses.collateralRegistry != address(0));
        assert(contractImplementationAddresses[ContractTypes.HINT_HELPERS] != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));

        singletonContractAddresses.hintHelpers = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.HINT_HELPERS],
                proxyAdminAddresses.proxyAdminForCoreContracts,
                _initDataForHintHelpers
            )
        );
    }

    function _deployMultiTroveGetter() internal {
        bytes memory _initDataForMultiTroveGetter =
            abi.encodeWithSelector(MultiTroveGetter.initialize.selector, singletonContractAddresses.collateralRegistry);

        assert(singletonContractAddresses.collateralRegistry != address(0));
        assert(contractImplementationAddresses[ContractTypes.MULTI_TROVE_GETTER] != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));

        singletonContractAddresses.multiTroveGetter = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.MULTI_TROVE_GETTER],
                proxyAdminAddresses.proxyAdminForCoreContracts,
                _initDataForMultiTroveGetter
            )
        );
    }

    function _deployMetadataNFT() internal {
        address _metadataNFTImpl = contractImplementationAddresses[ContractTypes.METADATA_NFT];
        assert(_metadataNFTImpl != address(0));
        assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
        assert(SALT != bytes32(0));

        MetadataNFT _metadataNFT =
            deployMetadata(SALT, address(proxyAdminAddresses.proxyAdminForCoreContracts), _metadataNFTImpl);
        singletonContractAddresses.metadataNFT = address(_metadataNFT);
    }

    function _deployCorrectPriceFeedImplementation() internal returns(address) {
        if(IS_REDSTONE_PRICE_FEED) {
            return address(new WHYPERedStonePriceFeed());
        } else {
            return address(new HLPriceFeed());
        }
    }

    function _deploySingletonContracts() internal {
        _deployfeUSDToken();
        _deployCollateralRegistry();
        _deployAdminController();
        _deployHintHelpers();
        _deployMultiTroveGetter();
        _deployMetadataNFT();
    }

    function _readCollateralParams() internal view returns (CollateralParams[] memory _collateralParams) {
        string memory collateralParamsJson = vm.readFile("trove-manager-params.json");
        bytes memory data = vm.parseJson(collateralParamsJson, ".data");
        return abi.decode(data, (CollateralParams[]));
    }

    function _buildCollateralsArray() internal view returns (IERC20Metadata[] memory _collateralFaucets) {
        _collateralFaucets = new IERC20Metadata[](COLLATERALS_LENGTH);
        _collateralFaucets[0] = IERC20Metadata(collateralParams[Collaterals.WHYPE].collToken);
        // _collateralFaucets[0] = IERC20Metadata(collateralParams[Collaterals.WETH].collToken);
        // assert(collateralParams[Collaterals.WETH].collToken != address(0));
        // _collateralFaucets[1] = IERC20Metadata(collateralParams[Collaterals.WBTC].collToken);
        // assert(collateralParams[Collaterals.WBTC].collToken != address(0));
        // _collateralFaucets[2] = IERC20Metadata(collateralParams[Collaterals.SOL].collToken);
        // assert(collateralParams[Collaterals.SOL].collToken != address(0));
        // _collateralFaucets[3] = IERC20Metadata(collateralParams[Collaterals.HYPE].collToken);
        // assert(collateralParams[Collaterals.HYPE].collToken != address(0));
        // _collateralFaucets[4] = IERC20Metadata(collateralParams[Collaterals.PURR].collToken);
        // assert(collateralParams[Collaterals.PURR].collToken != address(0));
    }

    function _buildTroveManagerAddressesArray() internal view returns (ITroveManager[] memory _troveManagers) {
        _troveManagers = new ITroveManager[](COLLATERALS_LENGTH);

        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            address _forecastedAddress = _forecastAddressForTroveManager(Collaterals(i));
            assert(_forecastedAddress != address(0));
            _troveManagers[i] = ITroveManager(_forecastedAddress);
        }
    }

    function _deployAddressesRegistries() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            CollateralParams memory _collateralParams = collateralParams[Collaterals(i)];
            // They already have checks in the initialize function
            bytes memory _initDataForAddressesRegistry = abi.encodeWithSelector( 
                AddressesRegistry.initialize.selector,
                _collateralParams.CCR,
                _collateralParams.MCR,
                _collateralParams.SCR,
                _collateralParams.LIQUIDATION_PENALTY_SP,
                _collateralParams.LIQUIDATION_PENALTY_REDISTRIBUTION,
                _collateralParams.maxDebtCap
            );
            assert(contractImplementationAddresses[ContractTypes.ADDRESSES_REGISTRY] != address(0));
            assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));

            branchContractAddresses[Collaterals(i)][ContractTypes.ADDRESSES_REGISTRY] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.ADDRESSES_REGISTRY],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForAddressesRegistry
                )
            );
        }
    }

    function _deployCorrectPriceFeed() internal {
        if(IS_REDSTONE_PRICE_FEED) {
            _deployRedStonePriceFeeds();
        } else {
            _deployPriceFeeds();
        }
    }

    function _deployRedStonePriceFeeds() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _borrowerOperations = _forecastAddressForBorrowerOperations(_collateral);
            CollateralParams memory _collateralParams = collateralParams[_collateral];

            bytes memory _initDataForRedStonePriceFeed = abi.encodeWithSelector(
                IWHYPERedstonePriceFeed.initialize.selector,
                _borrowerOperations,
                _collateralParams.redStonePriceFeedAddress
            );

            assert(_borrowerOperations != address(0));
            assert(contractImplementationAddresses[ContractTypes.PRICE_FEEDS] != address(0));
            assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
            assert(_collateralParams.redStonePriceFeedAddress != address(0));

            branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.PRICE_FEEDS],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForRedStonePriceFeed
                )
            );
        }
    }

    function _deployPriceFeeds() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            CollateralParams memory _collateralParams = collateralParams[_collateral];
            address _borrowerOperations = _forecastAddressForBorrowerOperations(_collateral);
            bytes memory _initDataForPriceFeeds = abi.encodeWithSelector(
                HLPriceFeed.initialize.selector,
                _collateralParams.PRICE_FEED_L1_INDEX,
                _collateralParams.PRICE_FEED_SZ_DECIMALS,
                _borrowerOperations
            );

            assert(_borrowerOperations != address(0));
            assert(contractImplementationAddresses[ContractTypes.PRICE_FEEDS] != address(0));
            assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));

            branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.PRICE_FEEDS],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForPriceFeeds
                )
            );
        }
    }

    function _deployInterestRouters() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            IInterestRouterV2.AllocationConfig memory _allocationConfig = _createInterestRouterAllocationConfig();
            bytes memory _initDataForInterestRouter = abi.encodeWithSelector(IInterestRouterV2.initialize.selector, singletonContractAddresses.adminController, singletonContractAddresses.feUSDToken, _allocationConfig);
            assert(contractImplementationAddresses[ContractTypes.INTEREST_ROUTER] != address(0));
            assert(proxyAdminAddresses.proxyAdminForCoreContracts != address(0));
            branchContractAddresses[_collateral][ContractTypes.INTEREST_ROUTER] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.INTEREST_ROUTER],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForInterestRouter
                )
            );
        }
    }

    function _setCollateralRegistryForAdminControllerAndfeUSDToken() internal {
        address _collateralRegistry = singletonContractAddresses.collateralRegistry;
        assert(_collateralRegistry != address(0));
        IAdminController _adminController = IAdminController(singletonContractAddresses.adminController);
        _adminController.setCollateralRegistry(_collateralRegistry);
        IfeUSDToken _feUSDToken = IfeUSDToken(singletonContractAddresses.feUSDToken);
        _feUSDToken.setCollateralRegistry(_collateralRegistry);
    }

    function _setAddressesRegistryAddressesForEachBranch() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            _setAddressesRegistryForBranchContracts(_collateral);
        }
    }

    function _setMultiSigAsDefaultAdminForAdminControllerAndRenounceRole() internal {
        AccessControlUpgradeable _adminController = AccessControlUpgradeable(singletonContractAddresses.adminController);
        _adminController.grantRole(_adminController.DEFAULT_ADMIN_ROLE(), multiSigWallet);
        _adminController.renounceRole(_adminController.DEFAULT_ADMIN_ROLE(), deployerInfo.deployerAddress);
    }

    function _setAddressesRegistryForBranchContracts(Collaterals _collateral) internal {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        IAddressesRegistry.AddressVars memory _addressVars = IAddressesRegistry.AddressVars({
            collToken: IERC20Metadata(collateralParams[_collateral].collToken),
            borrowerOperations: IBorrowerOperations(_forecastAddressForBorrowerOperations(_collateral)),
            troveManager: ITroveManager(_forecastAddressForTroveManager(_collateral)),
            troveNFT: ITroveNFT(_forecastAddressForTroveNFT(_collateral)),
            metadataNFT: IMetadataNFT(singletonContractAddresses.metadataNFT),
            stabilityPool: IStabilityPool(_forecastAddressForStabilityPool(_collateral)),
            priceFeed: HLPriceFeed(branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS]), 
            activePool: IActivePool(_forecastAddressForActivePool(_collateral)),
            defaultPool: IDefaultPool(_forecastAddressForDefaultPool(_collateral)),
            gasPoolAddress: _forecastAddressForGasPool(_collateral),
            collSurplusPool: ICollSurplusPool(_forecastAddressForCollSurplusPool(_collateral)),
            sortedTroves: ISortedTroves(_forecastAddressForSortedTroves(_collateral)),
            interestRouter: IInterestRouter(branchContractAddresses[_collateral][ContractTypes.INTEREST_ROUTER]),
            hintHelpers: HintHelpers(singletonContractAddresses.hintHelpers),
            multiTroveGetter: MultiTroveGetter(singletonContractAddresses.multiTroveGetter),
            collateralRegistry: CollateralRegistry(singletonContractAddresses.collateralRegistry),
            feUSDToken: IfeUSDToken(singletonContractAddresses.feUSDToken),
            WHYPE: IWHYPE(WHYPE_ADDRESS) // Needs to be the wrapped native token maybe we'll need to change interface
        });
        assert(address(_addressesRegistry) != address(0));
        _sanitizeAddressesRegistry(_addressVars);
        IAddressesRegistry(_addressesRegistry).setAddresses(_addressVars);
    }

    function _sanitizeAddressesRegistry(IAddressesRegistry.AddressVars memory _addressVars) internal {
        assert(address(_addressVars.collToken) != address(0));
        assert(address(_addressVars.borrowerOperations) != address(0));
        assert(address(_addressVars.troveManager) != address(0));
        assert(address(_addressVars.troveNFT) != address(0));
        assert(address(_addressVars.metadataNFT) != address(0));
        assert(address(_addressVars.stabilityPool) != address(0));
        assert(address(_addressVars.priceFeed) != address(0));
        assert(address(_addressVars.activePool) != address(0));
        assert(address(_addressVars.defaultPool) != address(0));
        assert(address(_addressVars.gasPoolAddress) != address(0));
        assert(address(_addressVars.collSurplusPool) != address(0));
        assert(address(_addressVars.sortedTroves) != address(0));
        assert(address(_addressVars.interestRouter) != address(0));
        assert(address(_addressVars.hintHelpers) != address(0));
        assert(address(_addressVars.multiTroveGetter) != address(0));
        assert(address(_addressVars.collateralRegistry) != address(0));
        assert(address(_addressVars.feUSDToken) != address(0));
        assert(address(_addressVars.WHYPE) != address(0));
    }


    function _setBranchAddressesForfeUSDToken() internal {
        IfeUSDToken _feUSDToken = IfeUSDToken(singletonContractAddresses.feUSDToken);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _troveManager = branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER];
            address _stabilityPool = branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL];
            address _borrowerOperations = branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS];
            address _activePool = branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL];
            assert(_troveManager != address(0));
            assert(_stabilityPool != address(0));
            assert(_borrowerOperations != address(0));
            assert(_activePool != address(0));
            _feUSDToken.setBranchAddresses(_troveManager, _stabilityPool, _borrowerOperations, _activePool);
        }
    }

    function _setAddressesRegistriesForAdminController() internal {
        IAdminController _adminController = IAdminController(singletonContractAddresses.adminController);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
            assert(_addressesRegistry != address(0));
            _adminController.addAddressRegistry(IAddressesRegistry(_addressesRegistry));
        }
    }

    function _deployCoreContracts() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            _deployCoreContractsForOneBranch(Collaterals(i));
        }
    }

    function _deployCoreContractsForOneBranch(Collaterals _collareral) internal {
        address _addressesRegistry = branchContractAddresses[_collareral][ContractTypes.ADDRESSES_REGISTRY];
        _deployBorrowerOperations(_addressesRegistry, _collareral);
        _deployTroveManager(_addressesRegistry, _collareral);
        _deployTroveNFT(_addressesRegistry, _collareral);
        _deployStabilityPool(_addressesRegistry, _collareral);
        _deployActivePool(_addressesRegistry, _collareral);
        _deployDefaultPool(_addressesRegistry, _collareral);
        _deployGasPool(_addressesRegistry, _collareral);
        _deployCollSurplusPool(_addressesRegistry, _collareral);
        _deploySortedTroves(_addressesRegistry, _collareral);
    }

    function _deployBorrowerOperations(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.BORROWER_OPERATIONS] = _deployProxy(
            contractImplementationAddresses[ContractTypes.BORROWER_OPERATIONS],
            abi.encodeWithSelector(BorrowerOperations.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.BORROWER_OPERATIONS]
                == _forecastAddressForBorrowerOperations(_collareral)
        );
    }

    function _deployTroveManager(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.TROVE_MANAGER] = _deployProxy(
            contractImplementationAddresses[ContractTypes.TROVE_MANAGER],
            abi.encodeWithSelector(TroveManager.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.TROVE_MANAGER]
                == _forecastAddressForTroveManager(_collareral)
        );
    }

    function _deployTroveNFT(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.TROVE_NFT] = _deployProxy(
            contractImplementationAddresses[ContractTypes.TROVE_NFT],
            abi.encodeWithSelector(TroveNFT.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.TROVE_NFT] == _forecastAddressForTroveNFT(_collareral)
        );
    }

    function _deployStabilityPool(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.STABILITY_POOL] = _deployProxy(
            contractImplementationAddresses[ContractTypes.STABILITY_POOL],
            abi.encodeWithSelector(IStabilityPool.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.STABILITY_POOL]
                == _forecastAddressForStabilityPool(_collareral)
        );
    }

    function _deployActivePool(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.ACTIVE_POOL] = _deployProxy(
            contractImplementationAddresses[ContractTypes.ACTIVE_POOL],
            abi.encodeWithSelector(IActivePool.initialize.selector, _addressesRegistry, SP_YIELD_SP)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.ACTIVE_POOL]
                == _forecastAddressForActivePool(_collareral)
        );
    }

    function _deployDefaultPool(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.DEFAULT_POOL] = _deployProxy(
            contractImplementationAddresses[ContractTypes.DEFAULT_POOL],
            abi.encodeWithSelector(IDefaultPool.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.DEFAULT_POOL]
                == _forecastAddressForDefaultPool(_collareral)
        );
    }

    function _deployGasPool(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.GAS_POOL] = _deployProxy(
            contractImplementationAddresses[ContractTypes.GAS_POOL],
            abi.encodeWithSelector(GasPool.initialize.selector, _addressesRegistry)
        );
        assert(branchContractAddresses[_collareral][ContractTypes.GAS_POOL] == _forecastAddressForGasPool(_collareral));
    }

    function _deployCollSurplusPool(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.COLL_SURPLUS_POOL] = _deployProxy(
            contractImplementationAddresses[ContractTypes.COLL_SURPLUS_POOL],
            abi.encodeWithSelector(ICollSurplusPool.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.COLL_SURPLUS_POOL]
                == _forecastAddressForCollSurplusPool(_collareral)
        );
    }

    function _deploySortedTroves(address _addressesRegistry, Collaterals _collareral) internal {
        branchContractAddresses[_collareral][ContractTypes.SORTED_TROVES] = _deployProxy(
            contractImplementationAddresses[ContractTypes.SORTED_TROVES],
            abi.encodeWithSelector(ISortedTroves.initialize.selector, _addressesRegistry)
        );
        assert(
            branchContractAddresses[_collareral][ContractTypes.SORTED_TROVES]
                == _forecastAddressForSortedTroves(_collareral)
        );
    }

    function _forecastAddressForBorrowerOperations(Collaterals _collateral)
        internal
        view
        returns (address _borrowerOperations)
    {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _borrowerOperations = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.BORROWER_OPERATIONS],
                    abi.encodeWithSelector(BorrowerOperations.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForTroveManager(Collaterals _collateral) internal view returns (address _troveManager) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _troveManager = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.TROVE_MANAGER],
                    abi.encodeWithSelector(TroveManager.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForStabilityPool(Collaterals _collateral) internal view returns (address _stabilityPool) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _stabilityPool = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.STABILITY_POOL],
                    abi.encodeWithSelector(StabilityPool.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForActivePool(Collaterals _collateral) internal view returns (address _activePool) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _activePool = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.ACTIVE_POOL],
                    abi.encodeWithSelector(IActivePool.initialize.selector, _addressesRegistry, SP_YIELD_SP)
                )
            )
        );
    }

    function _forecastAddressForDefaultPool(Collaterals _collateral) internal view returns (address _defaultPool) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _defaultPool = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.DEFAULT_POOL],
                    abi.encodeWithSelector(DefaultPool.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForGasPool(Collaterals _collateral) internal view returns (address _gasPool) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _gasPool = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.GAS_POOL],
                    abi.encodeWithSelector(GasPool.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForCollSurplusPool(Collaterals _collateral)
        internal
        view
        returns (address _collSurplusPool)
    {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _collSurplusPool = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.COLL_SURPLUS_POOL],
                    abi.encodeWithSelector(CollSurplusPool.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForSortedTroves(Collaterals _collateral) internal view returns (address _sortedTroves) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _sortedTroves = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.SORTED_TROVES],
                    abi.encodeWithSelector(SortedTroves.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForTroveNFT(Collaterals _collateral) internal view returns (address _troveNFT) {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        _troveNFT = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeProxy(
                    contractImplementationAddresses[ContractTypes.TROVE_NFT],
                    abi.encodeWithSelector(TroveNFT.initialize.selector, _addressesRegistry)
                )
            )
        );
    }

    function _forecastAddressForCurveGaugeDistributor() internal view returns (address _curveGaugeDistributor) {
        _curveGaugeDistributor = vm.computeCreate2Address(
            SALT,
            keccak256(
                _getBytecodeCurveGaugeDistributor()
            )
        );
    }

    function _transferOwnershipOfProxyAdminToAdminControllerAndProxyAdminForAdminControllerToMultiSigWallet() internal {
        address _adminController = singletonContractAddresses.adminController;
        address _proxyAdmin = proxyAdminAddresses.proxyAdminForCoreContracts;
        Ownable(_proxyAdmin).transferOwnership(_adminController);
        assert(Ownable(_proxyAdmin).owner() == _adminController);

        address _proxyAdminForAdminController = proxyAdminAddresses.proxyAdminForAdminController;
        Ownable(_proxyAdminForAdminController).transferOwnership(multiSigWallet);
        assert(Ownable(_proxyAdminForAdminController).owner() == multiSigWallet);
    }

    function _transferOwnershipOfCollateralRegistryToAdminController() internal {
        address _adminController = singletonContractAddresses.adminController;
        address _collateralRegistry = singletonContractAddresses.collateralRegistry;
        OwnableUpgradeable(_collateralRegistry).transferOwnership(_adminController);
        assert(OwnableUpgradeable(_collateralRegistry).owner() == _adminController);
    }

    function _deployProxy(address _impl, bytes memory _data) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy{salt: SALT}(
                _impl, address(proxyAdminAddresses.proxyAdminForCoreContracts), _data
            )
        );
    }

    function _getBytecodeProxy(address _impl, bytes memory _data) internal view returns (bytes memory) {
        return abi.encodePacked(
            type(TransparentUpgradeableProxy).creationCode,
            abi.encode(_impl, address(proxyAdminAddresses.proxyAdminForCoreContracts), _data)
        );
    }

    function _getBytecodeCurveGaugeDistributor() internal view returns (bytes memory) {
        return abi.encodePacked(
            type(CurveGaugeDistributor).creationCode,
            abi.encode(singletonContractAddresses.feUSDToken, deployerInfo.deployerAddress)
        );
    }

    function _setSPYieldSplit() internal {
        SP_YIELD_SP = vm.envUint("SP_YIELD_SPLIT");
    }

    function _performSanityChecksOnfeUSDToken() internal {
        IfeUSDToken _feUSDToken = IfeUSDToken(singletonContractAddresses.feUSDToken);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _troveManager = branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER];
            address _stabilityPool = branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL];
            address _borrowerOperations = branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS];
            address _activePool = branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL];
            assert(_troveManager != address(0));
            assert(_stabilityPool != address(0));
            assert(_borrowerOperations != address(0));
            assert(_activePool != address(0));
            assert(_feUSDToken.troveManagerAddresses(_troveManager));
            assert(_feUSDToken.stabilityPoolAddresses(_stabilityPool));
            assert(_feUSDToken.borrowerOperationsAddresses(_borrowerOperations));
            assert(_feUSDToken.activePoolAddresses(_activePool));
        }
    }

    function _performSanityChecksOnCollateralRegistry() internal {
        ICollateralRegistry _collateralRegistry = ICollateralRegistry(singletonContractAddresses.collateralRegistry);
        _checkCollateralTokensInCollateralRegistry(_collateralRegistry);
        _checkCollateralTroveManagersInCollateralRegistry(_collateralRegistry);
        _checkfeUSDTokenInCollateralRegistry(_collateralRegistry);
        _checkOwnerInCollateralRegistry(_collateralRegistry);
    }

    function _checkCollateralTokensInCollateralRegistry(ICollateralRegistry _collateralRegistry) internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _tokenFromParams = collateralParams[_collateral].collToken;
            address _tokenFromRegistry = address(_collateralRegistry.tokens(i));
            assert(_tokenFromParams == _tokenFromRegistry);
            assert(_tokenFromRegistry != address(0));
        }
    }

    function _checkCollateralTroveManagersInCollateralRegistry(ICollateralRegistry _collateralRegistry) internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _troveManagerDeployed = branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER];
            address _troveManagerFromRegistry = address(_collateralRegistry.troveManagers(i));
            assert(_troveManagerDeployed == _troveManagerFromRegistry);
            assert(_troveManagerFromRegistry != address(0));
        }
    }

    function _checkfeUSDTokenInCollateralRegistry(ICollateralRegistry _collateralRegistry) internal {
        address _feUSDTokenFromRegistry = address(_collateralRegistry.feUSDToken());
        address _feUSDTokenFromParams = singletonContractAddresses.feUSDToken;
        assert(_feUSDTokenFromRegistry == _feUSDTokenFromParams);
        assert(_feUSDTokenFromRegistry != address(0));
    }

    function _checkOwnerInCollateralRegistry(ICollateralRegistry _collateralRegistry) internal {
        address _ownerFromRegistry = OwnableUpgradeable(address(_collateralRegistry)).owner();
        address _ownerFromParams = singletonContractAddresses.adminController;
        assert(_ownerFromRegistry == _ownerFromParams);
        assert(_ownerFromRegistry != address(0));
    }

    function _performSanityChecksOnCriticalParamsForBorrowerOperations() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            IBorrowerOperations _borrowerOperations =
                IBorrowerOperations(branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS]);

            (
                address _borrowerOperationsActivePool,
                address _borrowerOperationsDefaultPool,
                address _borrowerOperationsPriceFeed
            ) = _getStorageValuesForLiquityBase(address(_borrowerOperations));

            address _branchPriceFeed = branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS];
            address _branchActivePool = branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL];
            address _branchDefaultPool = branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL];

            assert(_borrowerOperations.MCR() == collateralParams[_collateral].MCR);
            assert(_borrowerOperations.CCR() == collateralParams[_collateral].CCR);
            assert(_borrowerOperations.SCR() == collateralParams[_collateral].SCR);
            assert(_borrowerOperations.maxDebtCap() == collateralParams[_collateral].maxDebtCap);
            assert(_borrowerOperationsPriceFeed == _branchPriceFeed);
            assert(_borrowerOperationsPriceFeed != address(0));
            assert(_borrowerOperationsActivePool == _branchActivePool);
            assert(_borrowerOperationsActivePool != address(0));
            assert(_borrowerOperationsDefaultPool == _branchDefaultPool);
            assert(_borrowerOperationsDefaultPool != address(0));
        }
    }

    function _performSanityChecksOnActivePool() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            IActivePool _activePool = IActivePool(branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL]);
            assert(address(_activePool.collToken()) == address(collateralParams[_collateral].collToken));
            assert(
                address(_activePool.borrowerOperationsAddress())
                    == branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS]
            );
            assert(
                address(_activePool.troveManagerAddress())
                    == branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]
            );
            assert(
                address(_activePool.defaultPoolAddress())
                    == branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL]
            );
            assert(address(_activePool.feUSDToken()) == singletonContractAddresses.feUSDToken);
            assert(
                address(_activePool.interestRouter())
                    == branchContractAddresses[_collateral][ContractTypes.INTEREST_ROUTER]
            );
            assert(
                address(_activePool.stabilityPool())
                    == branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL]
            );
            assert(_activePool.SP_YIELD_SPLIT() == SP_YIELD_SP);
        }
    }

    function _performSanityChecksOnCollSurplusPool() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            ICollSurplusPool _collSurplusPool =
                ICollSurplusPool(branchContractAddresses[_collateral][ContractTypes.COLL_SURPLUS_POOL]);
            assert(address(_collSurplusPool.collToken()) == address(collateralParams[_collateral].collToken));
            assert(
                address(_collSurplusPool.borrowerOperationsAddress())
                    == branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS]
            );
            assert(
                address(_collSurplusPool.troveManagerAddress())
                    == branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]
            );
        }
    }

    function _performSanityChecksOnDefaultPool() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            IDefaultPool _defaultPool = IDefaultPool(branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL]);
            assert(address(_defaultPool.collToken()) == address(collateralParams[_collateral].collToken));
            assert(
                address(_defaultPool.troveManagerAddress())
                    == branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]
            );
            assert(
                address(_defaultPool.activePoolAddress())
                    == branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL]
            );
        }
    }

    function _performSanityChecksOnGasPool() internal {
        uint256 _maxAllowance = type(uint256).max;
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            GasPool _gasPool = GasPool(branchContractAddresses[_collateral][ContractTypes.GAS_POOL]);
            IWHYPE _whype = IWHYPE(collateralParams[Collaterals.WHYPE].collToken);
            assert(
                _whype.allowance(
                    address(_gasPool), address(branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS])
                ) == _maxAllowance
            );
            assert(
                _whype.allowance(
                    address(_gasPool), address(branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER])
                ) == _maxAllowance
            );
        }
    }

    function _performSanityChecksOnHintHelpers() internal {
        IHintHelpers _hintHelpers = IHintHelpers(singletonContractAddresses.hintHelpers);
        assert(address(_hintHelpers.collateralRegistry()) == singletonContractAddresses.collateralRegistry);
    }

    function _performSanityChecksOnMultiTroveGetter() internal {
        IMultiTroveGetter _multiTroveGetter = IMultiTroveGetter(singletonContractAddresses.multiTroveGetter);
        assert(address(_multiTroveGetter.collateralRegistry()) == singletonContractAddresses.collateralRegistry);
    }

    function _performSanityChecksOnSortedTroves() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            ISortedTroves _sortedTroves =
                ISortedTroves(branchContractAddresses[_collateral][ContractTypes.SORTED_TROVES]);
            assert(
                address(_sortedTroves.troveManager())
                    == branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]
            );
            assert(
                address(_sortedTroves.borrowerOperationsAddress())
                    == branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS]
            );
        }
    }

    function _performSanityChecksOnStabilityPool() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            StabilityPool _stabilityPool =
                StabilityPool(branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL]);

            (address _stabilityPoolActivePool, address _stabilityPoolDefaultPool, address _stabilityPoolPriceFeed) =
                _getStorageValuesForLiquityBase(address(_stabilityPool));

            address _branchTroveManager = branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER];
            address _branchfeUSDToken = singletonContractAddresses.feUSDToken;
            address _branchActivePool = branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL];
            address _branchDefaultPool = branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL];
            address _branchPriceFeed = branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS];

            assert(address(_stabilityPool.collToken()) == address(collateralParams[_collateral].collToken));
            assert(address(_stabilityPool.troveManager()) == _branchTroveManager);
            assert(address(_stabilityPool.feUSDToken()) == _branchfeUSDToken);
            assert(_stabilityPoolActivePool == _branchActivePool);
            assert(_stabilityPoolDefaultPool == _branchDefaultPool);
            assert(_stabilityPoolPriceFeed == _branchPriceFeed);
        }
    }

    function _performSanityChecksOnTroveManager() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            TroveManager _troveManager = TroveManager(branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]);

            (address _troveManagerActivePool, address _troveManagerDefaultPool, address _troveManagerPriceFeed) =
                _getStorageValuesForLiquityBase(address(_troveManager));

            (
                address _gasPool,
                address _collSurplusPool,
                address _feUSDToken,
                address _whype,
                uint256 _mcr,
                uint256 _scr,
                uint256 _liquidationPenaltySp,
                uint256 _liquidationPenaltyRedistribution
            ) = _getStorageValuesForTroveManager(address(_troveManager));

            assert(_troveManagerActivePool == branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL]);
            assert(_troveManagerDefaultPool == branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL]);
            assert(_troveManagerPriceFeed == branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS]);
            assert(_whype == address(collateralParams[Collaterals.WHYPE].collToken));
            assert(_feUSDToken == singletonContractAddresses.feUSDToken);
            assert(_gasPool == branchContractAddresses[_collateral][ContractTypes.GAS_POOL]);
            assert(_collSurplusPool == branchContractAddresses[_collateral][ContractTypes.COLL_SURPLUS_POOL]);
            assert(
                address(_troveManager.sortedTroves())
                    == branchContractAddresses[_collateral][ContractTypes.SORTED_TROVES]
            );
            assert(address(_troveManager.troveNFT()) == branchContractAddresses[_collateral][ContractTypes.TROVE_NFT]);
            assert(
                address(_troveManager.borrowerOperations())
                    == branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS]
            );
            assert(
                address(_troveManager.stabilityPool())
                    == branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL]
            );
            assert(_troveManager.CCR() == collateralParams[_collateral].CCR);
            assert(_mcr == collateralParams[_collateral].MCR);
            assert(_scr == collateralParams[_collateral].SCR);
            assert(_liquidationPenaltySp == collateralParams[_collateral].LIQUIDATION_PENALTY_SP);
            assert(
                _liquidationPenaltyRedistribution == collateralParams[_collateral].LIQUIDATION_PENALTY_REDISTRIBUTION
            );
        }
    }

    function _performSanityChecksOnTroveNFT() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            TroveNFT _troveNFT = TroveNFT(branchContractAddresses[_collateral][ContractTypes.TROVE_NFT]);
            assert(address(_troveNFT.collToken()) == address(collateralParams[_collateral].collToken));
            assert(address(_troveNFT.feUSDToken()) == singletonContractAddresses.feUSDToken);
            assert(address(_troveNFT.metadataNFT()) == singletonContractAddresses.metadataNFT);
            assert(
                address(_troveNFT.troveManager()) == branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER]
            );
        }
    }

    function _getStorageValuesForTroveManager(address _troveManager)
        internal
        view
        returns (
            address _gasPool,
            address _collSurplusPool,
            address _feUSDToken,
            address _whype,
            uint256 _mcr,
            uint256 _scr,
            uint256 _liquidationPenaltySp,
            uint256 _liquidationPenaltyRedistribution
        )
    {
        _gasPool = address(
            uint160(uint256(vm.load(address(_troveManager), bytes32(uint256(GAS_POOL_SLOT_FOR_TROVE_MANAGER)))))
        );
        _collSurplusPool = address(
            uint160(
                uint256(vm.load(address(_troveManager), bytes32(uint256(COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER))))
            )
        );
        _feUSDToken = address(
            uint160(uint256(vm.load(address(_troveManager), bytes32(uint256(FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER)))))
        );
        _whype =
            address(uint160(uint256(vm.load(address(_troveManager), bytes32(uint256(WHYPE_SLOT_FOR_TROVE_MANAGER))))));
        _mcr = uint256(vm.load(address(_troveManager), bytes32(uint256(MCR_SLOT_FOR_TROVE_MANAGER))));
        _scr = uint256(vm.load(address(_troveManager), bytes32(uint256(SCR_SLOT_FOR_TROVE_MANAGER))));
        _liquidationPenaltySp =
            uint256(vm.load(address(_troveManager), bytes32(uint256(LIQUIDATION_PENALTY_SP_SLOT_FOR_TROVE_MANAGER))));
        _liquidationPenaltyRedistribution = uint256(
            vm.load(address(_troveManager), bytes32(uint256(LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT_FOR_TROVE_MANAGER)))
        );
    }

    function _getStorageValuesForLiquityBase(address _contract)
        internal
        view
        returns (address _activePool, address _defaultPool, address _priceFeed)
    {
        _activePool = address(
            uint160(
                uint256(
                    vm.load(address(_contract), bytes32(uint256(ACTIVE_POOL_SLOT_FOR_LQ_BASE)))
                        >> ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE
                )
            )
        );
        _defaultPool =
            address(uint160(uint256(vm.load(address(_contract), bytes32(uint256(DEFAULT_POOL_SLOT_FOR_LQ_BASE))))));
        _priceFeed =
            address(uint160(uint256(vm.load(address(_contract), bytes32(uint256(PRICE_FEED_SLOT_FOR_LQ_BASE))))));
    }

    // TODO: Add sanity checks for price feeds once they work again

    function _getBranchContractsJson(Collaterals _collateral) internal returns (string memory) {
        return string.concat(
            string.concat(
            "{",
            string.concat(
                // Avoid stack too deep by chunking concats
                string.concat(
                    string.concat('"name":"', _getNameForCollateral(_collateral), '",'),
                    string.concat('"addressesRegistry":"', branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY].toHexString(), '",'),
                    string.concat('"activePool":"', branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL].toHexString(), '",'),
                    string.concat('"borrowerOperations":"', branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS].toHexString(), '",'),
                    string.concat('"collSurplusPool":"', branchContractAddresses[_collateral][ContractTypes.COLL_SURPLUS_POOL].toHexString(), '",'),
                    string.concat('"defaultPool":"', branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL].toHexString(), '",'),
                    string.concat('"sortedTroves":"', branchContractAddresses[_collateral][ContractTypes.SORTED_TROVES].toHexString(), '",'),
                    string.concat('"stabilityPool":"', branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL].toHexString(), '",'),
                    string.concat('"troveManager":"', branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER].toHexString(), '",')
                ),
                string.concat(
                    string.concat('"troveNFT":"', branchContractAddresses[_collateral][ContractTypes.TROVE_NFT].toHexString(), '",'),
                    string.concat('"priceFeed":"', branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS].toHexString(), '",'),
                    string.concat('"gasPool":"', branchContractAddresses[_collateral][ContractTypes.GAS_POOL].toHexString(), '",'),
                    string.concat('"interestRouter":"', branchContractAddresses[_collateral][ContractTypes.INTEREST_ROUTER].toHexString(), '",')
                ),
                string.concat(
                    string.concat('"collToken":"', collateralParams[_collateral].collToken.toHexString(), '"') // no comma
                )
            ),
            "}"
        ));
    }

    function _getNameForCollateral(Collaterals _collateral) internal pure returns (string memory) {

        if(_collateral == Collaterals.WHYPE) {
            return "WHYPE";
        }else {
            revert("Invalid collateral");
        }
        // if(_collateral == Collaterals.WETH) {
        //     return "ETH";
        // }else if(_collateral == Collaterals.WBTC) {
        //     return "WBTC";
        // }else if(_collateral == Collaterals.SOL) {
        //     return "SOL";
        // }else if(_collateral == Collaterals.HYPE){
        //     return "HYPE";
        // }else if(_collateral == Collaterals.PURR) {
        //     return "PURR";
        // }else {
        //     revert("Invalid collateral");
        // }
    }

    function _getDeploymentConstants() internal view returns (string memory) {
        return string.concat(
            "{",
            string.concat(
                string.concat('"ETH_GAS_COMPENSATION":"', ETH_GAS_COMPENSATION.toString(), '",'),
                string.concat('"INTEREST_RATE_ADJ_COOLDOWN":"', INTEREST_RATE_ADJ_COOLDOWN.toString(), '",'),
                string.concat('"MAX_ANNUAL_INTEREST_RATE":"', MAX_ANNUAL_INTEREST_RATE.toString(), '",'),
                string.concat('"MIN_ANNUAL_INTEREST_RATE":"', MIN_ANNUAL_INTEREST_RATE.toString(), '",'),
                string.concat('"MIN_DEBT":"', MIN_DEBT.toString(), '",'),
                string.concat('"SP_YIELD_SPLIT":"', SP_YIELD_SP.toString(), '",'),
                string.concat('"UPFRONT_INTEREST_PERIOD":"', UPFRONT_INTEREST_PERIOD.toString(), '"') // no comma
            ),
            "}"
        );
    }

    function _getManifestJson() internal returns (string memory) {
        string[] memory branches = new string[](COLLATERALS_LENGTH);

        // Poor man's .map()
        for (uint8 i = 0; i < COLLATERALS_LENGTH; ++i) {
            branches[i] = _getBranchContractsJson(Collaterals(i));
        }

        return string.concat(
            "{",
            string.concat(
                string.concat(
                '"adminController":"', singletonContractAddresses.adminController.toHexString(), '",',
                '"constants":', _getDeploymentConstants(), ",",
                '"proxyAdminForCoreContracts":"', proxyAdminAddresses.proxyAdminForCoreContracts.toHexString(), '",',
                '"proxyAdminForAdminController":"', proxyAdminAddresses.proxyAdminForAdminController.toHexString(), '",',
                '"collateralRegistry":"', singletonContractAddresses.collateralRegistry.toHexString(), '",',
                '"feUSDToken":"', singletonContractAddresses.feUSDToken.toHexString(), '",',
                '"hintHelpers":"', singletonContractAddresses.hintHelpers.toHexString(), '",',
                '"multiTroveGetter":"', singletonContractAddresses.multiTroveGetter.toHexString(), '",',
                '"metadataNFT":"', singletonContractAddresses.metadataNFT.toHexString(), '",',
                '"curvePool":"', curveAddresses.curvePool.toHexString(), '",',
                '"curveGauge":"', curveAddresses.curveGauge.toHexString(), '",',
                '"curveGaugeDistributor":"', curveAddresses.curveGaugeDistributor.toHexString(), '",'
            ),
                '"branches":[', branches.join(","), "]"
            ),
            "}"
        );
    }

    // Interest Router V2 Functions

    function _createInterestRouterAllocationConfig() internal view returns (IInterestRouterV2.AllocationConfig memory) {
        IInterestRouterV2.AllocationConfig memory _allocationConfig = IInterestRouterV2.AllocationConfig({
            rewardDestinations: _createInterestRouterDestinationsArray(),
            percentages: _createInterestRouterPercentagesArray(),
            rewardSelectors: _createInterestRouterSelectorsArray(),
            lastUpdatedTimestamp: uint256(0) // @note - This will be set later
        });
        return _allocationConfig;
    }

    function _createInterestRouterDestinationsArray() internal view returns (address[] memory) {
        address[] memory _destinations = new address[](REWARD_DESTINATIONS_LENGTH);
        _destinations[0] = _forecastAddressForCurveGaugeDistributor();
        return _destinations;
    }

    function _createInterestRouterPercentagesArray() internal view returns (uint256[] memory) {
        uint256[] memory _percentages = new uint256[](REWARD_DESTINATIONS_LENGTH);
        _percentages[0] = PERCENTAGE_DENOMINATOR;
        return _percentages;
    }

    function _createInterestRouterSelectorsArray() internal view returns (bytes4[] memory) {
        bytes4[] memory _selectors = new bytes4[](REWARD_DESTINATIONS_LENGTH);
        _selectors[0] = CurveGaugeDistributor.distributeRewardsToGauge.selector;
        return _selectors;
    }

    function _deployCurveGaugeDistributor() internal { 
        address _feUSDToken = singletonContractAddresses.feUSDToken;
        address _tempOwner = deployerInfo.deployerAddress;
        assert(_feUSDToken != address(0));
        assert(_tempOwner != address(0));
        address _gaugeDistributor = address(new CurveGaugeDistributor{salt: SALT}(_feUSDToken, _tempOwner));
        assert(_gaugeDistributor != address(0));
        assert(_gaugeDistributor == _forecastAddressForCurveGaugeDistributor());
        curveAddresses.curveGaugeDistributor = _gaugeDistributor;
    }

    function _setCurveGaugeDistributorInterestRouter() internal {
        address _gaugeDistributor = curveAddresses.curveGaugeDistributor;
        address _interestRouter = branchContractAddresses[Collaterals.WHYPE][ContractTypes.INTEREST_ROUTER];
        assert(_gaugeDistributor != address(0));
        assert(_interestRouter != address(0));
        CurveGaugeDistributor(_gaugeDistributor).setInterestRouterAndCurveGauge(_interestRouter, curveAddresses.curveGauge);
        assert(Ownable(_gaugeDistributor).owner() == address(0));
    }



    // Curve Pool Functions

    function _deployCurvePool() internal {
        ICurveStableswapNGPool _pool = CURVE_STABLESWAP_NG_FACTORY.deploy_plain_pool(
            POOL_NAME,
            POOL_SYMBOL,
            _getCoinsArrayCurvePool(),
            A,
            FEE,
            OFFPEG_FEE_MULTIPLIER,
            MA_EXP_TIME,
            IMPLEMENTATION_ID,
            _getAssetTypesArrayCurvePool(),
            _getMethodIdsArrayCurvePool(),
            _getOraclesArrayCurvePool()
        );
        address _coin0 = _pool.coins(0);
        address _coin1 = _pool.coins(1);

        assert(_coin0 == singletonContractAddresses.feUSDToken || _coin0 == USDC_ADDRESS);
        assert(_coin1 == singletonContractAddresses.feUSDToken || _coin1 == USDC_ADDRESS);
        assert(_coin0 != address(0) && _coin1 != address(0));
        assert(_coin0 != _coin1);
        assert(address(_pool) != address(0));

        // Initialize the curveAddresses struct
        curveAddresses = CurveAddresses({
            curvePool: address(_pool),
            coin0: _coin0,
            coin1: _coin1,
            curveGauge: address(0), // This will be assigned later in the script
            curveGaugeDistributor: address(0) // This will be assigned later in the script
        });
    }

    function _deployCurveGauge() internal {
        address _gauge = CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY.deploy_gauge(curveAddresses.curvePool, GAUGE_SALT, deployerInfo.deployerAddress);
        assert(_gauge != address(0));
        curveAddresses.curveGauge = _gauge;
    }

    function _setCurveGaugeReward() internal {
        address _gauge = curveAddresses.curveGauge;
        address _feUSDToken = singletonContractAddresses.feUSDToken;
        address _gaugeDistributor = curveAddresses.curveGaugeDistributor;

        IGauge(_gauge).add_reward(_feUSDToken, _gaugeDistributor);

        assert(_gaugeDistributor != address(0));
        assert(_gauge != address(0));
        assert(_feUSDToken != address(0));
    }

    function _setCurveGaugeDistributor() internal {
        address _gauge = curveAddresses.curveGauge;
        address _gaugeDistributor = curveAddresses.curveGaugeDistributor;
        address _feUSDToken = singletonContractAddresses.feUSDToken;
        assert(_gauge != address(0));
        assert(_gaugeDistributor != address(0));
        assert(_feUSDToken != address(0));
        IGauge(_gauge).set_reward_distributor(_feUSDToken, _gaugeDistributor);
    }

    function _transferCurveGaugeOwnership() internal {
        address _gauge = curveAddresses.curveGauge;
        address _adminController = singletonContractAddresses.adminController;

        IGauge(_gauge).set_gauge_manager(_adminController);

        assert(_gauge != address(0));
        assert(_adminController != address(0));
    }

    function _getCoinsArrayCurvePool() internal view returns (address[] memory) {
        address[] memory _coins = new address[](2);
        _coins[0] = singletonContractAddresses.feUSDToken;
        _coins[1] = USDC_ADDRESS;
        return _coins;
    }

    function _getAssetTypesArrayCurvePool() internal pure returns (uint8[] memory) {
        uint8[] memory _assetTypes = new uint8[](2);
        return _assetTypes;
    }

    function _getOraclesArrayCurvePool() internal pure returns (address[] memory) {
        address[] memory _oracles = new address[](2);
        return _oracles;
    }

    function _getMethodIdsArrayCurvePool() internal pure returns (bytes4[] memory) {
        bytes4[] memory _methodIds = new bytes4[](2);
        return _methodIds;
    }

    function _createManifestJson() internal {
        vm.writeFile("deployment-manifest.json", _getManifestJson());
    }

    function _startBroadcasting() internal {
        assert(deployerInfo.deployerPK != uint256(0));
        vm.startBroadcast(deployerInfo.deployerPK);
    }

    function _stopBroadcasting() internal {
        vm.stopBroadcast();
    }
}