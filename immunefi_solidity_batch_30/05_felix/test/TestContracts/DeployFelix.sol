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
import {SortedTroves} from "../../src/SortedTroves.sol";
import {StabilityPool} from "../../src/StabilityPool.sol";
import {TroveManager} from "../../src/TroveManager.sol";
import {TroveNFT} from "../../src/TroveNFT.sol";
import {MockInterestRouter} from "../../src/MockInterestRouter.sol";
import {MetadataNFT} from "../../src/NFTMetadata/MetadataNFT.sol";
import {MetadataDeployment} from "../../test/TestContracts/MetadataDeployment.sol";
import {HLPriceFeedMock} from "../../test/TestContracts/HLPriceFeedMock.sol"; // TODO: remove it when Hypeliquid fixed the price feed

// Collateral Faucets
import {ERC20Faucet} from "../../test/TestContracts/ERC20Faucet.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {WHYPETester} from "../../test/TestContracts/WHYPETester.sol";

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
import {ISortedTroves} from "../../src/Interfaces/ISortedTroves.sol";
import {IStabilityPool} from "../../src/Interfaces/IStabilityPool.sol";
import {IBorrowerOperations} from "../../src/Interfaces/IBorrowerOperations.sol";
import {IHintHelpers} from "../../src/Interfaces/IHintHelpers.sol";
import {IMultiTroveGetter} from "../../src/Interfaces/IMultiTroveGetter.sol";
import {ISortedTroves} from "../../src/Interfaces/ISortedTroves.sol";
import {IWHYPE} from "../../src/Interfaces/IWHYPE.sol";

import "../../src/Dependencies/Constants.sol";
import {MockL1Read} from "../../src/Dependencies/MockL1Read.sol";


