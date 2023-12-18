<script lang="ts">
	import { addBalance, checkMyBalance, getPostsByBrand, queryBrand } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Input, InputAddon, Button, ButtonGroup, GradientButton } from 'flowbite-svelte';
	import { Card, Badge, Accordion, AccordionItem, Spinner } from 'flowbite-svelte';
	import { ArrowRightOutline } from 'flowbite-svelte-icons';
	import { onMount } from 'svelte';
	import type { QueryBrand, QueryPost } from '../../declarations/backend.did';
	import { postIdMemory } from '../../stores/post-memory';
	import { goto } from '$app/navigation';
	import { convertNanosecondsToReadableDate } from '../../stores/unix-to-date';
	import { Diamonds } from 'svelte-loading-spinners';

	let amount: bigint;
	let balance: string = '';
	let allMyPosts: Array<QueryPost> = [];
	let myInfo: QueryBrand = {
		id: BigInt(0),
		balance: BigInt(0),
		principal: '',
		name: '',
		totalPosts: BigInt(0),
		lastPost: BigInt(0),
		industry: '',
		productOrServiceCategory: '',
		targetAudience: ''
	};

	let addbalanceWait = false;
	async function callAddbalance() {
		addbalanceWait = true;

		let add = BigInt(amount);
		let result = await addBalance(add);

		if ('err' in result) {
			await updateBalance();
			alert('Error : ' + result.err);
		} else if ('ok' in result) {
			await updateBalance();
		}

		addbalanceWait = false;
	}

	onMount(async () => {
		await updateBalance();
	});
	async function updateBalance() {
		balance = (await checkMyBalance()).toString();
	}

	async function getMyAllposts() {
		const result = await getPostsByBrand();
		console.log(result);
		if ('ok' in result) {
			allMyPosts = result.ok;
		} else if ('err' in result) {
			allMyPosts = [];
		}
	}

	async function getMyInfo() {
		const result = await queryBrand();

		if ('ok' in result) {
			myInfo = result.ok;
		} else if ('err' in result) {
			myInfo = {
				id: BigInt(0),
				balance: BigInt(0),
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
					<span class="font-medium px-2">{myInfo.principal}</span>
				</div>
				<div class="mb-3">
					<Badge large border>Balance</Badge>
					<span class="font-medium px-2">{(balance = myInfo.balance.toString())}</span>
					<Button class="" on:click={async () => await updateBalance()} color="blue" pill>⭮</Button>
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
