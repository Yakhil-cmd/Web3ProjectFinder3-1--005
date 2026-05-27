// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AdminControllerV2} from "./AdminControllerV2.sol";

contract AdminControllerV3 is AdminControllerV2 {

    error AdminControllerV3__MultipleUpgradeProposalDisabled();
    error AdminControllerV3__MultipleUpgradeApplicationDisabled();
    error AdminControllerV3__NewImplementationProposalDisabled();
    error AdminControllerV3__NewImplementationApplicationDisabled();

    function initializeV3() external reinitializer(3) {}

    function proposeMultipleUpgrade(UpgradeProposal[] memory _upgradeProposals, uint256 _branchIndex) external override onlyRole(PROPOSER_ROLE) {
        revert AdminControllerV3__MultipleUpgradeProposalDisabled();
    }

    function applyMultipleUpgrade(uint256 _branchIndex) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        revert AdminControllerV3__MultipleUpgradeApplicationDisabled();
    }

    function proposeNewImplementation(uint256 _branchIndex, address _newImplementation, ContractType _contractType, bytes memory _data) external override onlyRole(PROPOSER_ROLE) {
        revert AdminControllerV3__NewImplementationProposalDisabled();
    }

    function applyNewImplementation(uint256 _branchIndex) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        revert AdminControllerV3__NewImplementationApplicationDisabled();
    }
}