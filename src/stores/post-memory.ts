import { writable } from 'svelte/store';
import type { QueryPost } from '../declarations/backend.did';

export const postIdMemory = writable<bigint>(BigInt(0));

export const postMemory = writable<QueryPost>({
	created: BigInt(0),
	filledspot: BigInt(0),
	question: [],
	owner: '',
	spotLeft: BigInt(0),
	totalspot: BigInt(0),
	rewardLeft: BigInt(0),
	brandName: '',
	postId: BigInt(0),
	blockIndex: BigInt(0)
});
