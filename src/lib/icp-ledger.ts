/*
import { idlFactory } from '../declarations/icp_ledger_canister';
import type { _SERVICE } from '../declarations/icp_ledger_canister/icp_ledger_canister.did';
import { type Identity, HttpAgent, type ActorSubclass, Actor } from '@dfinity/agent';
import { AnonymousIdentity } from '@dfinity/agent';
import type {
	Account,
	AccountIdentifier,
	Icrc1Tokens
} from '../declarations/icp_ledger_canister/icp_ledger_canister.did';

const getAgent = async (identity: Identity): Promise<HttpAgent> => {
	const host = import.meta.env.DEV ? 'http://localhost:8080/' : 'https://icp0.io';
	const agent: HttpAgent = new HttpAgent({ identity, host });

	if (import.meta.env.DEV) {
		await agent.fetchRootKey();
	}

	return agent;
};

export const getICPLedgerActor = async (identity: Identity): Promise<ActorSubclass<_SERVICE>> => {
	const canisterId: string = import.meta.env.VITE_ICP_LEDGER_CANISTER_ID as string;
	const agent = await getAgent(identity);
	return Actor.createActor(idlFactory, { agent, canisterId });
};

let anonIdentity = new AnonymousIdentity();
export const icpLedger = await getICPLedgerActor(anonIdentity);

export const icpBalanceOf = async (account: Account): Promise<Icrc1Tokens> => {
	return icpLedger.icrc1_balance_of(account);
};

export const icpAccountAddress = async (account: Account): Promise<AccountIdentifier> => {
	return icpLedger.account_identifier(account);
};
*/
