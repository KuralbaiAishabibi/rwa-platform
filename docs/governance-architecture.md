# Governance Architecture

## Overview
The governance system uses OpenZeppelin Governor v4.9.6 with:
- GovernanceToken: ERC20 with ERC20Votes and ERC20Permit
- RWATimelock: 2-day delay on all executions
- RWAGovernor: full proposal lifecycle

## Proposal Lifecycle
1. Proposal created by holder with >= 1% supply
2. Voting delay: 1 day
3. Voting period: 1 week
4. Proposal must reach 4% quorum
5. Successful proposals queued in Timelock
6. After 2-day delay, proposal executed

## Roles
| Role | Holder | Privilege |
|------|--------|-----------|
| PROPOSER_ROLE | Governor | Create proposals in Timelock |
| EXECUTOR_ROLE | Governor | Execute proposals in Timelock |
| DEFAULT_ADMIN_ROLE | Timelock | Manage roles |

## Sequence Diagram
User -> Governor.propose() -> ProposalCreated
Voters -> Governor.castVote() -> VoteCast
Governor -> Timelock.queue() -> Queued
Timelock -> Governor.execute() -> Executed
