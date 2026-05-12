# Storage Layout - RwaLendingPool (UUPS Upgradeable)

This document describes the storage layout of the RwaLendingPool upgradeable contract to prove that storage collisions between V1 and V2 are impossible.

## Slot Allocation

| Slot | Variable | Type |
|------|----------|------|
| 0 | __gap[50] | uint256[50] (Initializable) |
| 50 | _owner | address (OwnableUpgradeable) |
| 51 | __gap[49] | uint256[49] |
| 100 | _status | uint256 (ReentrancyGuardUpgradeable) |
| 101 | _paused | bool (PausableUpgradeable) |
| 102 | stableAsset | IERC20Upgradeable |
| 103 | oracle | IPriceOracle |
| 104 | admin | address |
| 105 | loans | mapping(address => mapping(address => Loan)) |
| 106 | supportedCollateral | mapping(address => bool) |

## Upgrade Path V1 to V2

V1 represents the current implementation with basic lending functionality (deposit, borrow, repay, liquidate). V2 will add multi-collateral support and an improved interest rate model. Storage gaps between inherited contracts are reserved for future variables. Any new state variables will be appended to the end of the storage layout to prevent collisions.

## Upgrade Authorization

Only the admin address (intended to be the Governance Timelock) can authorize upgrades via the _authorizeUpgrade function.
