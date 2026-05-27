// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

address constant ZERO_ADDRESS = address(0);

uint256 constant MAX_UINT256 = type(uint256).max;

uint256 constant DECIMAL_PRECISION = 1e18;
uint256 constant _100pct = DECIMAL_PRECISION;
uint256 constant _1pct = DECIMAL_PRECISION / 100;

// Amount of ETH to be locked in gas pool on opening troves 
// This can never be changed during upgrades due to open troves
uint256 constant ETH_GAS_COMPENSATION = 0; 


// Batch CR buffer (same for all branches for now)
// On top of MCR to join a batch, or adjust inside a batch
uint256 constant BCR_ALL = 10 * _1pct;



// Fraction of collateral awarded to liquidator
uint256 constant COLL_GAS_COMPENSATION_DIVISOR = 200; // dividing by 200 yields 0.5%


// Minimum amount of net feUSD debt a trove must have
/// @dev changed from 2000e18 to 1000e18 (25/04/2025)
uint256 constant MIN_DEBT = 1000e18;

uint256 constant MIN_ANNUAL_INTEREST_RATE = _1pct / 2; // 0.5%
uint256 constant MAX_ANNUAL_INTEREST_RATE = 250 * _1pct;

// Batch management params
uint128 constant MAX_ANNUAL_BATCH_MANAGEMENT_FEE = uint128(_100pct / 10); // 10%
uint128 constant MIN_INTEREST_RATE_CHANGE_PERIOD = 1 hours; // prevents more than one adjustment per ~10 blocks

uint256 constant REDEMPTION_FEE_FLOOR = _1pct / 2; // 0.5%

// For the debt / shares ratio to increase by a factor 1e9
// at a average annual debt increase (compounded interest + fees) of 10%, it would take more than 217 years (log(1e9)/log(1.1))
// at a average annual debt increase (compounded interest + fees) of 50%, it would take more than 51 years (log(1e9)/log(1.5))
// The increase pace could be forced to be higher through an inflation attack,
// but precisely the fact that we have this max value now prevents the attack
uint256 constant MAX_BATCH_SHARES_RATIO = 1e9;

// Half-life of 6h. 6h = 3600 min
// (1/2) = d^360 => d = (1/2)^(1/360)
uint256 constant REDEMPTION_MINUTE_DECAY_FACTOR = 998076443575628800;

// BETA: 18 digit decimal. Parameter by which to divide the redeemed fraction, in order to calc the new base rate from a redemption.
// Corresponds to (1 / ALPHA) in the white paper.
uint256 constant REDEMPTION_BETA = 1;

// To prevent redemptions unless feUSD depegs below 0.95 and allow the system to take off
uint256 constant INITIAL_BASE_RATE = _100pct; // 100% initial redemption rate

// Discount to be used once the shutdown thas been triggered
uint256 constant URGENT_REDEMPTION_BONUS = 2e16; // 2%

uint256 constant ONE_MINUTE = 1 minutes;
uint256 constant ONE_HOUR = 1 hours;
uint256 constant ONE_YEAR = 365 days;
uint256 constant UPFRONT_INTEREST_PERIOD = 7 days;
uint256 constant INTEREST_RATE_ADJ_COOLDOWN = 7 days;


/// @dev TODO: Change to WETH for HL mainnet
address constant WHYPE_ADDRESS = 0x5555555555555555555555555555555555555555;


uint256 constant MIN_FEUSD_IN_SP = 1e18;

address constant STHYPE_ADDRESS = 0xfFaa4a3D97fE9107Cef8a3F48c069F577Ff76cC1;
address constant WSTHYPE_ADDRESS = 0x94e8396e0869c9F2200760aF0621aFd240E1CF38;
address constant HYPE_USDC_ORACLE_ADDRESS = 0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43;
address constant STHYPE_USD_ORACLE_ADDRESS = 0x4cEC96A68cb9A979621b104F3C94884be1a66da0;

uint256 constant STHYPE_USD_STALENESS_THRESHOLD = 7 * ONE_HOUR; // 7 hours
uint256 constant HYPE_USDC_STALENESS_THRESHOLD = 7 * ONE_HOUR; // 7 hours

address constant KHYPE_HYPE_ORACLE_ADDRESS = 0x3519B2f175D22a4dFA0595c291fEfe0945F0656d; // TODO: update
address constant KHYPE_EXCHANGE_RATE_ORACLE_ADDRESS = 0x9209648Ec9D448EF57116B73A2f081835643dc7A;
uint256 constant KHYPE_HYPE_STALENESS_THRESHOLD = 7 * ONE_HOUR; // 7 hours

address constant USDC_USD_ORACLE_ADDRESS = 0x4C89968338b75551243C99B452c84a01888282fD;
uint256 constant USDC_USD_STALENESS_THRESHOLD = 7 * ONE_HOUR; // 7 hours

// Dummy contract that lets legacy Hardhat tests query some of the constants
contract Constants {
    uint256 public constant _ETH_GAS_COMPENSATION = ETH_GAS_COMPENSATION;
    uint256 public constant _MIN_DEBT = MIN_DEBT;
}

// =============================== USELESS CONSTANTS ===============================

/// @dev TODO: Change to RETH for HL mainnet
address constant RETH_ADDRESS = 0xae78736Cd615f374D3085123A210448E74Fc6393;
// Chain ID for HL mainnet
/// @dev TODO: 0 is used as a placeholder, change to the actual chain ID
uint32 constant HL_MAINNET_CHAINID = 0;

// Hyperliquid ETH index in the price feed array
uint8 constant HL_ETH_FEED_L1_INDEX = 4;

// Hyperliquid L1 decimals size
uint8 constant HL_ETH_FEED_SZ_DECIMALS = 4;

// Liquidation
uint256 constant MIN_LIQUIDATION_PENALTY_SP = 5e16; // 5%
uint256 constant MAX_LIQUIDATION_PENALTY_REDISTRIBUTION = 20e16; // 20%

// Collateral branch parameters (SETH = staked ETH, i.e. wstETH / rETH)
uint256 constant CCR_WETH = 150 * _1pct;
uint256 constant CCR_SETH = 160 * _1pct;

uint256 constant MCR_WETH = 110 * _1pct;
uint256 constant MCR_SETH = 120 * _1pct;

uint256 constant SCR_WETH = 110 * _1pct;
uint256 constant SCR_SETH = 120 * _1pct;

uint256 constant LIQUIDATION_PENALTY_SP_WETH = 5 * _1pct;
uint256 constant LIQUIDATION_PENALTY_SP_SETH = 5 * _1pct;

uint256 constant LIQUIDATION_PENALTY_REDISTRIBUTION_WETH = 10 * _1pct;
uint256 constant LIQUIDATION_PENALTY_REDISTRIBUTION_SETH = 20 * _1pct;

uint256 constant COLL_GAS_COMPENSATION_CAP = 2 ether; // Max coll gas compensation capped at 2 ETH
