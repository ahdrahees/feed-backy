<script lang="ts">
	import { goto } from '$app/navigation';
	import { getBrandBasicInfo, post } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Breadcrumb, BreadcrumbItem } from 'flowbite-svelte';
	import { Label, Select, Input, GradientButton } from 'flowbite-svelte';
	import { Card, Badge } from 'flowbite-svelte';
	import { ArrowRightOutline } from 'flowbite-svelte-icons';
	import { Jellyfish, SyncLoader } from 'svelte-loading-spinners';
	import {
		GoogleGenerativeAI,
		HarmCategory,
		HarmBlockThreshold,
		type EnhancedGenerateContentResponse
	} from '@google/generative-ai';
	import type { BrandBasicInfo } from '../../../declarations/backend.did';
	import { onMount } from 'svelte';
	import { calculatePostCostInICP } from '../../../stores/icp-cost-per-post';
	import type { Account } from '../../../declarations/backend.did';
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

	let brandBasicInfo: Omit<BrandBasicInfo, 'account'> = {
		productOrServiceCategory: '',
		targetAudience: '',
		brandName: '',
		industry: ''
	};
	let productName = '';
	let genQuestions: string[] = [];
	let numberOfQues = '';
	let enableQuestionTextArea = false;

	let generateLoad = false;
	let postingLoad = false;

	let icpCostPerPost = 0;

	let account: Account;

	onMount(async () => {
		await getBasicInfo();
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

	async function getBasicInfo() {
		const result = await getBrandBasicInfo();

		if ('ok' in result) {
			brandBasicInfo = result.ok;
			account = result.ok.account;
		} else if ('err' in result) {
			console.log(result.err);
			brandBasicInfo = {
				productOrServiceCategory: '',
				targetAudience: '',
				brandName: '',
				industry: ''
			};
		}
	}

	async function generateQuestions() {
		if (!$authMethods.isAuthenticated) {
			alert('Please Login with Internet Identity First');
			return 0;
		} else if (productName.length < 1) {
			alert('Please provide product name');
			return 0;
		} else if (brandBasicInfo.brandName.length < 1) {
			alert('Please Provide brand name');
			return 0;
		} else if (brandBasicInfo.industry.length < 1) {
			alert('Please Provide industry');
			return 0;
		} else if (brandBasicInfo.productOrServiceCategory.length < 1) {
			alert('Please Provide Product / Service Category');
			return 0;
		} else if (brandBasicInfo.targetAudience.length < 1) {
			alert('Please Provide Target Audience');
			return 0;
		}

		generateLoad = true;
		genQuestions = await run();
		enableQuestionTextArea = true;
		generateLoad = false;
	}

	async function newPost() {
		let feedbackNos__: bigint;
		if (!$authMethods.isAuthenticated) {
			alert('Please Login with Internet Identity First');
			return 0;
		}

		if (questionsInput.length === 0) {
			alert('Select number of questions');
			return 0;
		}

		for (let i = 0; i < genQuestions.length; i++) {
			if (genQuestions[i].length < 1) {
				alert('Please fill all fields');
				return 0;
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

		postingLoad = true;
		let mybalance = $balanceStore;
		let postCostInICP = BigInt(calculatePostCostInICP(genQuestions.length, Number(feedbackNos)));
		if (mybalance < postCostInICP) {
			alert(
				'Not enough Balance. Your Balance is ' +
					(Number(mybalance) / 10 ** 8).toString() +
					' ICP. Post Cost is ' +
					(Number(postCostInICP) / 10 ** 8).toString() +
					' ICP.'
			);
			postingLoad = false;
			return 0;
		}
		feedbackNos__ = BigInt(feedbackNos);

		const result = await post(genQuestions, feedbackNos__);
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
		postingLoad = false;
	}

	function validateRewardInput() {
		const postButton = document.getElementById('post-button') as HTMLButtonElement;

		if (feedbackNos.toString().length === 0) {
			postButton.disabled = true;
		} else if (feedbackNos.toString().length < 1) {
			postButton.disabled = true;
		}
		postButton.disabled = false;
	}

	const MODEL_NAME = 'gemini-pro';
	const API_KEY: string = import.meta.env.VITE_GOOGLE_AI_STUDIO_API_KEY;

	async function run() {
		const genAI = new GoogleGenerativeAI(API_KEY);
		const model = genAI.getGenerativeModel({ model: MODEL_NAME });

		const generationConfig = {
			temperature: 0.9,
			topK: 1,
			topP: 1,
			maxOutputTokens: 2048
		};

		const safetySettings = [
			{
				category: HarmCategory.HARM_CATEGORY_HARASSMENT,
				threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
			},
			{
				category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
				threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
			},
			{
				category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
				threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
			},
			{
				category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
				threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
			}
		];

		const parts = [
			{
				text:
					"I'm creating an application which brand can post questions about their products, brand and other questions. And brand users can give feedbacks to their question. User will get rewards for giving their feedbacks to brands. I want use your ability as an AI model to validate the users feedbacks on brands posted questions. And also I want use you to generate valuable question for Brands to post. Are you capable of doing this ?\n\noutput format :\n 1. For Questions generations you have to give output as an Array of string. Each element in the array is the questions that Brand asked to generate to you(Note number of questions need is prompted by brand).\n2. For feedback validation output must be a boolean value.\n 1. **Question Generation:**\n\n   - What are your thoughts on our new product feature, [Feature Name]?\n   - How can we improve the user experience of our mobile app?\n   - What are your favorite and least favorite things about our brand?\n   - What kind of content would you like to see more of from us?\n   - What are your thoughts on our recent marketing campaign?\n   - What are your expectations for our brand in the future?\n   - Do you have any suggestions for new products or services that we could offer?\n   - What are your thoughts on our customer service?\n   - Would you recommend our brand to others?\n   - What are your overall impressions of our brand?\n\n2. **Feedback Validation:**\n\n   To validate user feedback, you can use a combination of natural language processing (NLP) techniques and business rules. Here are some factors to consider:\n\n   - **Sentiment Analysis:** Use NLP to determine the sentiment of the feedback, whether it is positive, negative, or neutral. This can be done by analyzing the words used in the feedback, as well as the overall tone and context.\n   \n   - **Spam Detection:** Check for signs of spam, such as irrelevant content, excessive repetition, or promotional language.\n   \n   - **Profanity Filtering:** Remove any profane or offensive language from the feedback.\n   \n   - **Business Rules:** Apply business rules to ensure that the feedback is relevant to the question asked and that it meets certain quality standards. For example, you may require that feedback be a certain length or that it answer a specific question.\n\n   Once you have considered these factors, you can assign a boolean value to the feedback, indicating whether it is valid or not.\n\nyour  job is to generate question when I tell your response should be question only. Not give any additional responses. If I prompt to validate the answers with question your response is only boolean (No other additional info needed only true or false)\n Sure, I am capable of doing this. I can generate valuable questions for brands to post, and I can validate user feedback on those questions.\n\n**Questions Generation:**\n\n- What are the key features of your product that you think customers will find most valuable?\n- What are some challenges that your customers commonly face, and how can your product help them overcome those challenges?\n- What are your thoughts on the current market trends in your industry, and how is your product positioned to take advantage of those trends?\n- What are your goals for your brand in the next 6-12 months, and how can user feedback help you achieve those goals?\n- What are some common misconceptions that customers have about your product or brand, and how can you address those misconceptions through your content?\n\n**Feedback Validation:**\n\n```\nTrue\n```\n\nPlease generate " +
					selected +
					' questions for the product name ' +
					productName +
					'. Here are the brand details: brand name is ' +
					brandBasicInfo.brandName +
					', brand industry is ' +
					brandBasicInfo.industry +
					', target is ' +
					brandBasicInfo.targetAudience +
					', and product or service category is ' +
					brandBasicInfo.productOrServiceCategory +
					'.\n'
			}
		];

		const result = await model.generateContent({
			contents: [{ role: 'user', parts }],
			generationConfig,
			safetySettings
		});

		const response: EnhancedGenerateContentResponse = result.response;
		let responseArray = response
			.text()
			.replace(/^1\. /, '')
			.replace('\n\n', '')
			.split(/\n\d+\.\s/)
			.filter(Boolean);
		console.log(response.text(), ' --Array---', responseArray);
		return responseArray;
	}

	function updatePostCost() {
		icpCostPerPost = calculatePostCostInICP(genQuestions.length, Number(feedbackNos)) / 10 ** 8;
	}
	let balance: number = Number($balanceStore) / 10 ** 8;

	async function myBalanceFN() {
		balance = Number($balanceStore) / 10 ** 8;
	}
</script>

<Breadcrumb aria-label="Solid background breadcrumb example" solid>
	<BreadcrumbItem href="/brand" home>Home</BreadcrumbItem>
	<BreadcrumbItem>Generate Post</BreadcrumbItem>
</Breadcrumb>
<div class="gradiant flex justify-center items-start h-[100vh]">
	{#if $authMethods.isAuthenticated}
		<div class="flex justify-center basis-full flex-wrap gradiant h-[auto]">
			<Card size="md" class="m-10 basis-full border-0 bg-gradient-to-r from-[#72ecd1] to-[#8d45ff]">
				<h5
					class="mb-2 text-center text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
				>
					Generate Questions with AI
				</h5>
				<Label class="space-y-2 mb-3 basis-full">
					Select Number of questions
					<Select
						class="mt-2 basis-full bg-[#e3d2ff]"
						items={countries}
						bind:value={selected}
						on:change={calculateInputsNeeded}
					/>
				</Label>
				{#if enablePostButton}
					{#await getBasicInfo() then _}
						<div class="mb-6">
							<Label for="default-input" class="block mb-2">Product Name</Label>
							<Input
								class="bg-[#e3d2ff]"
								id="name-input"
								placeholder="Name input"
								bind:value={productName}
							/>
						</div>
						<div class="mb-6">
							<Label for="default-input" class="block mb-2">Product / Service Category</Label>
							<Input
								class="bg-[#e3d2ff]"
								id="default-input"
								placeholder="Default input"
								bind:value={brandBasicInfo.productOrServiceCategory}
							/>
						</div>
						<div class="mb-6">
							<Label for="default-input" class="block mb-2">Brand Name</Label>
							<Input
								class="bg-[#e3d2ff]"
								id="default-input"
								placeholder="Default input"
								bind:value={brandBasicInfo.brandName}
							/>
						</div>
						<div class="mb-6">
							<Label for="default-input" class="block mb-2">Industry</Label>
							<Input
								class="bg-[#e3d2ff]"
								id="default-input"
								placeholder="Default input"
								bind:value={brandBasicInfo.industry}
							/>
						</div>

						<div class="mb-6">
							<Label for="default-input" class="block mb-2">Target Audience:</Label>
							<Input
								class="bg-[#e3d2ff]"
								id="default-input"
								placeholder="Default input"
								bind:value={brandBasicInfo.targetAudience}
							/>
						</div>
					{/await}
					{#if generateLoad}
						<div class="flex justify-center">
							<Jellyfish color="#00ffc8" />
						</div>
					{:else}
						<GradientButton
							color="purpleToBlue"
							class="w-full mb-8"
							on:click={async () => await generateQuestions()}
						>
							Generate Questions<ArrowRightOutline class="w-3.5 h-3.5 ms-2 text-white" />
						</GradientButton>
					{/if}
				{/if}
			</Card>
			{#if enableQuestionTextArea}
				<Card size="md" class="w-full m-10 bg-[#e3d2ff]">
					{#each genQuestions as question, index}
						<div class="mb-6">
							<Badge large class="font-semibold mb-2" rounded color="purple"
								>{'Question ' + (index + 1)}</Badge
							>
							<textarea
								bind:value={question}
								class="border bg-[rgb(249 250 251 / var(--tw-bg-opacity)] border-gray-300 p-3 text-base rounded-lg resize-y w-full"
								rows="3"
								placeholder={'Question ' + (index + 1)}
							></textarea>
						</div>
					{/each}

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
					{#if postingLoad}
						<div class="flex justify-evenly">
							<SyncLoader color="#8533ff" />
						</div>
					{:else}
						<GradientButton
							id="post-button"
							shadow
							color="purple"
							class="w-full"
							on:click={async () => {
								await newPost();
							}}>Post</GradientButton
						>
					{/if}
				</Card>
			{/if}
		</div>
	{/if}
</div>

<style>
	.gradiant {
		background-size: 180% 180%;
		animation: gradient-animation 18s ease infinite;

		background: linear-gradient(300deg, #00ffc8, #b288f8, #6000ff);
		background-size: 180% 180%;
		animation: gradient-animation 12s ease infinite;
	}
	@keyframes gradient-animation {
		0% {
			background-position: 0% 50%;
		}
		50% {
			background-position: 100% 50%;
		}
		100% {
			background-position: 0% 50%;
		}
	}
</style>
