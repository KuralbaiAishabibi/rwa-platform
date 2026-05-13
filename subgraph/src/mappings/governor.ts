import { ProposalCreated, VoteCast, ProposalExecuted } from '../../generated/RWAGovernor/RWAGovernor';
import { Proposal, VoteCast as VoteCastEntity } from '../../generated/schema';

export function handleProposalCreated(event: ProposalCreated): void {
  let proposal = new Proposal(event.params.proposalId.toString());
  proposal.proposalId = event.params.proposalId;
  proposal.proposer = event.params.proposer;
  proposal.description = event.params.description;
  proposal.startBlock = event.params.startBlock;
  proposal.endBlock = event.params.endBlock;
  proposal.forVotes = event.params.forVotes;
  proposal.againstVotes = event.params.againstVotes;
  proposal.abstainVotes = event.params.abstainVotes;
  proposal.executed = false;
  proposal.status = "Active";
  proposal.save();
}

export function handleVoteCast(event: VoteCast): void {
  let proposal = Proposal.load(event.params.proposalId.toString());
  if (!proposal) return;
  let voteId = event.params.proposalId.toString() + "-" + event.params.voter.toHexString();
  let vote = new VoteCastEntity(voteId);
  vote.proposal = event.params.proposalId.toString();
  vote.voter = event.params.voter;
  vote.support = event.params.support;
  vote.weight = event.params.weight;
  vote.save();
  if (event.params.support == 1) {
    proposal.forVotes = proposal.forVotes.plus(event.params.weight);
  } else if (event.params.support == 0) {
    proposal.againstVotes = proposal.againstVotes.plus(event.params.weight);
  } else {
    proposal.abstainVotes = proposal.abstainVotes.plus(event.params.weight);
  }
  proposal.save();
}

export function handleProposalExecuted(event: ProposalExecuted): void {
  let proposal = Proposal.load(event.params.proposalId.toString());
  if (proposal) {
    proposal.executed = true;
    proposal.status = "Executed";
    proposal.save();
  }
}
