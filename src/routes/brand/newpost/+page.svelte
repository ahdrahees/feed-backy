<script lang="ts">
	import { goto } from '$app/navigation';
	import { post } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Breadcrumb, BreadcrumbItem } from 'flowbite-svelte';
	import { Label, Select, Input, GradientButton } from 'flowbite-svelte';
	import { SyncLoader } from 'svelte-loading-spinners';
	import { calculatePostCostInICP } from '../../../stores/icp-cost-per-post';
	import { onMount } from 'svelte';
	import {
		addressStoreUpdate,
		balanceStore,
		balanceStoreUpdate
	} from '../../../stores/address-balance-store';

	type QuestionInput = {
		placeholder: string;
		userInput: string;
	};
	let selected = '';
	let questionsInput: QuestionInput[] = [];
	let countries = [
		{ value: '1', name: '1' },
		{ value: '2', name: '2' },
		{ value: '3', name: '3' },
		{ value: '4', name: '4' },
		{ value: '5', name: '5' }
	];
	let enablePostButton = false;
	let feedbackNos: bigint;

	let postingLoading = false;
	let icpCostPerPost = 0;

	onMount(async () => {
		await balanceStoreUpdate();
		await addressStoreUpdate();
	});

	function calculateInputsNeeded() {
		enablePostButton = true;
		questionsInput = [];
		if (selected === '1') {
			questionsInput.push({ placeholder: 'Question 1', userInput: '' });
		} else if (selected === '2') {
			questionsInput.push({ placeholder: 'Question 1', userInput: '' });
			questionsInput.push({ placeholder: 'Question 2', userInput: '' });
		} else if (selected === '3') {
			for (let i = 1; i <= 3; i++) {
				questionsInput.push({ placeholder: 'Question ' + i.toString(), userInput: '' });
			}
		} else if (selected === '4') {
			for (let i = 1; i <= 4; i++) {
				questionsInput.push({ placeholder: 'Question ' + i.toString(), userInput: '' });
			}
		} else if (selected === '5') {
			for (let i = 1; i <= 5; i++) {
				questionsInput.push({ placeholder: 'Question ' + i.toString(), userInput: '' });
			}
		} else {
			questionsInput = [];
		}
	}

	async function newPost() {
		let questions: string[] = [];
		let feedbackNos__: bigint;
		if (!$authMethods.isAuthenticated) {
			alert('Please Login with Internet Identity First');
			return 0;
		}

		if (questionsInput.length === 0) {
			alert('Select number of questions');
			return 0;
		}

		for (let i = 0; i < questionsInput.length; i++) {
			if (questionsInput[i].userInput.length < 1) {
				alert('Please fill all fields');
				return 0;
			} else {
				questions.push(questionsInput[i].userInput);
			}
		}
		if (typeof feedbackNos === 'undefined') {
			alert('Please fill number of feedbacks');
			return 0;
		}
		if (feedbackNos.toString().length < 1) {
			alert('Please fill number of feedbacks');
			return 0;
		}
		if (Number(feedbackNos) < 1) {
			alert('Please fill number of feedbacks greater than or equal to 1');
			return 0;
		}
		if (Number(feedbackNos) % 1 !== 0) {
			alert('Number of feedbacks should not be decimal point. Remove ractions part');
			return 0;
		}

		postingLoading = true;
		let mybalance = $balanceStore;
		let postCostInICP = BigInt(calculatePostCostInICP(questions.length, Number(feedbackNos)));
		if (mybalance < postCostInICP) {
			alert(
				'Not enough Balance. Your Balance is ' +
					(Number(mybalance) / 10 ** 8).toString() +
					' ICP. Post Cost is ' +
					(Number(postCostInICP) / 10 ** 8).toString() +
					' ICP.'
			);
			postingLoading = false;
			return 0;
		}
		feedbackNos__ = BigInt(feedbackNos);

		const result = await post(questions, feedbackNos__);
		if ('ok' in result) {
			goto('/brand');
			await balanceStoreUpdate();
		} else if ('err' in result) {
			console.log(result.err);
			// if ('LowBalance' in result.err) {
			// 	alert('Post Error : LowBalance' + result.err.LowBalance.toString());
			alert('Post Error : ' + result.err);
			// }
		}
		postingLoading = false;
	}

	function validateRewardInput() {
		const postButton = document.getElementById('post-button') as HTMLButtonElement;

		if (feedbackNos.toString().length === 0) {
			postButton.disabled = true;
		} else if (feedbackNos.toString().length < 1) {
			postButton.disabled = true;
		} else if (Number(feedbackNos) < 1) {
			postButton.disabled = true;
		}
		postButton.disabled = false;
	}

	function updatePostCost() {
		icpCostPerPost = calculatePostCostInICP(questionsInput.length, Number(feedbackNos)) / 10 ** 8;
	}
	let balance: number = Number($balanceStore) / 10 ** 8;

	async function myBalanceFN() {
		balance = Number($balanceStore) / 10 ** 8;
	}
</script>

<Breadcrumb aria-label="Solid background breadcrumb example" solid>
	<BreadcrumbItem href="/brand" home>Home</BreadcrumbItem>
	<BreadcrumbItem>Create New Post</BreadcrumbItem>
</Breadcrumb>

<div class="container mx-auto">
	<div class="flex items-center justify-center min-h-screen-80vh">
		<form class="w-full md:w-2/3 lg:w-1/2 xl:w-1/2 px-10">
			<Label>
				Select Number of questions
				<Select
					class="mt-2"
					items={countries}
					bind:value={selected}
					on:change={calculateInputsNeeded}
				/>
			</Label>
			<div class="py-3"></div>
			{#each questionsInput as quest}
				<div class="mb-6">
					<Label for="default-input" class="block mb-2">{quest.placeholder}</Label>
					<Input id="default-input" placeholder={quest.placeholder} bind:value={quest.userInput} />
				</div>
			{/each}
			{#if enablePostButton}
				<div class="mb-6">
					<Label for="default-input" class="block mb-2">Nos Feedbacks</Label>
					<Input
						type="number"
						id="default-input"
						placeholder="Minimum 1 Feedback"
						bind:value={feedbackNos}
						on:input={updatePostCost}
						required
					/>
				</div>
				<div class="mb-6 text-gray-600">
					{#await myBalanceFN() then _}
						{'Balance = ' + balance + ' ICP'}
						<br />
					{/await}
					{'Post Cost + Transaction Fee (0.0001) = ' + (icpCostPerPost + 0.0001) + ' ICP'}
					<br />
				</div>
				{#if postingLoading}
					<div class="flex justify-center">
						<SyncLoader color="#07b66a" />
					</div>
				{:else}
					<GradientButton
						id="post-button"
						shadow
						color="green"
						class="w-full"
						on:click={async () => {
							await newPost();
						}}>Post</GradientButton
					>
				{/if}
			{/if}
		</form>
	</div>
</div>

<style>
	.min-h-screen-80vh {
		min-height: 80vh;
	}
</style>
