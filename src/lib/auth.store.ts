import { AnonymousIdentity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import { writable, type Readable } from 'svelte/store';
import type { Identity } from '@dfinity/agent';

let authClient: AuthClient | null | undefined;

let anonIdentity = new AnonymousIdentity();

export interface IdentityData {
	isAuthenticated: boolean;
	identity: Identity;
}

export interface AuthMethods extends Readable<IdentityData> {
	sync: () => Promise<void>;
	signIn: () => Promise<void>;
	signOut: () => Promise<void>;
}

const init = async (): Promise<AuthMethods> => {
	const { subscribe, set } = writable<IdentityData>({
		isAuthenticated: false,
		identity: new AnonymousIdentity()
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
				// const authActor = await getActor(signIdentity);

				set({
					isAuthenticated,
					identity: signIdentity
				});

				return;
			}
			set({ isAuthenticated, identity: anonIdentity });
		},

		signIn: async () =>
			new Promise<void>(async (resolve, reject) => {
				authClient = authClient ?? (await AuthClient.create());

				const identityProvider =
					import.meta.env.MODE == 'development'
						? `https://identity.internetcomputer.org/`
						: `https://identity.internetcomputer.org/`;

				await authClient?.login({
					onSuccess: async () => {
						await sync();

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
			set({ isAuthenticated: false, identity: anonIdentity });
		}
	};
};

export const authMethods: AuthMethods = await init();

const sync = async () => await authMethods.sync();
