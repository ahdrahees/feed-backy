import { idlFactory } from '../declarations';
import type { _SERVICE } from '../declarations/backend.did';
import { Actor, HttpAgent, type ActorSubclass, type Identity } from '@dfinity/agent';

const getAgent = async (identity: Identity): Promise<HttpAgent> => {
	const host = import.meta.env.DEV ? 'http://localhost:8080/' : 'https://icp0.io';
	const agent: HttpAgent = new HttpAgent({ identity, host });

	if (import.meta.env.DEV) {
		await agent.fetchRootKey();
	}

	return agent;
};

export const getActor = async (identity: Identity): Promise<ActorSubclass<_SERVICE>> => {
	const canisterId: string = import.meta.env.VITE_BACKEND_CANISTER_ID as string;

	const agent = await getAgent(identity);

	return Actor.createActor(idlFactory, { agent, canisterId });
};
