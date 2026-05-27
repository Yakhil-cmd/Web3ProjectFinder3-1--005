// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";


abstract contract ReadManifestHelper is Test {

    enum Collaterals {
        WHYPE,
        WBTC,
        KHYPE,
        WSTHYPE,
        COLLATERALS_LENGTH
    }

    struct SingletonContracts {
        address feUSDToken;
        address collateralRegistry;
        address adminController;
        address proxyAdminForCoreContracts;
        address proxyAdminForAdminController;
        address hintHelpers;
        address metadataNFT;
        address multiTroveGetter;
    }

    struct BranchContracts {
        address activePool;
        address addressesRegistry;
        address borrowerOperations;
        address collToken;
        address interestRouter;
        address priceFeed;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        string name;
    }

    struct BranchPools {
        address collSurplusPool;
        address defaultPool;
        address gasPool;
    }

    struct CurveContracts {
        address curvePool;
        address curveGauge;
        address curveGaugeDistributor;
    }

    string public constant MANIFEST_PATH = "deployment-manifest.json";
    uint8 public constant BRANCHES_LENGTH = uint8(Collaterals.COLLATERALS_LENGTH);


    SingletonContracts public singletonContracts;
    mapping(Collaterals => BranchContracts) public branchContracts;
    mapping(Collaterals => BranchPools) public branchPools;
    CurveContracts public curveContracts;

    function setUp() public virtual {
        _readContractsFromManifest();
    }

    function _getManifestString() internal view returns (string memory) {
        return vm.readFile(MANIFEST_PATH);
    }

    function _parseSingletonContracts(string memory _manifest) internal {
        
        singletonContracts.feUSDToken = abi.decode(vm.parseJson(_manifest, ".feUSDToken"), (address));
        singletonContracts.collateralRegistry = abi.decode(vm.parseJson(_manifest, ".collateralRegistry"), (address));
        singletonContracts.adminController = abi.decode(vm.parseJson(_manifest, ".adminController"), (address));
        singletonContracts.proxyAdminForCoreContracts = abi.decode(vm.parseJson(_manifest, ".proxyAdminForCoreContracts"), (address));
        singletonContracts.proxyAdminForAdminController = abi.decode(vm.parseJson(_manifest, ".proxyAdminForAdminController"), (address));
        singletonContracts.hintHelpers = abi.decode(vm.parseJson(_manifest, ".hintHelpers"), (address));
        singletonContracts.metadataNFT = abi.decode(vm.parseJson(_manifest, ".metadataNFT"), (address));
        singletonContracts.multiTroveGetter = abi.decode(vm.parseJson(_manifest, ".multiTroveGetter"), (address));
    }

    function _parseBranchContracts(string memory _manifest) internal {
        for (uint8 i = 0; i < BRANCHES_LENGTH; i++) {
            string memory basePath = _getBasePath(i);

            branchContracts[Collaterals(i)].name = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".name")), (string));
            branchContracts[Collaterals(i)].activePool = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".activePool")), (address));
            branchContracts[Collaterals(i)].addressesRegistry = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".addressesRegistry")), (address));
            branchContracts[Collaterals(i)].borrowerOperations = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".borrowerOperations")), (address));
            branchContracts[Collaterals(i)].interestRouter = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".interestRouter")), (address));
            branchContracts[Collaterals(i)].interestRouter = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".interestRouter")), (address));
            branchContracts[Collaterals(i)].collToken = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".collToken")), (address));
            branchContracts[Collaterals(i)].priceFeed = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".priceFeed")), (address));
            branchContracts[Collaterals(i)].sortedTroves = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".sortedTroves")), (address));
            branchContracts[Collaterals(i)].stabilityPool = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".stabilityPool")), (address));
            branchContracts[Collaterals(i)].troveManager = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".troveManager")), (address));
            branchContracts[Collaterals(i)].troveNFT = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".troveNFT")), (address));
        }
    }

    function _parseBranchPools(string memory _manifest) internal {
        for (uint8 i = 0; i < BRANCHES_LENGTH; i++) {
            string memory basePath = _getBasePath(i);

            branchPools[Collaterals(i)].collSurplusPool = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".collSurplusPool")), (address));
            branchPools[Collaterals(i)].defaultPool = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".defaultPool")), (address));
            branchPools[Collaterals(i)].gasPool = abi.decode(vm.parseJson(_manifest, string.concat(basePath, ".gasPool")), (address));
        }
    }

    function _parseCurveContracts(string memory _manifest) internal {
        curveContracts.curvePool = abi.decode(vm.parseJson(_manifest, ".curvePool"), (address));
        curveContracts.curveGauge = abi.decode(vm.parseJson(_manifest, ".curveGauge"), (address));
        curveContracts.curveGaugeDistributor = abi.decode(vm.parseJson(_manifest, ".curveGaugeDistributor"), (address));
    }

    function _getBasePath(uint8 _branchIndex) internal pure returns (string memory) {
        return string.concat(
            ".branches[",
            vm.toString(_branchIndex),
            "]"
        );
    }

    function _readContractsFromManifest() internal {
        string memory _manifest = _getManifestString();
        _parseSingletonContracts(_manifest);
        _parseBranchContracts(_manifest);
        _parseBranchPools(_manifest);
        _parseCurveContracts(_manifest);
    }
}

