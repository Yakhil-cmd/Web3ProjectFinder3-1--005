// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {MetadataNFTBase} from "./utils/MatadataNFTBase.sol";
import {FixedAssetReader} from "./utils/FixedAssets.sol";

contract MetadataNFTV2 is MetadataNFTBase {

    error MetadataNFTV2__InvalidAdminController();
    error MetadataNFTV2__InvalidAssetReader();
    error MetadataNFTV2__NotAdminController();

    event AssetReaderSet(address indexed _assetReader);
    event AdminControllerSet(address indexed _adminController);

    address public adminController;

    modifier onlyAdminController() {
        if (msg.sender != adminController) revert MetadataNFTV2__NotAdminController();
        _;
    }

    function reinitialize(address _assetReader, address _adminController) public reinitializer(2) {
        if (_assetReader == address(0)) revert MetadataNFTV2__InvalidAssetReader();
        if (_adminController == address(0)) revert MetadataNFTV2__InvalidAdminController();

        assetReader = FixedAssetReader(_assetReader);
        adminController = _adminController;

        emit AssetReaderSet(_assetReader);
        emit AdminControllerSet(_adminController);
    }

    function setAssetReader(address _assetReader) external onlyAdminController {
        if (_assetReader == address(0)) revert MetadataNFTV2__InvalidAssetReader();
        assetReader = FixedAssetReader(_assetReader);

        emit AssetReaderSet(_assetReader);
    }

    

}