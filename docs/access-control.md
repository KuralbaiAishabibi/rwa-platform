# Access Control Matrix

## Role Definitions

| Contract | Role | Privilege | Intended Holder |
|----------|------|-----------|-----------------|
| AssetToken | DEFAULT_ADMIN_ROLE | Grant and revoke roles | Timelock |
| AssetToken | ISSUER_ROLE | Mint new asset-backed tokens | Authorized issuers |
| AssetCertificate | DEFAULT_ADMIN_ROLE | Grant and revoke roles | Timelock |
| AssetCertificate | ISSUER_ROLE | Mint asset certificates (ERC-721) | Authorized issuers |
| RwaYieldVault | Owner | Transfer ownership, manage vault | Timelock |
| RwaLendingPool | Admin | Pause, unpause, upgrade, set collateral tokens | Timelock |
| ChainlinkPriceOracle | Admin | Set price feed addresses | Timelock |

## Centralization Analysis

All admin roles are designed to be transferred to the Governance Timelock after deployment. During the setup phase, the deployer holds these roles. Once transferred, any privileged action must go through the governance proposal process with a 2-day timelock delay.

A malicious or compromised admin could:
- Change oracle price feeds to manipulate asset prices
- Pause the protocol indefinitely
- Add malicious collateral tokens

Mitigation: The Timelock enforces a 2-day delay on all admin actions, giving users time to exit before any malicious change takes effect.
