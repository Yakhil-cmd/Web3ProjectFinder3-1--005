// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IfeUSDToken} from "../../src/Interfaces/IfeUSDToken.sol";
import {ICollateralRegistry} from "../../src/Interfaces/ICollateralRegistry.sol";
import {IWHYPE} from "../../src/Interfaces/IWHYPE.sol";
import {HintHelpers} from "../../src/HintHelpers.sol";
import {TestDeployer} from "./Deployment.t.sol";

contract BaseMultiCollateralTest {
    struct Contracts {
        IWHYPE whype;
        ICollateralRegistry collateralRegistry;
        IfeUSDToken feUSDToken;
        HintHelpers hintHelpers;
        TestDeployer.LiquityContractsDev[] branches;
    }

    IERC20 whype;
    ICollateralRegistry collateralRegistry;
    IfeUSDToken feUSDToken;
    HintHelpers hintHelpers;
    TestDeployer.LiquityContractsDev[] branches;

    function setupContracts(Contracts memory contracts) internal {
        whype = contracts.whype;
        collateralRegistry = contracts.collateralRegistry;
        feUSDToken = contracts.feUSDToken;
        hintHelpers = contracts.hintHelpers;

        for (uint256 i = 0; i < contracts.branches.length; ++i) {
            branches.push(contracts.branches[i]);
        }
    }
}
