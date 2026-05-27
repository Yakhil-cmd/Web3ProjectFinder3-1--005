// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;


import {Initializable as OZInitializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {L1Read} from "../Dependencies/L1Read.sol";
import "../Interfaces/IBorrowerOperations.sol";
import "../Interfaces/IHLPriceFeed.sol";


contract HLPriceFeed is IHLPriceFeed, OZInitializable {

    error HLPriceFeed__AddressZero();
    error HLPriceFeed__InsufficientGasForExternalCall();

    address constant SYSTEM_CONTRACT = 0x44AFB4F9134c21E3ee69c785073FE2550607CA2a;
    uint256 constant INVALID_PRICE = 0;

    uint16 public l1Index;
    uint8 public szDecimals;
    L1Read public systemContract;

    // Last good price tracker for the derived USD price
    uint256 public lastGoodPrice;

    // Flag raised when the collateral branch gets shut down.
    bool public priceFeedDisabled;
    IBorrowerOperations borrowerOperations;

    constructor() {
        _disableInitializers();
    }

    /*
    * @param _owner The owner of the contract
    * @param _l1Index The index of the asset  in the HL System Contract's oracle
    * @param _szDecimals The number of decimals of the asset on the HL L1
    * @param borrowerOperations The address of the BorrowerOperations contract
    */
    function initialize(uint16 _l1Index, uint8 _szDecimals, address _borrowerOperations) public virtual initializer {
        __HLPriceFeed_init(_l1Index, _szDecimals, _borrowerOperations);
    }


    function __HLPriceFeed_init(uint16 _l1Index, uint8 _szDecimals, address _borrowerOperations) internal {
        if(_borrowerOperations == address(0)) revert HLPriceFeed__AddressZero();

        l1Index = _l1Index;
        szDecimals = _szDecimals;
        systemContract = L1Read(SYSTEM_CONTRACT);
        borrowerOperations = IBorrowerOperations(_borrowerOperations);

        _fetchPrice();

        // Check the oracle didn't already fail
        assert(priceFeedDisabled == false);
    }


    /*
    * @notice Fetch the price from the oracle
    * @return The price
    * @return A bool indicating whether a new oracle failure was detected in the call
    */
    function fetchPrice() public returns (uint256, bool) {
        if (priceFeedDisabled) return (lastGoodPrice, false);

        return _fetchPrice();
    }

    function setAddresses(address _borrowerOperationsAddress) external {}

    
    /*
    * @notice Fetch the price from the System Contract
    * @return The price
    * @return A bool indicating whether the oracle failed
    */
    function _fetchPrice() internal virtual returns (uint256, bool) {
        
        uint256 price = _getL1ReadResponse();
        price = _scaleHLPriceTo18decimals(price);

        if (price == INVALID_PRICE) {
            return _disableFeedAndShutDown(SYSTEM_CONTRACT);
        }


        lastGoodPrice = price;

        return (price, false);
    }

    /*
    * @notice Get the price from the System Contract
    * @return The price
    * @dev It is made in order to make the system resilient in case of a failed oracle call
    */
    function _getL1ReadResponse() internal view returns (uint256) {
        uint256 gasBefore = gasleft();

        try systemContract.oraclePx(l1Index) returns (uint64 price) {
            return uint256(price);
        }catch {
            if(gasleft() <= gasBefore / 64) revert HLPriceFeed__InsufficientGasForExternalCall();
            return INVALID_PRICE;
        }
    }

    /*
    * @notice Scale the price from 6 decimals to 18 decimals
    * @param _price The price to scale
    * @return The scaled price
    */
    function _scaleHLPriceTo18decimals(uint256 _price) internal view returns (uint256) {
        return _price * 10 ** (18 - (6 - szDecimals));
    }

    /*
    * @notice Disable the price feed and shut down the collateral branch
    * @param _failedOracleAddr The address of the failed oracle
    * @return The last good price
    */
    function _disableFeedAndShutDown(address _failedOracleAddr) internal returns (uint256, bool) {
        // Shut down the branch
        borrowerOperations.shutdownFromOracleFailure(_failedOracleAddr);

        priceFeedDisabled = true;
        return (lastGoodPrice, true);
    }
}
