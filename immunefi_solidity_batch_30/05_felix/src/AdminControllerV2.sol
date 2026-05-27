// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {BaseAdminController} from "./BaseAdminController.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title AdminControllerV2
 * @notice This contract is the second version of the AdminController. It allows for multiple upgrades to be proposed and applied in a single transaction.
 */
contract AdminControllerV2 is BaseAdminController {

    /// @notice The struct for a single upgrade proposal.
    struct UpgradeProposal {
        ContractType contractType; // The type of contract to upgrade.
        address newImplementation; // The address of the new implementation.
        bytes initCalldata; // The calldata to initialize the new implementation.
    }

    struct MultipleUpgradeProposal {
        UpgradeProposal[] upgradeProposals;
        uint256 timestamp;
    }

    /// @notice The error for an invalid upgrade proposal length.
    error AdminControllerV2__UpgradeProposalLengthInvalid();
    /// @notice The error for an invalid contract type.
    error AdminControllerV2__InvalidContractType();
    /// @notice The error for a zero address implementation.
    error AdminControllerV2__InvalidImplementation();

    /**
     * @notice The event for a multiple upgrade proposal pending.
     * @param _branchIndex The index of the branch.
     * @param _timestamp The timestamp of the proposal.
     * @param _upgradeProposals The upgrade proposals.
     */
    event MultipleUpgradeProposalPending(uint256 indexed _branchIndex, uint256 _timestamp, UpgradeProposal[] _upgradeProposals);
    /**
     * @notice The event for a multiple upgrade proposal applied.
     * @param _branchIndex The index of the branch.
     * @param _timestamp The timestamp of the proposal.
     * @param _upgradeProposals The upgrade proposals.
     */
    event MultipleUpgradeProposalApplied(uint256 indexed _branchIndex, uint256 _timestamp, UpgradeProposal[] _upgradeProposals);

    /// @notice The maximum length of a multiple upgrade proposal.
    uint256 public constant MULTIPLE_UPGRADE_PROPOSAL_MAX_LENGTH = 10;
    /// @notice The invalid contract type.
    uint8 public constant INVALID_CONTRACT_TYPE = uint8(ContractType.TROVE_MANAGER) + 1;

    /// @notice The mapping of branch index to pending multiple upgrade proposals.
    mapping(uint256 branchIndex => MultipleUpgradeProposal) public pendingMultipleUpgradeProposals;

   /// @notice It uses the reinitializer to upgrade the contract to the second version.
    function initializeV2() external reinitializer(2) {
        
    }

    /**
     * @notice It proposes a multiple upgrade.
     * @param _upgradeProposals The upgrade proposals.
     * @param _branchIndex The index of the branch.
     * @dev The length of the upgrade proposals is limited to 10.
     * @dev The branch index must be valid.
     * @dev Emits a MultipleUpgradeProposalAdded event.
     */
    function proposeMultipleUpgrade(UpgradeProposal[] memory _upgradeProposals, uint256 _branchIndex) external virtual onlyRole(PROPOSER_ROLE) {

        _requireValidUpgradeLength(_upgradeProposals.length);
        _requireValidUpgradeProposals(_upgradeProposals);
        _requireValidBranchIndex(_branchIndex);

        _cleanPendingMultipleUpgradeProposals(_branchIndex);

        uint256 _timestamp = block.timestamp;
        
        MultipleUpgradeProposal storage proposal = pendingMultipleUpgradeProposals[_branchIndex];
    
        for (uint256 i = 0; i < _upgradeProposals.length; i++) {
            proposal.upgradeProposals.push(_upgradeProposals[i]);
        }
    
        proposal.timestamp = _timestamp;

        emit MultipleUpgradeProposalPending(_branchIndex, _timestamp, _upgradeProposals);
    }

    /**
     * @notice It applies a multiple upgrade.
     * @param _branchIndex The index of the branch.
     * @dev The branch index must be valid.
     * @dev Emits a MultipleUpgradeProposalApplied event.
     */
    function applyMultipleUpgrade(uint256 _branchIndex) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _requireValidBranchIndex(_branchIndex);
        
        MultipleUpgradeProposal memory _multipleUpgradeProposal = pendingMultipleUpgradeProposals[_branchIndex];

        _checkTimelockPassed(_multipleUpgradeProposal.timestamp, OpImpact.SENSITIVE);
        _cleanPendingMultipleUpgradeProposals(_branchIndex);

        uint256 _proposalsLength = _multipleUpgradeProposal.upgradeProposals.length;

        for (uint256 i = 0; i < _proposalsLength; i++) {
            UpgradeProposal memory _upgradeProposal = _multipleUpgradeProposal.upgradeProposals[i];
            _applySingleUpgrade(_upgradeProposal, _branchIndex);
        }

        emit MultipleUpgradeProposalApplied(_branchIndex, _multipleUpgradeProposal.timestamp, _multipleUpgradeProposal.upgradeProposals);
    }

    function getPendingMultipleUpgradeProposals(uint256 _branchIndex) external view returns (MultipleUpgradeProposal memory) {
        return pendingMultipleUpgradeProposals[_branchIndex];
    }

    function _cleanPendingMultipleUpgradeProposals(uint256 _branchIndex) internal {
        if (pendingMultipleUpgradeProposals[_branchIndex].timestamp != 0) {
            delete pendingMultipleUpgradeProposals[_branchIndex];
        }
    }

    function _applySingleUpgrade(UpgradeProposal memory _upgradeProposal, uint256 _branchIndex) internal {
        ITransparentUpgradeableProxy _contractAddress = ITransparentUpgradeableProxy(_getContractFromType(_upgradeProposal.contractType, _branchIndex));

        if(_upgradeProposal.initCalldata.length > 0) {
            proxyAdmin.upgradeAndCall(_contractAddress, _upgradeProposal.newImplementation, _upgradeProposal.initCalldata);
        } else {
            proxyAdmin.upgrade(_contractAddress, _upgradeProposal.newImplementation);
        }
    }

    function _requireValidUpgradeProposals(UpgradeProposal[] memory _upgradeProposals) internal pure {
        for (uint256 i = 0; i < _upgradeProposals.length; i++) {
            _requireValidSingleUpgradeProposal(_upgradeProposals[i]);
        }
    }

    function _requireValidSingleUpgradeProposal(UpgradeProposal memory _upgradeProposal) internal pure {
        _requireValidContractType(_upgradeProposal.contractType);
        _requireValidImplementation(_upgradeProposal.newImplementation);
    }

    function _requireValidContractType(ContractType _contractType) internal pure {
        if (uint8(_contractType) >= INVALID_CONTRACT_TYPE) revert AdminControllerV2__InvalidContractType();
    }
    function _requireValidImplementation(address _implementation) internal pure {
        if (_implementation == address(0)) revert AdminControllerV2__InvalidImplementation();
    }

    function _requireValidBranchIndex(uint256 _branchIndex) internal view {
        if (_branchIndex >= addressesRegistries.length) revert AdminController__InvalidBranchIndex();
    }

    function _requireValidUpgradeLength(uint256 _upgradeLength) internal pure {
        if (_upgradeLength > MULTIPLE_UPGRADE_PROPOSAL_MAX_LENGTH) revert AdminControllerV2__UpgradeProposalLengthInvalid();
    }



    
}