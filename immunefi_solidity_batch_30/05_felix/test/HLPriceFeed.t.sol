// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {HLPriceFeed} from "../src/PriceFeeds/HLPriceFeed.sol";
import {HLPriceFeedMock} from "./TestContracts/HLPriceFeedMock.sol";
import {LatestTroveData} from "../src/TroveManager.sol";
import {BorrowerOperationsTester} from "./TestContracts/BorrowerOperationsTester.t.sol";
import {AddressesRegistry} from "../src/AddressesRegistry.sol";
import {IAddressesRegistry} from "../src/Interfaces/IAddressesRegistry.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import "./TestContracts/Accounts.sol";
import "./TestContracts/Deployment.t.sol";
import {MockL1Read} from "../src/Dependencies/MockL1Read.sol";

contract HLPriceFeedTest is Test {
    HLPriceFeed priceFeedImpl;
    HLPriceFeedMock priceFeedMockImpl;
    ProxyAdmin proxyAdmin;
    HLPriceFeed ethPriceFeed;
    HLPriceFeed btcPriceFeed;
    HLPriceFeedMock failingPriceFeed;
    AddressesRegistry registry;
    BorrowerOperationsTester borrowerOperations;
    uint32 constant ETH_L1_INDEX = 4;
    uint32 constant BTC_L1_INDEX = 3;
    uint8 constant ETH_SZ_DECIMALS = 4;
    uint8 constant BTC_SZ_DECIMALS = 5;
    uint256 constant FIXED_BLOCK = 7949936;
    uint256 constant FIXED_ETH_PRICE = 2694300000000000000000;
    uint256 constant FIXED_BTC_PRICE = 68514000000000000000000;
    uint256 constant MOCK_ETH_PRICE = 2600e18;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("hl_testnet"));
        vm.etch(0x44AFB4F9134c21E3ee69c785073FE2550607CA2a, address(new MockL1Read()).code);
        borrowerOperations = new BorrowerOperationsTester();
        deployFeeds();
    }

    function deployFeeds() internal {
        proxyAdmin = new ProxyAdmin();
        priceFeedImpl = new HLPriceFeed();
        priceFeedMockImpl = new HLPriceFeedMock();
        ethPriceFeed = HLPriceFeed(address(
            new TransparentUpgradeableProxy(
                address(priceFeedImpl),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    HLPriceFeed.initialize.selector,
                    ETH_L1_INDEX,
                    ETH_SZ_DECIMALS,
                    address(borrowerOperations)
                ))
            )
        );
        btcPriceFeed = HLPriceFeed(address(
            new TransparentUpgradeableProxy(
                address(priceFeedImpl),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    HLPriceFeed.initialize.selector,
                    BTC_L1_INDEX,
                    BTC_SZ_DECIMALS,
                    address(borrowerOperations)
                ))
            )
        );
        failingPriceFeed = HLPriceFeedMock(address(
            new TransparentUpgradeableProxy(
                address(priceFeedMockImpl),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    HLPriceFeedMock.initialize.selector,
                    MOCK_ETH_PRICE,
                    true
                ))
            )
        );
    }

    // function testFixedPrices() public {
    //     (uint256 ethPriceCurrent,) = ethPriceFeed.fetchPrice();
    //     (uint256 btcPriceCurrent,) = btcPriceFeed.fetchPrice();

    //     vm.createSelectFork(vm.rpcUrl("hl_testnet"), FIXED_BLOCK);
    //     deployFeeds();

    //     (uint256 ethPriceFixed,) = ethPriceFeed.fetchPrice();
    //     (uint256 btcPriceFixed,) = btcPriceFeed.fetchPrice();
        
    //     assertEq(ethPriceFixed, FIXED_ETH_PRICE);
    //     assertEq(btcPriceFixed, FIXED_BTC_PRICE);

    //     assertNotEq(ethPriceFixed, ethPriceCurrent);
    //     assertNotEq(btcPriceFixed, btcPriceCurrent);
    // }

    function testFetchPriceETH() public {
        (uint256 price, bool failure) = ethPriceFeed.fetchPrice();
        assertGt(price, 0);
        assertGt(price, 1e18);
        assertEq(failure, false);
    }

    function testFetchPriceBTC() public {
        (uint256 price, bool failure) = btcPriceFeed.fetchPrice();
        assertGt(price, 0);
        assertGt(price, 1e18);
        assertEq(failure, false);
    }

    function testLastGoodPriceETH() public {
        (uint256 currentPrice, bool failure) = ethPriceFeed.fetchPrice();
        assertGt(currentPrice, 0);
        assertEq(failure, false);
            
        uint256 lastGoodPrice = ethPriceFeed.lastGoodPrice();
        assertGt(lastGoodPrice, 0);
        assertEq(currentPrice, lastGoodPrice);
    }

    function testLastGoodPriceBTC() public {
        (uint256 currentPrice, bool failure) = btcPriceFeed.fetchPrice();
        assertGt(currentPrice, 0);
        assertEq(failure, false);
            
        uint256 lastGoodPrice = btcPriceFeed.lastGoodPrice();
        assertGt(lastGoodPrice, 0);
        assertEq(currentPrice, lastGoodPrice);
    }

    function testShutdownPriceFeed() public {
        (uint256 price, bool failure) = failingPriceFeed.fetchPrice();
        assertEq(price, MOCK_ETH_PRICE);
        assertEq(failure, true);
        assertEq(failingPriceFeed.lastGoodPrice(), price);
    }

