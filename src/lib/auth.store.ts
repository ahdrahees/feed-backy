import { AnonymousIdentity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import { writable, type Readable } from 'svelte/store';
import type { ActorSubclass, Identity } from '@dfinity/agent';
import type { _SERVICE } from '../declarations/backend.did';
import { getActor } from './actor';
import { navigateAfterLogin } from './navigation';

export interface IdentityData {
	isAuthenticated: boolean;
	identity: Identity;
	actor: ActorSubclass<_SERVICE>;
}

export interface AuthMethods extends Readable<IdentityData> {
	sync: () => Promise<void>;
	signIn: () => Promise<void>;
	signOut: () => Promise<void>;
}

let authClient: AuthClient | null | undefined;

let anonIdentity = new AnonymousIdentity();
let anonActor: ActorSubclass<_SERVICE> = await getActor(anonIdentity);

const init = async (): Promise<AuthMethods> => {
	const { subscribe, set } = writable<IdentityData>({
		isAuthenticated: false,
		identity: new AnonymousIdentity(),
		actor: anonActor
	});

	return {
		subscribe,

		sync: async () => {
			authClient = authClient ?? (await AuthClient.create());
			const isAuthenticated: boolean = await authClient.isAuthenticated();

			if (isAuthenticated) {
				const signIdentity: Identity = authClient.getIdentity();

				console.log(
					'isAuthenticated = ',
					isAuthenticated,
					'\n signIdentity = ',
					signIdentity.getPrincipal()
				);
				const authenticatedIdentityConnectedActor = await getActor(signIdentity);

				set({
					isAuthenticated,
					identity: signIdentity,
					actor: authenticatedIdentityConnectedActor
				});

				return;
			}
			set({ isAuthenticated, identity: anonIdentity, actor: anonActor });
		},

		signIn: async () =>
			new Promise<void>(async (resolve, reject) => {
				authClient = authClient ?? (await AuthClient.create());

				const identityProvider =
					import.meta.env.MODE == 'development'
						? `http://qhbym-qaaaa-aaaaa-aaafq-cai.localhost:8080`
						: `https://identity.internetcomputer.org/`;

				await authClient?.login({
					onSuccess: async () => {
						await sync();
						await navigateAfterLogin();
						resolve();
					},
					onError: reject,
					identityProvider
				});
			}),

		signOut: async () => {
			const client: AuthClient = authClient ?? (await AuthClient.create());
			await client.logout();

			// This fix a "sign in -> sign out -> sign in again" flow without window reload.
			authClient = null;
			set({ isAuthenticated: false, identity: anonIdentity, actor: anonActor });
		}
	};
};

export const authMethods: AuthMethods = await init();

const sync = async () => await authMethods.sync();
