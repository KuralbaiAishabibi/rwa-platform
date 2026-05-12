# Internal Audit Notes - Core Protocol Contracts

## Scope

This section covers findings from manual review and automated analysis of the core protocol contracts written by Aysha.

Files in scope:
- src/tokens/AssetToken.sol
- src/tokens/AssetCertificate.sol
- src/vault/RwaYieldVault.sol
- src/lending/RwaLendingPool.sol
- src/lending/libraries/InterestMath.sol
- src/oracles/ChainlinkPriceOracle.sol
- src/factories/VaultFactory.sol

## Reentrancy Case Study

Files:
- test/vulnerabilities/ReentrancyVulnerable.sol (vulnerable contract)
- test/vulnerabilities/Attacker.sol (exploit contract)
- test/vulnerabilities/ReentrancyTest.t.sol (proof of concept)

Description: The vulnerable contract has a withdraw function that sends ETH before updating the user balance. The attacker contract uses a receive callback to re-enter the withdraw function and drain funds.

Fix applied: All state-changing functions in RwaLendingPool use the ReentrancyGuard modifier from OpenZeppelin. The deposit and borrow functions follow the Checks-Effects-Interactions pattern.

Before fix: The attacker successfully drains more ETH than deposited.
After fix: ReentrancyGuard blocks reentrant calls with "ReentrancyGuard: reentrant call" error.

## Manual Review Findings

### S-01: Checks-Effects-Interactions Pattern
Status: Resolved
All external calls in RwaLendingPool are made after state updates. SafeERC20 wrappers handle ERC20 transfer return values correctly.

### S-02: Oracle Staleness Check
Status: Resolved
ChainlinkPriceOracle enforces MAX_STALENESS of 86400 seconds (1 day). If the price feed has not been updated within this window, the transaction reverts with "stale price".

### S-03: Pausable Circuit Breaker
Status: Resolved
RwaLendingPool extends PausableUpgradeable. The admin can pause deposit and borrow operations in case of an emergency.

### S-04: SafeERC20 Usage
Status: Resolved
All token transfers use SafeERC20 (safeTransfer, safeTransferFrom) to handle non-standard ERC20 implementations.

### G-01: Yul Optimization
Status: Resolved
InterestMath library provides two implementations for linear interest calculation. The Yul assembly version reduces gas costs by approximately 60 percent compared to the pure Solidity version.

## Slither Analysis

The full Slither output is attached as an appendix to the main audit report. No High or Medium severity findings were detected. All Low and Informational findings are documented and justified.