// Dependencies
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from
    "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployFelix is Script, MetadataDeployment {


    enum Collaterals {
        WHYPE,
        COLLATERALS_LENGTH // This is used as a sentinel number
    }

    enum ContractTypes {
        ACTIVE_POOL,
        ADDRESSES_REGISTRY,
        ADMIN_CONTROLLER,
        feUSD_TOKEN,
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
        METADATA_NFT,
        PRICE_FEEDS_MOCK // TODO: remove it when Hypeliquid fixed the price feed

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

    uint8 public constant COLLATERALS_LENGTH = uint8(Collaterals.COLLATERALS_LENGTH);

    uint256 public constant COLLATERAL_TAP_AMOUNT = 1000 ether;
    uint256 public constant COLLATERAL_TAP_PERIOD = 1 minutes;
    bytes32 public constant SALT = keccak256("feUSD_TESTNET_DEPLOYMENT");

    address public constant L1READ_ADDRESS = 0x44AFB4F9134c21E3ee69c785073FE2550607CA2a;

    // Slot Values
    // @note This is required because if we make those functions public we exceed contract size limit
    uint256 public constant GAS_POOL_SLOT_FOR_TROVE_MANAGER = 56;
    uint256 public constant COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER = 57;
    uint256 public constant feUSD_TOKEN_SLOT_FOR_TROVE_MANAGER = 58;
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

    bool public constant IS_MOCK_PRICE_FEED = false;

    uint256 public SP_YIELD_SP;

    DeployerInfo public deployerInfo;
    ProxyAdminAddresses public proxyAdminAddresses;

    // Singleton contracts
    SingletonContractAddresses public singletonContractAddresses;

    // Branch contracts
    mapping(Collaterals => mapping(ContractTypes => address)) public branchContractAddresses;

    mapping(Collaterals => CollateralParams) public collateralParams;
    mapping(Collaterals => address) public collateralFaucets;
    mapping(ContractTypes => address) public contractImplementationAddresses;

    function run() public virtual {
        _setUpDeployerPkAndAddress();
        _setUpPriceFeedPrecompiled();
        vm.startBroadcast(deployerInfo.deployerPK);
        _setUpCollateralFaucets();
        _setUpCollateralParams();
        _setSPYieldSplit();
        _deployContractImplementation();
        _deployProxyAdmins();
        _deployAddressesRegistries();
        _deploySingletonContracts();
        _setCollateralRegistryForAdminControllerAndfeUSDToken();
        _deployCorrectPriceFeeds();
        _deployInterestRouters();
        _setAddressesRegistryAddressesForEachBranch();
        _deployCoreContracts();
        _setBranchAddressesForfeUSDToken();
        _setAddressesRegistriesForAdminController();
        _transferOwnershipOfProxyAdminToAdminController();
        _transferOwnershipOfCollateralRegistryToAdminController();
        vm.stopBroadcast();
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
    }

    function _setUpDeployerPkAndAddress() internal {
        deployerInfo.deployerPK = vm.envUint("DEPLOYER");
        deployerInfo.deployerAddress = vm.addr(deployerInfo.deployerPK);
    }

    function _setUpCollateralParams() internal {
        CollateralParams[] memory _collateralParams = _readCollateralParams();
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            collateralParams[Collaterals(i)] = _collateralParams[i];
            collateralParams[Collaterals(i)].collToken = collateralFaucets[Collaterals(i)];
        }
    }

    function _setUpCollateralFaucets() internal {
        collateralFaucets[Collaterals.WHYPE] =
            address(new WHYPETester(COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
        // collateralFaucets[Collaterals.WETH] = address(new WETHTester(COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
        // collateralFaucets[Collaterals.WBTC] =
        //     address(new ERC20Faucet("Wrapped BTC", "WBTC", COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
        // collateralFaucets[Collaterals.SOL] =
        //     address(new ERC20Faucet("Solana", "SOL", COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
        // collateralFaucets[Collaterals.HYPE] =
        //     address(new ERC20Faucet("Hyperliquid", "HYPE", COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
        // collateralFaucets[Collaterals.PURR] =
        //     address(new ERC20Faucet("Purr", "PURR", COLLATERAL_TAP_AMOUNT, COLLATERAL_TAP_PERIOD));
    }

    function _deployContractImplementation() internal {
        contractImplementationAddresses[ContractTypes.ACTIVE_POOL] = address(new ActivePool());
        contractImplementationAddresses[ContractTypes.ADDRESSES_REGISTRY] = address(new AddressesRegistry());
        contractImplementationAddresses[ContractTypes.ADMIN_CONTROLLER] = address(new AdminController());
        contractImplementationAddresses[ContractTypes.feUSD_TOKEN] = address(new feUSDToken());
        contractImplementationAddresses[ContractTypes.BORROWER_OPERATIONS] = address(new BorrowerOperations());
        contractImplementationAddresses[ContractTypes.COLLATERAL_REGISTRY] = address(new CollateralRegistry());
        contractImplementationAddresses[ContractTypes.COLL_SURPLUS_POOL] = address(new CollSurplusPool());
        contractImplementationAddresses[ContractTypes.DEFAULT_POOL] = address(new DefaultPool());
        contractImplementationAddresses[ContractTypes.GAS_POOL] = address(new GasPool());
        contractImplementationAddresses[ContractTypes.HINT_HELPERS] = address(new HintHelpers());
        contractImplementationAddresses[ContractTypes.MULTI_TROVE_GETTER] = address(new MultiTroveGetter());
        contractImplementationAddresses[ContractTypes.PRICE_FEEDS] = address(new HLPriceFeed());
        contractImplementationAddresses[ContractTypes.SORTED_TROVES] = address(new SortedTroves());
        contractImplementationAddresses[ContractTypes.STABILITY_POOL] = address(new StabilityPool());
        contractImplementationAddresses[ContractTypes.TROVE_MANAGER] = address(new TroveManager());
        contractImplementationAddresses[ContractTypes.TROVE_NFT] = address(new TroveNFT());
        contractImplementationAddresses[ContractTypes.INTEREST_ROUTER] = address(new MockInterestRouter());
        contractImplementationAddresses[ContractTypes.METADATA_NFT] = address(new MetadataNFT());
        contractImplementationAddresses[ContractTypes.PRICE_FEEDS_MOCK] = address(new HLPriceFeedMock()); // TODO: remove it when Hypeliquid fixed the price feed
    }

    function _deployProxyAdmins() internal {
        proxyAdminAddresses.proxyAdminForCoreContracts = address(new ProxyAdmin());
        proxyAdminAddresses.proxyAdminForAdminController = address(new ProxyAdmin());
    }

    function _deployfeUSDToken() internal {
        bytes memory _initDataForfeUSDToken =
            abi.encodeWithSelector(feUSDToken.initialize.selector, deployerInfo.deployerAddress);

        singletonContractAddresses.feUSDToken = address(
            new TransparentUpgradeableProxy(
                contractImplementationAddresses[ContractTypes.feUSD_TOKEN],
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
        MetadataNFT _metadataNFT =
            deployMetadata(SALT, address(proxyAdminAddresses.proxyAdminForCoreContracts), _metadataNFTImpl);
        singletonContractAddresses.metadataNFT = address(_metadataNFT);
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

        _collateralFaucets[0] = IERC20Metadata(collateralFaucets[Collaterals.WHYPE]);    

        // _collateralFaucets[0] = IERC20Metadata(collateralFaucets[Collaterals.WETH]);
        // _collateralFaucets[1] = IERC20Metadata(collateralFaucets[Collaterals.WBTC]);
        // _collateralFaucets[2] = IERC20Metadata(collateralFaucets[Collaterals.SOL]);
        // _collateralFaucets[3] = IERC20Metadata(collateralFaucets[Collaterals.HYPE]);
        // _collateralFaucets[4] = IERC20Metadata(collateralFaucets[Collaterals.PURR]);
    }

    function _buildTroveManagerAddressesArray() internal view returns (ITroveManager[] memory _troveManagers) {
        _troveManagers = new ITroveManager[](COLLATERALS_LENGTH);

        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            _troveManagers[i] = ITroveManager(_forecastAddressForTroveManager(Collaterals(i)));
        }
    }

    function _deployAddressesRegistries() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            CollateralParams memory _collateralParams = collateralParams[Collaterals(i)];
            bytes memory _initDataForAddressesRegistry = abi.encodeWithSelector(
                AddressesRegistry.initialize.selector,
                _collateralParams.CCR,
                _collateralParams.MCR,
                _collateralParams.SCR,
                _collateralParams.LIQUIDATION_PENALTY_SP,
                _collateralParams.LIQUIDATION_PENALTY_REDISTRIBUTION,
                _collateralParams.maxDebtCap
            );
            branchContractAddresses[Collaterals(i)][ContractTypes.ADDRESSES_REGISTRY] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.ADDRESSES_REGISTRY],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForAddressesRegistry
                )
            );
        }
    }

    function _deployCorrectPriceFeeds() internal {
        IS_MOCK_PRICE_FEED ? _deployPriceFeedsMock() : _deployPriceFeeds();
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
            branchContractAddresses[_collateral][IS_MOCK_PRICE_FEED ? ContractTypes.PRICE_FEEDS_MOCK : ContractTypes.PRICE_FEEDS] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.PRICE_FEEDS],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForPriceFeeds
                )
            );
        }
    }

    function _getCorrectPriceFeed(Collaterals _collateral) internal view returns (address _priceFeed) {
        if (IS_MOCK_PRICE_FEED) {
            return branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS_MOCK];
        }
        return branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS];
    }

    function _deployPriceFeedsMock() internal {
        // TODO: remove it when Hypeliquid fixed the price feed
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            bytes memory _initDataForPriceFeedsMock = abi.encodeWithSelector(
                HLPriceFeedMock.initialize.selector, 100 ether, false
            );
            branchContractAddresses[_collateral][ContractTypes.PRICE_FEEDS_MOCK] = address(
                new TransparentUpgradeableProxy(
                    contractImplementationAddresses[ContractTypes.PRICE_FEEDS_MOCK],
                    proxyAdminAddresses.proxyAdminForCoreContracts,
                    _initDataForPriceFeedsMock
                )
            );
        }
    }

    function _deployInterestRouters() internal {
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            bytes memory _initDataForInterestRouter = abi.encodeWithSelector(MockInterestRouter.initialize.selector, address(0), address(0));
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

    function _setAddressesRegistryForBranchContracts(Collaterals _collateral) internal {
        address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
        IAddressesRegistry.AddressVars memory _addressVars = IAddressesRegistry.AddressVars({
            collToken: IERC20Metadata(collateralParams[_collateral].collToken),
            borrowerOperations: IBorrowerOperations(_forecastAddressForBorrowerOperations(_collateral)),
            troveManager: ITroveManager(_forecastAddressForTroveManager(_collateral)),
            troveNFT: ITroveNFT(_forecastAddressForTroveNFT(_collateral)),
            metadataNFT: IMetadataNFT(singletonContractAddresses.metadataNFT),
            stabilityPool: IStabilityPool(_forecastAddressForStabilityPool(_collateral)),
            priceFeed: HLPriceFeed(_getCorrectPriceFeed(_collateral)), // TODO: remove it when Hypeliquid fixed the price feed
            activePool: IActivePool(_forecastAddressForActivePool(_collateral)),
            defaultPool: IDefaultPool(_forecastAddressForDefaultPool(_collateral)),
            gasPoolAddress: _forecastAddressForGasPool(_collateral),
            collSurplusPool: ICollSurplusPool(_forecastAddressForCollSurplusPool(_collateral)),
            sortedTroves: ISortedTroves(_forecastAddressForSortedTroves(_collateral)),
            interestRouter: MockInterestRouter(branchContractAddresses[_collateral][ContractTypes.INTEREST_ROUTER]),
            hintHelpers: HintHelpers(singletonContractAddresses.hintHelpers),
            multiTroveGetter: MultiTroveGetter(singletonContractAddresses.multiTroveGetter),
            collateralRegistry: CollateralRegistry(singletonContractAddresses.collateralRegistry),
            feUSDToken: IfeUSDToken(singletonContractAddresses.feUSDToken),
            WHYPE: IWHYPE(collateralParams[Collaterals.WHYPE].collToken)
        });
        IAddressesRegistry(_addressesRegistry).setAddresses(_addressVars);
    }

    function _setBranchAddressesForfeUSDToken() internal {
        IfeUSDToken _feUSDToken = IfeUSDToken(singletonContractAddresses.feUSDToken);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _troveManager = branchContractAddresses[_collateral][ContractTypes.TROVE_MANAGER];
            address _stabilityPool = branchContractAddresses[_collateral][ContractTypes.STABILITY_POOL];
            address _borrowerOperations = branchContractAddresses[_collateral][ContractTypes.BORROWER_OPERATIONS];
            address _activePool = branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL];
            _feUSDToken.setBranchAddresses(_troveManager, _stabilityPool, _borrowerOperations, _activePool);
        }
    }

    function _setAddressesRegistriesForAdminController() internal {
        IAdminController _adminController = IAdminController(singletonContractAddresses.adminController);
        for (uint8 i = 0; i < COLLATERALS_LENGTH; i++) {
            Collaterals _collateral = Collaterals(i);
            address _addressesRegistry = branchContractAddresses[_collateral][ContractTypes.ADDRESSES_REGISTRY];
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

    function _transferOwnershipOfProxyAdminToAdminController() internal {
        address _adminController = singletonContractAddresses.adminController;
        address _proxyAdmin = proxyAdminAddresses.proxyAdminForCoreContracts;
        Ownable(_proxyAdmin).transferOwnership(_adminController);
    }

    function _transferOwnershipOfCollateralRegistryToAdminController() internal {
        address _adminController = singletonContractAddresses.adminController;
        address _collateralRegistry = singletonContractAddresses.collateralRegistry;
        OwnableUpgradeable(_collateralRegistry).transferOwnership(_adminController);
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

            address _branchPriceFeed = _getCorrectPriceFeed(_collateral);
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
            address _branchPriceFeed = _getCorrectPriceFeed(_collateral);

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
                address _feUSD,
                address _whype,
                uint256 _mcr,
                uint256 _scr,
                uint256 _liquidationPenaltySp,
                uint256 _liquidationPenaltyRedistribution
            ) = _getStorageValuesForTroveManager(address(_troveManager));

            assert(_troveManagerActivePool == branchContractAddresses[_collateral][ContractTypes.ACTIVE_POOL]);
            assert(_troveManagerDefaultPool == branchContractAddresses[_collateral][ContractTypes.DEFAULT_POOL]);
            assert(_troveManagerPriceFeed == _getCorrectPriceFeed(_collateral));
            assert(_whype == address(collateralParams[Collaterals.WHYPE].collToken));
            assert(_feUSD == singletonContractAddresses.feUSDToken);
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
            address _feUSD,
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
        _feUSD = address(
            uint160(uint256(vm.load(address(_troveManager), bytes32(uint256(feUSD_TOKEN_SLOT_FOR_TROVE_MANAGER)))))
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

    function _setUpPriceFeedPrecompiled() internal {
        // This is required because the price feed precompiled is not available in the test environment
        MockL1Read mockL1Read = new MockL1Read();
        vm.etch(L1READ_ADDRESS, address(mockL1Read).code);
    }

}