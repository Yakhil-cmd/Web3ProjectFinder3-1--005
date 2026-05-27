// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "src/NFTMetadata/MetadataNFT.sol";
import "src/NFTMetadata/utils/Utils.sol";
import "src/NFTMetadata/utils/FixedAssets.sol";

import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MetadataDeployment is Script {
    struct File {
        bytes data;
        uint256 start;
        uint256 end;
    }

    mapping(bytes4 => File) public files;

    address public pointer;

    FixedAssetReader public initializedFixedAssetReader;

    function deployMetadata(bytes32 _salt, address _proxyAdmin, address _impl) public returns (MetadataNFT) {
        _loadFiles();
        _storeFile();
        _deployFixedAssetReader(_salt);

        MetadataNFT metadataNFT = MetadataNFT(address(
            new TransparentUpgradeableProxy{salt: _salt}(
                _impl,
                _proxyAdmin,
                abi.encodeWithSelector(
                    MetadataNFT.initialize.selector,
                    initializedFixedAssetReader
                )
            )
        ));

        return metadataNFT;
    }

    function _loadFiles() internal {
        string memory root = string.concat(vm.projectRoot(), "/utils/assets/");
        uint256 offset = 0;
        
        // Load files one at a time using a helper function
        offset = _loadSingleFile("felix_logo.txt", "FELIX", offset);
        offset = _loadSingleFile("weth_logo.txt", "WETH", offset);
        offset = _loadSingleFile("wbtc_logo.txt", "WBTC", offset);
        offset = _loadSingleFile("sol_logo.txt", "SOL", offset);
        offset = _loadSingleFile("hype_logo.txt", "HYPE", offset);
        offset = _loadSingleFile("purr_logo.txt", "PURR", offset);
        offset = _loadSingleFile("felix_text.txt", "TEXT", offset);
    }

    function _loadSingleFile(string memory fileName, string memory key, uint256 offset) internal returns (uint256) {
        string memory root = string.concat(vm.projectRoot(), "/utils/assets/");
        bytes memory fileData = bytes(vm.readFile(string.concat(root, fileName)));
        files[bytes4(keccak256(bytes(key)))] = File(fileData, offset, offset + fileData.length);
        return offset + fileData.length;
    }

    function _storeFile() internal {
        // Create array of keys to reduce stack usage
        bytes4[] memory keys = new bytes4[](7);
        keys[0] = bytes4(keccak256("FELIX"));
        keys[1] = bytes4(keccak256("WETH"));
        keys[2] = bytes4(keccak256("WBTC"));
        keys[3] = bytes4(keccak256("SOL"));
        keys[4] = bytes4(keccak256("HYPE"));
        keys[5] = bytes4(keccak256("PURR"));
        keys[6] = bytes4(keccak256("TEXT"));
        // Concatenate in chunks to reduce stack pressure
        bytes memory data = files[keys[0]].data;
        for(uint i = 1; i < keys.length; i++) {
            data = bytes.concat(data, files[keys[i]].data);
        }

        pointer = SSTORE2.write(data);
    }

    function _deployFixedAssetReader(bytes32 _salt) internal {
        // First part - signatures
        bytes4[] memory sigs = _getSignatures();
        
        // Second part - assets
        FixedAssetReader.Asset[] memory fixedAssets = new FixedAssetReader.Asset[](7);
        
        bytes4[7] memory assetKeys = [
            bytes4(keccak256("FELIX")),
            bytes4(keccak256("WETH")),
            bytes4(keccak256("WBTC")),
            bytes4(keccak256("SOL")),
            bytes4(keccak256("HYPE")),
            bytes4(keccak256("PURR")),
            bytes4(keccak256("TEXT"))
        ];
        
        // Create assets in a loop to reduce stack usage
        for(uint i = 0; i < 7; i++) {
            fixedAssets[i] = FixedAssetReader.Asset(
                uint128(files[assetKeys[i]].start),
                uint128(files[assetKeys[i]].end)
            );
        }

        initializedFixedAssetReader = new FixedAssetReader{salt: _salt}(pointer, sigs, fixedAssets);
    }

    function _getSignatures() internal pure returns (bytes4[] memory) {
        bytes4[] memory sigs = new bytes4[](7);
        sigs[0] = bytes4(keccak256("FELIX"));
        sigs[1] = bytes4(keccak256("WETH"));
        sigs[2] = bytes4(keccak256("WBTC"));
        sigs[3] = bytes4(keccak256("SOL"));
        sigs[4] = bytes4(keccak256("HYPE"));
        sigs[5] = bytes4(keccak256("PURR"));
        sigs[6] = bytes4(keccak256("TEXT"));
        return sigs;
    }
}
