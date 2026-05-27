# Felix CDP

## Table of Contents

1. [Significant Changes in Felix CDP](#significant-changes-in-liquity-v2)
   - [Multi-collateral System](#multi-collateral-system)
   - [Collateral Choices](#collateral-choices)
   - [User-set Interest Rates](#user-set-interest-rates)
   - [Yield from Interest Paid to SP and LPs](#yield-from-interest-paid-to-sp-and-lps)
   - [Redemption Routing](#redemption-routing)
   - [Redemption Ordering](#redemption-ordering)
   - [Unredeemable Troves](#unredeemable-troves)
   - [Troves Represented by NFTs](#troves-represented-by-nfts)
   - [Individual Delegation](#individual-delegation)
   - [Batch Delegation](#batch-delegation)
   - [Collateral Branch Shutdown](#collateral-branch-shutdown)
   - [Removal of Recovery Mode](#removal-of-recovery-mode)
   - [Liquidation Penalties](#liquidation-penalties)
   - [Gas Compensation](#gas-compensation)
   - [More Flexibility for SP Reward Claiming](#more-flexibility-for-sp-reward-claiming)

2. [What Remains the Same in v2 from v1](#what-remains-the-same-in-v2-from-v1)
   - [Core Redemption Mechanism](#core-redemption-mechanism)
   - [Redemption Fee Mechanics](#redemption-fee-mechanics)
   - [Ordered Troves](#ordered-troves)
   - [Liquidation Mechanisms](#liquidation-mechanisms)
   - [Similar Smart Contract Architecture](#similar-smart-contract-architecture)
   - [Stability Pool Algorithm](#stability-pool-algorithm)
   - [Individual Overcollateralization](#individual-overcollateralization)
   - [Aggregate Overcollateralization](#aggregate-overcollateralization)

3. [Felix CDP Overview](#liquity-v2-overview)

4. [Multicollateral Architecture Overview](#multicollateral-architecture-overview)

5. [Core System Contracts](#core-system-contracts)
   - [Top Level Contracts](#top-level-contracts)
   - [Branch-level Contracts](#branch-level-contracts)
   - [Peripheral Helper Contracts](#peripheral-helper-contracts)

6. [Mainnet PriceFeed Contracts](#mainnet-pricefeed-contracts)

7. [Public State-changing Functions](#public-state-changing-functions)
   - [CollateralRegistry](#collateralregistry)
   - [BorrowerOperations](#borroweroperations)
   - [TroveManager](#trovemanager)
   - [StabilityPool](#stabilitypool)
   - [All PriceFeeds](#all-pricefeeds)
   - [feUSDToken](#feUSDtoken)

8. [Borrowing, Fees, and Interest Rates](#borrowing-fees-and-interest-rates)
   - [Interest on Trove Debt](#interest-on-trove-debt)
   - [Applying a Trove’s Interest](#applying-a-troves-interest)
   - [Interest Rate Scheme Implementation](#interest-rate-scheme-implementation)
   - [Aggregate vs Individual Recorded Debts](#aggregate-vs-individual-recorded-debts)
   - [Redemption Evasion Mitigation](#redemption-evasion-mitigation)
   - [Upfront Borrowing Fees](#upfront-borrowing-fees)
   - [Premature Adjustment Fees](#premature-adjustment-fees)

9. [feUSD Redemptions](#feUSD-redemptions)

10. [Redemption Routing](#redemption-routing)

11. [Redemptions at Branch Level](#redemptions-at-branch-level)
   - [Redemption Fees](#redemption-fees)
   - [Fee Schedule](#fee-schedule)
   - [Redemption Fee During Bootstrapping Period](#redemption-fee-during-bootstrapping-period)

12. [Unredeemable Troves](#unredeemable-troves)

13. [Stability Pool Implementation](#stability-pool-implementation)
   - [How Deposits and ETH Gains are Calculated](#how-deposits-and-eth-gains-are-calculated)
   - [Collateral Gains from Liquidations and the Product-Sum Algorithm](#collateral-gains-from-liquidations-and-the-product-sum-algorithm)
   - [feUSD Yield Gains](#feUSD-yield-gains)
   - [Liquidation and the Stability Pool](#liquidation-and-the-stability-pool)

14. [Liquidation Logic](#liquidation-logic)

15. [Liquidation Penalties and Borrowers’ Collateral Surplus](#liquidation-penalties-and-borrowers-collateral-surplus)
   - [Claiming Collateral Surpluses](#claiming-collateral-surpluses)

16. [Liquidation Gas Compensation](#liquidation-gas-compensation)

17. [Redistributions](#redistributions)
   - [Corrected Stake Solution](#corrected-stake-solution)

18. [Critical Collateral Ratio (CCR) Restrictions](#critical-collateral-ratio-ccr-restrictions)

19. [Delegation](#delegation)
   - [Add and Remove Managers](#add-and-remove-managers)
   - [Individual Interest Delegates](#individual-interest-delegates)
   - [Batch Interest Managers](#batch-interest-managers)
   - [Batch Management Implementation](#batch-management-implementation)

20. [Collateral Branch Shutdown](#collateral-branch-shutdown)
   - [Shutdown Logic](#shutdown-logic)
   - [Urgent Redemptions](#urgent-redemptions)

21. [Collateral Choices in Felix CDP](#collateral-choices-in-liquity-v2)

22. [Oracles in Felix CDP](#oracles-in-liquity-v2)

23. [Known Issues and Mitigations](#known-issues-and-mitigations)
   - [1 - Oracle Price Frontrunning](#1---oracle-price-frontrunning)
   - [2 - Bypassing Redemption Routing Logic via Temporary SP Deposits](#2---bypassing-redemption-routing-logic-via-temporary-sp-deposits)
   - [3 - Path-dependent Redemptions: Lower Fee when Chunking](#3---path-dependent-redemptions-lower-fee-when-chunking)
   - [4 - Oracle Failure and Urgent Redemptions with the Frozen Last Good Price](#4---oracle-failure-and-urgent-redemptions-with-the-frozen-last-good-price)
   - [5 - Stale Oracle Price Before Shutdown Triggered](#5---stale-oracle-price-before-shutdown-triggered)
   - [6 - Batch Management Ops Don’t Check for a Shutdown Branch](#6---batch-management-ops-dont-check-for-a-shutdown-branch)
   - [7 - Discrepancy Between Aggregate and Sum of Individual Debts](#7---discrepancy-between-aggregate-and-sum-of-individual-debts)
   - [8 - Discrepancy Between `yieldGainsOwed` and Sum of Individual Yield Gains in StabilityPool](#8---discrepancy-between-yieldgainsowed-and-sum-of-individual-yield-gains-in-stabilitypool)
   - [9 - LST Oracle Risks](#9---lst-oracle-risks)
   - [10 - Branch Shutdown and Bad Debt](#10---branch-shutdown-and-bad-debt)
   - [11 - Inaccurate Calculation of Average Branch Interest Rate](#11---inaccurate-calculation-of-average-branch-interest-rate)
   - [12 - TroveManager Can Make Troves Liquidatable by Changing the Batch Interest Rate](#12---trovemanager-can-make-troves-liquidatable-by-changing-the-batch-interest-rate)
   - [13 - Trove Adjustments May Be Griefed by Sandwich Raising the Average Interest Rate](#13---trove-adjustments-may-be-griefed-by-sandwich-raising-the-average-interest-rate)
   - [14 - Stability Pool Claiming and Compounding Yield Can Be Used to Gain a Slightly Higher Rate of Rewards](#14---stability-pool-claiming-and-compounding-yield-can-be-used-to-gain-a-slightly-higher-rate-of-rewards)
   - [15 - Urgent Redemptions Premium Can Worsen the ICR](#15---urgent-redemptions-premium-can-worsen-the-icr)

24. [Appendix](#appendix)

25. [Requirements](#requirements)

26. [Setup](#setup)

27. [How to Develop](#how-to-develop)

28. [License Notice](#license-notice)


## Significant changes in Felix CDP

- **Multi-collateral system.** The system now consists of a CollateralRegistry and multiple collateral branches. Each collateral branch is parameterized separately with its own Minimum Collateral Ratio (MCR), Critical Collateral Ratio (CCR) and Shutdown Collateral Ratio (SCR). Each collateral branch contains its own TroveManager and StabilityPool. Troves in a given branch only accept a single collateral (never mixed collateral). Liquidations of Troves in a given branch via SP offset are offset purely against the SP for that branch, and liquidation gains for SP depositors are always paid in a single collateral. Similarly, liquidations via redistribution split the collateral and debt across purely active Troves in that branch.
 
- **User-set interest rates.** When a borrower opens a Trove, they choose their own annual interest rate. They may change their annual interest rate at any point. Simple (non-compounding) interest accrues on their debt continuously, and gets compounded discretely every time the Trove is touched. Aggregate accrued Trove debt is periodically minted as feUSD. 

- **Yield from interest paid to SP and LPs.** feUSD yields from Trove interest are periodically paid out in a split to the Stability Pool (SP), and to a router which in turn routes its yield share to DEX LP incentives.  Yield paid to the SP from Trove interest on a given branch is always paid to the SP on that same branch.

- **Redemption routing.** Redemptions of feUSD are routed by the CollateralRegistry. For a given redemption, the redemption volume that hits a given branch is proportional to its relative “unbackedness”. The primary goal of redemptions is to restore the feUSD peg. A secondary purpose is to reduce the unbackedness of the most unbacked branches relatively more than the more backed branches. Unbackedness is defined as the delta between the total feUSD debt of the branch, and the feUSD in the branch’s SP.

- **Redemption ordering.** In a given branch, redemptions hit Troves in order of their annual interest rate, from lowest to highest. Troves with higher annual interest rates are more shielded from redemptions - they have more “debt-in-front” of them than Troves with lower interest rates. A Trove’s collateral ratio is not taken into account at all for redemption ordering.

- **Unredeemable Troves.** Redemptions now do not close Troves - they leave them open. Redemptions may now leave some Troves with a zero or very small feUSD debt < MIN_DEBT. These Troves are tagged as `unredeemable` in order to eliminate a redemption griefing attack vector. They become redeemable again when the borrower brings them back above the `MIN_DEBT`.

- **Troves represented by NFTs.** Troves are freely transferable and a given Ethereum address may own multiple Troves (by holding the corresponding NFTs).

- **Individual delegation.** A Trove owner may appoint an individual manager to set their interest rate and/or control debt and collateral adjustments.

- **Batch delegation.** A Trove owner may appoint a batch manager to manage their interest rate. A batch manager can adjust the interest rate of their batch within some predefined range (chosen by the batch manager at registration). A batch interest rate adjustment updates the interest rate for all Troves in the batch in a gas-efficient manner.

- **Collateral branch shutdown.** Under extreme negative conditions - i.e. sufficiently major collapse of the collateral market price, or an oracle failure - a collateral branch will be shut down. This entails freezing all borrower operations (except for closing of Troves), freezing interest accrual, and enabling “urgent” redemptions which have 0 redemption fee and even pay a slight collateral bonus to the redeemer. The intent is to clear as much debt from the branch as quickly as possible.

- **Removal of Recovery Mode**. The old Recovery Mode logic has been removed. Troves can only be liquidated when their collateral ratio (ICR) is below the minimum (MCR). However, some borrowing restrictions still apply below the critical collateral threshold (CCR) for a given branch.

- **Liquidation penalties**. Liquidated borrowers now no longer always lose their entire collateral in a liquidation. Depending on the collateral branch and liquidation type, they may be able to reclaim a small remainder.

- **Gas compensation**. Liquidations now pay gas compensation to the liquidator in a mix of collateral and WHYPE. The liquidation reserve is denominated in WHYPE irrespective of the collateral plus a variable compensation in the collateral, which is capped to avoid excessive compensations. 

- **More flexibility for SP reward claiming**.. SP depositors can now claim or stash their LST gains from liquidations, and either claim their feUSD yield gains or add them to their deposit.

### What remains the same in v2 from v1?

- **Core redemption mechanism** - swaps 1 feUSD for $1 worth of collateral, less the fee, in order to maintain a hard feUSD price floor


- **Redemption fee mechanics at branch level**. The `baseRate` with fee spike based on redemption volume, and time-based decay.

- **Ordered Troves**. Each branch maintains a sorted list of Troves (though now ordered by annual interest rate).

- **Liquidation mechanisms**. Liquidated Troves are still offset against the feUSD in the SP and redistribution to active Troves in the branch if/when the SP deposits are insufficient (though the liquidation penalty applied to the borrower is reduced).

- **Similar smart contract architecture**. At branch level the system architecture closely resembles that of v1 - the `TroveManager`, `BorrowerOperations` and `StabilityPool` contracts contain most system logic and direct the flows of feUSD and collateral.

- **Stability Pool algorithm**. Same arithmetic and logic is used for tracking deposits, collateral gains and feUSD yield gains over time as liquidations deplete the pool.

- **Individual overcollateralization**. Each Trove is individually overcollateralized and liquidated below the branch-specific MCR.

- **Aggregate (branch level) overcollateralization.** Each branch is overcollateralized, measured by the respective TCR.


## Felix CDP Overview

Felix CDP is a collateralized debt platform. Users can lock up WHYPE and/or other collaterals, and issue stablecoin tokens (feUSD) to their own address. The individual collateralized debt positions are called Troves.


The stablecoin tokens are economically geared towards maintaining value of 1 feUSD = $1 USD, due to the following properties:


1. The system is designed to always be over-collateralized - the dollar value of the locked collateral exceeds the dollar value of the issued stablecoins.


2. The stablecoins are fully redeemable - users can always swap x feUSD for $x worth of a mix of collaterals, directly with the system.
   
3. The system incorporates an adaptive interest rate mechanism, managing the attractiveness and thus the demand for holding and borrowing the stablecoin in a market-driven way.  


Upon  opening a Trove by depositing a viable collateral ERC20, users may issue ("borrow") feUSD tokens such that the collateralization ratio of their Trove remains above the minimum collateral ratio (MCR) for their collateral branch. For example, for an MCR of 110%, a user with $10000 worth of WHYPE in a Trove can issue up to 9090.90 feUSD against it.


The feUSD tokens are freely exchangeable - any Ethereum address can send or receive feUSD tokens, whether it has an open Trove or not. The feUSD tokens are burned upon repayment of a Trove's debt.


The Felix CDP system prices collateral via Chainlink oracles. When a Trove falls below the MCR, it is considered under-collateralized, and is vulnerable to liquidation.


## Multicollateral Architecture Overview

The core Liquity contracts are organized in this manner:

- There is a single `CollateralRegistry`, a single `feUSDToken`, and a set of core system contracts deployed for each collateral “branch”.

- A single `CollateralRegistry` maps external collateral ERC20 tokens to a `TroveManager` address. The `CollateralRegistry` also routes redemptions across the different collateral branches.


-An entire collateral branch is deployed for each LST collateral. A collateral branch contains all the logic necessary for opening and managing Troves, liquidating Troves, Stability Pool deposits, and redemptions (from that branch).

<img width="731" alt="image" src="https://github.com/user-attachments/assets/b7fd9a4f-353b-4b1a-b32f-0abf0b8c0405">

## Core System Contracts



### Top level contracts

- `CollateralRegistry` - Records all LST collaterals and maps branch-level TroveManagers to LST collaterals. Calculates redemption fees and routes feUSD redemptions to the TroveManagers of different branches in proportion to their “outside” debt.

- `feUSDToken` - the stablecoin token contract, which implements the ERC20 fungible token as well as EIP-2612 permit functionality. The contract mints, burns and transfers feUSD tokens.

### Branch-level contracts

The three main branch-level contracts - `BorrowerOperations`, `TroveManager` and `StabilityPool` - hold the user-facing public functions, and contain most of the internal system logic.

- `BorrowerOperations`- contains the basic operations by which borrowers and managers interact with their Troves: Trove creation, collateral top-up / withdrawal, feUSD issuance and repayment, and interest rate adjustments. BorrowerOperations functions call in to TroveManager, telling it to update Trove state where necessary. BorrowerOperations functions also call in to the various Pools, telling them to move collateral/feUSD between Pools or between Pool <> user, where necessary, and it also tells the ActivePool to mint interest.

- `TroveManager` - contains functionality for liquidations and redemptions and calculating individual Trove interest. Also contains the recorded  state of each Trove - i.e. a record of the Trove’s collateral, debt and interest rate, etc. TroveManager does not hold value (i.e. collateral or feUSD). TroveManager functions call in to the various Pools to tell them to move collateral or feUSD between Pools, where necessary.

- `TroveNFT` - Implements basic mint and burn functionality for Trove NFTs, controlled by the `TroveManager`. Implements the tokenURI functionality which serves Trove metadata, i.e. a unique image for each Trove.

- `LiquityBase` - Contains common functions and is inherited by `CollateralRegistry`, `TroveManager`, `BorrowerOperations`, `StabilityPool`. 

- `StabilityPool` - contains functionality for Stability Pool operations: making deposits, and withdrawing compounded deposits and accumulated collateral and feUSD yield gains. Holds the feUSD Stability Pool deposits, feUSD yield gains and collateral gains from liquidations for all depositors on that branch.

- `SortedTroves` - a doubly linked list that stores addresses of Trove owners, sorted by their annual interest rate. It inserts and re-inserts Troves at the correct position, based on their interest rate. It also contains logic for inserting/re-inserting entire batches of Troves, modelled as doubly linked-list slices.

- `ActivePool` - holds the branch collateral balance and records the total feUSD debt of the active Troves in the branch. Mints aggregate interest in a split to the StabilityPool as well as a (to-be) yield router for DEX LP incentives (currently, to MockInterestRouter)

- `DefaultPool` - holds the total collateral balance and records the total feUSD debt of the liquidated Troves that are pending redistribution to active Troves. If an active Trove has pending collateral and debt “rewards” in the DefaultPool, then they will be applied to the Trove when it next undergoes a borrower operation, a redemption, or a liquidation.

- `CollSurplusPool` - holds and tracks the collateral surplus from Troves that have been liquidated. Sends out a borrower’s accumulated collateral surplus when they claim it. 

- `GasPool` - holds the total WHYPE gas compensation. WHYPE is transferred from the borrower to the GasPool when a Trove is opened, and transferred out when a Trove is liquidated or closed.

- `MockInterestRouter` - Dummy contract that receives the LP yield split of minted interest. To be replaced with the real yield router that directs yield to DEX LP incentives.


### Peripheral helper contracts

- `HintHelpers` - Helper contract, containing the read-only functionality for calculation of accurate hints to be supplied to borrower operations.

- `MultiTroveGetter` - Helper contract containing read-only functionality for fetching arrays of Trove data structs which contain the complete recorded state of a Trove.

### Mainnet PriceFeed contracts

Different PriceFeed contracts are needed for pricing collaterals on different branches, since the price calculation methods differ across LSTs see the [Oracle section](#oracles-in-liquity-v2). However, much of the functionality is common to a couple of parent contracts.

- `MainnetPriceFeedBase` - Base contract that contains functionality for fetching prices from external Chainlink (and possibly Redstone) push oracles, verifying the responses, and triggering collateral branch shutdown in case of an oracle failure.


- `CompositePriceFeed` - Base contract that inherits `MainnetPriceFeedBase` and contains functionality for fetching prices from two market oracles: LST-ETH and ETH-USD, and calculating a composite LST- USD `market_price`. It also fetches the LST contract’s LST-ETH exchange rate, calculates a composite LST-USD `exchange_rate_price` and the final LST-USD price returned is `min(market_price, exchange_rate_price)`.

- `WHYPEPriceFeed` Inherits `MainnetPriceFeedBase`. Fetches the ETH-USD price from a Chainlink push oracle. Used to price collateral on the WHYPE branch.

- `WSTETHPriceFeed` - Inherits `MainnetPriceFeedBase`. Fetches the STETH-USD price from a Chainlink push oracle, and computes WSTETH-USD price from the STETH-USD price the WSTETH-STETH exchange rate from the LST contract. Used to price collateral on a WSTETH branch.

- `RETHPriceFeed` - Inherits `CompositePriceFeed` and fetches the specific RETH-ETH exchange rate from RocketPool’s RETHToken. Used to price collateral on a RETH branch.

## Public state-changing functions

### CollateralRegistry


- `redeemCollateral(uint256 _feUSDAmount, uint256 _maxIterations, uint256 _maxFeePercentage)`: redeems `_feUSDAmount` of feUSD tokens from the system in exchange for a mix of collaterals. Splits the feUSD redemption according to the [redemption routing logic](#redemption-routing), redeems from a number of Troves in each collateral branch, burns `_feUSDAmount` from the caller’s feUSD balance, and transfers each redeemed collateral amount to the redeemer. Executes successfully if the caller has sufficient feUSD to redeem. The number of Troves redeemed from per branch is capped by `_maxIterationsPerCollateral`. The borrower has to provide a `_maxFeePercentage` that he/she is willing to accept which mitigates fee slippage, i.e. when another redemption transaction is processed first and drives up the redemption fee.  Troves left with `debt < MIN_DEBT` are flagged as `unredeemable`.

### BorrowerOperations

- `openTrove(
        address _owner,
        uint256 _ownerIndex,
        uint256 _collAmount,
        uint256 _feUSDAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _annualInterestRate,
        uint256 _maxUpfrontFee
    )`: creates a Trove for the caller that is not part of a batch. Transfers `_collAmount` from the caller to the system, mints `_feUSDAmount` of feUSD to their address. Mints the Trove NFT to their address. The `ETH_GAS_COMPENSATION` of 0 wHYPE is transferred from the caller to the GasPool. Opening a Trove must result in the Trove’s ICR > MCR, and also the system’s TCR > CCR. An `upfrontFee` is charged, based on the system’s _average_ interest rate, the feUSD debt drawn and the `UPFRONT_INTEREST_PERIOD`. The borrower chooses a `_maxUpfrontFee` that he/she is willing to accept in case of a fee slippage, i.e. when the system’s average interest rate increases and in turn increases the fee they’d pay.


- `openTroveAndJoinInterestBatchManager(
        address _owner,
        uint256 _ownerIndex,
        uint256 _collAmount,
        uint256 _feUSDAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        address _interestBatchManager,
        uint256 _maxUpfrontFee
    )`: creates a Trove for the caller and adds it to the chosen `_interestBatchManager`’s batch. Transfers `_collAmount` from the caller to the system and mints `_feUSDAmount` of feUSD to their address.  Mints the Trove NFT to their address. The `ETH_GAS_COMPENSATION` of 0 WHYPE is transferred from the caller to the GasPool. Opening a batch Trove must result in the Trove’s ICR >= MCR, and also the system’s TCR >= CCR. An `upfrontFee` is charged, based on the system’s _average_ interest rate, the feUSD debt drawn and the `UPFRONT_INTEREST_PERIOD`. The fee is added to the Trove’s debt. The borrower chooses a `_maxUpfrontFee` that he/she is willing to accept in case of a fee slippage, i.e. when the system’s average interest rate increases and in turn increases the fee they’d pay.

- `addColl(uint256 _troveId, uint256 _collAmount)`: Transfers the `_collAmount` from the user to the system, and adds the received collateral to the caller's active Trove.

- `withdrawColl(uint256 _troveId, uint256 _amount)`: withdraws _amount of collateral from the caller’s Trove. Executes only if the user has an active Trove, must result in the user’s Trove `ICR >= MCR` and must obey the adjustment [CCR constraints](#critical-collateral-ratio-ccr-restrictions).

 - `withdrawfeUSD(uint256 _troveId, uint256 _amount, uint256 _maxUpfrontFee)`: adds _amount of feUSD to the user’s Trove’s debt, mints feUSD stablecoins to the user. Must result in `ICR >= MCR` and must obey the adjustment [CCR constraints](#critical-collateral-ratio-ccr-restrictions). An `upfrontFee` is charged, based on the system’s _average_ interest rate, the feUSD debt drawn and the `UPFRONT_INTEREST_PERIOD`. The fee is added to the Trove’s debt. The borrower chooses a `_maxUpfrontFee` that he/she is willing to accept in case of a fee slippage, i.e. when the system’s average interest rate increases and in turn increases the fee they’d pay.	

 - `repayfeUSD(uint256 _troveId, uint256 _amount)`: repay `_amount` of feUSD to the caller’s Trove, canceling that amount of debt. Transfers the feUSD from the caller to the system.

 - `closeTrove(uint256 _troveId)`: repays all debt in the user’s Trove, withdraws all their collateral to their address, and closes their Trove. Requires the borrower have a feUSD balance sufficient to repay their Trove's debt. Burns the feUSD from the user’s address.

- `adjustTrove(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _debtChange,
        bool isDebtIncrease,
        uint256 _maxUpfrontFee
    )`:  enables a borrower to simultaneously change both their collateral and debt, subject to the resulting `ICR >= MCR` and the adjustment [CCR constraints](#critical-collateral-ratio-ccr-restrictions). If the adjustment incorporates a `debtIncrease`, then an `upfrontFee` is charged as per `withdrawfeUSD`.


- `adjustUnredeemableTrove(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _feUSDChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )` - enables a borrower with a unredeemable Trove to adjust it. Any adjustment must result in the Trove’s `debt > MIN_DEBT` and `ICR > MCR`, along with the usual borrowing [CCR constraints](#critical-collateral-ratio-ccr-restrictions). The adjustment reinserts it to its previous batch, if it had one.

- `claimCollateral()`: Claims the caller’s accumulated collateral surplus gains from their liquidated Troves which were left with a collateral surplus after collateral seizure at liquidation.  Sends the accumulated collateral surplus to the caller and zeros their recorded balance.

- `shutdown()`: Shuts down the entire collateral branch. Only executes if the TCR < SCR, and it is not already shut down. Mints the final chunk of aggregate interest for the branch, and flags it as shut down.

- `adjustTroveInterestRate(
        uint256 _troveId,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )`: Change’s the caller’s annual interest rate on their Trove. The update is considered “premature” if they’ve recently changed their interest rate (i.e. within `INTEREST_RATE_ADJ_COOLDOWN` seconds), and if so, they incur an upfront fee - see the [interest rate adjustment section](#interest-rate-adjustments-redemption-evasion-mitigation).  The fee is also based on the system average interest rate, so the user may provide a `_maxUpfrontFee` if they make a premature adjustment.

- `applyPendingDebt(uint256 _troveId, uint256 _lowerHint, uint256 _upperHint)`: Applies all pending debt to the Trove - i.e. adds its accrued interest and any redistribution debt gain, to its recorded debt and updates its `lastDebtUpdateTime` to now. The purpose is to make sure all Troves can have their interest and gains applied with sufficient regularity even if their owner doesn’t touch them. Also makes unredeemable Troves that have reached `debt > MIN_DEBT` (e.g. from interest or redistribution gains) become redeemable again, by reinserting them to the SortedList and previous batch (if they were in one).  If the Trove is in a batch, it applies all of the batch's accrued interest and accrued management fee to the batch's recorded debt, as well as the _individual_ Trove's redistribution debt gain.

-  `setAddManager(uint256 _troveId, address _manager)`: sets an “Add” manager for the caller’s chosen Trove, who has permission to add collateral and repay debt to their Trove.

-  `setRemoveManager(uint256 _troveId, address _manager)`: sets a “Remove” manager for the caller’s chosen Trove, who has permission to remove collateral from and draw new feUSD from their Trove.

- `setRemoveManagerWithReceiver(uint256 _troveId, address _manager, address _receiver)`: sets a “Remove” manager for the caller’s chosen Trove, who has permission to remove collateral from and draw new feUSD from their Trove to the provided `_receiver` address.

- `setInterestIndividualDelegate(
        uint256 _troveId,
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )`: the Trove owner sets an individual delegate who will have permission to update the interest rate for that Trove in range `[ _minInterestRate,  _maxInterestRate]`.  Removes the Trove from a batch if it was in one. 

- `removeInterestIndividualDelegate(uint256 _troveId):` the Trove owner revokes individual delegate’s permission to change the given Trove’s interest rate. 

- `registerBatchManager(
        uint128 minInterestRate,
        uint128 maxInterestRate,
        uint128 currentInterestRate,
        uint128 fee,
        uint128 minInterestRateChangePeriod
    )`: registers the caller’s address as a batch manager, with their chosen min and max interest rates for the batch. Sets the `currentInterestRate` for the batch and the annual `fee`, which is charged as a percentage of the total debt of the batch. The `minInterestRateChangePeriod` determines how often the batch manager will be able to change the batch’s interest rates going forward.
   
- `lowerBatchManagementFee(uint256 _newAnnualFee)`: reduces the annual batch management fee for the caller’s batch. Mints accrued interest and accrued management fees to-date.

- `setBatchManagerAnnualInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )`: sets the annual interest rate for the caller’s batch. Executes only if the `minInterestRateChangePeriod` has passed.  Applies an upfront fee on premature adjustments, just like individual Trove interest rate adjustments. Mints accrued interest and accrued management fees to-date.


- `setInterestBatchManager(
        uint256 _troveId,
        address _newBatchManager,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )`: Trove owner sets a new `_newBatchManager` to control their Trove’s interest rate and inserts it to the chosen batch. The `_newBatchManager` must already be registered. Since this action very likely changes the Trove’s interest rate, it’s subject to a premature adjustment fee as per regular adjustments.


- `removeFromBatch(
        uint256 _troveId,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    )`: revokes the batch manager’s permission to manage the caller’s Trove. Sets a new owner-chosen annual interest rate, and removes it from the batch. Since this action very likely changes the Trove’s interest rate, it’s subject to a premature adjustment fee as per regular adjustments.

### TroveManager

- `liquidate(uint256 _troveId)`: attempts to liquidate the specified Trove. Executes successfully if the Trove meets the conditions for liquidation, i.e. ICR < MCR. Permissionless.


- `batchLiquidateTroves(uint256[] calldata _troveArray)`: Accepts a custom list of Troves IDs as an argument. Steps through the provided list and attempts to liquidate every Trove, until it reaches the end or it runs out of gas. A Trove is liquidated only if it meets the conditions for liquidation, i.e. ICR < MCR. Troves with ICR >= MCR are skipped in the loop. Permissionless.


- `urgentRedemption(uint256 _feUSDAmount, uint256[] calldata _troveIds, uint256 _minCollateral)`: Executes successfully only when the collateral branch has already been shut down.  Redeems only from the branch it is called on. Redeems from Troves with a slight collateral bonus - that is, 1 feUSD redeems for $1.01 worth of LST collateral.  Does not flag any redeemed-from Troves as `unredeemable`. Caller specifies the `_minCollateral` they want to receive.

### StabilityPool

- `provideToSP(uint256 _amount, bool _doClaim)`: deposit _amount of feUSD to the Stability Pool. It transfers _amount of feUSD from the caller’s address to the Pool, and tops up their feUSD deposit by _amount. `doClaim` determines how the depositor’s existing collateral and feUSD yield gains (if any exist) are treated: if true they’re transferred to the depositor’s address, otherwise the collateral is stashed (added to a balance tracker) and the feUSD gain is added to their deposit.

- `withdrawFromSP(uint256 _amount, bool doClaim)`: withdraws _amount of feUSD from the Stability Pool, up to the value of their remaining deposit. It increases their feUSD balance by _amount. If the user makes a partial withdrawal, their remaining deposit will earn further liquidation and yield gains.  `doClaim` determines how the depositor’s existing collateral and feUSD yield gains (if any exist) are treated: if true they’re transferred to the depositor’s address, otherwise the collateral is stashed (added to a balance tracker) and the feUSD gain is added to their deposit.


- `claimAllCollGains()`: Sends all stashed collateral gains to the caller and zeros their stashed balance. Used only when the caller has no current deposit yet has stashed collateral gains from the past.

### All PriceFeeds

`fetchPrice()`:  Permissionless. Tells the PriceFeed to fetch price answers from oracles, and if necessary calculates the final derived LST-USD price. Checks if any oracle used has failed (i.e. if it reverted, returned a stale price, or a 0 price). If so, shuts the collateral branch down. Otherwise, stores the fetched price as `lastGoodPrice`. 

### feUSDToken

Standard ERC20 and EIP2612 (`permit()` ) functionality.



## Borrowing, fees and interest rates

When a Trove is opened, borrowers commit an amount of their chosen LST token as collateral, select their feUSD debt, and select an interest rate in range `[INTEREST_RATE_MIN, INTEREST_RATE_MAX]`.

### Interest on Trove debt

Interest in Felix CDP is **simple** interest and non-compounding - that is, for a given Trove debt, interest accrues linearly over time and proportional to its recorded debt as long as the Trove isn’t altered.


Troves have a `recordedDebt` property which stores the Trove’s entire debt at the time it was last updated.

A Trove’s accrued interest is calculated dynamically  as `d * period`

Where:

- `d` is recorded debt
- `period` is the time passed since the recorded debt was updated.


This is calculated in `TroveManager.calcTroveAccruedInterest`.

The getter `TroveManager.getTroveEntireDebt` incorporates all accrued interest into the final return value. All references to `entireDebt` in the code incorporate the Trove’s accrued Interest.

### Applying a Trove’s interest

Upon certain actions that touch the Trove, its accrued interest is calculated and added to its recorded debt. Its `lastUpdateTime`  property is then updated to the current time, which makes its accrued interest reset to 0.

The following actions apply a Trove’s interest:

- Borrower or manager changes The Trove’s collateral or debt with `adjustTrove`
- Borrower or manager adjusts the Trove’s interest rate with `adjustTroveInterestRate`
- Trove gets liquidated
- Trove gets redeemed
- Trove’s accrued interest is permissionlessly applied by anyone with `applyTroveInterestPermissionless`


### Interest rate scheme implementation

As well as individual Trove’s interest, we also need to track the total accrued interest in a branch, in order to calculate its total debt (in turn needed to calculate the TCR).


This must be done in a scalable way - and looping over Troves and summing their accrued interest would not be scalable.

To calculate total accrued interest, the Active Pool maintains two global tracker sums:
- `weightedRecordedDebtSum` 
- `aggRecordedDebt`

Along with a timekeeping variable  `lastDebtUpdateTime`


`weightedRecordedDebtSum` tracks the sum of Troves’ debts weighted by their respective annual interest rates.

The aggregate pending interest at any given moment is given by 

`weightedRecordedDebtSum * period`

 where period is the time since the last update.

At most system operations, the `aggRecordedDebt` is updated - the pending aggregate interest is calculated and added to it, and the `lastDebtUpdateTime` is updated to now - thus resetting the aggregate pending interest.

The theoretical approach is laid out in [this paper](https://docs.google.com/document/d/1KOP09exxLcrNKHoJ9zgxvNFS_W9AIy5jt85OqmeAwN4/edit?usp=sharing).

In practice, the implementation in code follows these steps but the exact sequence of operations is sometimes different due to other considerations (e.g. gas efficiency).

### Aggregate vs individual recorded debts

Importantly, the `aggRecordedDebt` does *not* always equal the sum of individual recorded Trove debts.

This is because the `aggRecordedDebt` is updated very regularly, whereas a given Trove’s recorded debt may not be.  When the `aggRecordedDebt` has been updated more recently than a given Trove, then it already includes that Trove’s accrued interest - because when it is updated, _all_ Trove's accrued pending interest is added to it.

It’s best to think of the `aggRecordedDebt` and aggregate interest calculation running in parallel to the individual recorded debts and interest.

[This example](https://docs.google.com/spreadsheets/d/1Q_PtY4iyUsTNVQi-a90fS0B4ODEQpJE-GwpiIUDRoas/edit?usp=sharing) illustrates how it works.

[TODO - DIAGRAM]

### Core debt invariant 

For a given branch, the system maintains the following invariant:

**Aggregate total debt of a branch always equals the sum of individual entire Trove debts**.

That is:

```
ActivePool.aggRecordedDebt + ActivePool.calcPendingAggInterest()
+ ActivePool.aggBatchManagementFees() + ActivePool.calcPendingAggBatchManagementFee()
+ DefaultPool.feUSDDebt
= SUM_i=1_n(TroveManager.getEntireTroveDebt())
```

For all `n` Troves in the branch.

It can be shown mathematically that this holds (TBD).

### Applying and minting pending aggregate interest 

Pending aggregate interest is “applied” upon most system actions. That is:

- The  `aggRecordedDebt` is updated - the pending aggregate interest is calculated and added to `aggRecordedDebt`, and the `lastDebtUpdateTime` is updated to now.

- The pending aggregate interest is minted by the ActivePool as fresh feUSD. This is considered system “yield”.  A fixed part (72%, final value TBD) of it is immediately sent to the branch’s SP and split proportionally between depositors, and the remainder is sent to a router to be used as LP incentives on DEXes (determined by governance).

This is the only way feUSD is ever minted as interest. Applying individual interest to a Trove updates its recorded debt, but interest is always minted in aggregate.


### Redemption evasion mitigation

In healthy system states (TCR > CCR) a borrower may adjust their Trove’s interest rate or debt at any time, as well as close their Trove. As such, a borrower may evade a redemption transaction by either frontrunning it with an interest rate adjustment, or closing and reopening their Trove. Both "hard" and "soft" frontrunning are viable: savvy borrowers may watch the mempool for redemption transactions, or simply watch the feUSD peg, and take evasive action when it is below $1 and redemptions are likely imminent.

To disincentivize redemption evasion, two upfront fees are implemented: a borrowing fee, as well as a premature interest rate adjustment fee.

### Upfront borrowing fees

An upfront borrowing fee is applied when a borrower:
- Opens a Trove
- Increases the debt of their Trove

The creates a cost for the borrower seeking to evade a redemption by closing and reopening their trove.

The upfront borrowing fee is equal to 7 days of average interest on the respective collateral branch. It is charged in feUSD and is added to the Trove's debt.

### Premature adjustment fees

Since redemptions are performed in order of Troves’ user-set interest rates, a “premature adjustment fee” mechanism is in place. Without it, low-interest rate borrowers could evade redemptions by sandwiching a redemption transaction with both an upward and downward interest rate adjustment, which in turn would unduly direct the redemption against higher-interest borrowers.

The premature adjustment fee works as so:

- When a Trove is opened, its `lastInterestRateAdjTime` property is set equal to the current time
- When a borrower adjusts their interest rate via `adjustTroveInterestRate` the system checks that the cooldown period has passed since their last interest rate adjustment 
- If the adjustment is sooner it incurs an upfront fee (equal to 7 days of average interest of the respective branch) which is added to their debt.

#### Batches and premature adjustment fees

##### Joining a batch
When a trove joins a batch, it pays an upfront fee if the last trove adjustment was done more than the cool period ago. It does’t matter if the Trove and batch have the same interest rate, or when was the last adjustment by the batch.

The last interest rate timestamp will be updated to the time of joining.

Batch interest rate changes only take into account global batch timestamps, so when the new batch manager changes the interest rate less than the cooldown period after the borrower moved to the new batch, but more than the cooldown period after its last adjustment, the newly joined borrower wouldn't pay the upfront fee despite the fact that his last interest rate change happened less than the cooldown period ago.

That’s why Troves pay upfront fee when joining even if the interest is the same. Otherwise a trove may game it by having a batch created in advance (with no recent changens), joining it and the changing the rate of the batch.

##### Leaving a batch
When a trove leaves a batch, the user's timestamp is again reset to the current time.
No upfront fee is charged, unless the interest rate is changed in the same transaction and either the batch changed the interest rate, or the trove joined the batch, less than the cooldown period ago.

##### Switching batches
As the function to switch batches is just a wrapper that calls the functions for leaving and joining a batch, this means that switching batches always incurs in upfront fee now (unless user doesn’t use the wrapper and waits for 1 week between leaving and joining).


## feUSD Redemptions

Any feUSD holder (whether or not they have an active Trove) may redeem their feUSD directly with the system. Their feUSD is exchanged for a mixture of collaterals at face value: redeeming 1 feUSD token returns $1 worth of collaterals (minus a dynamic redemption fee), priced at their current market values according to their respective oracles. Redemptions have two purposes:


1. When feUSD is trading at <$1 on the external market, arbitrageurs may redeem `$x` worth of feUSD for `>$x` worth of collaterals, and instantly sell those collaterals to make a profit. This reduces the circulating supply of feUSD which in turn should help restore the $1 feUSD peg.


2. Redemptions improve the relative health of the least healthy collateral branches (those with greater "outside" debt, i.e. debt not covered by their SP).


## Redemption routing

<img width="742" alt="image" src="https://github.com/user-attachments/assets/6df3b8bf-ccd8-4aa0-9796-900ea808a352">


Redemptions are performed via the `CollateralRegistry.redeemCollateral` endpoint. A given redemption may be routed across several collateral branches.

A given feUSD redemption is split across branches according in proportion to the **outside debt** of that branch, i.e. (pseudocode):

`redeem_amount_i = redeem_amount * outside_debt_i / total_outside_debt`

Where `outside_debt_i` for branch i is given by `feUSD_debt_i  - feUSD_in_SP_i`.

That is, a redemption reduces the outside debt on each branch by the same percentage.

_Example: 2000 feUSD is redeemed across 4 branches_

<img width="704" alt="image" src="https://github.com/user-attachments/assets/21afcc49-ed50-4f3e-8b36-1949cd7a3809">

As can be seen in the above table and proven in generality (TBD), the outside debt is reduced by the same proportion in all branches, making redemptions path-independent.


[TODO - GRAPH BRANCH REDEMPTION]


## Redemptions at branch level

When feUSD is redeemed for collaterals, the system cancels the feUSD with debt from Troves, and the corresponding collateral is removed.

In order to fulfill the redemption request on a given branch, Troves are redeemed from in ascending order of their annual interest rates.

A redemption sequence of n steps will fully redeem all debt from the first n-1 Troves, and, and potentially partially redeem from the final Trove in the sequence.


Redemptions are skipped for Troves with ICR  < 100%. This is to ensure that redemptions improve the ICR of the Trove.

Unredeemable troves are also skipped - see [unredeemable Troves section](#unredeemable-troves).

### Redemption fees

The redemption fee mechanics are broadly the same as in Liquity v1,  but with adapted parametrization (TBD). The redemption fee is taken as a cut of the total ETH drawn from the system in a redemption. It is based on the current redemption rate.

The fee percentage is calculated in the `CollateralRegistry`, and then applied to each branch.

### Rationale for fee schedule


The larger the redemption volume, the greater the fee percentage applied to that redemption.

The longer the time delay since the last redemption, the more the `baseRate` decreases.

The intent is to throttle large redemptions with higher fees, and to throttle further redemptions immediately after large redemption volumes. The `baseRate` decay over time ensures that the fee will “cool down”, while redemptions volumes are low.

Furthermore, the fees cannot become smaller than the fee floor of 0.5%, which somewhat mitigates arbitrageurs frontrunning Chainlink oracle price updates with redemption transactions.

The redemption fee (red line) should follow this dynamic over time as redemptions occur (blue bars).

[REDEMPTION COOLDOWN GRAPH]

<img width="703" alt="image" src="https://github.com/user-attachments/assets/810fff65-3fd0-41fb-9810-c6940f143aa3">



### Fee Schedule

Redemption fees are based on the `baseRate` state variable in `CollateralRegistry`, which is dynamically updated. The `baseRate` increases with each redemption, and exponentially decays according to time passed since the last redemption.


The current fee schedule:

Upon each redemption of x feUSD:

- `baseRate` is decayed based on time passed since the last fee event and incremented by an amount proportional to the fraction of the total feUSD supply to be redeemed, i.e. `x/total_feUSD_supply`

The redemption fee percentage is given by `min(REDEMPTION_FEE_FLOOR + baseRate , 1)`.

### Redemption fee during bootstrapping period

At deployment, the `baseRate` is set to `INITIAL_REDEMPTION_RATE`, which is some sizable value e.g. 5%  - exact value TBD. It then decays as normal over time.

The intention is to discourage early redemptions in the early days when the total system debt is small, and give it time to grow.


## Unredeemable Troves

In Felix CDP, redemptions do not close Troves (unlike v1).

**Rationale for leaving Troves open**: Troves are now ordered by interest rate rather than ICR, and so (unlike v1) it is now possible to redeem Troves with ICR > TCR.  If such Troves were closed upon redemption, then redemptions may lower the TCR - this would be an economic risk / attack vector.

Hence redemptions in v2 always leave Troves open. This ensures that normal redemptions never lower the TCR* of a branch.

**Need for unredeemable Troves**: Leaving Troves open at redemption means redemptions may result in Troves with very small (or zero) `debt < MIN_DEBT`.  This could create a griefing risk - by creating many Troves with tiny `debt < MIN_DEBT` at the minimum interest rate, an attacker could “clog up” the bottom of the sorted list of Troves, and future redemptions would hit many Troves without redeeming much feUSD, or even be unprofitable due to gas costs.

Therefore, when a Trove is redeemed to below MIN_DEBT, it is tagged as unredeemable and removed from the sorted list.  

When a borrower touches their unredeemable Trove, they must either bring it back to `debt > MIN_DEBT` (in which case the Trove becomes redeemable again), or close it. Adjustments that leave it with insufficient debt are not possible.

Pending debt gains from redistributions and accrued interest can bring the Trove's debt above `MIN_DEBT`, but these pending gains don't make the Trove redeemable again. Only the borrower can do that when they adjust it and leave their recorded `debt > MIN_DEBT`.

### Full unredeemable Troves logic

When a Trove is redeemed down to `debt < MIN_DEBT`, we:
- Change its status to `unredeemable`
- Remove it from the SortedTroves list
- _Don't_ remove it from the `TroveManager.Troves` array since this is only used for off-chain hints (also this saves gas for the borrower for future Trove touches)


Unredeemable Troves:


- Can not be redeemed
- Can be liquidated
- Do receive redistribution gains
- Do accrue interest
- Can have their accrued interest permissionlessly applied
- Can not have their interest rate changed by their owner/manager
- Can not be adjusted such that they're left with debt <`MIN_DEBT` by owner/manager
- Can be closed by their owner
- Can be brought above `MIN_DEBT` by owner (which re-adds them to the Sorted Troves list, and changes their status back to 'Active')

_(*as long as TCR > 100%. If TCR < 100%, then normal redemptions would lower the TCR, but the shutdown threshold is set above 100%, and therefore the branch would be shut down first. See the [shutdown section](#shutdown-logic) )_


## Stability Pool implementation

feUSD depositors in the Stability Pool on a given branch earn:

- feUSD yield paid from interest minted on Troves on that branch
- Collateral penalty gains from liquidated Troves on that branch


Depositors deposit feUSD to the SP via `provideToSP` and withdraw it with `withdrawFromSP`. 

Their accumulated collateral gains and feUSD yield gains are calculated every time they touch their deposit - i.e. at top up or withdrawal. If the depositor chooses to withdraw gains (via the `doClaim` bool param), all their collateral and feUSD yield gain are sent to their address.

Otherwise, their collateral gain is stashed in a tracked balance and their feUSD yield gain is added to their deposit.



### How deposits and ETH gains are calculated


The SP uses a scalable method of tracking deposits, collateral and yield gains which has O(1) complexity - i.e. constant gas cost regardless of the number of depositors. 

It is the same Product-Sum algorithm from Liquity v1.


### Collateral gains from Liquidations and the Product-Sum algorithm

When a liquidation occurs, rather than updating each depositor’s deposit and collateral and yield gain, we simply update two global tracker variables: a product `P`, a sum `S` corresponding to the collateral gain.

A mathematical manipulation allows us to factor out the initial deposit, and accurately track all depositors’ compounded deposits and accumulated collateral gains over time, as liquidations occur, using just these two variables. When depositors join the Stability Pool, they get a snapshot of `P` and `S`.  

The approach is similar in spirit to the Scalable Reward Distribution on the Ethereum Network by Bogdan Batog et al (i.e. the standard UniPool algorithm), however, the arithmetic is more involved as it handles a compounding, decreasing stake along with a corresponding collateral gain.

The formula for a depositor’s accumulated collateral gain is derived here:


### Scalable reward distribution for compounding, decreasing stake

Each liquidation updates `P` and `S`. After a series of liquidations, a compounded deposit and corresponding ETH gain can be calculated using the initial deposit, the depositor’s snapshots, and the current values of `P` and `S`.

Any time a depositor updates their deposit (withdrawal, top-up) their collateral gain is paid out, and they receive new snapshots of `P` and `S`.

### feUSD Yield Gains

feUSD yield gains for Stability Pool depositors are triggered whenever the ActivePool mints aggregate system interest - that is, upon most system operations. The feUSD yield gain is minted to the Stability Pool and a feUSD gain for all depositors is triggered in proportion to their deposit size.

To efficiently and accurately track feUSD yield gains for depositors as deposits decrease over time from liquidations, we re-use the above product-sum algorithm for deposit and gains.


The same product `P` is used, and a sum `B` is used to track feUSD yield gains. Each deposit gets a new snapshot of `B` when it is updated.


## Liquidation and the Stability Pool

When a Trove’s collateral ratio falls below the minimum collateral ratio (MCR) for its branch, it becomes immediately liquidatable.  Anyone may call `batchLiquidateTroves` with a custom list of Trove IDs to attempt to liquidate.

In a liquidation, most of the Trove’s collateral is seized and the Trove is closed.


Liquity utilizes a two-step liquidation mechanism in the following order of priority:

1. Offset under-collateralized Troves’ debt against the branch’s SP containing feUSD tokens, and award the seized collateral to the SP depositors
2. When the SP is empty, Redistribute under-collateralized Troves debt and seized collateral to other Troves in the same branch

Liquity primarily uses the feUSD tokens in its Stability Pool to absorb the under-collateralized debt, i.e. to repay the liquidated borrower's liability.

Any user may deposit feUSD tokens to any Stability Pool. This allows them to earn the collateral from Troves liquidated on the branch. When a liquidation occurs, the liquidated debt is cancelled with the same amount of feUSD in the Pool (which is burned as a result), and the seized collateral is proportionally distributed to depositors.

Stability Pool depositors can expect to earn net gains from liquidations, as in most cases, the value of the seized collateral will be greater than the value of the cancelled debt (since a liquidated Trove will likely have an ICR just slightly below the MCR). MCRs are constants and may differ between branches, but all take a value above 100%.

If the liquidated debt is higher than the amount of feUSD in the Stability Pool, the system applies both steps 1) and then 2): that is, it cancels as much debt as possible with the feUSD in the Stability Pool, and then redistributes the remaining liquidated collateral and debt across all active Troves in the branch.


## Liquidation logic

| Condition                         | Description                                                                                                                                                                                                                                                                                                                  |
|-----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ICR < MCR & SP.feUSD >= Trove.debt | feUSD in the StabilityPool equal to the Trove's debt is offset with the Trove's debt. The Trove's seized collateral is shared between depositors.                                                                                                                                                                                    |
| ICR < MCR & SP.feUSD < Trove.debt  | The total StabilityPool feUSD is offset with an equal amount of debt from the Trove. A portion of the Trove's collateral corresponding to the offset debt is shared between depositors. The remaining debt and seized collateral (minus collateral gas compensation) is redistributed to active Troves.  |
| ICR < MCR & SP.feUSD = 0           | Redistribute all debt and seized collateral (minus collateral gas compensation) to active Troves.                                                                                                                                                                                                                                    |
| ICR >= MCR                        | Liquidation not possible.                                                                                                                                                                                                                                                                                                     |


## Liquidation penalties and borrowers’ collateral surplus

Separate liquidation penalty percentages are used for offsets and redistributions - `LIQUIDATION_PENALTY_SP` and `LIQUIDATION_PENALTY_REDISTRIBUTION`. 

Exact values of these constants are TBD  for each branch, however the following inequalities will hold for every branch:

`LIQUIDATION_PENALTY_SP <= LIQUIDATION_PENALTY_REDISTRIBUTION <= 10% <= MCR`  

After liquidation, a liquidated borrower may have a collateral surplus to claim back (this is unlike Liquity v1 where the entire Trove collateral was always seized in Normal Mode).

In a pure offset, the maximum seized collateral is given by ` 1 + LIQUIDATION_PENALTY_SP`.  The claimable collateral surplus for the borrower is then the collateral remainder.

In a pure redistribution, the maximum seized collateral is given by `1 + LIQUIDATION_PENALTY_REDISTRIBUTION`. The claimable collateral surplus for the borrower is then the collateral remainder.

In a mixed offset and redistribution, the above logic is applied sequentially - that is:

- An intermediate collateral surplus is calculated for the offset portion of the Trove using the offset penalty
- The intermediate surplus is added to the collateral for the redistribution portion
- A final collateral surplus is calculated for the borrower using this total remaining collateral and the redistribution penalty

### Claiming collateral surpluses


Collateral surpluses for a given borrower accumulate in the CollSurplusPool, and are claimable by the borrower with `claimColl`.
                                                                                                                                                                       
## Liquidation gas compensation


The system compensates liquidators for their gas costs in order to incentivize rapid liquidations even in high gas price periods.

Gas compensation in Felix CDP is entirely paid in a mixture of WHYPE and collateral from the Trove.

When a Trove is opened, a flat `ETH_GAS_COMPENSATION` of 0 WHYPE is deposited by the borrower and set aside. This does not count as Trove’s collateral - i.e. it does not back any  debt and is not taken into account in the ICR or the TCR calculations.

If the borrower closes their Trove, this WHYPE is refunded.

The collateral portion of the gas compensation is calculated at liquidation. It is the lesser of: 0.5% of the Trove’s collateral, or 2 units of the LST.

That is, the max collateral that can be paid is 2 stETH on the stETH branch, 2 rETH on the rETH branch, etc.

Thus the total funds the liquidator receives upon a Trove liquidation is:

0.5% trove_collateral. 

## Redistributions

When a liquidation occurs and the Stability Pool is empty or smaller than the liquidated debt, the redistribution mechanism distributes the remaining collateral and debt of the liquidated Trove, to all active Troves in the system, in proportion to their collateral.

Redistribution is performed in a gas-efficient O(1) manner - that is, rather than updating the `coll` and `debt` properties on every Trove (prohbitive due to gas costs),  global tracker sums `L_Coll` and `L_feUSDDebt` are updated, and each Trove records snapshots of these at every touch. A Trove’s pending redistribution gains are calculated using these trackers, and are incorporated in `TroveManager.getEntireDebtAndColl`.

When a borrower touches their Trove, redistribution gains are applied - i.e. added to their recorded `coll` and `debt` - and its tracker snapshots are updated.

This is the standard Batog / UniPool reward distribution scheme common across DeFi.

A Trove’s redistribution gains can also be applied permissionlessly (along with accrued interest) using the function `applyTroveInterestPermissionless`. Similarly, batch redistribution gains can be applied with `applyBatchInterestAndFeePermissionless`.


### Redistributions and Corrected Stakes


For two Troves A and B with collateral `A.coll > B.coll`, Trove A should earn a bigger share of the liquidated collateral and debt.

It important that (for a given branch) the entire collateral always backs all of the debt. That is, collateral received by a Trove from redistributions should be taken into account at _future_ redistributions.


However, when it comes to implementation, Ethereum gas costs make it too expensive to loop over all Troves and write new data to storage for each one. When a Trove receives redistribution gains, the system does not update the Trove's collateral and debt properties - instead, the Trove’s redistribution gains remain "pending" until the borrower's next operation.

It is difficult to account for these “pending redistribution gains” in _future_ redistributions calculations in a scalable way, since we can’t loop over and update the recorded collateral of each Trove one-by-one.

Consider the case where a new Trove is created after all active Troves have received a redistribution from a liquidation. This “fresh” Trove has then experienced fewer rewards than the older Troves, and thus, it would receive a disproportionate share of subsequent redistributions, relative to its total collateral.

The fresh Trove would earn gains based on its entire collateral, whereas old Troves would earn rewards based only on some portion of their collateral - since a part of their collateral is pending, and not included in the old Trove’s `coll` property.

### Corrected Stake Solution

We use a corrected stake to account for this discrepancy, and ensure that newer Troves earn the same liquidation gains per unit of total collateral, as do older Troves with pending redistribution gains.
 
When a Trove is opened, its stake is calculated based on its collateral, and snapshots of the entire system collateral and debt which were taken immediately after the last liquidation.

A Trove’s stake is given by:

`stake = _coll.mul(totalStakesSnapshot).div(totalCollateralSnapshot)`

Essentially, we scale new stakes down after redistribution, rather than increasing all older stakes by their collateral redistribution gain.


The Trove then earns redistribution gains based on this corrected stake. A newly opened Trove’s stake will be less than its raw collateral, if the system contains active Troves with pending redistribution gains when it was made.

Whenever a borrower adjusts their Trove’s collateral, their pending rewards are applied, and a fresh corrected stake is computed.

## Critical collateral ratio (CCR) restrictions

When the TCR of a branch falls below its Critical Collateral Ratio (CCR), the system imposes extra restrictions on borrowing in order to maintain system health and branch overcollateralization.

Here is the full CCR-based logic:

<img width="703" alt="image" src="https://github.com/user-attachments/assets/63c1d142-ed93-47c6-a996-fe228c34476d">



As a result, when `TCR < CCR`, the following restrictions apply:

<img width="696" alt="image" src="https://github.com/user-attachments/assets/066d4bbe-58e5-4fca-8941-67341bf30e85">


### Rationale

The CCR logic has the following purposes:


- Ensure that when `TCR >= CCR` borrower operations can not reduce system health too much by bringing the `TCR < CCR`
- Ensure that when `TCR < CCR`, borrower operations only improve system health
- Ensure that when `TCR < CCR`, borrower operations can not grow the debt of the system

##  Delegation 

The system incorporates 3 types of delegation by which borrowers can outsource management of their Trove to third parties: 

- Add / Remove managers who can adjust an individual Trove’s collateral and debt
- Individual interest delegates who can adjust an individual Trove’s interest rate
- Batch interest delegates who can adjust the interest rate for a batch of several Troves

### Add and Remove managers

Add managers and Remove managers may be set by the Trove owner when the Trove is opened, or at any time later.

#### Add Managers

- An Add Manager may add collateral or repay debt to a Trove
- When set to `address(0)`, any address is allowed to perform these operations on the Trove
- Otherwise, only the designated `AddManager` in this mapping Trove is allowed to add collateral / repay debt
- A Trove owner may set the AddManager equal to their own address in order to disallow anyone from adding collateral / repaying debt.

#### Remove Managers

Remove Managers may withdraw collateral or draw new feUSD debt.

- Only the designated Remove manager, if any, and the Trove owner, are allowed 
- A receiver address may be chosen which can be different from the Remove Manager and Trove owner. The receiver receives the collateral and feUSD drawn by the Remove Manager.
- By default, a Trove has no Remove Manager - it must be explicitly set by the Trove owner upon opening or at a later point.
 - The receiver address can never be zero.

### Individual interest delegates

A Trove owner may set an individual delegate at any point after opening.The individual delegate has permission to update the Trove’s interest rate in a range set by the owner, i.e. `[ _minInterestRate,  _maxInterestRate]`.  

A Trove can not be in a managed batch if it has an individual interest delegate. 

The Trove owner may also revoke individual delegate’s permission to change the given Trove’s interest rate at any point.

### Batch interest managers

A Trove owner may set a batch manager at any point after opening. They must choose a registered batch manager. The Trove owner may remove the Trove from the batch at any time.

A batch manager controls the interest rate of Troves under their management, in a predefined range chosen when they register. This range may not be changed after registering, enabling borrowers to know in advance the min and max interest rates the manager could set.

All Troves in a given batch have the same interest rate, and all batch interest rate adjustments update the interest rate for all Troves in the batch.

Batch-management is gas-efficient and O(1) complexity - that is, altering the interest rate for a batch is constant gas cost regardless of the number of Troves. 

### Batch management implementation

In the `SortedTroves` list, batches of Troves are modeled as slices of the linked list. They utilise the new `Batch` data structure and `slice` functionality. A `Batch` contains head and tail properties, i.e. the ends of the list slice.

When a batch manager updates their batch’s interest rate, the entire `Batch` is reinserted to its new position based on the interest rate ordering of the SortedTroves list. 

 ### Internal representation as shared Trove

A batch accrues two kinds of time-based debt increases: normal interest and management fees. Individual Troves in the batch may also accrue redistribution gains (coll and debt), though these remained tracked at the individual Trove level, not at the batch level.

To handle accrued interest and fees in a gas-efficient way, the batch is internally modelled as a single “shared” Trove. 

The system tracks a batch’s `recordedDebt` and `annualInterestRate`. Accrued interest is calculated in the same way as for individual Troves, and the batch’s weighted debt is incorporated in the aggregate sum as usual.

### Batch management fee

The management fee is an annual percentage, and is calculated in the same way as annual interest.  It is initially chosen by the batch manager when they register, and can not be changed for that batch thereafter.

### Batch `recordedDebt` updates

A batch’s `recordedDebt` is updated when:
- a Trove in a batch has it’s debt updated by the borrower
- The batch manager changes the batch’s interest rate
- The pending debt of a Trove in the batch is permissionlessly applied 

The batch-level accrued interest and accrued management fees are calculated and added to the batch's recorded debt, along with any individual changes due to a Trove touch - i.e. the Trove's debt adjustment, and/or application of its pending redistribution debt gain.

### Batch premature adjustment fees

Batch managers incur premature fees in the same manner as individual Troves - i.e. if they adjust before the cooldown period has past since their last adjustment (see [premature adjustment section](#premature-adjustment-fees).

When a borrower adds their Trove to a batch, there is a trust assumption: they expect the batch manager to manage interest rates well and not incur excessive adjustment fees.  However, the manager can commit in advance to a maximum update frequency when they register by passing a `_minInterestRateChangePeriod`.

Generally is expected that competent batch managers will build good reputations and attract borrowers. Malicious or poor managers will likely end up with empty batches in the long-term.

### Batch invariants

Batch Troves are intended to be fundamentally equivalent to individual Troves. That is, if individual Trove A and batch Trove B have identical state at a given time (such as coll, debt, stake, accrued interest, etc) - then they would also have identical state after both undergoing the same operation (coll/debt adjustment, application of interest, receiving a redistribution gain).

Also, since batches are modelled as "virtual Troves", equivalences between a Batch and an equivalent individual Trove hold across identical operations.

A thorough description of these batch Trove invariants is found in the [properties and invariants](https://docs.google.com/spreadsheets/d/1WKEwXsmo_lwVWuJvcy3NmVh0IYogPQ-Z2Ab64HuJzkU/edit?usp=sharing) sheet in yellow.


## Collateral branch shutdown

Under extreme conditions such as collateral price collapse or oracle failure, a collateral branch may be shut down in order to preserve wider system health and the stability of the feUSD token.

A collateral branch is shut down when:

1. Its TCR falls below the Shutdown Collateral Ratio (SCR)

When `TCR < SCR` (1), anyone may trigger branch shutdown by calling `BorrowerOperations.shutdown`.


### Interest rates and shutdown

Upon shutdown:
- All pending aggregate interest gets applied and minted
- All pending aggregate batch management fees get applied and minted

And thereafter:
- No further aggregate interest is minted or accrued
- Individual Troves accrue no further interest. Trove accrued interest is calculated only up to the shutdown timestamp
- Batches accrue no further interest nor management fees. Accrued interest and fees are only calculated up to the shutdown timestamp

Once a branch has been shut down it can not be revived.

###  Shutdown logic

The following operations are disallowed at shutdown and also during temporary shutdown:

- Opening a new Trove
- Adjusting a Trove’s debt or collateral
- Adjusting a Trove’s interest rate
- Applying a Trove’s interest
- Adjusting a batch’s interest rate
- Applying a batch’s interest and management fee
- Normal redemptions (only under urgent redemption)

The following operations are still allowed after shut down:

- Closing a Trove
- Liquidating Troves
- Depositing to and withdrawing from the SP
- Urgent redemptions (see below)

 ### Urgent redemptions 

During shutdown the redemption logic is modified to incentivize swift reduction of the branch’s debt, and even do so when feUSD is trading at peg ($1 USD). Redemptions in shutdown are known as “urgent” redemptions.

Urgent redemptions:

- Are performed directly via the shut down branch’s `TroveManager`, and they only affect that branch. They are not routed across branches.
- Charge no redemption fee
- Pay a slight collateral bonus of 1% to the redeemer. That is, in exchange for every 1 feUSD redeemed, the redeemer receives $1.01 worth of the LST collateral.
- Do not redeem Troves in order of interest rate. Instead, the redeemer passes a list of Troves to redeem from.
- Do not create unredeemable Troves, even if the Trove is left with tiny or zero debt - since, due to the preceding point there is no risk of clogging up future urgent redemptions with tiny Troves.

## Temporary Shutdown
The temporary shutdown can happen in the following situations:
- When the AdminController contract calls the AdminShutdown() function
- When the priceFeed returns a failure in fetching the price.

The temporary shutdown disables the following operations:
- Opening a new Trove
- Adjusting a Trove’s debt or collateral
- Adjusting a Trove’s interest rate

The following operations are still allowed after temporary shut down:
- Closing a Trove
- Liquidating Troves
- Depositing to and withdrawing from the SP

The during temporary shutdown the interest accrual accountancy behaves as under regular conditions. After a branch is temporary shut down it can be resumed by the AdminController.

## Collateral choices in Felix CDP

- WHYPE
- UBTC


## Oracles in Felix CDP

Felix CDP requires accurate pricing in USD for the above collateral assets. 

All oracles are integrated via Chainlink’s `AggregatorV3Interface`, and all oracle price requests are made using its `latestRoundData` function.

#### Terminology

- _**Oracle**_ refers to the external system which Felix CDP fetches the price from- e.g. "the Chainlink ETH-USD **oracle**".
- _**PriceFeed**_ refers to the internal Felix CDP system contract which contains price calculations and logic for a given branch - e.g. "the WHYPE **PriceFeed**, which fetches prica data from the WHYPE-USD **oracle**"

### Choice of oracles and price calculations

Chainlink push oracles were chosen due to Chainlink’s reliability and track record. 

The pricing method for each LST depends on availability of oracles. Where possible, direct LST-USD market oracles have been used. 

Otherwise, composite market oracles have been created which utilise the ETH-USD market feed and an LST-ETH market feed. In the case of the WSTETH oracle, the STETH-USD price and the WSTETH-STETH exchange rate is used.

LST-ETH canonical exchange rates are also used as sanity checks for the more vulnerable LSTs (i.e. lower liquidity/volume).

Here are the oracles and price calculations for each PriceFeed:

| Felix CDP PriceFeed | Oracles used                                  | Price calculation                                              |
|----------------------|-----------------------------------------------|----------------------------------------------------------------|
| WETH-USD             | ETH-USD                                       | ETH-USD                                                        |
| WSTETH-USD           | STETH-USD, WSTETH-STETH_canonical               | STETH-USD * WSTETH-STETH_canonical                             |
| RETH-USD             | ETH-USD, RETH-ETH, RETH-ETH_canonical         | min(ETH-USD * RETH-ETH, ETH-USD * RETH-ETH_canonical)          |



### PriceFeed Deployment 

Upon deployment, the `stalenessThreshold` property of each oracle is set. This is in all cases greater than the oracle’s intrinsic update heartbeat.

### Fetching the price 

When a system branch operation needs to know the current price of collateral, it calls `fetchPrice` on the relevant PriceFeed. 


- If the PriceFeed has already been disabled, return the `lastGoodPrice`. Otherwise:
- Fetch all necessary oracle answers with `aggregator.latestRoundData`
- Verify each oracle answer. If any oracle used is deemed to have failed, disable the PriceFeed and shut the branch down
- Calculate the final LST-USD price (according to table above)
- Store the final LST-USD price and return it 

The conditions for shutdown at the verification step are:

- Call to oracle reverts
- Oracle returns a price of 0
- Oracle returns a price older than its `stalenessThreshold`

If the `fetchPrice` call is the top-level call, then failed verification due to one of the above conditions being met results in the PriceFeed being disabled and teh branch is shut down.  

If the `fetchPrice` call is called inside a borrower operation or redemption, then when a shutdown condition is met the transaction simply reverts. This is to prevent operations succeeding when the feed should be shut down. To disble the PriceFeed and shut down the branch, `fetchPrice` should be called directly.



This is intended to catch some obvious oracle failure modes, as well as the scenario whereby the oracle provider disables their feed. Chainlink have stated that they may disable LST feeds if volume becomes too small, and that in this case, the call to the oracle will revert.

### Using `lastGoodPrice` if an oracle has been disabled

If an oracle has failed, then the best the branch can do is use the last good price seen by the system. Using an out-of-date price obviously has undesirable consequences, but it’s the best that can be done in this extreme scenario. The impacts are addressed in [Known Issue 4](https://github.com/liquity/feUSD/blob/main/README.md#4---oracle-failure-and-urgent-redemptions-with-the-frozen-last-good-price).

However, as mentioned there, a possible improvement exists whereby the ETH-USD price can be used alongside the canonical LST rate as a price fallback.  See this PR:
https://github.com/liquity/feUSD/pull/393

### Protection against upward market price manipulation

The smaller LST i.e. RETH has lower liquidity and thus it is cheaper for a malicious actor to manipulate their market price.

The impacts of downward market manipulation are bounded - it could result in excessive liquidations and branch shutdown, but should not affect other branches nor feUSD stability.

However, upward market manipulation could be catastrophic as it would allow excessive feUSD minting from Troves, which could cause a depeg.

The system mitigates this by taking the minimum of the LST-USD prices derived from market and canonical rates on the RETHPriceFeed. As such, to manipulate the system price upward, an attacker would need to manipulate both the market oracle _and_ the canonical rate which would be much more difficult.


However this is not the only LST/oracle risk scenario. There are several to consider - see the [LST oracle risks section](#9---lst-oracle-risks).


## Known issues and mitigations

### 1 - Oracle price frontrunning

Push oracles are used for all collateral pricing. Since these oracles push price update transactions on-chain, it is possible to frontrun them with redemption transactions.

An attack sequence may look like this:

- Observe collateral price increase oracle update in the mempool
- Frontrun with redemption transaction for `$x` worth of feUSD and receive `$x - fee` worth of collateral
- Oracle price increase update transaction is validated
- Sell redeemed collateral for `$y` such that `$y > $x`, due to the price increase
- Extracts `$(y-x)` from the system.

This is “hard” frontrunning: the attacker directly frontrun the oracle price update. “Soft” frontrunning is also possible when the attacker sees the market price increase before even seeing the oracle price update transaction in the mempool.

The value extracted is excessive, i.e. above and beyond the arbitrage profit expected from feUSD peg restoration. In fact, oracle frontrunning can even be performed when feUSD is trading >= $1.

In Liquity v1, this issue was largely mitigated by the 0.5% minimum redemption fee which matched Chainlink’s ETH-USD oracle update threshold of 0.5%.

In v2, some oracles used for LSTs have larger update thresholds - e.g. Chainlink’s RETH-ETH, at 2%.

However, we don’t expect oracle frontrunning to be a significant issue since these LST-ETH feeds are historically not volatile and rarely deviate by significant amounts: they usually update based on the heartbeat (mininum update frequency) rather than the threshold.

 Still several solutions were considered. None are ideal:

| Solution                                                                                  | Challenge                                                                                                                                                   |
|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Low latency pull-based oracle                                                             | Mainnet block-time introduces a lower bound for price staleness. According to Chainlink, during high vol periods, these oracles may not be fast enough on mainnet |
| Custom 2-step redemptions: commit-confirm pattern, redeemer confirms                      | Price uncertainty for legitimate redemption arbers. Could discourage legitimate redemptions                                                                 |
| 2-step redemptions with pull-based oracle. Commit-confirm pattern, keeper confirms        | Price uncertainty for legitimate redemption arbers. Could discourage legitimate redemptions                                                                 |
| Canonical rate oracle (ETH-USD_market x LST_ETH_canonical) for redemptions                | Likely fixes the issue - though in case of canonical rate manipulation, redemptions would be unprofitable (upward manipulation) or pay too much collateral (downward manipulation) |
| Canonical rate oracle (ETH-USD_market x LST_ETH_canonical) for redemptions, with upward and downward protection (e.g. Aave) | Likely fixes the issue - but cap parameters may be hard to tune, and could not be changed                                                                  |
| Adapt redemption fee parameters (fee spike gain, fee decay half-life)                     | Hard to tune parameters                                                                                                                                     |

#### Solution 

Solution 6 was provisionally chosen, as it involves minimal technical complexity. Parameters for redemptions are TBD.

### 2 - Bypassing redemption routing logic via temporary SP deposits

The redemption routing logic reduces the “outside” debt of each branch by the same percentage, where outside debt for branch `i` is given by:

`outside_debt_i = feUSD_debt_i  - feUSD_in_SP_i`.

It is clearly possible for a redeemer to temporarily manipulate the outside debt of one or more branches by depositing to the SP.

Thus, an attacker could direct redemptions to their chosen branch(es) by depositing to SPs in branches they don’t wish to redeem from. 

This sequence - deposit to SPs on unwanted branches, then redeem from chosen branch(es) -  can be performed in one transaction and a flash loan could be used to obtain the feUSD funds for deposits.

By doing this redeemer extracts no extra value from the system, though it may increase their profit if they are able to choose LSTs to redeem which have lower slippage on external markets.
The manipulation does not change the fee the attacker pays (which is based purely on the `baseRate`, the redeemed feUSD and the total feUSD supply).

#### Solution

Currently no fix is in place, because:

- The redemption arbitrage is highly competitive, and flash loan fees reduce profits (though, the manipulation could still result in a greater profit as mentioned above)
- There is no direct value extraction from the system
- Redemption routing is not critical to system health. It is intended as a soft measure to nudge the system back to a healthier state, but in the end the system is heavily reliant on the health of all collateral markets/assets.

### 3 - Path-dependent redemptions: lower fee when chunking

The redemption fee formula is path-dependent: that is, given some given prior system state, the fee incurred from redeeming one big chunk of feUSD in a single transaction is greater than the total fee incurred by redeeming the same feUSD amount in many smaller chunks with many transactions (assuming no other system state change in between chunks).

As such, redeemers may be incentivized to split their redemption into many transactions in order to pay a lower total redemption fee.

See this example from this sheet:
https://docs.google.com/spreadsheets/d/1MPVI6edLLbGnqsEo-abijaaLnXle-cJA_vE4CN16kOE/edit?usp=sharing



#### Solution

No fix is deemed necessary, since:

- Redemption arbitrage is competitive and profit margins are thin. Chunking redemptions incurs a higher total gas cost and eats into arb profits.
- Redemptions in Liquity v1 (with the same fee formula) have broadly functioned well, and proven effective in restoring the feUSD peg.
- The redemption fee spike gain and decay half-life are “best-guess” parameters anyway - there’s little reason to believe that even the intended fee scheme is absolutely optimal.

### 4 - Oracle failure and urgent redemptions with the frozen last good price

When an oracle failure triggers a branch shutdown, the respective PriceFeed’s `fetchPrice` function returns the recorded `lastGoodPrice` price thereafter. Thus the LST on that branch after shutdown is always priced using `lastGoodPrice`.

During shutdown, the only operation that uses the LST price is urgent redemptions.   

When `lastGoodPrice` is used to price the LST, the _real_ market price may be higher or lower. This leads the following distortions:

| Scenario                     | Consequence                                                                                                                                       |
|------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| lastGoodPrice > market price | Urgent redemptions return too little LST collateral, and may be unprofitable even when feUSD trades at $1 or below                                   |
| lastGoodPrice < market price | Urgent redemptions return too much LST collateral. They may be too profitable, compared to the market price.              |

#### Solution

No fix is implemented for this, for the following reasons:

- In the second case, although urgent redemptions return too much value to the redeemer, they can still clear all debt from the branch.
- In the first case, the final result is that some uncleared feUSD debt remains on the shut down branch, and the system carries this unbacked debt burden going forward.  This is an inherent risk of a multicollateral system anyway, which relies on the economic health of the LST assets it integrates. A solution to clear bad debt is TODO, to be chosen and implemented - see [Branch shutdown and bad debt](https://github.com/liquity/feUSD?tab=readme-ov-file#10---branch-shutdown-and-bad-debt) section.
- Also an Oracle failure, if it occurs, will much more likely be due to a disabled Chainlink feed rather than hack or technical failure. A disabled LST oracle implies an LST with low liquidity/volume, which in turn probably implies that the LST constitutes a small fraction of total Felix CDP collateral.

#### Possible Improvement - use `ETH-USD * canonical_rate`
If the primary oracle setup fails on a given LST branch, then using `lastGoodPrice` has the shortcoming noted above: when `lastGoodPrice > market price`, it may be unprofitable to redeem even with feUSD at $1, thus leaving excess bad debt in the branch.

However, a fallback price utilizing the ETH-USD price and the LST's canonical rate could be used. The proposed fallback price calculation for each branch is here:

| Collateral | Primary price calc                                             | Fallback price calc                        |
|------------|----------------------------------------------------------------|--------------------------------------------|
| WHYPE      | HYPE-USD                                                       | lastGoodPrice                              |
| UBTC       | UBTC-USD                                                       | lastGoodPrice                              |

During shutdown no borrower ops are allowed, so the main risk of a manipulated canonical rate (inflated price and excess feUSD minting) is eliminated, and it will be safe to use the canonical rate in conjunction with ETH-USD.

Additionally, if the _ETH-USD_ oracle fails after shut down, then the LST PriceFeed should finally switch to the `lastGoodPrice`, and the branch remains shut down.

The full logic is implemented in this PR:
https://github.com/liquity/feUSD/pull/393

### 5 - Stale oracle price before shutdown triggered

Felix CDP checks all returned market oracle answers for staleness, and if they exceed a pre-set staleness threshold, it shuts down their associated branch.

However, in case of a stale oracle (i.e. an oracle that has not updated for longer than it’s stated heartbeat), then in the period between the last oracle update and the branch shutdown, the Felix CDP system will use the latest oracle price which may be out of date.

The system could experience distortions in this period due to pricing collateral too low or too high relative to the real market price. Unwanted arbitrages and operations may be possible, such as:

- Redeeming too profitably or unprofitably
- Borrowing (and selling) feUSD with too little collateral provided
- Liquidation of healthy Troves

#### Solution

Oracle staleness threshold parameters are TBD and should be carefully chosen in order to minimize the potential price deltas and distortions. The ETH-USD (and STETH-USD) feeds should have a lower staleness threshold than the LST-ETH feeds, since the USD feeds are typically much more volatile, and their prices could deviate by a larger percentage in a given time period than the LST-ETH feeds.

All staleness thresholds must be also greater than the push oracle’s update heartbeat.

Provisionally, the preset staleness thresholds in Felix CDP as follows, though are subject to change before deployment:

| Oracle                                                  | Oracle heartbeat | Provisional staleness threshold (s.t. change) |
|---------------------------------------------------------|------------------|----------------------------------------------|
| Chainlink ETH-USD                                       | 1 hour           | 24 hours                                     |
| Chainlink stETH-USD                                     | 1 hour           | 24 hours                                     |
| Chainlink rETH-ETH                                      | 24 hours         | 48 hours                                     |


### 6 - Batch management ops don’t check for a shutdown branch

Currently, batch management operations such as `setBatchManagerAnnualInterestRate` and `applyBatchInterestAndFeePermissionless` don’t check for branch shutdown. These operations should not be possible on a shutdown branch.

#### Solution
This fix is TODO.


### 7 - Discrepancy between aggregate and sum of individual debts

As mentioned in the interest rate [implementation section](#core-debt-invariant), the core debt invariant is given by:

**Aggregate total debt always equals the sum of individual entire Trove debts**.

That is:

```
ActivePool.aggRecordedDebt + ActivePool.calcPendingAggInterest()
+ ActivePool.aggBatchManagementFees() + ActivePool.calcPendingAggBatchManagementFee()
+ DefaultPool.feUSDDebt
= SUM_i=1_n(TroveManager.getEntireTroveDebt())
```

For all `n` Troves in the branch.

However, this invariant doesn't hold perfectly - the aggregate is sometimes slightly less than the sum over Troves. 

#### Solution

Though rounding error is inevitable, we have ensured that the error always “favors the system” - that is, the aggregate is always greater than the sum over Troves, and every Trove can be closed (until there is only 1 left in the system, as intended).

### 8 - Discrepancy between `yieldGainsOwed` and sum of individual yield gains in StabilityPool

StabilityPool increases `yieldGainsOwed` by the amount of feUSD yield it receives from interest minting, and decreases it by the claimed amount any time a depositor makes a claim. As such, `yieldGainsOwed` should always equal the sum of unclaimed yield present in deposits:

`StabilityPool.getYieldGainsOwed() = SUM(StabilityPool.getDepositorYieldGain())`

Currently, the discrepancy between these 2 can be rather large, especially if yield is received immediately after a liquidation that results in very little remaining deposited feUSD in StabilityPool. What's worse, the discrepancy can sometimes be negative, meaning if every depositor were to try and claim their gains, at some point we would try to reduce `yieldGainsOwed` below zero, resulting in arithmetic underflow.

#### Solution

Some imprecision in the StabilityPool arithmetic is inevitable, but we should avoid arithmetic underflow in `yieldGainsOwed` by ensuring the error stays positive. The root cause of the underflow is not yet clear, however it seems to be connected to our error feedback mechanism.

[PR 261](https://github.com/liquity/feUSD/pull/261) contains a proof-of-concept patch that eliminates error correction while also simplifying the code in an effort make it easier to reason about. This fixes all currently known instances of arithmetic underflow.

**TODO**: we should analyze the issue more and understand the root cause better.

### 9 - LST oracle risks 

Liquity v1 primarily used the Chainlink ETH-USD oracle to price collateral. ETH clearly has very deep liquidity and diverse price sources, which makes this oracle robust.

However, Felix CDP must also price a variety of LSTs, which comes with challenges:

- LSTs may have thin liquidity and/or low trading volume
- A given LST may trade only on 1-2 venues, i.e. a single DEX pool
- LST smart contract risk: withdrawal bugs, manipulation of canonical exchange rates, etc

Thin liquidity and lack of price source diversity lead to an increased risk of market price manipulation. An attacker could (for example) relatively cheaply tilt the primary DEX pool on which the LST trades, and thus pump or crash the LST price reported by the oracle. 

Felix CDP would be fully exposed to this risk if it purely relied on LST-USD market price oracles for the riskier LSTs.

An alternative to market price oracles is to calculate a composite LST-USD price using an ETH-USD market oracle and the LST canonical exchange rate from the LST smart contract.

This mitigates against market manipulation since the only market oracle used is the more robust ETH-USD, but then exposes the system to canonical exchange rate manipulation.

Canonical exchange rates are updated in different ways depending on the given LST, and most are controlled by an oracle-like scheme, though some LSTs are moving to trustless zk-proof based updates. Therefore, using canonical rates introduces exchange rate manipulation risk, the magnitude of which is hard to assess for smaller LSTs (does the team abandon the project? do promises to move to zk-proofs materialize? What are the attack costs for the oracle-like canonical rate update?).

Various risk scenarios have been analysed in this sheet for different oracle setups: (see sheet 1, and overview in sheet 2):
https://docs.google.com/spreadsheets/d/1Of5eIKBMVAevVfw5AtbdFpRlMLn8q9vt0vqmtrDhySc/edit?usp=sharing

#### Solution

To mitigate the worst outcome of upward price manipulation, Felix CDP uses solution 2) - i.e. takes the lower of LST-USD prices derived from an LST market price and the LST canonical rate.

Downward price manipulation is not protected against, however the impact should be contained to the branch (liquidations and shutdown). Also, downard manipulation likely implies a low liquidty LST, which in turn likely implies the LST is a small fraction of total collateral in Felix CDP. Thus the impact on the system and any bad debt created should be small.

On the other hand, upward price manipulation would result in excessive feUSD minting, which is detrimental to the entire system health and feUSD peg.

Taking the minimum of both market and canonical prices means that to make Felix CDP consume an artificially high LST price, an attacker needs to manipulate both the market oracle _and_ the LST canonical rate at the same time, which seems much more difficult to do.

The best solution on paper seems to be 3) i.e. taking the minimum with an additional growth rate cap on the exchange rate, following [Aave’s approach](https://github.com/bgd-labs/aave-capo). However, deriving parameters for growth rate caps for each LST is tricky, and may not be suitable for an immutable system. 

### 10 - Branch shutdown and bad debt

In the case of a collateral price collapse or oracle failure, a branch will shut down and urgent redemptions will be enabled. The collapsed branch may be left with 0 collateral (or collateral with 0 value), and some remaining bad debt.

This could in the worst case lead to bank runs: a portion of the system debt can not be cleared, and hence a portion of the feUSD supply can never be redeemed.

Even though the entire system may be overcollateralized in aggregate, this unredeemable portion of feUSD is problematic: no user wants to be left holding unredeemable feUSD and so they may dump feUSD en masse (repay, redeem, sell).

This would likely cause the entire system to evaporate, and may also break the feUSD peg. Even without a peg break, a bank run is still entirely possible and very undesirable.

**Potential solutions**

Various solutions have been fielded. Generally, any solution which appears to credibly and eventually clear the bad debt should have a calming effect on any bank run dynamic: when bad debt exists yet users believe the feUSD peg will be maintained in the long-term, they are less likely to panic and repay/redeem/dump feUSD.

1. **Redemption fees pay down bad debt**. When bad debt exists, direct normal redemption fees to clearing the bad debt. It works like this: when `x` feUSD is redeemed, `x-fee` debt on healthy branches is cleared 1:1 for collateral, and `fee` is canceled with debt on the shut down branch. This would slowly pay down the debt over time. It also makes bank runs via redemption nicely self-limiting: large redemption volume -> fee spike -> pays down the bad debt more quickly. 

2. **Haircut for SP depositors**. If there is bad debt in the system, feUSD from all SPs could be burned pro-rata to cancel it.  This socializes the loss across SP depositors.

3. **Redistribution to active Troves on healthy branches**. Socializes the loss across Troves. Could be used as a fallback for 2.

4. **New multi-collateral Stability Pool.** This pool would absorb some fraction of liquidations from all branches, including shut down branches. 

5. **Governance can direct feUSD interest to pay down bad debt**. feUSD interest could be voted to be redirected to paying down the bad debt over time.  Although this would not directly clear the bad debt, economically, it should have the same impact  - since ultimately, it is the redeemability of _circulating_ feUSD that determines the peg.  When an amount equal to the bad debt has been burned, then all circulating feUSD is fully redeemable. See this example:

<img width="537" alt="image" src="https://github.com/user-attachments/assets/3045cba9-45a3-46b4-a5d0-58bed7f38a04">

This provides a credible way of eventually "filling the hole" created by bad debt (unlike other approaches such as the SP haircut, which depends on SP funds). No additional core system code nor additional governance features are required. Governance may simply propose to redirect feUSD interest to a burn address. 

If there is remaining collateral in the shutdown branch (albeit perhaps at zero USD value) and there are liquidateable Troves, Governance could alternatively vote to direct fees to a permissionless contract that deposits the feUSD to the SP of the shutdown branch and liquidates the Troves against those funds. The resulting collateral gains could, if they have non-zero value, be swapped on a DEX, e.g. for feUSD which could be then directed to LP incentives. All deposits and swaps could be handled permissionlessly by this governance-deployed contract.

And some additional solutions that may help reduce the chance of bad debt occurring in the first place:

6. **Restrict SP withdrawals when TCR < 100%**. This ensure that SP depositors can’t flee when their branch is insolvent, and would be forced to eat the loss. This could lead to less bad debt than otherwise. On the other hand, when TCR > 100%, the expectation of this restriction kicking in could force pre-empting SP fleeing, which may limit liquidations and make bad debt _more_ likely.  An alternative would be to restrict SP withdrawals only when the LST-ETH price falls significantly below 1, indicating an adverse LST depeg event.

7. **Pro-rata redemptions at TCR < 100% (branch specific, not routed)**. Urgent redemptions are helpful for shrinking the debt of a shut down branch when it is at `TCR > 100%`. However, at `TCR < 100%`, urgent redemptions do not help clear the bad debt. They simply remove all collateral and push it into its final state faster (and in fact, make it slightly worse since they pay a slight collateral bonus).  At `TCR < 100%`, we could offer special pro-rata redemptions only on the shut down branch - e.g. at `TCR = 80%`, users may redeem 1 feUSD for $0.80 worth of collateral. This would (in principle) allow someone to completely clear the bad debt via redemption. At first glance it seems unprofitable, but if the redeemer has reason to believe the collateral is underpriced and the price may rebound at some point in future, they may believe it to be profitable to redeem pro-rata.

**Conclusion**

Ultimately, no measures have been implemented in the protocol directly, so the protocol may end up with some bad debt in the case of a branch shut down.  Here there is a theoretical possibility that the feUSD supply may be reduced by either users accidentally burning feUSD, or that borrower's interest could be directed by governance to burn feUSD, which would restore its backing over time.

### 11 - Inaccurate calculation of average branch interest rate

`getNewApproxAvgInterestRateFromTroveChange` does not actually calculate the correct average interest rate for a collateral branch. Ideally, we would like to calculate the debt-weighted average interest of all Troves within the branch, upon which our calculation of the upfront fee is based. The desired formula would be:

```
        sum(r_i * debt'_i)
r_avg = -----------------
           sum(debt'_i)
```

where `r_i` and `debt'_i` are the interest rate and _current_ debt of the i-th Trove, respectively. Here, `debt'_i` includes pending interest.

However, in the actual implementation as Dedaub points out: in the denominator "the pending interest of all the troves is added", however the numerator "takes into account only the change in the Trove under consideration and not the pending interest of all the other troves". Thus, the actual implementation is closer to (disregarding the upfront fee that applies to the Trove being adjusted):

```
         sum(r_i * debt_i)
r'_avg = -----------------
            sum(debt'_i)
```

where `debt_i` is the debt of the i-th Trove when it was last adjusted, in other words: exluding pending interest. As we see, there's a discrepancy in weights between the numerator and denominator of our weighted average formula. As the sum of weights in the denominator is greater than the sum of weights in the numerator, our estimate of the average interest rate will be lower than the ideal average.

Roughly speaking: if `s` is the current total debt of a collateral branch and `p` the total amount of interest that hasn't been compounded yet, our estimate will be off by a factor of `s / (s + p)`.

#### Side-note: "discrete" compounding in v2

By design, Trove debt in Felix CDP is compounded "discretely", that is: whenever an operation directly modifies a Trove (such as a borrower making a Trove adjustment, or a Trove getting redeemed). Compounding only takes place for the Trove(s) "touched" by an operation, thus, each Trove has an individual timestamp (`lastDebtUpdateTime`) of the time when the Trove's debt was last compounded.

#### Potential improvement 1

One way to fix the above-mentioned discrepancy between the numerator and the denominator would be to take into account pending interest in the former. As mentioned before, the current definition of the numerator is:

```
sum(r_i * debt_i)
```

`ActivePool` keeps track of this sum in an O(1) fashion on-chain as `aggWeightedDebtSum`. To take into account pending interest, the numerator would have to be changed to:

```
sum(r_i * debt'_i) = sum(r_i * debt_i) + sum(r_i * debt_i * dT_i)
```

where `dT_i` is `block.timestamp - lastDebtUpdateTime`, i.e. the time elapsed since the i-th Trove was last compounded. While it seems possible to do so in O(1) complexity, `ActivePool` currently doesn't keep track of this metric. Thus without additional accounting (keeping track of the sum in a new state variable), it would take O(N) time to calculate the ideal numerator.

#### Potential improvement 2

Alternatively, we could modify the denominator to ignore pending debt instead. Currently, we use:

```
sum(debt'_i)
```

which is kept track of as `aggRecordedDebt` by `ActivePool`. Instead, we could use:

```
sum(debt_i)
```

While this wouldn't result in the most accurate estimation of the average interest rate either — considering we'd be using outdated debt values sampled at different times for each Trove as weights — at least we would have consistent weights in the numerator and denominator of our weighted average. To implement this though, we'd have to keep track of this modified sum (i.e. the sum of recorded Trove debts) in `ActivePool`, which we currently don't do.

### 12. TroveManager can make troves liquidatable by changing the batch interest rate
Users that add their Trove to a Batch are allowing the BatchManager to charge a lot of fees by simply adjusting the interest rate as soon as they can via `setBatchManagerAnnualInterestRate`.

This change cannot result in triggering the critical threshold, however it can make any trove in the batch liquidatable

Thus BatchManagers should be considered benign trusted actors

### 13. Trove Adjustments may be griefed by sandwich raising the average interest rate

Borrowing requires accepting an upfront fee. This is effectively a percentage of the debt change (not necessarily of TCR due to price changes). Due to this, it is possible for other ordinary operations to grief a Trove adjustments by changing the `avgInterestRate`.

To mitigate this, users should use tight but not exact checks for the `_maxUpfrontFee`.

### 14. Stability Pool claiming and compounding Yield can be used to gain a slightly higher rate of rewards
The StabilityPool doesn't automatically compound feUSD yield gains to depositors

All deposits are added to `totalfeUSDDeposits`.

Claimable yields are not part of `totalfeUSDDeposits`.

Claiming feUSD allows to receive the corresponding yield and it does increase `totalfeUSDDeposits`.

If we compare a deposit that never claims, against one that compound their claims.

The depositor compounding their claims will technically receive the rewards that could have been received by the passive depositor.

Meaning that claiming frequently is the preferred strategy.

### 15. Urgent Redemptions Premium can worsen the ICR when Trove Coll Value < Debt Value * .1
If ICR is less than 101% , urgent redemptions with 1% premium reduce the ICR of a Trove.

This may be used to lock in a bit more bad debt.

Liquidations already carry a collateral premium to the caller and to the liquidators.

Redemptions at this CR may allow for a bit more bad debt to be redistributed which could cause a liquidation cascade, however the difference doesn't seem particularly meaningful when compared to how high the Liquidation Premium tends to be for liquidations.


## Appendix: Key Modifications in the Felix Protocol Compared to LiquityV2

### Transparent Proxy Design
Unlike the immutable design of the LiquityV2 protocol, the Felix protocol employs a Transparent Proxy design for each contract. This approach allows for greater flexibility by enabling contract upgrades while preserving existing state and functionality.

### Mutable Critical Parameters
The Felix protocol introduces mutability for certain critical parameters via setter functions. These parameters include:

- **MCR (Minimum Collateral Ratio)**: The minimum ratio of collateral to debt required to maintain a trove.
- **CCR (Critical Collateral Ratio)**: The ratio at which the system enters recovery mode.
- **MaxCapDebt**: A new parameter introduced in this fork to prevent overexposure to specific collateral types. It considers the total debt accrued (including interest) and enforces the cap only when users attempt to mint additional debt. Note: Debt accumulation from interest is unaffected by this cap and continues as usual.
- **Interest Router Address**: Allows updates to the routing mechanism for interest accrual.
- **Stability Pool Yield Percentage**: Configurable yield percentage for Stability Pool participants.

### AdminController for Centralized Governance
Administrative actions are centralized under the AdminController contract, which serves as the owner of all system contracts. Key features include:

- **Proposal/Apply Methodology**:
  - Changes to critical parameters follow a proposal and apply mechanism.
  - An enforced timelock period between proposal and application ensures users have time to respond to protocol changes.
- **Upgradeability**:
  - The proxy admin for all contract proxies is owned by the AdminController, which can upgrade contract implementations if necessary.

### Removal of Gas Compensation Mechanism
The Felix protocol eliminates the gas compensation mechanism originally included in LiquityV2. In the original protocol, users were compensated with gas tokens upon opening a trove to incentivize liquidators during periods of high gas costs. This mechanism is no longer necessary as the Felix protocol targets chains without significant gas limitations.

- **ETH_GAS_COMPENSATION**: This constant has been set to 0.
- Certain versions of WHYPE contracts (such as this one)[https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2] support allowance, transfer, and deposit operations with a 0 amount, ensuring compatibility with the updated protocol.
- Note: ETH_GAS_COMPENSATION is immutable once set, ensuring consistency for troves already opened under this configuration.

### Known Issue with Collateral Tokens
The Felix protocol currently has a known issue when introducing collateral tokens with decimals other than 18. This limitation arises from assumptions in the codebase that expect all tokens to adhere to the 18-decimal standard.

### Admin Shutdown Functionality

Due to the novel nature of the Hyperliquid ecosystem the Felix team has opted to implement a temporary shutdown functionality. This is done in orcder to contrast possible black swan events such as price feed failures, unpredictable changes of in peg due to market conditions and limited external infrastructure presence (i.d. the temporary absence on chain of a fiat backed stablecoin to pair with in dexes enabling much more fluid pegging operations such as redemtions and reverse redemptions). The admin shutdown functionality is only triggerable by the AdminController contract and it does not affect the underlying interest accounting mechanism. All the functions on the BorrowerOperations contract that would be locked under a regular shutdown are locked under an admin shutdown as well. The inherent risk of this approach is the system accruing interest on troves during a shutdown which would not happen under a regular shutdown.  


### Conclusion
These changes position the Felix protocol as a more flexible and adaptable alternative to LiquityV2, suitable for deployment on modern blockchains with minimal gas constraints. By implementing transparent proxies, mutable critical parameters, and a streamlined governance process, Felix ensures enhanced adaptability while maintaining user trust through timelocks and clear governance procedures.



## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation)



## Setup

```sh
git clone git@github.com:felixprotocol/felix-contracts.git
cd felix-contracts
forge install
```

## Basic Instructions

```sh
# Run the anvil local node (keep it running in a separate terminal):
anvil --fork-url $MAINNET_RPC_URL --disable-block-gas-limit

# Copy the example .env file:
cp .env.example .env

# Fill the .env file 
fill the .env file with a private key and and address that should be the MULTI_SIG_WALLET and PROXY_ADMIN_OWNER

# Build & deploy the contracts:
forge script ./script/Mainnet/DeployFelixMainnet.s.sol

# Run tets
forge test
```

## License Notice

This project includes code from Liquity Protocol, licensed using a Business Source License 1.1.
The full text of the original license can be found in [here](./LICENSE).

Modifications, additions, and other original work contributed by Felix Protocol are licensed under the SOURCE-VIEW LICENCE 1.0.
The full text of our license can be found in [LICENSE-FELIX](./LICENSE-FELIX).

<!-- AUDIT_DOSSIER_START -->
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `2026-05-26T16:59:50Z`  
Project: `05_felix`  
Solidity files: `255`

### Structure
Top Solidity directories:
- `src`: 148 `.sol` files
- `test`: 104 `.sol` files
- `scripts`: 3 `.sol` files

Pragmas:
- `0.8.24`
- `>=0.5.0`
- `>=0.7.0 <0.9.0`
- `>=0.7.5`
- `>=0.8.0`
- `^0.8.0`
- `^0.8.12`
- `^0.8.18`
- `^0.8.20`

Contracts/Libraries/Interfaces detected: `264`

### Life Total / Balance Values
Detected accounting/state total variables:
- `aggRecordedDebt` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `aggWeightedDebtSum` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `defaultPoolAddress` | type: `address public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `stabilityPool` | type: `IfeUSDRewardsReceiver public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `collSurplusPool` | type: `ICollSurplusPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `defaultPool` | type: `IDefaultPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `gasPoolAddress` | type: `address public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `100_000_000_000 ether`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `10_000 ether`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `1_000_000_000 ether`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `10_000 ether`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `0`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10000 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1200 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1_00000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `2`
- `NEW_COLLATERAL` | type: `Collaterals public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `Collaterals.KHYPE`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `"WSTHYPE"`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `2_500 ether`
- `ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `2 ether`
- `AMOUNT_OF_COLLATERAL_TO_WITHDRAW` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1e7`
- `AMOUNT_OF_COLLATERAL_TO_WITHDRAW_STANDARD_DECIMALS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1e17`
- `AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1`
- `COLLATERAL_AMOUNT_FOR_TROVE_OPENING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `2`
- `DEBT_AMOUNT_FOR_TROVE_OPENING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `10_000 ether`
- `DEBT_AMOUNT_TO_INCREASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `5_000 ether`
- `DEBT_AMOUNT_TO_REPAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1_000 ether`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `0`
- `newBorrowerOperationsImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol`
- `AMOUNT_OF_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_000_000 ether`
- `COLLATERALS_LENGTH` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `uint8(Collaterals.COLLATERALS_LENGTH)`
- `FEUSD_AMOUNT_FOR_STABILITY_POOL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `100 ether`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `curvePool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `poolDeployer` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `makeAddr("poolDeployer")`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_000 ether`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `"WBTC"`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_500 ether`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `10 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1_200 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1_200 ether`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `"WBTC"`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `2_500 ether`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `0`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `3_000 ether`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `2_500 ether`
- `DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `50 ether`
- `DECREASE_INCREASE_AMOUNT_FOR_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `100 ether`
- `NEW_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000_000_000 ether`
- `ORIGINAL_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000_000 ether`
- `REDEEM_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `100 ether`
- `STABILITY_POOL_USER_DEPOSIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `500 ether`
- `newStabilityPoolImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `vault` | type: `IVault private constant` | vis: `private` | flags: `constant` | `BalancerFlashLoan` @ `src/Zappers/Modules/FlashLoans/BalancerFlashLoan.sol` = `IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8)`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `100_000_000_000 ether`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `10_000 ether`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `collateralRegistry` | type: `ICollateralRegistry` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `activePool` | type: `IActivePool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `borrowerOperations` | type: `IBorrowerOperationsTester` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `collSurplusPool` | type: `ICollSurplusPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `collateralRegistry` | type: `ICollateralRegistry` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `defaultPool` | type: `IDefaultPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `gasPool` | type: `GasPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `stabilityPool` | type: `IStabilityPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `COLL_SURPLUS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `109`
- `GAS_POOL_ADDRESS_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `108`
- `balances` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `_MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `src/Dependencies/Constants.sol` = `MIN_DEBT`
- `ownerIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol`
- `ownerIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `ContextHelper` @ `test/ContextHelper.t.sol`
- `COLL_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `curvePool` | type: `ICurvePool public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `activePoolAddress` | type: `address public` | vis: `public` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `0`
- `COLLATERAL_TAP_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1000 ether`
- `COLLATERAL_TAP_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1 minutes`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `57`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `56`
- `collateralFaucets` | type: `mapping(Collaterals => address) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `0`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `57`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `ICurveXChainLiquidityGaugeFactory(0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6)`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `56`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `"feUSD/WHYPE"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `"feUSDWHYPE"`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `0`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `57`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `ICurveXChainLiquidityGaugeFactory(0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6)`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `1`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `56`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `"feUSD/USDC"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `"feUSDCUSDC"`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `MAX_POOL_INDEX` | type: `int128 public constant` | vis: `public` | flags: `constant` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol` = `1`
- `s_USDCPoolIndex` | type: `int128 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_borrowerOperations` | type: `mapping(uint256 branchIndex => address borrowerOperations) public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_curvePool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_feUSDPoolIndex` | type: `int128 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_stabilityPools` | type: `mapping(uint256 branchIndex => address stabilityPool) public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `assets` | type: `mapping(bytes4 => Asset) public` | vis: `public` | flags: `-` | `FixedAssetReader` @ `src/NFTMetadata/utils/FixedAssets.sol`
- `borrowerOperations` | type: `IBorrowerOperations` | vis: `default` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `l1Index` | type: `uint16 public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `BTC_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `3`
- `ETH_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `4`
- `borrowerOperations` | type: `BorrowerOperationsTester` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `HintHelpers` @ `src/HintHelpers.sol`
- `USDC_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `curvePool` | type: `ICurveStableswapNGPool public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `AMOUNT_FOR_CURVE_POOL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `200_000`
- `AMOUNT_TO_STAKE_INTO_GAUGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `10_000 ether`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `ICurveXChainLiquidityGaugeFactory( 0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6 )`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `"feUSD/USDC"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `"feUSDCUSDC"`
- `TOTAL_REWARDS_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `1_000_000 ether`
- `s_activePool` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ACTIVE_POOL")`
- `s_pool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_staker` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("STAKER")`
- `_troveIndexOf` | type: `mapping(uint256 branchIdx => mapping(address owner => uint256))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `totalCollRedist` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `totalDebtRedist` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `SPOT_BALANCE_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000801`
- `VAULT_EQUITY_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000802`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `defaultPool` | type: `IDefaultPool internal` | vis: `internal` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `ACTIVE_POOL_OFFSET` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `2`
- `ACTIVE_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `0`
- `DEFAULT_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `1`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `defaultPool` | type: `IDefaultPool internal` | vis: `internal` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `initializedFixedAssetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataDeployment` @ `test/TestContracts/MetadataDeployment.sol`
- `assetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataNFT` @ `src/NFTMetadata/MetadataNFT.sol`
- `assetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataNFTBase` @ `src/NFTMetadata/utils/MatadataNFTBase.sol`
- `INITIAL_SUPPLY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockFeUSD` @ `test/TestContracts/MockFeUSD.sol` = `10_000_000 ether`
- `INITIAL_SUPPLY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockUSDC` @ `test/TestContracts/MockUSDC.sol` = `10_000_000e6`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `MultiTroveGetter` @ `src/MultiTroveGetter.sol`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `MulticollateralTest` @ `test/multicollateral.t.sol` = `4`
- `AMOUNT_OF_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `200 ether`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `300 ether`
- `COLLATERAL_LENGTH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `2`
- `MAX_CAP_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `1_000_000_000 ether`
- `NEW_MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `MIN_DEBT`
- `activePoolNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `borrowerOperationsNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `borrowerOperationsSecondImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `stabilityPoolNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `branchPools` | type: `mapping(Collaterals => BranchPools) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol`
- `branchPools` | type: `mapping(Collaterals => BranchPools) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations` | vis: `default` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `30_000 ether`
- `stabilityPool` | type: `IStabilityPool` | vis: `default` | flags: `-` | `SPInvariantsBase` @ `test/SPInvariants.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `collSurplusPool` | type: `ICollSurplusPool immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `collateralToken` | type: `IERC20` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `stabilityPool` | type: `IStabilityPool immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `troveIndexOf` | type: `mapping(address owner => uint256)` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `0`
- `MAX_DEBT_CAP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `150_000 ether`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `ShutdownTest` @ `test/shutdown.t.sol` = `4`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `SortedTroves` @ `src/SortedTroves.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `totalfeUSDDeposits` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `COLL_TOKEN_INDEX` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `USDC_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `activePoolImpl` | type: `IActivePoolTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new ActivePoolTester()`
- `borrowerOperationsImpl` | type: `BorrowerOperations` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new BorrowerOperations()`
- `borrowerOperationsTesterImpl` | type: `BorrowerOperationsTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new BorrowerOperationsTester()`
- `collSurplusPoolImpl` | type: `CollSurplusPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new CollSurplusPool()`
- `collateralRegistryImpl` | type: `CollateralRegistry` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new CollateralRegistry()`
- `defaultPoolImpl` | type: `DefaultPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new DefaultPool()`
- `feUSD_TOKEN_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `0`
- `gasPoolImpl` | type: `GasPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new GasPool()`
- `stabilityPoolImpl` | type: `IStabilityPoolTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new StabilityPoolTester()`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `0`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `700 ether`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `5000 ether`
- `L_feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `lastfeUSDDebtError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalCollateralSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalStakes` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalStakesSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `BORROWER_OPERATIONS_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `54`
- `COLLATERAL_REGISTRY_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `60`
- `COLL_SURPLUS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `57`
- `GAS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `56`
- `STABILITY_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `55`
- `L_feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `lastfeUSDDebtError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalCollateralSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalStakes` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalStakesSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `0`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol`
- `balanceOf` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `2500 ether`
- `DEFAULT_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `currentIndexForTrove` | type: `uint256 public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0`
- `collateralToken` | type: `address public` | vis: `public` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `activePoolAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `borrowerOperationsAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `collateralRegistryAddress` | type: `address public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `stabilityPoolAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol` = `3`

All detected state variables (full list):
- `accountsPks` | type: `uint256[10] public` | vis: `public` | flags: `-` | `Accounts` @ `test/TestContracts/Accounts.sol` = `[ 0x60ddFE7f579aB6867cbE7A2Dc03853dC141d7A4aB6DBEFc0Dae2d2B1Bd4e487F, 0xeaa445c85f7b438dEd6e831d06a4eD0CEBDc2f8527f84Fcda6EBB5fCfAd4C0e9, 0x8b693607Bd68C4dEB7bcF976a473Cf998BDE9fBeDF08e1D8ADadAcDff4e5D1b6, 0x519B6e4f493e532a1BEbfeB2a06eA25AAD691A17875cCB38607D4A4C28DFADC2, 0x09CFF53c181C96B42255ccbCEB2CeE7012A532EcbcEaaBab4d55a47E1874FbFC, 0x054ce61b1eA12d9Edb667ceFB001FADB07FE0C37b5A74542BB0DaBF5DDeEe5f0, 0x42F55f0dFFE4e9e2C2BdfdE2FF98f3d1ea6d3F21A8bB0dA644f1c0e0Acd84FA0, 0x8F3aFFEC01e78ea6925De62d68A5F3f2cFda7D0C1E7ED9b20d31eb88b9Ed6A58, 0xBeBeF90A7E9A8e018F0F0baBb868Bc432C5e7F1EfaAe7e5B465d74afDD87c7cf, 0xaD55BABd2FdceD7aa85eB1FEf47C455DBB7a57a46a16aC9ACFFBE66d7Caf83Ee ]`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `ActivePool` @ `src/ActivePool.sol` = `"ActivePool"`
- `SP_YIELD_SPLIT` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `aggBatchManagementFees` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `aggRecordedDebt` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `aggWeightedBatchManagementFeeSum` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `aggWeightedDebtSum` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `defaultPoolAddress` | type: `address public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `interestRouter` | type: `IInterestRouter public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `lastAggBatchManagementFeesUpdateTime` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `lastAggUpdateTime` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `shutdownTime` | type: `uint256 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `stabilityPool` | type: `IfeUSDRewardsReceiver public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `troveManagerAddress` | type: `address public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `AddRemoveManagers` @ `src/Dependencies/AddRemoveManagers.sol`
- `removeManagerReceiverOf` | type: `mapping(uint256 => RemoveManagerReceiver) public` | vis: `public` | flags: `-` | `AddRemoveManagers` @ `src/Dependencies/AddRemoveManagers.sol`
- `troveNFT` | type: `ITroveNFT internal` | vis: `internal` | flags: `-` | `AddRemoveManagers` @ `src/Dependencies/AddRemoveManagers.sol`
- `BCR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AddressesRegistry` @ `src/AddressesRegistry.sol` = `BCR_ALL`
- `CCR` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `LIQUIDATION_PENALTY_REDISTRIBUTION` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `LIQUIDATION_PENALTY_SP` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `MCR` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `SCR` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `WHYPE` | type: `IWHYPE public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `collSurplusPool` | type: `ICollSurplusPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `collToken` | type: `IERC20Metadata public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `defaultPool` | type: `IDefaultPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `gasPoolAddress` | type: `address public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `hintHelpers` | type: `IHintHelpers public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `interestRouter` | type: `IInterestRouter public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `isFirstCall` | type: `bool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `metadataNFT` | type: `IMetadataNFT public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `multiTroveGetter` | type: `IMultiTroveGetter public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `priceFeed` | type: `IPriceFeed public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `sortedTroves` | type: `ISortedTroves public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `temporaryOwner` | type: `address public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `troveNFT` | type: `ITroveNFT public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `100e16`
- `CONTRACT_TYPE_COUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `12`
- `DEFAULT_BRANCH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `0`
- `MAX_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `4.5e18`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `100_000_000_000 ether`
- `MAX_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `4.5e18`
- `MIN_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `1e18`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `10_000 ether`
- `MIN_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `1e18`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `keccak256("PROPOSER_ROLE")`
- `REQUIRED_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `18`
- `REWARDS_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `keccak256("REWARDS_ADMIN_ROLE")`
- `SENSITIVE_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `7 days`
- `SHUTDOWN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `keccak256("SHUTDOWN_ROLE")`
- `STANDARD_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminController` @ `src/AdminController.sol` = `1 days`
- `addressesRegistries` | type: `IAddressesRegistry[] public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingCCRProposals` | type: `mapping(uint256 branchIndex => CCRProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingInterestRouterProposals` | type: `mapping(uint256 branchIndex => InterestRouterProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingMCRProposals` | type: `mapping(uint256 branchIndex => MCRProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingNewImplementationProposals` | type: `mapping(uint256 branchIndex => NewImplementationProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingPriceFeedProposals` | type: `mapping(uint256 branchIndex => PriceFeedProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingSPYieldProposals` | type: `mapping(uint256 branchIndex => SPYieldProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `usedTroveManagers` | type: `mapping(address troveManager => bool isUsed) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `100e16`
- `CONTRACT_TYPE_COUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `12`
- `DEFAULT_BRANCH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `0`
- `MAX_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `4.5e18`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `1_000_000_000 ether`
- `MAX_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `4.5e18`
- `MIN_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `1e18`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `10_000 ether`
- `MIN_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `1e18`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `keccak256("PROPOSER_ROLE")`
- `REQUIRED_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `18`
- `REWARDS_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `keccak256("REWARDS_ADMIN_ROLE")`
- `SENSITIVE_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `0 days`
- `SHUTDOWN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `keccak256("SHUTDOWN_ROLE")`
- `STANDARD_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol` = `0 days`
- `addressesRegistries` | type: `IAddressesRegistry[] public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingCCRProposals` | type: `mapping(uint256 branchIndex => CCRProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingInterestRouterProposals` | type: `mapping(uint256 branchIndex => InterestRouterProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingMCRProposals` | type: `mapping(uint256 branchIndex => MCRProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingNewImplementationProposals` | type: `mapping(uint256 branchIndex => NewImplementationProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingPriceFeedProposals` | type: `mapping(uint256 branchIndex => PriceFeedProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingSPYieldProposals` | type: `mapping(uint256 branchIndex => SPYieldProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `usedTroveManagers` | type: `mapping(address troveManager => bool isUsed) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `0`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `keccak256("DEFAULT_ADMIN_ROLE")`
- `IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `OP_DELAY_SENSITIVE` | type: `uint256 public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `OP_DELAY_STANDARD` | type: `uint256 public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `PAUSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `keccak256("PAUSER_ROLE")`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AdminControllerTest` @ `test/adminController.t.sol` = `keccak256("PROPOSER_ROLE")`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `addressesRegistry` | type: `IAddressesRegistry public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `adminController` | type: `AdminController public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `adminControllerOwner` | type: `address public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `deployFelix` | type: `DeployFelix public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `AdminControllerTest` @ `test/adminController.t.sol`
- `INVALID_CONTRACT_TYPE` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `AdminControllerV2` @ `src/AdminControllerV2.sol` = `uint8(ContractType.TROVE_MANAGER) + 1`
- `MULTIPLE_UPGRADE_PROPOSAL_MAX_LENGTH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AdminControllerV2` @ `src/AdminControllerV2.sol` = `10`
- `pendingMultipleUpgradeProposals` | type: `mapping(uint256 branchIndex => MultipleUpgradeProposal) public` | vis: `public` | flags: `-` | `AdminControllerV2` @ `src/AdminControllerV2.sol`
- `ACCEPTABLE_DELTA_IN_CLOSE_TROVE_EXCHANGE_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10 ether`
- `ACCEPTABLE_DELTA_IN_REDEMPTION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10 ether`
- `AMOUNT_TO_DEPOSIT_TO_SP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1_000 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10000 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1200 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1_00000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10000 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `INETEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10e16`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `2`
- `NEW_COLLATERAL` | type: `Collaterals public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `Collaterals.KHYPE`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `"WSTHYPE"`
- `NEW_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `15e16`
- `REDEMPTION_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `100 ether`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `2_500 ether`
- `adminControllerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `makeAddr("BOB")`
- `charlie` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `makeAddr("CHARLIE")`
- `multiSig` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol`
- `multiSigForProxy` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol`
- `proposerAddress` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol`
- `ACCEPTABLE_DELTA_FOR_DEBT_AMOUNT_IN_OPEN_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `2 ether`
- `AMOUNT_OF_COLLATERAL_TO_WITHDRAW` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1e7`
- `AMOUNT_OF_COLLATERAL_TO_WITHDRAW_STANDARD_DECIMALS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1e17`
- `AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1`
- `AMOUNT_OF_UNDERLYING_TOKENS_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `10`
- `BASE_EXPONENT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `10`
- `COLLATERAL_AMOUNT_FOR_TROVE_OPENING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `2`
- `DEBT_AMOUNT_FOR_TROVE_OPENING` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `10_000 ether`
- `DEBT_AMOUNT_TO_INCREASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `5_000 ether`
- `DEBT_AMOUNT_TO_REPAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1_000 ether`
- `STANDARD_DECIMALS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `18`
- `WRAPPER_ZAPPER` | type: `WrapperZappers public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `WrapperZappers(0x557dE9e0C3Cc187CEe25e14325A7ef845Dad286c)`
- `amountOfUnderlyingTokensForUsers` | type: `uint256 public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `underlyingToken` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `underlyingTokenDecimals` | type: `uint256 public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `ADMIN_MULTISIG` | type: `address public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `0x2157f54f7a745c772e686AA691Fa590B49171eC9`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `0`
- `NEW_ADMIN_CONTROLLER_IMPL` | type: `address public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `0x12690a56d6764c31FAda397567d4611677e61A57`
- `NON_SENSITIVE_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `1 days`
- `SENSITIVE_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `7 days`
- `newBorrowerOperationsImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol`
- `newInterestRouter` | type: `address public` | vis: `public` | flags: `-` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `makeAddr("newInterestRouter")`
- `newPriceFeed` | type: `address public` | vis: `public` | flags: `-` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol` = `makeAddr("newPriceFeed")`
- `newSPImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterAdminControllerUpgrade` @ `test/AfterExecutionTests/AfterAdminControllerUpgrade.t.sol`
- `AMOUNT_OF_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_000_000 ether`
- `AMOUNT_OF_COLL_IN_DOLLARS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `10_000 ether`
- `AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_300 ether`
- `AMOUNT_OF_FEUSD_SCENARIO_01` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `5_000 ether`
- `AMOUNT_OF_USDC` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_000_000 ether`
- `AMOUNT_OF_WHYPE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_000_000 ether`
- `AMOUNT_OF_WHYPE_SCENARIO_01` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `15_000 ether`
- `BOB_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `5e16`
- `COLLATERALS_LENGTH` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `uint8(Collaterals.COLLATERALS_LENGTH)`
- `COLL_AMOUNT_SCENARIO_03` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `20_000 ether`
- `COLL_CHANGE_SCENARIO_02` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `5_000 ether`
- `DECIMAL_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1e18`
- `DEFAULT_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `0x00`
- `DO_CLAIM` | type: `bool public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `false`
- `FEUSD_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `2_000 ether`
- `FEUSD_AMOUNT_FOR_REPAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `3_000 ether`
- `FEUSD_AMOUNT_FOR_STABILITY_POOL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `100 ether`
- `FEUSD_CHANGE_SCENARIO_03` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `2_000 ether`
- `MAX_UPFRONT_FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `type(uint256).max`
- `PROXY_ADMIN_SLOT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- `SKIP_TEST` | type: `bool public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `true`
- `adminController` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `makeAddr("alice")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `makeAddr("bob")`
- `branchContracts` | type: `mapping(Collaterals => Branch) public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `curveGauge` | type: `IGauge public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `curvePool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `feUSD` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `hintHelpers` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `hypePrice` | type: `uint256 public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `metadataNFT` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `multiSigWallet` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `multiTroveGetter` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `poolDeployer` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `makeAddr("poolDeployer")`
- `proxyAdminOwner` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `token_0` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `token_1` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `whype` | type: `IERC20 public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `IERC20(0x5555555555555555555555555555555555555555)`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10 ether`
- `ACCEPTABLE_DELTA_IN_REDEMPTION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10 ether`
- `AMOUNT_TO_DEPOSIT_TO_SP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1_000 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `INETEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10e16`
- `MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_000 ether`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `"WBTC"`
- `NEW_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `15e16`
- `NEW_MCR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1428570000000000000`
- `REDEMPTION_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `100 ether`
- `TROVE_MANAGER_MCR_SLOT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `63`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `2_500 ether`
- `adminControllerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `makeAddr("BOB")`
- `charlie` | type: `address public` | vis: `public` | flags: `-` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `makeAddr("CHARLIE")`
- `multiSig` | type: `address public` | vis: `public` | flags: `-` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `10 ether`
- `ACCEPTABLE_DELTA_IN_REDEMPTION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `10 ether`
- `AMOUNT_TO_DEPOSIT_TO_SP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `200 ether`
- `BRANCH_OF_PROPOSAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1_200 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `INETEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `30e16`
- `MAX_CAP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `type(uint256).max`
- `MAX_CAP_SLOT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `117`
- `NEW_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `40e16`
- `PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `215`
- `PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1`
- `REDEMPTION_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `100 ether`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1_200 ether`
- `adminControllerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `makeAddr("BOB")`
- `charlie` | type: `address public` | vis: `public` | flags: `-` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `makeAddr("CHARLIE")`
- `multiSig` | type: `address public` | vis: `public` | flags: `-` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol`
- `ACCEPTABLE_DELTA_IN_INCREASE_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10 ether`
- `ACCEPTABLE_DELTA_IN_REDEMPTION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10 ether`
- `AMOUNT_TO_DEPOSIT_TO_SP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1_000 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `2_000 ether`
- `DECREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `0.02 ether`
- `DECREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `FEUSD_AMOUNT_BUFFER_FOR_CLOSE_TROVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1 ether`
- `INCREASE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `0.02 ether`
- `INCREASE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `INETEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10e16`
- `MAX_CAP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `type(uint256).max`
- `MAX_CAP_SLOT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `117`
- `NEW_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1`
- `NEW_COLLATERAL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `"WBTC"`
- `NEW_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `15e16`
- `PENDING_PRICE_FEED_PROPOSAL_SLOT_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `161`
- `PENDING_PRICE_FEED_PROPOSAL_TIMESTAMP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1`
- `REDEMPTION_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `100 ether`
- `WHYPE_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `500 ether`
- `WHYPE_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `2_500 ether`
- `adminControllerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `makeAddr("BOB")`
- `charlie` | type: `address public` | vis: `public` | flags: `-` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `makeAddr("CHARLIE")`
- `multiSig` | type: `address public` | vis: `public` | flags: `-` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `0`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000 ether`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `3_000 ether`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `2_500 ether`
- `DECREASE_INCREASE_AMOUNT_FOR_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `50 ether`
- `DECREASE_INCREASE_AMOUNT_FOR_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `100 ether`
- `FEUSD_AMOUNT_TO_RECEIVE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `300 ether`
- `HYPE_AMOUNT_FOR_BURNER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000 ether`
- `INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `10e16`
- `MAX_FEE_PERCENTAGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `20e16`
- `MAX_ITERATIONS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `100`
- `NEW_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000_000_000 ether`
- `NEW_INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `15e16`
- `NEW_MINT_CAP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000_000_000 ether`
- `NEW_SENSITIVE_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `0`
- `NEW_STANDARD_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `0`
- `ORIGINAL_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1_000_000 ether`
- `ORIGINAL_SENSITIVE_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `7 days`
- `ORIGINAL_STANDARD_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `1 days`
- `REDEEM_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `100 ether`
- `STABILITY_POOL_USER_DEPOSIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `500 ether`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol` = `makeAddr("BOB")`
- `burnerWallet` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `multiSigWallet` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `newAdminControllerImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `newStabilityPoolImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `newTroveManagerImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `originalAdminControllerImplementation` | type: `address public` | vis: `public` | flags: `-` | `AfterUpgradeTest` @ `test/AfterExecutionTests/AfterUpgradeTest.t.sol`
- `handler` | type: `InvariantsTestHandler` | vis: `default` | flags: `-` | `AnchoredInvariantsTest` @ `test/AnchoredInvariantsTest.t.sol`
- `actors` | type: `Actor[]` | vis: `default` | flags: `-` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol`
- `adam` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x1111111111111111111111111111111111111111`
- `barb` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x2222222222222222222222222222222222222222`
- `carl` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x3333333333333333333333333333333333333333`
- `dana` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x4444444444444444444444444444444444444444`
- `eric` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x5555555555555555555555555555555555555555`
- `fran` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x6666666666666666666666666666666666666666`
- `gabe` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x7777777777777777777777777777777777777777`
- `hope` | type: `address constant` | vis: `default` | flags: `constant` | `AnchoredSPInvariantsTest` @ `test/AnchoredSPInvariantsTest.t.sol` = `0x8888888888888888888888888888888888888888`
- `BTC_USD_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol` = `8`
- `BTC_USD_STALENESS_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol` = `86400`
- `btcUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol`
- `receiver` | type: `IFlashLoanReceiver public` | vis: `public` | flags: `-` | `BalancerFlashLoan` @ `src/Zappers/Modules/FlashLoans/BalancerFlashLoan.sol`
- `vault` | type: `IVault private constant` | vis: `private` | flags: `constant` | `BalancerFlashLoan` @ `src/Zappers/Modules/FlashLoans/BalancerFlashLoan.sol` = `IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8)`
- `BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `100e16`
- `CONTRACT_TYPE_COUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `12`
- `DEFAULT_BRANCH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `0`
- `MAX_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `4.5e18`
- `MAX_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `100_000_000_000 ether`
- `MAX_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `4.5e18`
- `MIN_CCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `1e18`
- `MIN_DEBT_LIMIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `10_000 ether`
- `MIN_MCR_BOUND` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `1e18`
- `PROPOSER_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `keccak256("PROPOSER_ROLE")`
- `REQUIRED_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `18`
- `REWARDS_ADMIN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `keccak256("REWARDS_ADMIN_ROLE")`
- `SENSITIVE_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `7 days`
- `SHUTDOWN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `keccak256("SHUTDOWN_ROLE")`
- `STANDARD_OPERATIONS_DELAY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BaseAdminController` @ `src/BaseAdminController.sol` = `1 days`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `addressesRegistries` | type: `IAddressesRegistry[] public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingCCRProposals` | type: `mapping(uint256 branchIndex => CCRProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingInterestRouterProposals` | type: `mapping(uint256 branchIndex => InterestRouterProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingMCRProposals` | type: `mapping(uint256 branchIndex => MCRProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingNewImplementationProposals` | type: `mapping(uint256 branchIndex => NewImplementationProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingPriceFeedProposals` | type: `mapping(uint256 branchIndex => PriceFeedProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingSPYieldProposals` | type: `mapping(uint256 branchIndex => SPYieldProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `usedTroveManagers` | type: `mapping(address troveManager => bool isUsed) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `actors` | type: `Actor[]` | vis: `default` | flags: `-` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol`
- `barb` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x2222222222222222222222222222222222222222`
- `carl` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x3333333333333333333333333333333333333333`
- `dana` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x4444444444444444444444444444444444444444`
- `eric` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x5555555555555555555555555555555555555555`
- `fran` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x6666666666666666666666666666666666666666`
- `gabe` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x7777777777777777777777777777777777777777`
- `hope` | type: `address constant` | vis: `default` | flags: `constant` | `BaseInvariantTest` @ `test/TestContracts/BaseInvariantTest.sol` = `0x8888888888888888888888888888888888888888`
- `branches` | type: `TestDeployer.LiquityContractsDev[]` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `collateralRegistry` | type: `ICollateralRegistry` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `feUSDToken` | type: `IfeUSDToken` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `hintHelpers` | type: `HintHelpers` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `BCR` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `CCR` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `LIQUIDATION_PENALTY_REDISTRIBUTION` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `LIQUIDATION_PENALTY_SP` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `MCR` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `SCR` | type: `uint256` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `STALE_TROVE_DURATION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BaseTest` @ `test/TestContracts/BaseTest.sol` = `90 days`
- `WHYPE` | type: `IWHYPE` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `activePool` | type: `IActivePool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `addressesRegistry` | type: `IAddressesRegistry` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `borrowerOperations` | type: `IBorrowerOperationsTester` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `collSurplusPool` | type: `ICollSurplusPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `collToken` | type: `IERC20` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `collateralRegistry` | type: `ICollateralRegistry` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `defaultPool` | type: `IDefaultPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `feUSDToken` | type: `IfeUSDToken` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `gasCompZapper` | type: `GasCompZapper` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `gasPool` | type: `GasPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `hintHelpers` | type: `HintHelpers` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `leverageZapperCurve` | type: `ILeverageZapper` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `leverageZapperUniV3` | type: `ILeverageZapper` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `metadataNFT` | type: `IMetadataNFT` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `mockInterestRouter` | type: `IInterestRouter` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `priceFeed` | type: `IPriceFeedTestnet` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `proxyAdmin` | type: `address` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `sortedTroves` | type: `ISortedTroves` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `stabilityPool` | type: `IStabilityPool` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `troveManager` | type: `ITroveManagerTester` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `troveNFT` | type: `ITroveNFT` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `whypeZapper` | type: `WHYPEZapper` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `WHYPE` | type: `IWHYPE public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `exchange` | type: `IExchange public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `flashLoanProvider` | type: `IFlashLoanProvider public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `has` | type: `mapping(BatchId => bool) public` | vis: `public` | flags: `-` | `BatchIdSet` @ `test/SortedTroves.t.sol`
- `BCR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BorrowerOperations` @ `src/BorrowerOperations.sol` = `BCR_ALL`
- `CCR` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `MCR` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `SCR` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `WHYPE` | type: `IWHYPE internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `collToken` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `hasBeenShutDown` | type: `bool public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `interestBatchManagerOf` | type: `mapping(uint256 => address) public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `interestBatchManagers` | type: `mapping(address => InterestBatchManager) private` | vis: `private` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `interestIndividualDelegateOf` | type: `mapping(uint256 => InterestIndividualDelegate) private` | vis: `private` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `isTemporaryShutdown` | type: `bool public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `sortedTroves` | type: `ISortedTroves internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `troveManager` | type: `ITroveManager internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `CCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `113`
- `COLL_SURPLUS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `109`
- `COLL_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `106`
- `FEUSD_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `110`
- `GAS_POOL_ADDRESS_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `108`
- `MAX_CAP_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `117`
- `MCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `116`
- `SCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `114`
- `SORTED_TROVES_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `111`
- `TROVE_MANAGER_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `107`
- `TROVE_NFT_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `53`
- `WHYPE_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `112`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `CollSurplusPool` @ `src/CollSurplusPool.sol` = `"CollSurplusPool"`
- `balances` | type: `mapping(address => uint256) internal` | vis: `internal` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `troveManagerAddress` | type: `address public` | vis: `public` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `baseRate` | type: `uint256 public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `lastFeeOperationTime` | type: `uint256 public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `tokens` | type: `IERC20Metadata[] public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `troveManagers` | type: `ITroveManager[] public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `CompositePriceFeed` @ `src/PriceFeeds/CompositePriceFeed.sol`
- `lstEthOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `CompositePriceFeed` @ `src/PriceFeeds/CompositePriceFeed.sol`
- `rateProviderAddress` | type: `address public` | vis: `public` | flags: `-` | `CompositePriceFeed` @ `src/PriceFeeds/CompositePriceFeed.sol`
- `_ETH_GAS_COMPENSATION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `src/Dependencies/Constants.sol` = `ETH_GAS_COMPENSATION`
- `_MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `src/Dependencies/Constants.sol` = `MIN_DEBT`
- `BASE_RATE_SLOT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `104`
- `DECIMAL_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `1e18`
- `DECIMAL_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `1e18`
- `MAX_UINT256` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `type(uint256).max`
- `MAX_UINT256` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `type(uint256).max`
- `PRICE_FEED_SLOT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `2`
- `REDUCED_BASE_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `1e16`
- `SKIP_TEST` | type: `bool public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `true`
- `STANDARD_HINT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `0`
- `STANDARD_HINT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `0`
- `THUNDERHEAD_OVERSEER` | type: `address public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `0xB96f07367e69e86d6e9C3F29215885104813eeAE`
- `UPDATED_AT_TIME_BUFFER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `1 hours`
- `UPDATED_AT_TIME_BUFFER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `10_000 seconds`
- `WHYPE_USDC_RED_STONE_FEED` | type: `address public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`
- `WHYPE_USDC_RED_STONE_FEED` | type: `address public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `_IMPLEMENTATION_SLOT` | type: `bytes32 internal constant` | vis: `internal` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- `ownerIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol`
- `ownerIndex` | type: `uint256 public` | vis: `public` | flags: `-` | `ContextHelper` @ `test/ContextHelper.t.sol`
- `COLL_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `curvePool` | type: `ICurvePool public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `MAX_UINT256` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `CurveGaugeDistributor` @ `src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol` = `type(uint256).max`
- `s_curveGauge` | type: `address public` | vis: `public` | flags: `-` | `CurveGaugeDistributor` @ `src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `CurveGaugeDistributor` @ `src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol`
- `s_interestRouter` | type: `address public` | vis: `public` | flags: `-` | `CurveGaugeDistributor` @ `src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `DefaultPool` @ `src/DefaultPool.sol` = `"DefaultPool"`
- `activePoolAddress` | type: `address public` | vis: `public` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `troveManagerAddress` | type: `address public` | vis: `public` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `0`
- `COLLATERAL_TAP_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1000 ether`
- `COLLATERAL_TAP_PERIOD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1 minutes`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `57`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `1`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `56`
- `IS_MOCK_PRICE_FEED` | type: `bool public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `false`
- `L1READ_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `0x44AFB4F9134c21E3ee69c785073FE2550607CA2a`
- `LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `66`
- `LIQUIDATION_PENALTY_SP_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `65`
- `MCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `63`
- `PRICE_FEED_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `2`
- `SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `keccak256("feUSD_TESTNET_DEPLOYMENT")`
- `SCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `64`
- `SP_YIELD_SP` | type: `uint256 public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `WHYPE_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `61`
- `branchContractAddresses` | type: `mapping(Collaterals => mapping(ContractTypes => address)) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `collateralFaucets` | type: `mapping(Collaterals => address) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `contractImplementationAddresses` | type: `mapping(ContractTypes => address) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `deployerInfo` | type: `DeployerInfo public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `feUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `58`
- `proxyAdminAddresses` | type: `ProxyAdminAddresses public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `singletonContractAddresses` | type: `SingletonContractAddresses public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `A` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `2700000`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `0`
- `ADJUSTMENT_STEP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `100000000000`
- `ALLOWED_EXTRA_PROFIT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `100000000000`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `57`
- `CURVE_CRYPTO_SWAP_FACTORY` | type: `ICryptoSwapFactory public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `ICryptoSwapFactory(0xc9Fe0C63Af9A39402e8a5514f9c43Af0322b665F)`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `ICurveXChainLiquidityGaugeFactory(0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6)`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1`
- `FEE_GAMMA` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `350000000000000`
- `FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `58`
- `GAMMA` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1300000000000`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `56`
- `GAUGE_SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `keccak256("curve.gauge.feUSD.WHYPE")`
- `IMPLEMENTATION_ID` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `0`
- `INITIAL_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `15 ether`
- `IS_REDSTONE_PRICE_FEED` | type: `bool public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `true`
- `LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `66`
- `LIQUIDATION_PENALTY_SP_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `65`
- `MA_HALF_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `600`
- `MCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `63`
- `MID_FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `2999999`
- `OUT_FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `80000000`
- `PERCENTAGE_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1e18`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `"feUSD/WHYPE"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `"feUSDWHYPE"`
- `PRICE_FEED_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `2`
- `REWARD_DESTINATIONS_LENGTH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1`
- `SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `keccak256("FELIX_MAINNET_DEPLOYMENT")`
- `SCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `64`
- `SP_YIELD_SP` | type: `uint256 public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `UPDATED_AT_TIME_BUFFER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `1 minutes`
- `WHYPE_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `61`
- `ZERO_BYTES4` | type: `bytes4 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `bytes4(0)`
- `branchContractAddresses` | type: `mapping(Collaterals => mapping(ContractTypes => address)) public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `contractImplementationAddresses` | type: `mapping(ContractTypes => address) public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `curveAddresses` | type: `CurveAddresses public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `deployerInfo` | type: `DeployerInfo public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `multiSigWallet` | type: `address public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `proxyAdminAddresses` | type: `ProxyAdminAddresses public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `singletonContractAddresses` | type: `SingletonContractAddresses public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `A` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `100`
- `ACTIVE_POOL_BITS_OFFSET_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `16`
- `ACTIVE_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `0`
- `COLL_SURPLUS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `57`
- `CURVE_STABLESWAP_NG_FACTORY` | type: `ICurveStableswapNGFactory public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `ICurveStableswapNGFactory(0x604388Bb1159AFd21eB5191cE22b4DeCdEE2Ae22)`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `ICurveXChainLiquidityGaugeFactory(0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6)`
- `DEFAULT_POOL_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `1`
- `FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `4000000`
- `FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `58`
- `GAS_POOL_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `56`
- `GAUGE_SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `keccak256("curve.gauge.feUSDUSDC")`
- `IMPLEMENTATION_ID` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `0`
- `IS_REDSTONE_PRICE_FEED` | type: `bool public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `true`
- `LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `66`
- `LIQUIDATION_PENALTY_SP_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `65`
- `MA_EXP_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `866`
- `MCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `63`
- `OFFPEG_FEE_MULTIPLIER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `20000000000`
- `PERCENTAGE_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `1e18`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `"feUSD/USDC"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `"feUSDCUSDC"`
- `PRICE_FEED_SLOT_FOR_LQ_BASE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `2`
- `REWARD_DESTINATIONS_LENGTH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `1`
- `SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `keccak256("FELIX_MAINNET_DEPLOYMENT")`
- `SCR_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `64`
- `SP_YIELD_SP` | type: `uint256 public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `USDC_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `0xdeC702aa5a18129Bd410961215674A7A130A12e5`
- `WHYPE_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `61`
- `ZERO_BYTES4` | type: `bytes4 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `bytes4(0)`
- `branchContractAddresses` | type: `mapping(Collaterals => mapping(ContractTypes => address)) public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `contractImplementationAddresses` | type: `mapping(ContractTypes => address) public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `curveAddresses` | type: `CurveAddresses public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `deployerInfo` | type: `DeployerInfo public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `multiSigWallet` | type: `address public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `proxyAdminAddresses` | type: `ProxyAdminAddresses public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `singletonContractAddresses` | type: `SingletonContractAddresses public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `SP_YIELD_SPLIT` | type: `uint256 public` | vis: `public` | flags: `-` | `DevTestSetup` @ `test/TestContracts/DevTestSetup.sol` = `75e16`
- `lastTapped` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `ERC20Faucet` @ `test/TestContracts/ERC20Faucet.sol`
- `tapAmount` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `ERC20Faucet` @ `test/TestContracts/ERC20Faucet.sol`
- `tapPeriod` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `ERC20Faucet` @ `test/TestContracts/ERC20Faucet.sol`
- `MAX_APPROVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol` = `type(uint256).max`
- `MAX_POOL_INDEX` | type: `int128 public constant` | vis: `public` | flags: `constant` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol` = `1`
- `s_USDC` | type: `IERC20 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_USDCPoolIndex` | type: `int128 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_borrowerOperations` | type: `mapping(uint256 branchIndex => address borrowerOperations) public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_curvePool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_feUSDPoolIndex` | type: `int128 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_stabilityPools` | type: `mapping(uint256 branchIndex => address stabilityPool) public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `assets` | type: `mapping(bytes4 => Asset) public` | vis: `public` | flags: `-` | `FixedAssetReader` @ `src/NFTMetadata/utils/FixedAssets.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `GasCompZapper` @ `src/Zappers/GasCompZapper.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `GasCompZapper` @ `src/Zappers/GasCompZapper.sol`
- `INVALID_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol` = `0`
- `SYSTEM_CONTRACT` | type: `address constant` | vis: `default` | flags: `constant` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol` = `0x44AFB4F9134c21E3ee69c785073FE2550607CA2a`
- `borrowerOperations` | type: `IBorrowerOperations` | vis: `default` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `l1Index` | type: `uint16 public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `lastGoodPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `priceFeedDisabled` | type: `bool public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `systemContract` | type: `L1Read public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `szDecimals` | type: `uint8 public` | vis: `public` | flags: `-` | `HLPriceFeed` @ `src/PriceFeeds/HLPriceFeed.sol`
- `failure` | type: `bool public` | vis: `public` | flags: `-` | `HLPriceFeedMock` @ `test/TestContracts/HLPriceFeedMock.sol`
- `price` | type: `uint256 public` | vis: `public` | flags: `-` | `HLPriceFeedMock` @ `test/TestContracts/HLPriceFeedMock.sol`
- `BTC_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `3`
- `BTC_SZ_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `5`
- `ETH_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `4`
- `ETH_SZ_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `4`
- `FIXED_BLOCK` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `7949936`
- `FIXED_BTC_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `68514000000000000000000`
- `FIXED_ETH_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `2694300000000000000000`
- `MOCK_ETH_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `2600e18`
- `borrowerOperations` | type: `BorrowerOperationsTester` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `btcPriceFeed` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `ethPriceFeed` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `failingPriceFeed` | type: `HLPriceFeedMock` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `priceFeedImpl` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `priceFeedMockImpl` | type: `HLPriceFeedMock` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `proxyAdmin` | type: `ProxyAdmin` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `registry` | type: `AddressesRegistry` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `HintHelpers` @ `src/HintHelpers.sol` = `"HintHelpers"`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `HintHelpers` @ `src/HintHelpers.sol`
- `USDC` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `USDC_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `WETH` | type: `IWETH public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `curvePool` | type: `ICurveStableswapNGPool public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feeUsdcWeth` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feeWethColl` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `uniV3Router` | type: `ISwapRouter public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `MAX_APPROVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol` = `type(uint256).max`
- `MAX_UINT256` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouter` @ `src/InterestRouter.sol` = `type(uint256).max`
- `REWARDS_CLAIM_INTERVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouter` @ `src/InterestRouter.sol` = `1 weeks`
- `SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol` = `keccak256("INTEREST_ROUTER_FELIX")`
- `WEEK` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol` = `7 days`
- `s_adminController` | type: `IAdminController public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol`
- `s_curveGauge` | type: `address public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter.sol`
- `s_deployedAtTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter.sol`
- `s_lastClaimTimestamp` | type: `uint256 public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter.sol`
- `s_rewardsAllocator` | type: `address public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol`
- `MAX_ALLOCATION_CONFIG_SIZE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2` @ `src/InterestRouterV2.sol` = `10`
- `MIN_REWARDS_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2` @ `src/InterestRouterV2.sol` = `100 ether`
- `PERCENTAGE_DENOMINATOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2` @ `src/InterestRouterV2.sol` = `1e18`
- `REWARD_INTERVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2` @ `src/InterestRouterV2.sol` = `1 weeks`
- `ZERO_BYTES4` | type: `bytes4 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2` @ `src/InterestRouterV2.sol` = `bytes4(0)`
- `s_adminController` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2` @ `src/InterestRouterV2.sol`
- `s_currentAllocationConfig` | type: `AllocationConfig private` | vis: `private` | flags: `-` | `InterestRouterV2` @ `src/InterestRouterV2.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2` @ `src/InterestRouterV2.sol`
- `s_nextAllocationConfig` | type: `AllocationConfig private` | vis: `private` | flags: `-` | `InterestRouterV2` @ `src/InterestRouterV2.sol`
- `A` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `100`
- `AMOUNT_FOR_CURVE_POOL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `200_000`
- `AMOUNT_TO_STAKE_INTO_GAUGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `10_000 ether`
- `BPS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `1e18`
- `CURVE_STABLESWAP_NG_FACTORY` | type: `ICurveStableswapNGFactory public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `ICurveStableswapNGFactory(0x604388Bb1159AFd21eB5191cE22b4DeCdEE2Ae22)`
- `CURVE_X_CHAIN_LIQUIDITY_GAUGE_FACTORY` | type: `ICurveXChainLiquidityGaugeFactory public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `ICurveXChainLiquidityGaugeFactory( 0x8b3EFBEfa6eD222077455d6f0DCdA3bF4f3F57A6 )`
- `FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `4000000`
- `GAUGE_DISTRIBUTOR_SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `keccak256("curve.fi.gauge.distributor")`
- `GAUGE_SALT` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `keccak256("curve.fi.gauge.v2")`
- `IMPLEMENTATION_ID` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `0`
- `MAX_UINT256` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `type(uint256).max`
- `MA_EXP_TIME` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `866`
- `OFFPEG_FEE_MULTIPLIER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `20000000000`
- `PERCENTAGE_FOR_EACH_RECEIVER_WITHOUT_GAUGE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `25e16`
- `POOL_NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `"feUSD/USDC"`
- `POOL_SYMBOL` | type: `string public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `"feUSDCUSDC"`
- `RECEIVERS_ARRAY_SIZE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `4`
- `REWARDS_INTERVAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `1 weeks`
- `SKIP_TEST` | type: `bool public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `true`
- `TOTAL_REWARDS_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `1_000_000 ether`
- `WEEKLY_REWARDS_MAX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `10_000 ether`
- `WEEKLY_REWARDS_MIN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `2_000 ether`
- `ZERO_BYTES4` | type: `bytes4 public constant` | vis: `public` | flags: `constant` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `bytes4(0)`
- `s_activePool` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ACTIVE_POOL")`
- `s_adminController` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ADMIN_CONTROLLER")`
- `s_alternativeCollaboratorsWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ALTERNATIVE_COLLABORATORS_WALLET")`
- `s_alternativeCommunityWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ALTERNATIVE_COMMUNITY_WALLET")`
- `s_alternativeFoundationWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ALTERNATIVE_FOUNDATION_WALLET")`
- `s_alternativeStrategistsWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("ALTERNATIVE_STRATEGISTS_WALLET")`
- `s_coin0` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_coin1` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_collaboratorsWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("COLLABORATORS_WALLET")`
- `s_communityWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("COMMUNITY_WALLET")`
- `s_curveGaugeDistributor` | type: `CurveGaugeDistributor public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_foundationWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("FOUNDATION_WALLET")`
- `s_gauge` | type: `IGauge public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_interestRouter` | type: `InterestRouterV2 public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_interestRouterImplementation` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_mockFeUSD` | type: `MockFeUSD public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_mockUSDC` | type: `MockUSDC public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_pool` | type: `ICurveStableswapNGPool public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `s_staker` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("STAKER")`
- `s_strategistsWallet` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol` = `makeAddr("STRATEGISTS_WALLET")`
- `handler` | type: `InvariantsTestHandler` | vis: `default` | flags: `-` | `InvariantsTest` @ `test/Invariants.t.sol`
- `seenBatches` | type: `BatchIdSet` | vis: `default` | flags: `-` | `InvariantsTest` @ `test/Invariants.t.sol`
- `ACTIVE` | type: `ITroveManager.Status constant` | vis: `default` | flags: `constant` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `ITroveManager.Status.active`
- `BCR` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `CCR` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `CLOSED_BY_LIQ` | type: `ITroveManager.Status constant` | vis: `default` | flags: `constant` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `ITroveManager.Status.closedByLiquidation`
- `CLOSED_BY_OWNER` | type: `ITroveManager.Status constant` | vis: `default` | flags: `constant` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `ITroveManager.Status.closedByOwner`
- `LIQ_PENALTY_REDIST` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `LIQ_PENALTY_SP` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `MCR` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `SCR` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `ZOMBIE` | type: `ITroveManager.Status constant` | vis: `default` | flags: `constant` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `ITroveManager.Status.zombie`
- `_assumeNoExpectedFailures` | type: `bool immutable` | vis: `default` | flags: `immutable` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_baseRate` | type: `uint256` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `INITIAL_BASE_RATE`
- `_batchManagerOf` | type: `mapping(uint256 branchIdx => mapping(uint256 troveId => address))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_batchManagers` | type: `mapping(uint256 branchIdx => EnumerableAddressSet)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_batches` | type: `mapping(uint256 branchIdx => mapping(address batchManager => Batch))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_functionCaller` | type: `FunctionCaller immutable` | vis: `default` | flags: `immutable` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_handlerfeUSD` | type: `uint256` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_liquidation` | type: `LiquidationTransientState` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_pendingInterest` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_price` | type: `mapping(uint256 branchIdx => uint256)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_redemption` | type: `mapping(uint256 branchIdx => RedemptionTransientState)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_timeSinceLastBatchInterestRateAdjustment` | type: `mapping(uint256 branchIdx => mapping(address batchManager => uint256))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_timeSinceLastRedemption` | type: `uint256` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol` = `0`
- `_timeSinceLastTroveInterestRateAdjustment` | type: `mapping(uint256 branchIdx => mapping(uint256 troveId => uint256))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_troveIds` | type: `mapping(uint256 branchIdx => EnumerableSet)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_troveIndexOf` | type: `mapping(uint256 branchIdx => mapping(address owner => uint256))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_troves` | type: `mapping(uint256 branchIdx => mapping(uint256 troveId => Trove))` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_urgentRedemption` | type: `UrgentRedemptionTransientState` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `_zombieTroveIds` | type: `mapping(uint256 branchIdx => EnumerableSet)` | vis: `default` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `collSurplus` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `designatedVictimId` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `isShutdown` | type: `mapping(uint256 branchIdx => bool) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `spColl` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `spfeUSDDeposits` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `spfeUSDYield` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `totalCollRedist` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `totalDebtRedist` | type: `mapping(uint256 branchIdx => uint256) public` | vis: `public` | flags: `-` | `InvariantsTestHandler` @ `test/TestContracts/InvariantsTestHandler.t.sol`
- `KHYPE_HYPE_DEVIATION_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `KHYPEPriceFeed` @ `src/PriceFeeds/KHYPEPriceFeed.sol` = `0.5e16`
- `kHypeHypeOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `KHYPEPriceFeed` @ `src/PriceFeeds/KHYPEPriceFeed.sol`
- `DELEGATIONS_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000804`
- `DELEGATOR_SUMMARY_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000805`
- `L1_BLOCK_NUMBER_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000809`
- `MARK_PX_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000806`
- `ORACLE_PX_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000807`
- `SPOT_BALANCE_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000801`
- `SPOT_PX_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000808`
- `VAULT_EQUITY_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000802`
- `WITHDRAWABLE_PRECOMPILE_ADDRESS` | type: `address constant` | vis: `default` | flags: `constant` | `L1Read` @ `src/Dependencies/L1Read.sol` = `0x0000000000000000000000000000000000000803`
- `N_TROVES` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `LiquidationCostsTest` @ `test/liquidationCosts.t.sol` = `100`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `defaultPool` | type: `IDefaultPool internal` | vis: `internal` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `priceFeed` | type: `IPriceFeed internal` | vis: `internal` | flags: `-` | `LiquityBase` @ `src/Dependencies/LiquityBase.sol`
- `ACTIVE_POOL_OFFSET` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `2`
- `ACTIVE_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `0`
- `DEFAULT_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `1`
- `PRICE_FEED_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `LiquityBaseInit` @ `src/Libraries/LiquityBaseInit.sol` = `2`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `defaultPool` | type: `IDefaultPool internal` | vis: `internal` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `priceFeed` | type: `IPriceFeedLst internal` | vis: `internal` | flags: `-` | `LiquityBaseLst` @ `src/Dependencies/LiquityBaseLst.sol`
- `lastGoodPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `MainnetPriceFeedBase` @ `src/PriceFeeds/MainnetPriceFeedBase.sol`
- `priceFeedDisabled` | type: `bool` | vis: `default` | flags: `-` | `MainnetPriceFeedBase` @ `src/PriceFeeds/MainnetPriceFeedBase.sol`
- `initializedFixedAssetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataDeployment` @ `test/TestContracts/MetadataDeployment.sol`
- `pointer` | type: `address public` | vis: `public` | flags: `-` | `MetadataDeployment` @ `test/TestContracts/MetadataDeployment.sol`
- `assetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataNFT` @ `src/NFTMetadata/MetadataNFT.sol`
- `description` | type: `string public constant` | vis: `public` | flags: `constant` | `MetadataNFT` @ `src/NFTMetadata/MetadataNFT.sol` = `"Felix Trove position"`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `MetadataNFT` @ `src/NFTMetadata/MetadataNFT.sol` = `"Felix Trove"`
- `__gap` | type: `uint256[48] internal` | vis: `internal` | flags: `-` | `MetadataNFTBase` @ `src/NFTMetadata/utils/MatadataNFTBase.sol`
- `assetReader` | type: `FixedAssetReader public` | vis: `public` | flags: `-` | `MetadataNFTBase` @ `src/NFTMetadata/utils/MatadataNFTBase.sol`
- `description` | type: `string public constant` | vis: `public` | flags: `constant` | `MetadataNFTBase` @ `src/NFTMetadata/utils/MatadataNFTBase.sol` = `"Felix Trove position"`
- `name` | type: `string public constant` | vis: `public` | flags: `constant` | `MetadataNFTBase` @ `src/NFTMetadata/utils/MatadataNFTBase.sol` = `"Felix Trove"`
- `adminController` | type: `address public` | vis: `public` | flags: `-` | `MetadataNFTV2` @ `src/NFTMetadata/MetadataNFTV2.sol`
- `INITIAL_SUPPLY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockFeUSD` @ `test/TestContracts/MockFeUSD.sol` = `10_000_000 ether`
- `owner` | type: `address public` | vis: `public` | flags: `-` | `MockInterestRouter` @ `src/MockInterestRouter.sol`
- `ETH_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `10 ether`
- `HYPE_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `27 ether`
- `PURR_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `0.3 ether`
- `SOL_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `270 ether`
- `WBTC_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `99_000 ether`
- `WETH_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `3_750 ether`
- `decimals_` | type: `uint8 public` | vis: `public` | flags: `-` | `MockPriceFeed` @ `test/TestContracts/MockPriceFeed.sol`
- `price` | type: `uint256 public` | vis: `public` | flags: `-` | `MockPriceFeed` @ `test/TestContracts/MockPriceFeed.sol`
- `updatedAt_` | type: `uint256 public` | vis: `public` | flags: `-` | `MockPriceFeed` @ `test/TestContracts/MockPriceFeed.sol`
- `_batchIds` | type: `BatchId[] private` | vis: `private` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol`
- `_batches` | type: `mapping(BatchId => Batch) private` | vis: `private` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol`
- `_nextBatchId` | type: `uint160 public` | vis: `public` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol` = `1`
- `_nextTroveId` | type: `uint256 public` | vis: `public` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol` = `1`
- `_sortedTroves` | type: `SortedTroves private` | vis: `private` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol`
- `_troveIds` | type: `TroveId[] private` | vis: `private` | flags: `-` | `MockTroveManager` @ `test/SortedTroves.t.sol`
- `INITIAL_SUPPLY` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockUSDC` @ `test/TestContracts/MockUSDC.sol` = `10_000_000e6`
- `isNewImplementation` | type: `bool public` | vis: `public` | flags: `-` | `MockV2feUSDZapper` @ `test/TestContracts/MockV2feUSDZapper.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `MultiTroveGetter` @ `src/MultiTroveGetter.sol`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `MulticollateralTest` @ `test/multicollateral.t.sol` = `4`
- `contractsArray` | type: `TestDeployer.LiquityContractsDev[] public` | vis: `public` | flags: `-` | `MulticollateralTest` @ `test/multicollateral.t.sol`
- `AMOUNT_OF_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `200 ether`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `300 ether`
- `COLLATERAL_LENGTH` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `2`
- `HYPE_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `1 ether`
- `INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `10e16`
- `MAX_CAP_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `1_000_000_000 ether`
- `MULTI_SIG_WALLET` | type: `address public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `0x2157f54f7a745c772e686AA691Fa590B49171eC9`
- `NEW_MIN_DEBT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `MIN_DEBT`
- `activePoolNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `adminControllerNoDelaysImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `adminControllerV2Implementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol` = `makeAddr("BOB")`
- `borrowerOperationsNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `borrowerOperationsSecondImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `stabilityPoolNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `troveManagerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `troveManagerSecondImplementation` | type: `address public` | vis: `public` | flags: `-` | `MultipleUpgradeTest` @ `test/MultipleUpgradeTest.t.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `NonPayableSwitch` @ `test/TestContracts/NonPayableSwitch.sol`
- `isPayable` | type: `bool` | vis: `default` | flags: `-` | `NonPayableSwitch` @ `test/TestContracts/NonPayableSwitch.sol`
- `_owner` | type: `address private` | vis: `private` | flags: `-` | `Ownable` @ `src/Dependencies/Ownable.sol`
- `PRICE` | type: `uint256 private` | vis: `private` | flags: `-` | `PriceFeedMock` @ `test/TestContracts/PriceFeedMock.sol`
- `_price` | type: `uint256 private` | vis: `private` | flags: `-` | `PriceFeedTestnet` @ `test/TestContracts/PriceFeedTestnet.sol` = `200 * 1e18`
- `BRANCHES_LENGTH` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol` = `uint8(Collaterals.COLLATERALS_LENGTH)`
- `BRANCHES_LENGTH` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol` = `uint8(Collaterals.COLLATERALS_LENGTH)`
- `branchContracts` | type: `mapping(Collaterals => BranchContracts) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol`
- `branchContracts` | type: `mapping(Collaterals => BranchContracts) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol`
- `branchPools` | type: `mapping(Collaterals => BranchPools) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol`
- `branchPools` | type: `mapping(Collaterals => BranchPools) public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol`
- `curveContracts` | type: `CurveContracts public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol`
- `curveContracts` | type: `CurveContracts public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol`
- `singletonContracts` | type: `SingletonContracts public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `scripts/Mainnet/Utils/ReadManifestHelper.sol`
- `singletonContracts` | type: `SingletonContracts public` | vis: `public` | flags: `-` | `ReadManifestHelper` @ `test/ReadManifestHelper.t.sol`
- `WITH_INTEREST` | type: `bool` | vis: `default` | flags: `-` | `RebasingBatchShares` @ `test/rebasingBatchShares.t.sol` = `true`
- `lastGoodPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `RedStonePriceFeedBase` @ `src/PriceFeeds/RedStonePriceFeedBase.sol`
- `priceFeedDisabled` | type: `bool` | vis: `default` | flags: `-` | `RedStonePriceFeedBase` @ `src/PriceFeeds/RedStonePriceFeedBase.sol`
- `borrowerOperations` | type: `IBorrowerOperations` | vis: `default` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `hypeUsdcOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `lastGoodPrice` | type: `uint256 public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `priceSource` | type: `PriceSource public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `usdcUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `COLLATERAL_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `30_000 ether`
- `HYPE_AMOUNT_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `1 ether`
- `INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `10e16`
- `REDEMPTION_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `300_000 ether`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `RedemptionGas` @ `test/RedemptionGas.t.sol` = `makeAddr("BOB")`
- `__gap` | type: `uint256[48] private` | vis: `private` | flags: `-` | `RedstoneCompositePriceFeedLst` @ `src/PriceFeeds/RedstoneCompositePriceFeedLst.sol`
- `rateProviderAddress` | type: `address public` | vis: `public` | flags: `-` | `RedstoneCompositePriceFeedLst` @ `src/PriceFeeds/RedstoneCompositePriceFeedLst.sol`
- `MAX_BATCH_SIZE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol` = `50`
- `WEEK` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol` = `7 days`
- `s_currentWeek` | type: `uint256 public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `s_hasClaimed` | type: `mapping(address staker => mapping(uint256 week => bool hasClaimed)) public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `s_interestRouter` | type: `address public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `s_weeklyRewards` | type: `mapping(uint256 week => WeeklyRewards) public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `handler` | type: `SPInvariantsTestHandler` | vis: `default` | flags: `-` | `SPInvariantsBase` @ `test/SPInvariants.t.sol`
- `stabilityPool` | type: `IStabilityPool` | vis: `default` | flags: `-` | `SPInvariantsBase` @ `test/SPInvariants.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `collSurplusPool` | type: `ICollSurplusPool immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `collateralToken` | type: `IERC20` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `fixtureDeposited` | type: `uint256[]` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `hintHelpers` | type: `HintHelpers immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `initialPrice` | type: `uint256 immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `myfeUSD` | type: `uint256` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol` = `0`
- `priceFeed` | type: `IPriceFeedTestnet immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `spColl` | type: `uint256` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol` = `0`
- `spfeUSD` | type: `uint256` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol` = `0`
- `stabilityPool` | type: `IStabilityPool immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `troveIndexOf` | type: `mapping(address owner => uint256)` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `troveManager` | type: `ITroveManagerTester immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `0`
- `MAX_DEBT_CAP` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `150_000 ether`
- `SKIP_TEST` | type: `bool public constant` | vis: `public` | flags: `constant` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `true`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol` = `makeAddr("BOB")`
- `multisigWallet` | type: `address public` | vis: `public` | flags: `-` | `SetMaxCap` @ `test/AfterExecutionTests/SetMaxCap.t.sol`
- `SHUTDOWN_ROLE` | type: `bytes32 public constant` | vis: `public` | flags: `constant` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol` = `keccak256("SHUTDOWN_ROLE")`
- `activePool` | type: `IActivePool public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `adminController` | type: `IAdminController public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `deployFelix` | type: `DeployFelix public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `deployerPK` | type: `uint256 public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `owner` | type: `address public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `ShutdownAndResume` @ `test/shutdownAndResume.t.sol`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `ShutdownTest` @ `test/shutdown.t.sol` = `4`
- `contractsArray` | type: `TestDeployer.LiquityContractsDev[] public` | vis: `public` | flags: `-` | `ShutdownTest` @ `test/shutdown.t.sol`
- `BAD_HINT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `SortedTroves` @ `src/SortedTroves.sol` = `0`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `SortedTroves` @ `src/SortedTroves.sol` = `"SortedTroves"`
- `UNINITIALIZED_ID` | type: `uint256 constant` | vis: `default` | flags: `constant` | `SortedTroves` @ `src/SortedTroves.sol` = `0`
- `batches` | type: `mapping(BatchId => Batch) public` | vis: `public` | flags: `-` | `SortedTroves` @ `src/SortedTroves.sol`
- `borrowerOperationsAddress` | type: `address public` | vis: `public` | flags: `-` | `SortedTroves` @ `src/SortedTroves.sol`
- `nodes` | type: `mapping(uint256 => Node) public` | vis: `public` | flags: `-` | `SortedTroves` @ `src/SortedTroves.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `SortedTroves` @ `src/SortedTroves.sol`
- `addressesRegistryImpl` | type: `IAddressesRegistry` | vis: `default` | flags: `-` | `SortedTrovesTest` @ `test/SortedTroves.t.sol` = `new AddressesRegistry()`
- `proxyAdmin` | type: `ProxyAdmin` | vis: `default` | flags: `-` | `SortedTrovesTest` @ `test/SortedTroves.t.sol` = `new ProxyAdmin()`
- `sortedtrovesImpl` | type: `SortedTroves` | vis: `default` | flags: `-` | `SortedTrovesTest` @ `test/SortedTroves.t.sol` = `new SortedTroves()`
- `sortedTroves` | type: `ISortedTroves` | vis: `default` | flags: `-` | `SortedTrovesTester` @ `test/TestContracts/SortedTrovesTester.sol`
- `MAX_SCALE_FACTOR_EXPONENT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StabilityPool` @ `src/StabilityPool.sol` = `8`
- `NAME` | type: `string public constant` | vis: `public` | flags: `constant` | `StabilityPool` @ `src/StabilityPool.sol` = `"StabilityPool"`
- `P` | type: `uint256 public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `P_PRECISION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StabilityPool` @ `src/StabilityPool.sol` = `1e36`
- `SCALE_FACTOR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StabilityPool` @ `src/StabilityPool.sol` = `1e9`
- `SCALE_SPAN` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `StabilityPool` @ `src/StabilityPool.sol` = `2`
- `collBalance` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `currentScale` | type: `uint256 public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `depositSnapshots` | type: `mapping(address => Snapshots) public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `scaleToB` | type: `mapping(uint256 => uint256) public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `scaleToS` | type: `mapping(uint256 => uint256) public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `stashedColl` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `totalfeUSDDeposits` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `yieldGainsOwed` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `yieldGainsPending` | type: `uint256 internal` | vis: `internal` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `DECIMALS` | type: `uint256 constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `18`
- `DECIMAL_SEPARATOR` | type: `string constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `"."`
- `DECIMAL_UNIT` | type: `string constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `" ether"`
- `GROUP_DIGITS` | type: `uint256 constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `3`
- `GROUP_SEPARATOR` | type: `bytes1 constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `"_"`
- `ONE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `StringFormatting` @ `test/Utils/StringFormatting.sol` = `10 ** DECIMALS`
- `A` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `B` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `C` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `D` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `E` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `F` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `G` | type: `address public` | vis: `public` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `accounts` | type: `Accounts` | vis: `default` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `accountsList` | type: `address[]` | vis: `default` | flags: `-` | `TestAccounts` @ `test/TestContracts/Accounts.sol`
- `COLL_TOKEN_INDEX` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `SALT` | type: `bytes32 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `keccak256("LiquityV2")`
- `SP_YIELD_SPLIT` | type: `uint256` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `vm.envUint("SP_YIELD_SPLIT")`
- `UNIV3_FEE` | type: `uint24 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `3000`
- `UNIV3_FEE_USDC_WETH` | type: `uint24 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `500`
- `UNIV3_FEE_WETH_COLL` | type: `uint24 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `100`
- `USDC` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `USDC_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `WETH_MAINNET` | type: `IWETH constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)`
- `WHYPE_MAINNET` | type: `IWHYPE constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `IWHYPE(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)`
- `activePoolImpl` | type: `IActivePoolTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new ActivePoolTester()`
- `addressesRegistryImpl` | type: `IAddressesRegistry` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new AddressesRegistry()`
- `borrowerOperationsImpl` | type: `BorrowerOperations` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new BorrowerOperations()`
- `borrowerOperationsTesterImpl` | type: `BorrowerOperationsTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new BorrowerOperationsTester()`
- `collSurplusPoolImpl` | type: `CollSurplusPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new CollSurplusPool()`
- `collateralRegistryImpl` | type: `CollateralRegistry` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new CollateralRegistry()`
- `curveFactory` | type: `ICurveFactory constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `ICurveFactory(0x98EE851a00abeE0d95D08cF4CA2BdCE32aeaAF7F)`
- `curveStableswapFactory` | type: `ICurveStableswapNGFactory constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `ICurveStableswapNGFactory(0x6A8cbed756804B16E05E741eDaBd5cB544AE21bf)`
- `defaultPoolImpl` | type: `DefaultPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new DefaultPool()`
- `feUSDTokenImpl` | type: `feUSDToken` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new feUSDToken()`
- `feUSD_TOKEN_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `0`
- `gasCompZapperImpl` | type: `GasCompZapper` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new GasCompZapper()`
- `gasPoolImpl` | type: `GasPool` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new GasPool()`
- `hintHelpersImpl` | type: `HintHelpers` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new HintHelpers()`
- `hlPriceFeedImpl` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new HLPriceFeed()`
- `leverageLSTZapperImpl` | type: `LeverageLSTZapper` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new LeverageLSTZapper()`
- `leverageWHYPEZapperImpl` | type: `LeverageWHYPEZapper` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new LeverageWHYPEZapper()`
- `metadataNFTImpl` | type: `MetadataNFT` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new MetadataNFT()`
- `mockInterestRouterImpl` | type: `MockInterestRouter` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new MockInterestRouter()`
- `multiTroveGetterImpl` | type: `MultiTroveGetter` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new MultiTroveGetter()`
- `proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new ProxyAdmin()`
- `sortedTrovesImpl` | type: `SortedTroves` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new SortedTroves()`
- `stabilityPoolImpl` | type: `IStabilityPoolTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new StabilityPoolTester()`
- `troveManagerImpl` | type: `TroveManager` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new TroveManager()`
- `troveManagerTesterImpl` | type: `TroveManagerTester` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new TroveManagerTester()`
- `troveNFTImpl` | type: `TroveNFT` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new TroveNFT()`
- `uniV3PositionManager` | type: `INonfungiblePositionManager constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88)`
- `uniV3Router` | type: `ISwapRouter constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564)`
- `whypeZapperImpl` | type: `WHYPEZapper` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new WHYPEZapper()`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `0`
- `COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `700 ether`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `5000 ether`
- `HYPE_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `1 ether`
- `INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `10e16`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol` = `makeAddr("BOB")`
- `multiSig` | type: `address public` | vis: `public` | flags: `-` | `TestMaxCap` @ `test/AfterExecutionTests/TestMaxCap.t.sol`
- `BCR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TroveManager` @ `src/TroveManager.sol` = `BCR_ALL`
- `CCR` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `LIQUIDATION_PENALTY_REDISTRIBUTION` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `LIQUIDATION_PENALTY_SP` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `L_coll` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `L_feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `MCR` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `SCR` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `WHYPE` | type: `IWHYPE internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `batchIds` | type: `address[] public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `lastCollError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `lastZombieTroveId` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `lastfeUSDDebtError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `rewardSnapshots` | type: `mapping(uint256 => RewardSnapshot) public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `shutdownTime` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `sortedTroves` | type: `ISortedTroves public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalCollateralSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalStakes` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `totalStakesSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `troveNFT` | type: `ITroveNFT public` | vis: `public` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `BORROWER_OPERATIONS_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `54`
- `CCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `62`
- `COLLATERAL_REGISTRY_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `60`
- `COLL_SURPLUS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `57`
- `FEUSD_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `58`
- `GAS_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `56`
- `LIQUIDATION_PENALTY_REDISTRIBUTION_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `66`
- `LIQUIDATION_PENALTY_SP_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `65`
- `MCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `63`
- `SCR_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `64`
- `SORTED_TROVES_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `59`
- `STABILITY_POOL_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `55`
- `TROVE_NFT_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `53`
- `WHYPE_ADDRESS_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `61`
- `BCR` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `TroveManagerLst` @ `src/TroveManagerLst.sol` = `BCR_ALL`
- `CCR` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `LIQUIDATION_PENALTY_REDISTRIBUTION` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `LIQUIDATION_PENALTY_SP` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `L_coll` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `L_feUSDDebt` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `MCR` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `SCR` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `WHYPE` | type: `IWHYPE internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `batchIds` | type: `address[] public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `collSurplusPool` | type: `ICollSurplusPool internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `collateralRegistry` | type: `ICollateralRegistry public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `gasPoolAddress` | type: `address internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `lastCollError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `lastZombieTroveId` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `lastfeUSDDebtError_Redistribution` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `rewardSnapshots` | type: `mapping(uint256 => RewardSnapshot) public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `shutdownTime` | type: `uint256 public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `sortedTroves` | type: `ISortedTroves public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `stabilityPool` | type: `IStabilityPool public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalCollateralSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalStakes` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `totalStakesSnapshot` | type: `uint256 internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `troveNFT` | type: `ITroveNFT public` | vis: `public` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `STALE_TROVE_DURATION` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerTester` @ `test/TestContracts/TroveManagerTester.t.sol` = `90 days`
- `collToken` | type: `IERC20Metadata public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `metadataNFT` | type: `IMetadataNFT public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `troveManager` | type: `ITroveManager public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `fee` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `uniV3Router` | type: `ISwapRouter public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `ADMIN_CONTROLLER` | type: `IAdminController public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `IAdminController(0xF42fDD953E68D0010F5fA9d61ef1ba0Fc997Ef2F)`
- `BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `0`
- `MULTI_SIG` | type: `address public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `0x4A827418D632C415E19825fd011283A4ba020B3A`
- `MULTI_SIG_1` | type: `address public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `0x699090E73c4077eF2aF42773b31788C6564F079c`
- `MULTI_SIG_2` | type: `address public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `0x4A827418D632C415E19825fd011283A4ba020B3A`
- `PROXY_ADMIN` | type: `ProxyAdmin public constant` | vis: `public` | flags: `constant` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol` = `ProxyAdmin(0xdf1293b46D3D8f6c090aB98094805db68922CE30)`
- `adminControllerNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol`
- `spNewImplementation` | type: `address public` | vis: `public` | flags: `-` | `UpgradeAdminController` @ `test/upgradeAdminController.t.sol`
- `allowance` | type: `mapping(address => mapping(address => uint256)) public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol`
- `balanceOf` | type: `mapping(address => uint256) public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol` = `18`
- `name` | type: `string public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol` = `"Wrapped Ether"`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `WETH9` @ `test/TestContracts/WETH.sol` = `"WETH"`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WETHPriceFeed` @ `src/PriceFeeds/WETHPriceFeed.sol`
- `allowance` | type: `mapping(address => mapping(address => uint)) public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol`
- `balanceOf` | type: `mapping(address => uint) public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol`
- `decimals` | type: `uint8 public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol` = `18`
- `name` | type: `string public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol` = `"Wrapped HYPE"`
- `symbol` | type: `string public` | vis: `public` | flags: `-` | `WHYPE9` @ `test/TestContracts/WHYPE.sol` = `"WHYPE"`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WHYPEPriceFeed` @ `src/PriceFeeds/WHYPEPriceFeed.sol`
- `DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `2500 ether`
- `DEFAULT_BRANCH_INDEX` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0`
- `DEFAULT_STALENESS_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `86400`
- `HINT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0`
- `INTEREST_RATE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `10e16`
- `MAX_UPFRONT_FEE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `type(uint256).max`
- `ORACLE_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `8`
- `REDSTONE_ORACLE` | type: `AggregatorV3Interface public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `AggregatorV3Interface(0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43)`
- `STARTING_ORACLE_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `15e8`
- `WHYPE_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0x5555555555555555555555555555555555555555`
- `WHYPE_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `2000 ether`
- `adminController` | type: `IAdminController public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `alice` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `makeAddr("ALICE")`
- `bob` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `makeAddr("BOB")`
- `borrowerOperations` | type: `IBorrowerOperations public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `currentIndexForTrove` | type: `uint256 public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol` = `0`
- `deployerAddress` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `deployerContract` | type: `DeploymentMainnet public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `deployerPk` | type: `uint256 public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `feUSD` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `mockPriceFeed` | type: `MockPriceFeed public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `multiSigWallet` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `newWhypeRedstoneOracle` | type: `WHYPERedStonePriceFeed public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `oldPriceFeed` | type: `address public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `proxyAdmin` | type: `ProxyAdmin public` | vis: `public` | flags: `-` | `WHYPERedStoneOracleTest` @ `test/whypeRedstoneOracle.s.sol`
- `WHYPE_USD_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `WHYPERedStonePriceFeed` @ `src/PriceFeeds/WHYPERedStonePriceFeed.sol` = `8`
- `WHYPE_USD_STALENESS_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WHYPERedStonePriceFeed` @ `src/PriceFeeds/WHYPERedStonePriceFeed.sol` = `86400`
- `whypeUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WHYPERedStonePriceFeed` @ `src/PriceFeeds/WHYPERedStonePriceFeed.sol`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `WHYPEZapper` @ `src/Zappers/WHYPEZapper.sol`
- `stEthUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WSTETHPriceFeed` @ `src/PriceFeeds/WSTETHPriceFeed.sol`
- `wstETH` | type: `IWSTETH public` | vis: `public` | flags: `-` | `WSTETHPriceFeed` @ `src/PriceFeeds/WSTETHPriceFeed.sol`
- `STHYPE_USD_DEVIATION_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WSTHYPEPriceFeed` @ `src/PriceFeeds/WSTHYPEPriceFeed.sol` = `0.5e16`
- `stHypeUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WSTHYPEPriceFeed` @ `src/PriceFeeds/WSTHYPEPriceFeed.sol`
- `MAX_DECIMALS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Wrapper` @ `src/Misc/Wrapper.sol` = `18`
- `i_originalToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Wrapper` @ `src/Misc/Wrapper.sol`
- `i_originalTokenDecimals` | type: `uint8 public immutable` | vis: `public` | flags: `immutable` | `Wrapper` @ `src/Misc/Wrapper.sol`
- `isWrapperCreated` | type: `mapping(address originalToken => bool hasBeenCreated) public` | vis: `public` | flags: `-` | `WrapperFactory` @ `src/Misc/WrapperFactory.sol`
- `STANDARD_DECIMALS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol` = `18`
- `__gap` | type: `uint256[50] private` | vis: `private` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `collateralToken` | type: `address public` | vis: `public` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `underlyingToken` | type: `address public` | vis: `public` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `BLACK` | type: `string constant` | vis: `default` | flags: `constant` | `baseSVG` @ `src/NFTMetadata/utils/baseSVG.sol` = `"#000000"`
- `DARK_BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `baseSVG` @ `src/NFTMetadata/utils/baseSVG.sol` = `"#121B44"`
- `GEIST` | type: `string constant` | vis: `default` | flags: `constant` | `baseSVG` @ `src/NFTMetadata/utils/baseSVG.sol` = `''`
- `STOIC_WHITE` | type: `string constant` | vis: `default` | flags: `constant` | `baseSVG` @ `src/NFTMetadata/utils/baseSVG.sol` = `"#DEE4FB"`
- `BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#405AE5"`
- `BROWN` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#D99664"`
- `CORAL` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#FB7C59"`
- `CYAN` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#95CBF3"`
- `DARK_BLUE` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#121B44"`
- `GOLDEN` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#F5D93A"`
- `GREEN` | type: `string constant` | vis: `default` | flags: `constant` | `bauhaus` @ `src/NFTMetadata/utils/bauhaus.sol` = `"#63D77D"`
- `_NAME` | type: `string internal constant` | vis: `internal` | flags: `constant` | `feUSDToken` @ `src/feUSDToken.sol` = `"feUSD"`
- `_SYMBOL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `feUSDToken` @ `src/feUSDToken.sol` = `"feUSD"`
- `activePoolAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `borrowerOperationsAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `collateralRegistryAddress` | type: `address public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `stabilityPoolAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `troveManagerAddresses` | type: `mapping(address => bool) public` | vis: `public` | flags: `-` | `feUSDToken` @ `src/feUSDToken.sol`
- `DOUBLE_QUOTES` | type: `string constant` | vis: `default` | flags: `constant` | `json` @ `src/NFTMetadata/utils/JSON.sol` = `'\\"'`
- `NUM_COLLATERALS` | type: `uint256` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol` = `3`
- `NUM_VARIANTS` | type: `uint256` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol` = `4`
- `contractsArray` | type: `TestDeployer.LiquityContractsDev[] public` | vis: `public` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveIds` | type: `uint256[]` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveNFTRETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveNFTWETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveNFTWstETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `NULL` | type: `string internal constant` | vis: `internal` | flags: `constant` | `utils` @ `src/NFTMetadata/utils/Utils.sol` = `""`

### Tokens Added / Token State Values
Detected token-related variables:
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `ActivePool` @ `src/ActivePool.sol`
- `collToken` | type: `IERC20Metadata public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `hintHelpers` | type: `IHintHelpers public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `AddressesRegistry` @ `src/AddressesRegistry.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminController` @ `src/AdminController.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `AdminControllerNoDelays` @ `src/AdminControllerNoDelays.sol`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `10000 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateral` @ `test/AfterExecutionTests/AfterAddCollateral.t.sol` = `1200 ether`
- `AMOUNT_OF_UNDERLYING_TOKENS_FOR_ADD_COLLATERAL` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `1`
- `AMOUNT_OF_UNDERLYING_TOKENS_FOR_USERS` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol` = `10`
- `amountOfUnderlyingTokensForUsers` | type: `uint256 public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `underlyingToken` | type: `address public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `underlyingTokenDecimals` | type: `uint256 public` | vis: `public` | flags: `-` | `AfterAddCollateralWithZapper` @ `test/AfterExecutionTests/AfterAddCollateralWithZapper.t.sol`
- `AMOUNT_OF_FEUSD_FOR_USDC_WITH_BUFFER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_300 ether`
- `AMOUNT_OF_USDC` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `1_000_000 ether`
- `hintHelpers` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `token_0` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `token_1` | type: `address public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol`
- `whype` | type: `IERC20 public` | vis: `public` | flags: `-` | `AfterDeploymentTest` @ `test/AfterExecutionTests/AfterDeployment.t.sol` = `IERC20(0x5555555555555555555555555555555555555555)`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMCRChange` @ `test/AfterExecutionTests/AfterMCRChange.t.sol` = `10_000 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterMinDebtProposal` @ `test/AfterExecutionTests/AfterMinDebtProposal.t.sol` = `1_200 ether`
- `BTC_COLLATERAL_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `1 ether`
- `BTC_DEBT_AMOUNT` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `AfterPriceFeed` @ `test/AfterExecutionTests/AfterPriceFeedTest.t.sol` = `10_000 ether`
- `BTC_USD_DECIMALS` | type: `uint8 public constant` | vis: `public` | flags: `constant` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol` = `8`
- `BTC_USD_STALENESS_THRESHOLD` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol` = `86400`
- `btcUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `BTCRedStonePriceFeedOracle` @ `src/PriceFeeds/BTCRedStonePriceFeedOracle.sol`
- `pendingMaxDebtCapProposals` | type: `mapping(uint256 branchIndex => MaxDebtCapProposal) public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `pendingNewCollateralProposal` | type: `NewCollateralProposal public` | vis: `public` | flags: `-` | `BaseAdminController` @ `src/BaseAdminController.sol`
- `feUSDToken` | type: `IfeUSDToken` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `hintHelpers` | type: `HintHelpers` | vis: `default` | flags: `-` | `BaseMultiCollateralTest` @ `test/TestContracts/BaseMultiCollateralTest.sol`
- `collToken` | type: `IERC20` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `feUSDToken` | type: `IfeUSDToken` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `hintHelpers` | type: `HintHelpers` | vis: `default` | flags: `-` | `BaseTest` @ `test/TestContracts/BaseTest.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `BaseZapper` @ `src/Zappers/BaseZapper.sol`
- `collToken` | type: `IERC20 internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `maxDebtCap` | type: `uint256 public` | vis: `public` | flags: `-` | `BorrowerOperations` @ `src/BorrowerOperations.sol`
- `COLL_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `106`
- `FEUSD_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `BorrowerOperationsInit` @ `src/Libraries/BorrowerOperationsInit.sol` = `110`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `CollSurplusPool` @ `src/CollSurplusPool.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `tokens` | type: `IERC20Metadata[] public` | vis: `public` | flags: `-` | `CollateralRegistry` @ `src/CollateralRegistry.sol`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `CompositePriceFeed` @ `src/PriceFeeds/CompositePriceFeed.sol`
- `lstEthOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `CompositePriceFeed` @ `src/PriceFeeds/CompositePriceFeed.sol`
- `_ETH_GAS_COMPENSATION` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `Constants` @ `src/Dependencies/Constants.sol` = `ETH_GAS_COMPENSATION`
- `WHYPE_USDC_RED_STONE_FEED` | type: `address public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`
- `WHYPE_USDC_RED_STONE_FEED` | type: `address public constant` | vis: `public` | flags: `constant` | `ContextHelper` @ `test/ContextHelper.t.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`
- `COLL_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint256 public immutable` | vis: `public` | flags: `immutable` | `CurveExchange` @ `src/Zappers/Modules/Exchanges/CurveExchange.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `CurveGaugeDistributor` @ `src/Zappers/Modules/Exchanges/Curve/CurveGaugeDistributor.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `DefaultPool` @ `src/DefaultPool.sol`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol`
- `feUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelix` @ `test/TestContracts/DeployFelix.sol` = `58`
- `FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol` = `58`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeployFelixMainnet` @ `scripts/Mainnet/DeployFelixMainnet.s.sol`
- `FEUSD_TOKEN_SLOT_FOR_TROVE_MANAGER` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `58`
- `USDC_ADDRESS` | type: `address public constant` | vis: `public` | flags: `constant` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol` = `0xdeC702aa5a18129Bd410961215674A7A130A12e5`
- `collateralParams` | type: `mapping(Collaterals => CollateralParams) public` | vis: `public` | flags: `-` | `DeploymentMainnet` @ `test/TestContracts/DeploymentMainnet.sol`
- `s_USDC` | type: `IERC20 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_USDCPoolIndex` | type: `int128 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `FeUSDZapper` @ `src/Zappers/FeUSDZapper.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `GasCompZapper` @ `src/Zappers/GasCompZapper.sol`
- `BTC_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `3`
- `BTC_SZ_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `5`
- `ETH_L1_INDEX` | type: `uint32 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `4`
- `ETH_SZ_DECIMALS` | type: `uint8 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `4`
- `FIXED_BTC_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `68514000000000000000000`
- `FIXED_ETH_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `2694300000000000000000`
- `MOCK_ETH_PRICE` | type: `uint256 constant` | vis: `default` | flags: `constant` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol` = `2600e18`
- `btcPriceFeed` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `ethPriceFeed` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `HLPriceFeedTest` @ `test/HLPriceFeed.t.sol`
- `USDC` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `USDC_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `WETH` | type: `IWETH public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feUSD_TOKEN_INDEX` | type: `uint128 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feeUsdcWeth` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `feeWethColl` | type: `uint24 public immutable` | vis: `public` | flags: `immutable` | `HybridCurveUniV3Exchange` @ `src/Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter/InterestRouter.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `InterestRouter` @ `src/InterestRouter.sol`
- `s_feUSDToken` | type: `address public` | vis: `public` | flags: `-` | `InterestRouterV2` @ `src/InterestRouterV2.sol`
- `s_mockUSDC` | type: `MockUSDC public` | vis: `public` | flags: `-` | `InterestRouterV2Test` @ `test/InterestRouterV2.t.sol`
- `ETH_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `10 ether`
- `WBTC_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `99_000 ether`
- `WETH_PRICE` | type: `uint256 public constant` | vis: `public` | flags: `constant` | `MockL1Read` @ `src/Dependencies/MockL1Read.sol` = `3_750 ether`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `NonPayableSwitch` @ `test/TestContracts/NonPayableSwitch.sol`
- `hypeUsdcOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `usdcUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `RedStonePriceFeedBaseLst` @ `src/PriceFeeds/RedStonePriceFeedBaseLst.sol`
- `s_feUSD` | type: `IERC20 public` | vis: `public` | flags: `-` | `RewardsAllocator` @ `src/InterestRouter/RewardsAllocator.sol`
- `collateralToken` | type: `IERC20` | vis: `default` | flags: `-` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `hintHelpers` | type: `HintHelpers immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `initialPrice` | type: `uint256 immutable` | vis: `default` | flags: `immutable` | `SPInvariantsTestHandler` @ `test/TestContracts/SPInvariantsTestHandler.t.sol`
- `collToken` | type: `IERC20 public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `StabilityPool` @ `src/StabilityPool.sol`
- `COLL_TOKEN_INDEX` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `UNIV3_FEE_USDC_WETH` | type: `uint24 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `500`
- `UNIV3_FEE_WETH_COLL` | type: `uint24 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `100`
- `USDC` | type: `IERC20 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)`
- `USDC_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `1`
- `WETH_MAINNET` | type: `IWETH constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)`
- `feUSDTokenImpl` | type: `feUSDToken` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new feUSDToken()`
- `feUSD_TOKEN_INDEX` | type: `uint128 constant` | vis: `default` | flags: `constant` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `0`
- `hintHelpersImpl` | type: `HintHelpers` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new HintHelpers()`
- `hlPriceFeedImpl` | type: `HLPriceFeed` | vis: `default` | flags: `-` | `TestDeployer` @ `test/TestContracts/Deployment.t.sol` = `new HLPriceFeed()`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `TroveManager` @ `src/TroveManager.sol`
- `FEUSD_TOKEN_SLOT` | type: `uint256 constant` | vis: `default` | flags: `constant` | `TroveManagerInit` @ `src/Libraries/TroveManagerInit.sol` = `58`
- `feUSDToken` | type: `IfeUSDToken internal` | vis: `internal` | flags: `-` | `TroveManagerLst` @ `src/TroveManagerLst.sol`
- `collToken` | type: `IERC20Metadata public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `feUSDToken` | type: `IfeUSDToken public` | vis: `public` | flags: `-` | `TroveNFT` @ `src/TroveNFT.sol`
- `collToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `feUSDToken` | type: `IfeUSDToken public immutable` | vis: `public` | flags: `immutable` | `UniV3Exchange` @ `src/Zappers/Modules/Exchanges/UniV3Exchange.sol`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WETHPriceFeed` @ `src/PriceFeeds/WETHPriceFeed.sol`
- `ethUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WHYPEPriceFeed` @ `src/PriceFeeds/WHYPEPriceFeed.sol`
- `stEthUsdOracle` | type: `Oracle public` | vis: `public` | flags: `-` | `WSTETHPriceFeed` @ `src/PriceFeeds/WSTETHPriceFeed.sol`
- `wstETH` | type: `IWSTETH public` | vis: `public` | flags: `-` | `WSTETHPriceFeed` @ `src/PriceFeeds/WSTETHPriceFeed.sol`
- `i_originalToken` | type: `IERC20 public immutable` | vis: `public` | flags: `immutable` | `Wrapper` @ `src/Misc/Wrapper.sol`
- `i_originalTokenDecimals` | type: `uint8 public immutable` | vis: `public` | flags: `immutable` | `Wrapper` @ `src/Misc/Wrapper.sol`
- `collateralToken` | type: `address public` | vis: `public` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `underlyingToken` | type: `address public` | vis: `public` | flags: `-` | `WrapperZappers` @ `src/Zappers/WrapperZappers.sol`
- `troveNFTRETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveNFTWETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`
- `troveNFTWstETH` | type: `TroveNFT` | vis: `default` | flags: `-` | `troveNFTTest` @ `test/troveNFT.t.sol`

Hardcoded token addresses found:
- `USDC_ADDRESS` @ `test/TestContracts/DeploymentMainnet.sol` = `0xdeC702aa5a18129Bd410961215674A7A130A12e5`
- `WHYPE_USDC_RED_STONE_FEED` @ `scripts/Mainnet/Utils/ContextHelper.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`
- `WHYPE_USDC_RED_STONE_FEED` @ `test/ContextHelper.t.sol` = `0xa8a94Da411425634e3Ed6C331a32ab4fd774aa43`

### Struct Values (All Parsed Struct Fields)
- `ABCDEF` (test/TestContracts/BaseTest.sol): uint256 A, uint256 B, uint256 C, uint256 D, uint256 E, uint256 F
- `Actor` (test/AnchoredSPInvariantsTest.t.sol): string label, address account
- `Actor` (test/TestContracts/BaseInvariantTest.sol): string label, address account
- `AddressVars` (src/Interfaces/IAddressesRegistry.sol): IERC20Metadata collToken, IBorrowerOperations borrowerOperations, ITroveManager troveManager, ITroveNFT troveNFT, IMetadataNFT metadataNFT, IStabilityPool stabilityPool, IPriceFeed priceFeed, IActivePool activePool, IDefaultPool defaultPool, address gasPoolAddress, ICollSurplusPool collSurplusPool, ISortedTroves sortedTroves, IInterestRouter interestRouter, IHintHelpers hintHelpers, IMultiTroveGetter multiTroveGetter, ICollateralRegistry collateralRegistry, IfeUSDToken feUSDToken, IWHYPE WHYPE
- `AdjustTroveContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 i, AdjustedTroveProperties prop, uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 oldTCR, uint256 troveId, LatestTroveData t, address batchManager, uint256 batchManagementFee, Trove trove, bool wasActive, bool wasZombie, bool useZombie, uint256 maxDebtDec, int256 collDelta, int256 debtDelta, int256 $ collDelta36, uint256 upfrontFee, string functionName, uint256 newICR, uint256 newTCR, uint256 newDebt, string errorString
- `AdjustTroveInterestRateContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 troveId, address batchManager, LatestTroveData t, Trove trove, bool wasActive, bool premature, uint256 upfrontFee, string errorString
- `AllocationConfig` (src/InterestRouterV2.sol): address[] rewardDestinations, uint256[] percentages, bytes4[] rewardSelectors, uint256 lastUpdatedTimestamp
- `AllocationConfig` (src/Interfaces/IInterestRouterV2.sol): address[] rewardDestinations, uint256[] percentages, bytes4[] rewardSelectors, uint256 lastUpdatedTimestamp
- `ApplyMyPendingDebtContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 troveId, address batchManager, uint256 batchManagementFee, LatestTroveData t, Trove trove, bool wasOpen, string errorString
- `ArbBatchedTroveCreation` (test/SortedTroves.t.sol): uint256 annualInterestRate, ArbHints hints, uint256 role, uint256 batch
- `ArbHints` (test/SortedTroves.t.sol): uint256 prev, uint256 next
- `ArbIndividualTroveCreation` (test/SortedTroves.t.sol): uint256 annualInterestRate, ArbHints hints
- `ArbReInsertion` (test/SortedTroves.t.sol): uint256 trove, uint256 newAnnualInterestRate, ArbHints hints
- `Asset` (src/NFTMetadata/utils/FixedAssets.sol): uint128 start, uint128 end
- `Batch` (src/SortedTroves.sol): uint256 head, uint256 tail
- `Batch` (src/TroveManager.sol): uint256 debt, uint256 coll, uint64 arrayIndex, uint64 lastDebtUpdateTime, uint64 lastInterestRateAdjTime, uint256 annualInterestRate, uint256 annualManagementFee, uint256 totalDebtShares
- `Batch` (src/TroveManagerLst.sol): uint256 debt, uint256 coll, uint64 arrayIndex, uint64 lastDebtUpdateTime, uint64 lastInterestRateAdjTime, uint256 annualInterestRate, uint256 annualManagementFee, uint256 totalDebtShares
- `Batch` (test/SortedTroves.t.sol): uint256 annualInterestRate
- `Batch` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 interestRateMin, uint256 interestRateMax, uint256 interestRate, uint256 managementRate, uint256 pendingManagementFee, uint256 period, EnumerableSet troves
- `BatchIdSet` (test/Utils/BatchIdSet.sol): mapping(BatchId => bool) _has, BatchId[] _batchIds
- `Branch` (test/AfterExecutionTests/AfterDeployment.t.sol): address activePool, address addressesRegistry, address borrowerOperations, address collSurplusPool, address collToken, address defaultPool, address gasPool, address interestRouter, address priceFeed, address sortedTroves, address stabilityPool, address troveManager, address troveNFT, string name
- `BranchContracts` (scripts/Mainnet/Utils/ReadManifestHelper.sol): address activePool, address addressesRegistry, address borrowerOperations, address collToken, address interestRouter, address priceFeed, address sortedTroves, address stabilityPool, address troveManager, address troveNFT, string name
- `BranchContracts` (test/ReadManifestHelper.t.sol): address activePool, address addressesRegistry, address borrowerOperations, address collToken, address interestRouter, address priceFeed, address sortedTroves, address stabilityPool, address troveManager, address troveNFT, string name
- `BranchPools` (scripts/Mainnet/Utils/ReadManifestHelper.sol): address collSurplusPool, address defaultPool, address gasPool
- `BranchPools` (test/ReadManifestHelper.t.sol): address collSurplusPool, address defaultPool, address gasPool
- `CCRProposal` (src/AdminController.sol): uint256 ccr, uint256 timestamp
- `CCRProposal` (src/AdminControllerNoDelays.sol): uint256 ccr, uint256 timestamp
- `CCRProposal` (src/BaseAdminController.sol): uint256 ccr, uint256 timestamp
- `CCRProposal` (src/Interfaces/IAdminController.sol): uint256 ccr, uint256 timestamp
- `COLORS` (src/NFTMetadata/utils/bauhaus.sol): colorCode rect1, colorCode rect2, colorCode rect3, colorCode rect4, colorCode rect5, colorCode poly, colorCode circle1, colorCode circle2, colorCode circle3
- `ChainlinkResponse` (src/PriceFeeds/MainnetPriceFeedBase.sol): uint80 roundId, int256 answer, uint256 timestamp, bool success
- `CloseTroveContext` (test/TestContracts/InvariantsTestHandler.t.sol): TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 troveId, LatestTroveData t, address batchManager, uint256 batchManagementFee, bool wasOpen, uint256 dealt, string errorString
- `CloseTroveParams` (src/Zappers/Interfaces/IZapper.sol): uint256 troveId, uint256 flashLoanAmount, address receiver
- `CollateralParams` (scripts/Mainnet/DeployFelixMainnet.s.sol): uint256 CCR, uint256 LIQUIDATION_PENALTY_REDISTRIBUTION, uint256 LIQUIDATION_PENALTY_SP, uint256 MCR, uint16 PRICE_FEED_L1_INDEX, uint8 PRICE_FEED_SZ_DECIMALS, uint256 SCR, address collToken, uint256 maxDebtCap, address redStonePriceFeedAddress
- `CollateralParams` (test/TestContracts/DeployFelix.sol): uint256 CCR, uint256 LIQUIDATION_PENALTY_REDISTRIBUTION, uint256 LIQUIDATION_PENALTY_SP, uint256 MCR, uint16 PRICE_FEED_L1_INDEX, uint8 PRICE_FEED_SZ_DECIMALS, uint256 SCR, address collToken, uint256 maxDebtCap
- `CollateralParams` (test/TestContracts/DeploymentMainnet.sol): uint256 CCR, uint256 LIQUIDATION_PENALTY_REDISTRIBUTION, uint256 LIQUIDATION_PENALTY_SP, uint256 MCR, uint16 PRICE_FEED_L1_INDEX, uint8 PRICE_FEED_SZ_DECIMALS, uint256 SCR, address collToken, uint256 maxDebtCap, address redStonePriceFeedAddress
- `CollectParams` (src/Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol): uint256 tokenId, address recipient, uint128 amount0Max, uint128 amount1Max
- `CombinedTroveData` (src/Interfaces/IMultiTroveGetter.sol): uint256 id, uint256 entireDebt, uint256 entireColl, uint256 redistfeUSDDebtGain, uint256 redistCollGain, uint256 accruedInterest, uint256 recordedDebt, uint256 annualInterestRate, uint256 accruedBatchManagementFee, uint256 lastInterestRateAdjTime, uint256 stake, uint256 lastDebtUpdateTime, address interestBatchManager, uint256 batchDebtShares, uint256 snapshotETH, uint256 snapshotBoldDebt
- `Constants` (test/AfterExecutionTests/AfterDeployment.t.sol): uint256 ETH_GAS_COMPENSATION, uint256 INTEREST_RATE_ADJ_COOLDOWN, uint256 MAX_ANNUAL_INTEREST_RATE, uint256 MIN_ANNUAL_INTEREST_RATE, uint256 MIN_DEBT, uint256 SP_YIELD_SPLIT, uint256 UPFRONT_INTEREST_PERIOD
- `Contracts` (test/TestContracts/BaseMultiCollateralTest.sol): IWHYPE whype, ICollateralRegistry collateralRegistry, IfeUSDToken feUSDToken, HintHelpers hintHelpers, TestDeployer.LiquityContractsDev[] branches
- `Contracts` (test/TestContracts/SPInvariantsTestHandler.t.sol): IfeUSDToken feUSDToken, IBorrowerOperations borrowerOperations, IERC20 collateralToken, IPriceFeedTestnet priceFeed, IStabilityPool stabilityPool, ITroveManagerTester troveManager, ICollSurplusPool collSurplusPool
- `CorrespondingColl` (test/redemptions.t.sol): uint256 A, uint256 B, uint256 C
- `CurveAddresses` (scripts/Mainnet/DeployFelixMainnet.s.sol): address curvePool, address coin0, address coin1, address curveGauge, address curveGaugeDistributor
- `CurveAddresses` (test/TestContracts/DeploymentMainnet.sol): address curvePool, address coin0, address coin1, address curveGauge, address curveGaugeDistributor
- `CurveContracts` (scripts/Mainnet/Utils/ReadManifestHelper.sol): address curvePool, address curveGauge, address curveGaugeDistributor
- `CurveContracts` (test/ReadManifestHelper.t.sol): address curvePool, address curveGauge, address curveGaugeDistributor
- `DebtPerInterestRate` (src/Interfaces/IMultiTroveGetter.sol): address interestBatchManager, uint256 interestRate, uint256 debt
- `DecreaseLiquidityParams` (src/Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol): uint256 tokenId, uint128 liquidity, uint256 amount0Min, uint256 amount1Min, uint256 deadline
- `Delegation` (src/Dependencies/L1Read.sol): address validator, uint64 amount, uint64 lockedUntilTimestamp
- `DelegatorSummary` (src/Dependencies/L1Read.sol): uint64 delegated, uint64 undelegated, uint64 totalPendingWithdrawal, uint64 nPendingWithdrawals
- `DeployerInfo` (scripts/Mainnet/DeployFelixMainnet.s.sol): uint256 deployerPK, address deployerAddress
- `DeployerInfo` (test/TestContracts/DeployFelix.sol): uint256 deployerPK, address deployerAddress
- `DeployerInfo` (test/TestContracts/DeploymentMainnet.sol): uint256 deployerPK, address deployerAddress
- `DeploymentParamsMainnet` (test/TestContracts/Deployment.t.sol): IERC20Metadata collToken, IPriceFeed priceFeed, IfeUSDToken feUSDToken, ICollateralRegistry collateralRegistry, IWHYPE whype, IAddressesRegistry addressesRegistry, address troveManagerAddress, IHintHelpers hintHelpers, IMultiTroveGetter multiTroveGetter, ICurveStableswapNGPool usdcCurvePool
- `DeploymentResultMainnet` (test/TestContracts/Deployment.t.sol): LiquityContracts[] contractsArray, ExternalAddresses externalAddresses, ICollateralRegistry collateralRegistry, IfeUSDToken feUSDToken, HintHelpers hintHelpers, MultiTroveGetter multiTroveGetter, Zappers[] zappersArray
- `DeploymentVarsDev` (test/TestContracts/Deployment.t.sol): uint256 numCollaterals, IERC20Metadata[] collaterals, IAddressesRegistry[] addressesRegistries, ITroveManager[] troveManagers, bytes bytecode, address feUSDTokenAddress, uint256 i
- `DeploymentVarsMainnet` (test/TestContracts/Deployment.t.sol): OracleParams oracleParams, uint256 numCollaterals, IERC20Metadata[] collaterals, IAddressesRegistry[] addressesRegistries, ITroveManager[] troveManagers, IPriceFeed[] priceFeeds, bytes bytecode, address feUSDTokenAddress, uint256 i
- `Deposit` (src/StabilityPool.sol): uint256 initialValue
- `Deposit` (test/events.t.sol): uint256 recordedBold, uint256 stashedColl, uint256 pendingBoldLoss, uint256 pendingCollGain, uint256 pendingBoldYieldGain
- `EnumerableAddressSet` (test/Utils/EnumerableSet.sol): EnumerableSet _base
- `EnumerableSet` (test/Utils/EnumerableSet.sol): mapping(uint256 element => uint256) _indexOf, uint256[] _elements
- `ExactInputParams` (src/Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol): bytes path, address recipient, uint256 deadline, uint256 amountIn, uint256 amountOutMinimum
- `ExactInputSingleParams` (src/Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol): address tokenIn, address tokenOut, uint24 fee, address recipient, uint256 deadline, uint256 amountIn, uint256 amountOutMinimum, uint160 sqrtPriceLimitX96
- `ExactOutputParams` (src/Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol): bytes path, address recipient, uint256 deadline, uint256 amountOut, uint256 amountInMaximum
- `ExactOutputSingleParams` (src/Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol): address tokenIn, address tokenOut, uint24 fee, address recipient, uint256 deadline, uint256 amountOut, uint256 amountInMaximum, uint160 sqrtPriceLimitX96
- `ExpectedSPYield` (test/stabilityPool.t.sol): uint256 _1, uint256 _2, uint256 _3
- `ExpectedShareOfReward` (test/stabilityPool.t.sol): uint256 _1_A, uint256 _1_B, uint256 _2_A, uint256 _2_B, uint256 _2_C, uint256 _2_D, uint256 _3_A, uint256 _3_B, uint256 _3_C, uint256 _3_D
- `ExternalAddresses` (test/TestContracts/Deployment.t.sol): address ETHOracle, address STETHOracle, address RETHOracle, address ETHXOracle, address OSETHOracle, address WSTETHToken, address RETHToken, address StaderOracle, address OsTokenVaultController
- `File` (test/TestContracts/MetadataDeployment.sol): bytes data, uint256 start, uint256 end
- `FinalValues` (test/liquidationsLST.t.sol): uint256 spfeUSDBalance, uint256 spCollBalance, uint256 collToLiquidate, uint256 collSPPortion, uint256 collPenaltySP, uint256 collToSendToSP, uint256 collRedistributionPortion, uint256 collPenaltyRedistribution
- `Hints` (test/SortedTroves.t.sol): TroveId prev, TroveId next
- `IncreaseLiquidityParams` (src/Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol): uint256 tokenId, uint256 amount0Desired, uint256 amount1Desired, uint256 amount0Min, uint256 amount1Min, uint256 deadline
- `InitialBalances` (src/Zappers/LeftoversSweep.sol): IERC20[4] tokens, uint256[4] balances, address receiver
- `InitialValues` (test/liquidationsLST.t.sol): uint256 spfeUSDBalance, uint256 spCollBalance, uint256 ACollBalance, uint256 AInterest, uint256 BDebt, uint256 BColl
- `InterestBatchManager` (src/Interfaces/IBorrowerOperations.sol): uint128 minInterestRate, uint128 maxInterestRate, uint256 minInterestRateChangePeriod
- `InterestIndividualDelegate` (src/Interfaces/IBorrowerOperations.sol): address account, uint128 minInterestRate, uint128 maxInterestRate, uint256 minInterestRateChangePeriod
- `InterestRouterProposal` (src/AdminController.sol): address interestRouter, uint256 timestamp
- `InterestRouterProposal` (src/AdminControllerNoDelays.sol): address interestRouter, uint256 timestamp
- `InterestRouterProposal` (src/BaseAdminController.sol): address interestRouter, uint256 timestamp
- `InterestRouterProposal` (src/Interfaces/IAdminController.sol): address interestRouter, uint256 timestamp
- `LatestBatchData` (src/Types/LatestBatchData.sol): uint256 entireDebtWithoutRedistribution, uint256 entireCollWithoutRedistribution, uint256 accruedInterest, uint256 recordedDebt, uint256 annualInterestRate, uint256 weightedRecordedDebt, uint256 annualManagementFee, uint256 accruedManagementFee, uint256 weightedRecordedBatchManagementFee, uint256 lastDebtUpdateTime, uint256 lastInterestRateAdjTime
- `LatestTroveData` (src/Types/LatestTroveData.sol): uint256 entireDebt, uint256 entireColl, uint256 redistfeUSDDebtGain, uint256 redistCollGain, uint256 accruedInterest, uint256 recordedDebt, uint256 annualInterestRate, uint256 weightedRecordedDebt, uint256 accruedBatchManagementFee, uint256 lastInterestRateAdjTime
- `LeverDownTroveParams` (src/Zappers/Interfaces/ILeverageZapper.sol): uint256 troveId, uint256 flashLoanAmount, uint256 minfeUSDAmount
- `LeverUpTroveParams` (src/Zappers/Interfaces/ILeverageZapper.sol): uint256 troveId, uint256 flashLoanAmount, uint256 feUSDAmount, uint256 maxUpfrontFee
- `LiqTestVars` (test/stabilityPool.t.sol): uint256 debtABefore, uint256 collABefore, uint256 debtBBefore, uint256 collBBefore, uint256 collCBefore, uint256 collGasComp, uint256 spCollBalBefore, uint256 spCollBalAfter, uint256 collToGiveToSP, uint256 collToRedist
- `LiquidationParams` (test/events.t.sol): uint256 collSentToSP, uint256 collRedistributed, uint256 collGasCompensation, uint256 collSurplus, uint256 debtOffsetBySP, uint256 debtRedistributed, uint256 ethGasCompensation
- `LiquidationTotals` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 collGasComp, uint256 spCollGain, uint256 spOffset, uint256 collRedist, uint256 debtRedist, uint256 collSurplus
- `LiquidationTransientState` (test/TestContracts/InvariantsTestHandler.t.sol): address[] batch, EnumerableSet remaining, EnumerableAddressSet liquidated, EnumerableAddressSet batchManagers, LiquidationTotals t
- `LiquidationValues` (src/TroveManager.sol): uint256 collGasCompensation, uint256 debtToOffset, uint256 collToSendToSP, uint256 debtToRedistribute, uint256 collToRedistribute, uint256 collSurplus, uint256 ETHGasCompensation, uint256 oldWeightedRecordedDebt, uint256 newWeightedRecordedDebt
- `LiquidationValues` (src/TroveManagerLst.sol): uint256 collGasCompensation, uint256 debtToOffset, uint256 collToSendToSP, uint256 debtToRedistribute, uint256 collToRedistribute, uint256 collSurplus, uint256 ETHGasCompensation, uint256 oldWeightedRecordedDebt, uint256 newWeightedRecordedDebt
- `LiquidationsTestVars` (test/liquidations.t.sol): uint256 liquidationAmount, uint256 collAmount, uint256 ATroveId, uint256 BTroveId, uint256 price, uint256 spfeUSDBalance, uint256 spCollBalance, uint256 ACollBalance, uint256 BDebt, uint256 BColl, uint256 AInterest, uint256 BInterest
- `LiquityContractAddresses` (test/TestContracts/Deployment.t.sol): address activePool, address borrowerOperations, address collSurplusPool, address defaultPool, address sortedTroves, address stabilityPool, address troveManager, address troveNFT, address metadataNFT, address priceFeed, address gasPool, address interestRouter
- `LiquityContracts` (test/TestContracts/Deployment.t.sol): IAddressesRegistry addressesRegistry, IActivePool activePool, IBorrowerOperations borrowerOperations, ICollSurplusPool collSurplusPool, IDefaultPool defaultPool, ISortedTroves sortedTroves, IStabilityPool stabilityPool, ITroveManager troveManager, ITroveNFT troveNFT, IPriceFeed priceFeed, GasPool gasPool, IInterestRouter interestRouter, IERC20Metadata collToken
- `LiquityContractsDev` (test/TestContracts/Deployment.t.sol): IAddressesRegistry addressesRegistry, IActivePoolTester activePool, IBorrowerOperationsTester borrowerOperations, ICollSurplusPool collSurplusPool, ISortedTroves sortedTroves, IStabilityPoolTester stabilityPool, ITroveManagerTester troveManager, ITroveNFT troveNFT, IPriceFeedTestnet priceFeed, IInterestRouter interestRouter, IERC20Metadata collToken, LiquityContractsDevPools pools, address proxyAdmin
- `LiquityContractsDevPools` (test/TestContracts/Deployment.t.sol): IDefaultPool defaultPool, ICollSurplusPool collSurplusPool, GasPool gasPool
- `LocalVariables_adjustTrove` (src/BorrowerOperations.sol): IActivePool activePool, IfeUSDToken feUSDToken, LatestTroveData trove, uint256 price, bool isBelowCriticalThreshold, uint256 newICR, uint256 newDebt, uint256 newColl, bool newOracleFailureDetected
- `LocalVariables_openTrove` (src/BorrowerOperations.sol): ITroveManager troveManager, IActivePool activePool, IfeUSDToken feUSDToken, uint256 troveId, uint256 price, uint256 avgInterestRate, uint256 entireDebt, uint256 ICR, uint256 newTCR, bool newOracleFailureDetected
- `LocalVariables_removeFromBatch` (src/BorrowerOperations.sol): ITroveManager troveManager, ISortedTroves sortedTroves, address batchManager, LatestTroveData trove, LatestBatchData batch, uint256 newBatchDebt
- `LocalVariables_setInterestBatchManager` (src/BorrowerOperations.sol): ITroveManager troveManager, IActivePool activePool, ISortedTroves sortedTroves, address oldBatchManager, LatestTroveData trove, LatestBatchData oldBatch, LatestBatchData newBatch
- `MCRProposal` (src/AdminController.sol): uint256 mcr, uint256 timestamp
- `MCRProposal` (src/AdminControllerNoDelays.sol): uint256 mcr, uint256 timestamp
- `MCRProposal` (src/BaseAdminController.sol): uint256 mcr, uint256 timestamp
- `MCRProposal` (src/Interfaces/IAdminController.sol): uint256 mcr, uint256 timestamp
- `ManifestJson` (test/AfterExecutionTests/AfterDeployment.t.sol): address adminController, Constants constants, address collateralRegistry, address feUSDToken, address hintHelpers, address metadataNFT, address multiTroveGetter, uint256 branchCount, Branch[] branches
- `MaxDebtCapProposal` (src/AdminController.sol): uint256 maxDebtCap, uint256 timestamp
- `MaxDebtCapProposal` (src/AdminControllerNoDelays.sol): uint256 maxDebtCap, uint256 timestamp
- `MaxDebtCapProposal` (src/BaseAdminController.sol): uint256 maxDebtCap, uint256 timestamp
- `MaxDebtCapProposal` (src/Interfaces/IAdminController.sol): uint256 maxDebtCap, uint256 timestamp
- `MintParams` (src/Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol): address token0, address token1, uint24 fee, int24 tickLower, int24 tickUpper, uint256 amount0Desired, uint256 amount1Desired, uint256 amount0Min, uint256 amount1Min, address recipient, uint256 deadline
- `MultipleUpgradeProposal` (src/AdminControllerV2.sol): UpgradeProposal[] upgradeProposals, uint256 timestamp
- `NewCollateralProposal` (src/AdminController.sol): address newCollateral, IAddressesRegistry addressRegistry, uint256 timestamp
- `NewCollateralProposal` (src/AdminControllerNoDelays.sol): address newCollateral, IAddressesRegistry addressRegistry, uint256 timestamp
- `NewCollateralProposal` (src/BaseAdminController.sol): address newCollateral, IAddressesRegistry addressRegistry, uint256 timestamp
- `NewImplementationProposal` (src/AdminController.sol): address newImplementation, ContractType contractType, bytes data, uint256 timestamp
- `NewImplementationProposal` (src/AdminControllerNoDelays.sol): address newImplementation, ContractType contractType, bytes data, uint256 timestamp
- `NewImplementationProposal` (src/BaseAdminController.sol): address newImplementation, ContractType contractType, bytes data, uint256 timestamp
- `Node` (src/SortedTroves.sol): uint256 nextId, uint256 prevId, BatchId batchId, bool exists
- `OnSetInterestBatchManagerParams` (src/Interfaces/ITroveManager.sol): uint256 troveId, uint256 troveColl, uint256 troveDebt, TroveChange troveChange, address newBatchAddress, uint256 newBatchColl, uint256 newBatchDebt
- `OpenLeveragedTroveParams` (src/Zappers/Interfaces/ILeverageZapper.sol): address owner, uint256 ownerIndex, uint256 collAmount, uint256 flashLoanAmount, uint256 feUSDAmount, uint256 upperHint, uint256 lowerHint, uint256 annualInterestRate, address batchManager, uint256 maxUpfrontFee, address addManager, address removeManager, address receiver
- `OpenTroveAndJoinInterestBatchManagerParams` (src/Interfaces/IBorrowerOperations.sol): address owner, uint256 ownerIndex, uint256 collAmount, uint256 feUSDAmount, uint256 upperHint, uint256 lowerHint, address interestBatchManager, uint256 maxUpfrontFee, address addManager, address removeManager, address receiver
- `OpenTroveContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 i, uint256 borrowed, uint256 icr, bool join, uint256 interestRate, uint32 batchManagerSeed, uint32 upperHintSeed, uint32 lowerHintSeed, address batchManager, uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 batchManagementFee, uint256 upfrontFee, uint256 debt, uint256 coll, uint256 troveId, bool wasOpen, string errorString
- `OpenTroveParams` (src/Zappers/Interfaces/IZapper.sol): address owner, uint256 ownerIndex, uint256 collAmount, uint256 feUSDAmount, uint256 upperHint, uint256 lowerHint, uint256 annualInterestRate, address batchManager, uint256 maxUpfrontFee, address addManager, address removeManager, address receiver
- `OpenTroveVars` (src/BorrowerOperations.sol): ITroveManager troveManager, uint256 troveId, TroveChange change, LatestBatchData batch
- `OpenTroveVars` (src/Zappers/FeUSDZapper.sol): address owner, uint256 ownerIndex, uint256 collAmount, uint256 feUSDAmount, uint256 upperHint, uint256 lowerHint, uint256 annualInterestRate, uint256 maxUpfrontFee
- `Oracle` (src/PriceFeeds/MainnetPriceFeedBase.sol): AggregatorV3Interface aggregator, uint256 stalenessThreshold, uint8 decimals
- `Oracle` (src/PriceFeeds/RedStonePriceFeedBase.sol): AggregatorV3Interface aggregator, uint256 stalenessThreshold, uint8 decimals
- `Oracle` (src/PriceFeeds/RedStonePriceFeedBaseLst.sol): AggregatorV3Interface aggregator, uint256 stalenessThreshold, uint8 decimals
- `OracleParams` (test/TestContracts/Deployment.t.sol): uint256 ethUsdStalenessThreshold, uint256 stEthUsdStalenessThreshold, uint256 rEthEthStalenessThreshold, uint256 ethXEthStalenessThreshold, uint256 osEthEthStalenessThreshold
- `PTestVars` (test/stabilityPool.t.sol): uint256 storedVal, uint256 deposit1_A, uint256 deposit2_A, uint256 deposit1_B, uint256 deposit2_B, uint256 scale1, uint256 scale2, uint256 expectedSpYield1, uint256 expectedDeposit1_A, uint256 expectedDeposit2_A, uint256 expectedDeposit1_B, uint256 expectedDeposit2_B, uint256 expectedShareOfYield1_A, uint256 expectedShareOfYield1_B, uint256 expectedShareOfYield1_C, uint256 expectedShareOfYield1_D, uint256 troveDebt_C, uint256 troveDebt_D, uint256 totalSPBeforeLiq_C, uint256 totalSPBeforeLiq_D, uint256 expectedShareOfColl1_A, uint256 expectedShareOfColl1_B, uint256 expectedShareOfColl2_A, uint256 expectedShareOfColl2_B, uint256 boldGainA, uint256 boldGainB, uint256 boldGainC, uint256 boldGainD, uint256 spEthGain1, uint256 spEthGain2, uint256 ethGainA, uint256 ethGainB, uint256 ethGainC, uint256 ethGainD, uint256 expectedShareOfColl, uint256 spEthGain, uint256 totalDepositsBefore, uint256 spEthBal1, uint256 spEthBal2, uint256 initialfeUSDGainA, uint256 initialfeUSDGainB
- `PendingAggInterest` (test/stabilityPool.t.sol): uint256 _1, uint256 _2, uint256 _3
- `Position` (src/Dependencies/L1Read.sol): int64 szi, uint32 leverage, uint64 entryNtl
- `Position` (src/SortedTroves.sol): uint256 prevId, uint256 nextId
- `PriceFeedProposal` (src/AdminController.sol): address priceFeed, uint256 timestamp
- `PriceFeedProposal` (src/AdminControllerNoDelays.sol): address priceFeed, uint256 timestamp
- `PriceFeedProposal` (src/BaseAdminController.sol): address priceFeed, uint256 timestamp
- `PriceFeedProposal` (src/Interfaces/IAdminController.sol): address priceFeed, uint256 timestamp
- `ProvideToSPContext` (test/TestContracts/InvariantsTestHandler.t.sol): TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 totalfeUSDDeposits, uint256 blockedSPYield, uint256 initialfeUSDDeposit, uint256 feUSDDeposit, uint256 feUSDYield, uint256 ethGain, uint256 ethStash, uint256 ethClaimed, uint256 feUSDClaimed, string errorString
- `ProxyAdminAddresses` (scripts/Mainnet/DeployFelixMainnet.s.sol): address proxyAdminForCoreContracts, address proxyAdminForAdminController
- `ProxyAdminAddresses` (test/TestContracts/DeployFelix.sol): address proxyAdminForCoreContracts, address proxyAdminForAdminController
- `ProxyAdminAddresses` (test/TestContracts/DeploymentMainnet.sol): address proxyAdminForCoreContracts, address proxyAdminForAdminController
- `QuoteExactInputSingleParams` (src/Zappers/Modules/Exchanges/UniswapV3/IQuoterV2.sol): address tokenIn, address tokenOut, uint256 amountIn, uint24 fee, uint160 sqrtPriceLimitX96
- `QuoteExactOutputSingleParams` (src/Zappers/Modules/Exchanges/UniswapV3/IQuoterV2.sol): address tokenIn, address tokenOut, uint256 amount, uint24 fee, uint160 sqrtPriceLimitX96
- `RedStoneResponse` (src/PriceFeeds/RedStonePriceFeedBase.sol): uint80 roundId, int256 answer, uint256 timestamp, bool success
- `RedStoneResponse` (src/PriceFeeds/RedStonePriceFeedBaseLst.sol): uint80 roundId, int256 answer, uint256 timestamp, bool success
- `Redeemed` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 troveId, uint256 coll, uint256 debt, bool becomesZombie
- `RedemptionTotals` (src/CollateralRegistry.sol): uint256 numCollaterals, uint256 feUSDSupplyAtStart, uint256 unbacked, uint256 redeemedAmount
- `RedemptionTransientState` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 attemptedAmount, uint256 totalCollRedeemed, Redeemed[] redeemed, EnumerableAddressSet batchManagers, uint256 newDesignatedVictimId
- `RemoveFromBatchContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 troveId, LatestTroveData t, address batchManager, uint256 batchManagementFee, bool wasActive, bool premature, uint256 upfrontFee, string errorString
- `RemoveManagerReceiver` (src/Dependencies/AddRemoveManagers.sol): address manager, address receiver
- `Reward` (src/Zappers/Modules/Exchanges/Curve/IGauge.sol): address distributor, uint256 period_finish, uint256 rate, uint256 last_update, uint256 integral
- `RewardSnapshot` (src/TroveManager.sol): uint256 coll, uint256 feUSDDebt
- `RewardSnapshot` (src/TroveManagerLst.sol): uint256 coll, uint256 feUSDDebt
- `SPYieldProposal` (src/AdminController.sol): uint256 spYieldPercentage, uint256 timestamp
- `SPYieldProposal` (src/AdminControllerNoDelays.sol): uint256 spYieldPercentage, uint256 timestamp
- `SPYieldProposal` (src/BaseAdminController.sol): uint256 spYieldPercentage, uint256 timestamp
- `SPYieldProposal` (src/Interfaces/IAdminController.sol): uint256 spYieldPercentage, uint256 timestamp
- `SetBatchManagerAnnualInterestRateContext` (test/TestContracts/InvariantsTestHandler.t.sol): uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, LatestBatchData b, bool premature, uint256 upfrontFee, string errorString
- `SetInterestBatchManagerContext` (test/TestContracts/InvariantsTestHandler.t.sol): address newBatchManager, uint256 upperHint, uint256 lowerHint, TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 troveId, LatestTroveData t, uint256 batchManagementFee, Trove trove, bool wasOpen, bool wasActive, uint256 upfrontFee, string errorString
- `SingleRedemptionValues` (src/TroveManager.sol): uint256 troveId, address batchAddress, uint256 feUSDLot, uint256 collLot, uint256 collFee, uint256 appliedRedistfeUSDDebtGain, uint256 oldWeightedRecordedDebt, uint256 newWeightedRecordedDebt, uint256 newStake, bool isZombieTrove, LatestTroveData trove, LatestBatchData batch
- `SingleRedemptionValues` (src/TroveManagerLst.sol): uint256 troveId, address batchAddress, uint256 feUSDLot, uint256 collLot, uint256 collFee, uint256 appliedRedistfeUSDDebtGain, uint256 oldWeightedRecordedDebt, uint256 newWeightedRecordedDebt, uint256 newStake, bool isZombieTrove, LatestTroveData trove, LatestBatchData batch
- `SingletonContractAddresses` (scripts/Mainnet/DeployFelixMainnet.s.sol): address feUSDToken, address collateralRegistry, address adminController, address hintHelpers, address multiTroveGetter, address metadataNFT
- `SingletonContractAddresses` (test/TestContracts/DeployFelix.sol): address feUSDToken, address collateralRegistry, address adminController, address hintHelpers, address multiTroveGetter, address metadataNFT
- `SingletonContractAddresses` (test/TestContracts/DeploymentMainnet.sol): address feUSDToken, address collateralRegistry, address adminController, address hintHelpers, address multiTroveGetter, address metadataNFT
- `SingletonContracts` (scripts/Mainnet/Utils/ReadManifestHelper.sol): address feUSDToken, address collateralRegistry, address adminController, address proxyAdminForCoreContracts, address proxyAdminForAdminController, address hintHelpers, address metadataNFT, address multiTroveGetter
- `SingletonContracts` (test/ReadManifestHelper.t.sol): address feUSDToken, address collateralRegistry, address adminController, address proxyAdminForCoreContracts, address proxyAdminForAdminController, address hintHelpers, address metadataNFT, address multiTroveGetter
- `Snapshots` (src/StabilityPool.sol): uint256 S, uint256 P, uint256 B, uint256 scale
- `SpotBalance` (src/Dependencies/L1Read.sol): uint64 total, uint64 hold, uint64 entryNtl
- `StabilityPoolRewardsState` (test/events.t.sol): uint256 scale, uint256 P, uint256 S, uint256 B
- `TestValues` (test/multicollateral.t.sol): uint256 troveId, uint256 price, uint256 unbackedPortion, uint256 redeemAmount, uint256 fee, uint256 collInitialBalance, uint256 collFinalBalance, uint256 branchDebt, uint256 collTokenBalBefore_A, uint256 redeemed, uint256 correspondingETH, uint256 ETHFee, uint256 spfeUSDAmount
- `Trove` (src/TroveManager.sol): uint256 debt, uint256 coll, uint256 stake, Status status, uint64 arrayIndex, uint64 lastDebtUpdateTime, uint64 lastInterestRateAdjTime, uint256 annualInterestRate, address interestBatchManager, uint256 batchDebtShares
- `Trove` (src/TroveManagerLst.sol): uint256 debt, uint256 coll, uint256 stake, Status status, uint64 arrayIndex, uint64 lastDebtUpdateTime, uint64 lastInterestRateAdjTime, uint256 annualInterestRate, address interestBatchManager, uint256 batchDebtShares
- `Trove` (test/SortedTroves.t.sol): uint256 arrayIndex, uint256 annualInterestRate, BatchId batchId
- `Trove` (test/Utils/Trove.sol): uint256 coll, uint256 debt, uint256 interestRate, uint256 batchManagementRate, uint256 totalCollRedist, uint256 totalDebtRedist, uint256 _pendingCollRedist, uint256 _pendingDebtRedist, uint256 _pendingInterest, uint256 _pendingBatchManagementFee
- `TroveChange` (src/Types/TroveChange.sol): uint256 appliedRedistfeUSDDebtGain, uint256 appliedRedistCollGain, uint256 collIncrease, uint256 collDecrease, uint256 debtIncrease, uint256 debtDecrease, uint256 newWeightedRecordedDebt, uint256 oldWeightedRecordedDebt, uint256 upfrontFee, uint256 batchAccruedManagementFee, uint256 newWeightedRecordedBatchManagementFee, uint256 oldWeightedRecordedBatchManagementFee
- `TroveData` (src/NFTMetadata/MetadataNFT.sol): uint256 _tokenId, address _owner, address _collToken, address _feUSDToken, uint256 _collAmount, uint256 _debtAmount, uint256 _interestRate, ITroveManager.Status _status
- `TroveData` (src/NFTMetadata/utils/MatadataNFTBase.sol): uint256 _tokenId, address _owner, address _collToken, address _feUSDToken, uint256 _collAmount, uint256 _debtAmount, uint256 _interestRate, ITroveManager.Status _status
- `TroveManagerParams` (test/TestContracts/Deployment.t.sol): uint256 CCR, uint256 MCR, uint256 SCR, uint256 LIQUIDATION_PENALTY_SP, uint256 LIQUIDATION_PENALTY_REDISTRIBUTION, uint256 maxDebtCap
- `UniV3Vars` (test/TestContracts/Deployment.t.sol): IExchange uniV3Exchange, uint256 price, address[2] tokens
- `UpgradeProposal` (src/AdminControllerV2.sol): ContractType contractType, address newImplementation, bytes initCalldata
- `UrgentRedemptionTransientState` (test/TestContracts/InvariantsTestHandler.t.sol): address[] batch, EnumerableSet redeemedIds, uint256 totalDebtRedeemed, uint256 totalCollRedeemed, Redeemed[] redeemed, EnumerableAddressSet batchManagers
- `UserVaultEquity` (src/Dependencies/L1Read.sol): uint64 equity
- `WeeklyRewards` (src/InterestRouter/RewardsAllocator.sol): uint256 startTimestamp, uint256 endTimestamp, uint256 totalRewards, uint256 claimedRewards, bytes32 merkleRoot
- `WithdrawFromSPContext` (test/TestContracts/InvariantsTestHandler.t.sol): TestDeployer.LiquityContractsDev c, uint256 pendingInterest, uint256 totalfeUSDDeposits, uint256 blockedSPYield, uint256 initialfeUSDDeposit, uint256 feUSDDeposit, uint256 feUSDYield, uint256 ethGain, uint256 ethStash, uint256 ethClaimed, uint256 feUSDClaimed, uint256 withdrawn, string errorString
- `Withdrawable` (src/Dependencies/L1Read.sol): uint64 withdrawable
- `Zappers` (test/TestContracts/Deployment.t.sol): WHYPEZapper whypeZapper, GasCompZapper gasCompZapper, ILeverageZapper leverageZapperCurve, ILeverageZapper leverageZapperUniV3, ILeverageZapper leverageZapperHybrid
- `feUSDRedeemAmounts` (test/redemptions.t.sol): uint256 A, uint256 B, uint256 C

### Enum State Values
- `AdjustedTroveProperties` (test/TestContracts/InvariantsTestHandler.t.sol): onlyColl, onlyDebt, both, _COUNT
- `ArbRole` (test/SortedTroves.t.sol): Individual, BatchStarter, BatchJoiner
- `BatchOperation` (src/Interfaces/ITroveEvents.sol): registerBatchManager, lowerBatchManagerAnnualFee, setBatchManagerAnnualInterestRate, applyBatchInterestAndFee, joinBatch, exitBatch, troveChange
- `Collaterals` (scripts/Mainnet/DeployFelixMainnet.s.sol): WHYPE, COLLATERALS_LENGTH
- `Collaterals` (scripts/Mainnet/Utils/ReadManifestHelper.sol): WHYPE, WBTC, COLLATERALS_LENGTH
- `Collaterals` (test/AfterExecutionTests/AfterDeployment.t.sol): WHYPE, COLLATERALS_LENGTH
- `Collaterals` (test/ReadManifestHelper.t.sol): WHYPE, WBTC, KHYPE, WSTHYPE, COLLATERALS_LENGTH
- `Collaterals` (test/TestContracts/DeployFelix.sol): WHYPE, COLLATERALS_LENGTH
- `Collaterals` (test/TestContracts/DeploymentMainnet.sol): WHYPE, COLLATERALS_LENGTH
- `ContractType` (src/AdminController.sol): ACTIVE_POOL, ADDRESS_REGISTRY, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER
- `ContractType` (src/AdminControllerNoDelays.sol): ACTIVE_POOL, ADDRESS_REGISTRY, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER
- `ContractType` (src/BaseAdminController.sol): ACTIVE_POOL, ADDRESS_REGISTRY, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER
- `ContractType` (src/Interfaces/IAdminController.sol): ACTIVE_POOL, ADDRESS_REGISTRY, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER
- `ContractTypes` (scripts/Mainnet/DeployFelixMainnet.s.sol): ACTIVE_POOL, ADDRESSES_REGISTRY, ADMIN_CONTROLLER, FEUSD_TOKEN, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, PRICE_FEEDS, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER, TROVE_NFT, INTEREST_ROUTER, METADATA_NFT
- `ContractTypes` (test/TestContracts/DeployFelix.sol): ACTIVE_POOL, ADDRESSES_REGISTRY, ADMIN_CONTROLLER, feUSD_TOKEN, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, PRICE_FEEDS, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER, TROVE_NFT, INTEREST_ROUTER, METADATA_NFT, PRICE_FEEDS_MOCK
- `ContractTypes` (test/TestContracts/DeploymentMainnet.sol): ACTIVE_POOL, ADDRESSES_REGISTRY, ADMIN_CONTROLLER, FEUSD_TOKEN, BORROWER_OPERATIONS, COLLATERAL_REGISTRY, COLL_SURPLUS_POOL, DEFAULT_POOL, GAS_POOL, HINT_HELPERS, MULTI_TROVE_GETTER, PRICE_FEEDS, SORTED_TROVES, STABILITY_POOL, TROVE_MANAGER, TROVE_NFT, INTEREST_ROUTER, METADATA_NFT
- `OpImpact` (src/AdminController.sol): STANDARD, SENSITIVE
- `OpImpact` (src/AdminControllerNoDelays.sol): STANDARD, SENSITIVE
- `OpImpact` (src/BaseAdminController.sol): STANDARD, SENSITIVE
- `Operation` (src/Interfaces/IStabilityPoolEvents.sol): provideToSP, withdrawFromSP, claimAllCollGains
- `Operation` (src/Interfaces/ITroveEvents.sol): openTrove, closeTrove, adjustTrove, adjustTroveInterestRate, applyPendingDebt, liquidate, redeemCollateral, openTroveAndJoinBatch, setInterestBatchManager, removeFromBatch
- `Operation` (src/Zappers/Interfaces/IFlashLoanProvider.sol): OpenTrove, CloseTrove, LeverUpTrove, LeverDownTrove
- `PriceSource` (src/PriceFeeds/RedStonePriceFeedBaseLst.sol): primary, HYPEUSDxCanonical, lastGoodPrice
- `Status` (src/Interfaces/ITroveManager.sol): nonExistent, active, closedByOwner, closedByLiquidation, zombie
- `colorCode` (src/NFTMetadata/utils/bauhaus.sol): GOLDEN, CORAL, GREEN, CYAN, BLUE, DARK_BLUE, BROWN

### Invariant Values (Variable-Tied)
- Debt growth must stay bounded by collateral/liquidation constraints
- Every token address/handle variable must be non-zero and immutable or governance-gated
- Struct fields representing amounts/indexes/nonces must remain monotonic or strictly validated per lifecycle transition

### Full Raw State Inventory
- `AUDIT_STATE_VALUES_FULL.json` includes:
  - all state variables
  - all total/balance variables
  - all token variables
  - all structs and fields
  - enum values
<!-- AUDIT_DOSSIER_END -->
