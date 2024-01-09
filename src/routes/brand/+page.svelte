<script lang="ts">
	import { getPostsByBrand, queryBrand } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { GradientButton } from 'flowbite-svelte';
	import { Card, Badge, Accordion, AccordionItem, Spinner } from 'flowbite-svelte';
	import { ArrowRightOutline } from 'flowbite-svelte-icons';
	import type { Account, QueryBrand, QueryPost } from '../../declarations/backend.did';
	import { postIdMemory } from '../../stores/post-memory';
	import { goto } from '$app/navigation';
	import { convertNanosecondsToReadableDate } from '../../stores/unix-to-date';
	import { Copy } from '@dfinity/gix-components';
	import {
		addressStore,
		addressStoreUpdate,
		balanceStore,
		balanceStoreUpdate
	} from '../../stores/address-balance-store';
	import { onMount } from 'svelte';

	type SubAccount = Uint8Array | number[];

	let balance: BigInt = $balanceStore;
	let allMyPosts: Array<QueryPost> = [];
	let account: Account;

	type MyInfo = Omit<QueryBrand, 'account'>;
	let myInfo: MyInfo = {
		id: BigInt(0),
		principal: '',
		name: '',
		totalPosts: BigInt(0),
		lastPost: BigInt(0),
		industry: '',
		productOrServiceCategory: '',
		targetAudience: ''
	};

	const toHexString = (subAccount: SubAccount) => {
		return Array.from(subAccount, function (byte) {
			return ('0' + (byte & 0xff).toString(16)).slice(-2);
		}).join('');
	};

	let icpWalletAddress = toHexString($addressStore);

	async function getMyAllposts() {
		const result = await getPostsByBrand();

		if ('ok' in result) {
			allMyPosts = result.ok;
		} else if ('err' in result) {
			console.log(result.err);
			allMyPosts = [];
		}
	}

	async function getMyInfo() {
		const result = await queryBrand();

		if ('ok' in result) {
			myInfo = result.ok;
			account = result.ok.account;
		} else if ('err' in result) {
			console.log(result.err);
			myInfo = {
				id: BigInt(0),
				principal: '',
				name: '',
				totalPosts: BigInt(0),
				lastPost: BigInt(0),
				industry: '',
				productOrServiceCategory: '',
				targetAudience: ''
			};
		}
	}

	function forwardToPostInfoPage(postId: bigint) {
		postIdMemory.update((value) => (value = postId));
		goto('/brand/postInfo');
	}

	function shortenWalletAddress(address: string) {
		const firstSixChars = address.slice(0, 8);
		const lastFourChars = address.slice(-7);
		const middleEllipsis = '...';
		return firstSixChars + middleEllipsis + lastFourChars;
	}

	onMount(async () => {
		await balanceStoreUpdate();
		await addressStoreUpdate();
	});
</script>

{#if $authMethods.isAuthenticated}
	{#await getMyInfo() then _}
		<div class="flex justify-center">
			<Card class="basis-full" size="xl">
				<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
					Your Account Info
				</h5>

				<div class="mb-3">
					<Badge large color="green">Name</Badge>
					<span class="font-medium px-2">{myInfo.name}</span>
				</div>
				<div class="mb-3">
					<Badge large color="green">Industry / Vertical</Badge>
					<span class="font-medium px-2">{myInfo.industry}</span>
				</div>
				<div class="mb-3">
					<Badge large color="green">Product/Service Category</Badge>
					<span class="font-medium px-2">{myInfo.productOrServiceCategory}</span>
				</div>
				<div class="mb-3">
					<Badge large color="green">Target Audience</Badge>
					<span class="font-medium px-2">{myInfo.targetAudience}</span>
				</div>
				<div class="mb-3">
					<Badge large color="green">Principal</Badge>
					<span class="font-medium px-2"
						>{shortenWalletAddress(myInfo.principal)}<Copy value={myInfo.principal} /></span
					>
				</div>
				<div class="mb-3">
					<Badge large color="green">ICP Wallet</Badge>
					<span class="font-medium px-2"
						>{shortenWalletAddress(icpWalletAddress)} <Copy value={icpWalletAddress} /></span
					>
				</div>
				<div class="mb-3">
					<Badge large border>Balance</Badge>
					<span class="font-medium px-2"
						>{(Number(balance) / 10 ** 8).toString()}
						<span class="text-red-500">{' ICP'}</span></span
					>
				</div>
				<div class="mb-3">
					<Badge large color="indigo">Total Posts</Badge>
					<span class="font-medium px-2">{myInfo.totalPosts}</span>
				</div>
				<div class="mb-3">
					<Badge large color="indigo">Last Post</Badge>
					<span class="font-medium px-2"
						>{convertNanosecondsToReadableDate(myInfo.lastPost.toString())}</span
					>
				</div>
			</Card>
		</div>
	{/await}

	<Accordion class="m-5">
		<AccordionItem transitionParams={{ duration: 200 }} open>
			<span class="font-bold" slot="header">My Posts</span>
			{#await getMyAllposts()}
				<div class="text-center"><Spinner color="purple" size={'12'} /></div>
			{:then _}
				<div class="flex flex-wrap justify-evenly">
					{#each allMyPosts as post}
						<Card
							class={post.spotLeft.toString() === '0'
								? 'bg-green-300 basis-full m-3'
								: 'bg-indigo-300 basis-full m-3'}
						>
							{#each post.question as question, index}
								<p
									class="mb-3 text-base font-medium text-gray-700 dark:text-gray-400 leading-tight"
								>
									<Badge large class="font-semibold" rounded color="purple"
										>{'Question ' + (index + 1)}</Badge
									>
									{question}
								</p>
							{/each}
							<GradientButton
								color="greenToBlue"
								on:click={async () => {
									forwardToPostInfoPage(post.postId);
								}}
								class="w-fit"
							>
								Feedbacks & Post Info <ArrowRightOutline class="w-3.5 h-3.5 ms-2 text-white" />
							</GradientButton>
							<p class="font-light text-sm py-1 text-black ml-1">
								{convertNanosecondsToReadableDate(post.created.toString())}
							</p>
						</Card>
					{/each}
				</div>
			{/await}
		</AccordionItem>
	</Accordion>
{/if}
