// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC721MetadataUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ITroveManager.sol";
import './IAddressesRegistry.sol';
import {IMetadataNFT} from "../NFTMetadata/MetadataNFT.sol";
import "./IfeUSDToken.sol";


interface ITroveNFT is IERC721MetadataUpgradeable {
    function mint(address _owner, uint256 _troveId) external;
    function burn(uint256 _troveId) external;
    function troveManager() external view returns (ITroveManager);
    function metadataNFT() external view returns (IMetadataNFT);
    function initialize(IAddressesRegistry _addressRegistry) external;
    function collToken() external view returns (IERC20Metadata);
    function feUSDToken() external view returns (IfeUSDToken);
}