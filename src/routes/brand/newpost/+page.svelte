<script lang="ts">
	import { goto } from '$app/navigation';
	import { checkMyBalance, post } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Breadcrumb, BreadcrumbItem } from 'flowbite-svelte';
	import { Label, Select, Input, GradientButton } from 'flowbite-svelte';
	import { SyncLoader } from 'svelte-loading-spinners';

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
	let rewardsInput: bigint;

	let postingLoading = false;

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
		console.log(questionsInput);
	}

	async function newPost() {
		let questions: string[] = [];
		let rewards: bigint;
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
		if (rewardsInput.toString().length < 1) {
			alert('Please fill reward');
			return 0;
		}
		if (Number(rewardsInput) < 10) {
			alert('Reward should be 10 or greater');
			return 0;
		}
		if (Number(rewardsInput) % 10 !== 0) {
			alert('Reward should be multiple of 10');
			return 0;
		}

		postingLoading = true;
		let mybalance = await checkMyBalance();
		if (mybalance < BigInt(rewardsInput)) {
			alert('Not enough Balance');
			postingLoading = false;
			return 0;
		}
		rewards = BigInt(rewardsInput);

		const result = await post(questions, rewards);
		if ('ok' in result) {
			goto('/brand');
		} else if ('err' in result) {
			// if ('LowBalance' in result.err) {
			// 	alert('Post Error : LowBalance' + result.err.LowBalance.toString());
			alert('Post Error : ' + result.err);
			// }
		}
		postingLoading = false;
	}

	function validateRewardInput() {
		const postButton = document.getElementById('post-button') as HTMLButtonElement;

		if (rewardsInput.toString().length === 0) {
			postButton.disabled = true;
		} else if (rewardsInput.toString().length < 1) {
			postButton.disabled = true;
		} else if (Number(rewardsInput) < 10) {
			Number(rewardsInput) < 10;
		}
		postButton.disabled = false;
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
					<Label for="default-input" class="block mb-2">Rewards</Label>
					<Input
						type="number"
						id="default-input"
						placeholder="Minimum 10 Rewards"
						bind:value={rewardsInput}
						required
					/>
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
