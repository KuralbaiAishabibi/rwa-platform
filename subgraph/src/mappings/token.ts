import { Transfer } from '../../generated/GovernanceToken/GovernanceToken';
import { GovernanceToken, TokenHolder } from '../../generated/schema';
import { BigInt } from '@graphprotocol/graph-ts';

export function handleTransfer(event: Transfer): void {
  let token = GovernanceToken.load("1");
  if (!token) {
    token = new GovernanceToken("1");
    token.totalSupply = BigInt.zero();
  }

  let fromHolder = TokenHolder.load(event.params.from.toHexString());
  if (fromHolder) {
    fromHolder.balance = fromHolder.balance.minus(event.params.value);
    fromHolder.save();
  }

  let toHolder = TokenHolder.load(event.params.to.toHexString());
  if (!toHolder) {
    toHolder = new TokenHolder(event.params.to.toHexString());
    toHolder.address = event.params.to;
    toHolder.balance = BigInt.zero();
    toHolder.token = "1";
  }
  toHolder.balance = toHolder.balance.plus(event.params.value);
  toHolder.save();
}