/*     function testManualShutdown() public {
        ethPriceFeed.disableFeedAndShutDown();
        assertEq(ethPriceFeed.priceFeedDisabled(), true);
    } */

/*     function testChangeOwnership() public {
        address newOwner = makeAddr("NEW_OWNER");
        ethPriceFeed.transferOwnership(newOwner);
        assertEq(ethPriceFeed.owner(), address(this));
        vm.prank(newOwner);
        ethPriceFeed.acceptOwnership();
        assertEq(ethPriceFeed.owner(), newOwner);
    } */
}

contract HLPriceFeeedTestIntegration is TestAccounts {
    // TestDeployer.LiquityContracts[] contractsArray;
    // ICollateralRegistry collateralRegistry;
    // IfeUSDToken feUSDToken;
    // ITroveManager troveManager;
    // IAddressesRegistry addressesRegistry;
    // IBorrowerOperations borrowerOperations;
    // IERC20Metadata collToken;
    // TestDeployer deployer;

    // function setUp() public {
    //     vm.createSelectFork(vm.rpcUrl("hl_testnet"));
    //     MockL1Read mockL1Read = new MockL1Read();
    //     vm.etch(0x44AFB4F9134c21E3ee69c785073FE2550607CA2a, address(mockL1Read).code);

    //     accounts = new Accounts();
    //     createAccounts();

    //     (A, B, C, D, E, F) =
    //         (accountsList[0], accountsList[1], accountsList[2], accountsList[3], accountsList[4], accountsList[5]);

    //     uint256 numCollaterals = 1;
    //     TestDeployer.TroveManagerParams memory tmParams =
    //         TestDeployer.TroveManagerParams(120e16, 120e16, 110e16, 5e16, 10e16, 1_000_000_000 ether);
    //     TestDeployer.TroveManagerParams[] memory troveManagerParamsArray =
    //         new TestDeployer.TroveManagerParams[](numCollaterals);
    //     for (uint256 i = 0; i < troveManagerParamsArray.length; i++) {
    //         troveManagerParamsArray[i] = tmParams;
    //     }

    //     deployer = new TestDeployer();
    //     TestDeployer.DeploymentResultMainnet memory result =
    //         deployer.deployAndConnectContractsHLTestnet(troveManagerParamsArray);
    //     collateralRegistry = result.collateralRegistry;
    //     feUSDToken = result.feUSDToken;
    //     collToken = result.contractsArray[0].collToken;

    //     // Record contracts
    //     for (uint256 c = 0; c < numCollaterals; c++) {
    //         contractsArray.push(result.contractsArray[c]);
    //     }

    //     // Give all users all collaterals
    //     uint256 initialColl = 1000_000e18;
    //     for (uint256 i = 0; i < 6; i++) {
    //         for (uint256 j = 0; j < numCollaterals; j++) {
    //             deal(address(contractsArray[j].collToken), accountsList[i], initialColl);
    //             vm.startPrank(accountsList[i]);
    //             // Approve all Borrower Ops to use the user's WETH funds
    //             contractsArray[0].collToken.approve(address(contractsArray[j].borrowerOperations), type(uint256).max);
    //             // Approve Borrower Ops in LST branches to use the user's respective LST funds
    //             contractsArray[j].collToken.approve(address(contractsArray[j].borrowerOperations), type(uint256).max);
    //             vm.stopPrank();
    //         }

    //         vm.startPrank(accountsList[i]);
    //     }

    //     troveManager = contractsArray[0].troveManager;
    //     addressesRegistry = contractsArray[0].addressesRegistry;
    //     borrowerOperations = contractsArray[0].borrowerOperations;
    // }

    // function testOpenTroveWETH() public {
    //     IHLPriceFeed priceFeed = IHLPriceFeed(address(addressesRegistry.priceFeed()));
    //     (uint256 price,) = priceFeed.fetchPrice();

    //     uint256 coll = 5 ether;
    //     uint256 debtRequest = 2100 ether;

    //     uint256 trovesCount = troveManager.getTroveIdsCount();
    //     assertEq(trovesCount, 0);

    //     vm.startPrank(A);
    //     borrowerOperations.openTrove(
    //         A, 0, coll, debtRequest, 0, 0, 5e16, debtRequest, address(0), address(0), address(0)
    //     );

    //     trovesCount = troveManager.getTroveIdsCount();
    //     assertEq(trovesCount, 1);
    // }

    // function testRedeemCollateral() public {
    //     (uint256 price,) = addressesRegistry.priceFeed().fetchPrice();
    //     uint256 coll = 5 ether;
    //     uint256 debtRequest = 2100 ether;

    //     vm.startPrank(A);
    //     borrowerOperations.openTrove(
    //         A, 0, coll, debtRequest, 0, 0, 5e16, debtRequest, address(0), address(0), address(0)
    //     );
    //     vm.stopPrank();

    //     vm.startPrank(B);
    //     uint256 B_Id = borrowerOperations.openTrove(
    //         B, 0, coll, debtRequest, 0, 0, 5e16, debtRequest, address(0), address(0), address(0)
    //     );
    //     vm.stopPrank();

    //     LatestTroveData memory _latestTroveData = troveManager.getLatestTroveData(B_Id);

    //     uint256 debt_1 = _latestTroveData.entireDebt;
    //     uint256 coll_1 = _latestTroveData.entireColl;

    //     uint256 redemptionAmount = 1000e18; // 1k feUSD

    //     // A redeems 1k feUSD
    //     vm.warp(100 days);
    //     vm.startPrank(A);
    //     collateralRegistry.redeemCollateral(redemptionAmount, 10, 1e18);
    //     vm.stopPrank();


    //     // Check B's coll and debt reduced
    //     _latestTroveData = troveManager.getLatestTroveData(B_Id);

    //     uint256 debt_2 = _latestTroveData.entireDebt;
    //     uint256 coll_2 = _latestTroveData.entireColl;

    //     assertLt(debt_2, debt_1);
    //     assertLt(coll_2, coll_1);        
    // }

    // function testRedeemCollateralWithNewCollaterals() public {
    //     (uint256 price,) = addressesRegistry.priceFeed().fetchPrice();
    //     uint256 coll = 5 ether;
    //     uint256 debtRequest = 2100 ether;

    //     vm.startPrank(A);
    //     borrowerOperations.openTrove(
    //         A, 0, coll, debtRequest, 0, 0, 5e16, debtRequest, address(0), address(0), address(0)
    //     );
    //     vm.stopPrank();

    //     // Add new collateral
    //     vm.startPrank(address(deployer));
    //     collateralRegistry.addCollateral(IERC20Metadata(address(collToken)), troveManager);
    //     vm.stopPrank();

    //     vm.startPrank(B);
    //     uint256 B_Id = borrowerOperations.openTrove(
    //         B, 0, coll, debtRequest, 0, 0, 5e16, debtRequest, address(0), address(0), address(0)
    //     );
    //     vm.stopPrank();

    //     LatestTroveData memory _latestTroveData = troveManager.getLatestTroveData(B_Id);

    //     uint256 debt_1 = _latestTroveData.entireDebt;
    //     uint256 coll_1 = _latestTroveData.entireColl;

    //     uint256 redemptionAmount = 1000e18; // 1k feUSD

    //     // A redeems 1k feUSD
    //     vm.warp(100 days);
    //     vm.startPrank(A);
    //     collateralRegistry.redeemCollateral(redemptionAmount, 10, 1e18);
    //     vm.stopPrank();

    //     // Add new collateral
    //     vm.startPrank(address(deployer));
    //     collateralRegistry.addCollateral(IERC20Metadata(address(collToken)), troveManager);
    //     vm.stopPrank();


    //     // B redeems 1k feUSD
    //     vm.warp(100 days);
    //     vm.startPrank(B);
    //     collateralRegistry.redeemCollateral(redemptionAmount, 10, 1e18);
    //     vm.stopPrank();

    //     // Check B's coll and debt reduced
    //     _latestTroveData = troveManager.getLatestTroveData(B_Id);

    //     uint256 debt_2 = _latestTroveData.entireDebt;
    //     uint256 coll_2 = _latestTroveData.entireColl;

    //     assertLt(debt_2, debt_1);
    //     assertLt(coll_2, coll_1);        
    // }
}