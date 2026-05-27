// SPDX-License-Identifier: MIT


pragma solidity 0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Wrapper} from "./Wrapper.sol";

contract WrapperFactory is Ownable2Step {


    error WrapperFactory__ZeroAddress();
    error WrapperFactory__ZeroDecimals();
    error WrapperFactory__WrapperAlreadyCreated();
    error WrapperFactory__ZeroOwner();

    event WrapperCreated(address indexed originalToken, address indexed wrapper);

    mapping(address originalToken => bool hasBeenCreated) public isWrapperCreated;


    constructor(address _owner) Ownable2Step() {
        _transferOwnership(_owner);
    }


    function createWrapper(address _originalToken) external onlyOwner returns (address) {

        if (_originalToken == address(0)) revert WrapperFactory__ZeroAddress();
        if (isWrapperCreated[_originalToken]) revert WrapperFactory__WrapperAlreadyCreated();

        isWrapperCreated[_originalToken] = true;

        (string memory _name, string memory _symbol) = _createNameAndSymbol(_originalToken);

        address wrapper = address(new Wrapper(_originalToken, _name, _symbol));

        emit WrapperCreated(_originalToken, wrapper);

        return wrapper;
    }


    function _createNameAndSymbol(address _originalToken) internal view returns (string memory, string memory) {
        string memory _originalTokenName = IERC20Metadata(_originalToken).name();
        string memory _originalTokenSymbol = IERC20Metadata(_originalToken).symbol();

        return (string.concat("Felix - ", _originalTokenName), string.concat("fe", _originalTokenSymbol));
    }
}