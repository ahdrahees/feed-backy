import { icpAccountAddress, icpBalanceOf } from '$lib/api';
import { writable } from 'svelte/store';

export const balanceStore = writable<bigint>(BigInt(0));
export const addressStore = writable<Uint8Array | number[]>([]);

export const balanceStoreUpdate = async () => {
	let balance_ = await icpBalanceOf();
	balanceStore.update((value) => (value = balance_));
};

export const addressStoreUpdate = async () => {
	let address_ = await icpAccountAddress();
	addressStore.update((value) => (value = address_));
};
