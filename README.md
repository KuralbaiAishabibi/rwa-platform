# RWA Tokenization Platform

A production-grade decentralized protocol for tokenizing real-world assets.

## Scenario: Option C - RWA Tokenization Platform

## Deployed Addresses (Arbitrum Sepolia)
| Contract | Address |
|----------|---------|
| GovernanceToken | TBD |
| RWATimelock | TBD |
| RWAGovernor | TBD |
| AssetToken | TBD |
| AssetCertificate | TBD |
| RwaYieldVault | TBD |
| ChainlinkPriceOracle | TBD |
| RwaLendingPool | TBD |
| VaultFactory | TBD |

## Quick Start
```bash
forge build
forge test -vvv
forge coverage
Deploy
bash
forge script script/DeployAll.s.sol --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify
Frontend
bash
cd frontend
npm install
npm run dev
Team
Ayshabibi Kuralbai - Core Protocol Contracts

Lenara Symbatkyzy - Governance, Frontend, DevOps, Documentation

License
MIT
