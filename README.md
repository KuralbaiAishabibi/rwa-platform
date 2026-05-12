# RWA Tokenization Platform

A production-grade decentralized protocol for tokenizing real-world assets (RWA). Built as the capstone project for Blockchain Technologies 2.

## Scenario: Option C - RWA Tokenization Platform

- ERC-20 asset-backed tokens representing real-world collateral
- ERC-4626 yield vault for underwriter yield
- Chainlink Proof of Reserve and price feeds with staleness checks
- Role-gated minting for authorized issuers
- DAO governance over asset onboarding and parameter changes
- L2 deployment on Arbitrum Sepolia

## Tech Stack

- Solidity 0.8.20 (Foundry)
- React + Viem + Wagmi (Frontend)
- The Graph (Indexing)
- OpenZeppelin Contracts v4.9.6
- Chainlink Oracles

## Quick Start

### Prerequisites

- Foundry (forge, cast, anvil)

### Build

forge build

### Test

forge test -vvv

### Coverage

forge coverage

### Deploy

forge script script/DeployCore.s.sol --rpc-url $RPC_URL --broadcast --verify

## Team

- Ayshabibi Kuralbai - Core Protocol Contracts
- Lenara Symbatkyzy - Governance, Frontend, DevOps

## License

MIT
