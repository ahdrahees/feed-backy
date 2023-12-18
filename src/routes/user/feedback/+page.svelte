<script lang="ts">
	import { Card, Breadcrumb, BreadcrumbItem, Badge, GradientButton } from 'flowbite-svelte';
	import { Jellyfish } from 'svelte-loading-spinners';
	import { postMemory } from '../../../stores/post-memory';
	import { convertNanosecondsToReadableDate } from '../../../stores/unix-to-date';
	import { authMethods } from '$lib/auth.store';
	import { postfeedback } from '$lib/api';
	import { goto } from '$app/navigation';
	import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from '@google/generative-ai';

	let feedbacks: Array<string> = [];
	let submitLoad = false;

	async function giveFeedback() {
		if (!$authMethods.isAuthenticated) {
			alert('Please Login with Internet Identity First');
			return 0;
		}
		if (feedbacks.length === 0) {
			alert('Please fill feedback text area');
			return 0;
		}
		if (feedbacks.length !== $postMemory.question.length) {
			alert('Please fill feedback');
			return 0;
		}

		for (let i = 0; i < feedbacks.length; i++) {
			if (feedbacks[i].length < 1) {
				alert('Please give feedback to all questions.');
				return 0;
			}
		}
		submitLoad = true;

		const aiValidationResult = await run();
		const result = await postfeedback($postMemory.postId, feedbacks, aiValidationResult);

		if ('ok' in result) {
			goto('/user');
		} else if ('err' in result) {
			console.log(result.err);
			alert('Feedback Error : ' + result.err);
		}
		submitLoad = false;
	}
	function containsTrue(str: string) {
		return str.toLowerCase().includes('true');
	}

	const MODEL_NAME = 'gemini-pro';
	const API_KEY = import.meta.env.VITE_GOOGLE_AI_STUDIO_API_KEY;
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
		const validationPrompt: string = stitchStrings($postMemory.question, feedbacks);
		const parts = [
			{
				text:
					'I\'m creating an application which brand can post questions about their products, brand and other questions. And brand users can give feedbacks to their question. User will get rewards for giving their feedbacks to brands. I want use your ability as an AI model to validate the users feedbacks on brands posted questions. And also I want use you to generate valuable question for Brands to post. Are you capable of doing this ?\n\noutput format :\n 1. For Questions generations you have to give output as an Array of string. Each element in the array is the questions that Brand asked to generate to you(Note number of questions need is prompted by brand).\n2. For feedback validation output must be a boolean value.\n 1. **Question Generation:**\n\n   - What are your thoughts on our new product feature, [Feature Name]?\n   - How can we improve the user experience of our mobile app?\n   - What are your favorite and least favorite things about our brand?\n   - What kind of content would you like to see more of from us?\n   - What are your thoughts on our recent marketing campaign?\n   - What are your expectations for our brand in the future?\n   - Do you have any suggestions for new products or services that we could offer?\n   - What are your thoughts on our customer service?\n   - Would you recommend our brand to others?\n   - What are your overall impressions of our brand?\n\n2. **Feedback Validation:**\n\n   To validate user feedback, you can use a combination of natural language processing (NLP) techniques and business rules. Here are some factors to consider:\n\n   - **Sentiment Analysis:** Use NLP to determine the sentiment of the feedback, whether it is positive, negative, or neutral. This can be done by analyzing the words used in the feedback, as well as the overall tone and context.\n   \n   - **Spam Detection:** Check for signs of spam, such as irrelevant content, excessive repetition, or promotional language.\n   \n   - **Profanity Filtering:** Remove any profane or offensive language from the feedback.\n   \n   - **Business Rules:** Apply business rules to ensure that the feedback is relevant to the question asked and that it meets certain quality standards. For example, you may require that feedback be a certain length or that it answer a specific question.\n\n   Once you have considered these factors, you can assign a boolean value to the feedback, indicating whether it is valid or not.\n\nyour  job is to generate question when I tell your response should be question only. Not give any additional responses. If I prompt to validate the answers with question your response is only boolean (No other additional info needed only true or false)\n Sure, I am capable of doing this. I can generate valuable questions for brands to post, and I can validate user feedback on those questions.\n\n**Questions Generation:**\n\n- What are the key features of your product that you think customers will find most valuable?\n- What are some challenges that your customers commonly face, and how can your product help them overcome those challenges?\n- What are your thoughts on the current market trends in your industry, and how is your product positioned to take advantage of those trends?\n- What are your goals for your brand in the next 6-12 months, and how can user feedback help you achieve those goals?\n- What are some common misconceptions that customers have about your product or brand, and how can you address those misconceptions through your content?\n\n**Feedback Validation:**\n\n```\nTrue\n```\n\nValidate the feedback of this question "What are your thoughts on the unique design of our Lokii necklace, and how well do you think it complements different styles and outfits?", here is the user feedback "Its really good looking with my yellow outfit. I Love it"\n ```\nTrue\n```\n' +
					validationPrompt
			}
		];

		const result = await model.generateContent({
			contents: [{ role: 'user', parts }],
			generationConfig,
			safetySettings
		});

		const response = result.response;
		console.log(response.text());
		console.log(containsTrue(response.text()), typeof containsTrue(response.text()));
		return containsTrue(response.text());
	}

	function stitchStrings(questions: string[], feedback: string[]) {
		let result = 'Validate the feedback of the ';
		for (let i = 0; i < questions.length; i++) {
			result += `Question ${i + 1} "${questions[i]}", user feedback ${i + 1} "${feedback[i]}". `;
		}
		return result.trim();
	}
</script>

<Breadcrumb class="bg-[#fff5f2] p-3 pl-5" aria-label="Default breadcrumb example">
	<BreadcrumbItem href="/user" home>Home</BreadcrumbItem>
	<BreadcrumbItem>Feedback</BreadcrumbItem>
</Breadcrumb>
{#if $authMethods.isAuthenticated}
	<div class="flex justify-center">
		<Card size="md" class="m-3 bg-[#ffcab9] w-full">
			<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
				{$postMemory.brandName}
			</h5>

			{#each $postMemory.question as question, index}
				<p
					class="bg-[#ffe0d6] rounded-lg p-3 mb-3 text-base font-normal text-gray-700 dark:text-gray-400 leading-tight"
				>
					<Badge large class="font-semibold me-1" rounded color="purple"
						>{'Question ' + (index + 1)}</Badge
					>
					{question}
				</p>
				<div class="mb-6">
					<textarea
						bind:value={feedbacks[index]}
						class="border bg-[rgb(249 250 251 / var(--tw-bg-opacity)] border-gray-300 p-3 text-base rounded-lg resize-y w-full"
						rows="1"
						placeholder={'Feedback ' + (index + 1)}
					></textarea>
				</div>
			{/each}
			<div class="flex justify-between">
				{#if submitLoad}
					<div class="ml-5">
						<Jellyfish color="#9146FF" />
					</div>
				{:else}
					<GradientButton
						class="my-3 w-fit"
						color="purpleToPink"
						on:click={async () => {
							console.log(feedbacks);
							await giveFeedback();
						}}
						>Feedback
					</GradientButton>
				{/if}

				<p class="mt-[1.375rem] font-light text-sm">
					{convertNanosecondsToReadableDate($postMemory.created.toString())}
				</p>
			</div>
		</Card>
	</div>
{/if}
