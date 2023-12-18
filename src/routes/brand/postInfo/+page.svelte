<script lang="ts">
	import { getAPostAndFeedbacks } from '$lib/api';
	import { Card, Spinner, Badge, BreadcrumbItem, Breadcrumb } from 'flowbite-svelte';
	import { postIdMemory } from '../../../stores/post-memory';
	import type { Feedback, QueryPost } from '../../../declarations/backend.did';
	import { authMethods } from '$lib/auth.store';
	import { convertNanosecondsToReadableDate } from '../../../stores/unix-to-date';
	import { AccordionItem, Accordion } from 'flowbite-svelte';

	let post: QueryPost = {
		created: BigInt(0),
		filledspot: BigInt(0),
		question: [],
		owner: '',
		spotLeft: BigInt(0),
		totalspot: BigInt(0),
		rewardLeft: BigInt(0),
		brandName: '',
		postId: BigInt(0)
	};
	let feedbacks: Feedback[] = [];

	async function callGetAPostAndFeedbacks() {
		const result = await getAPostAndFeedbacks($postIdMemory);
		if ('ok' in result) {
			post = result.ok.post;
			feedbacks = result.ok.feedbacks;
		} else if ('err' in result) {
			feedbacks = [];
			post = {
				created: BigInt(0),
				filledspot: BigInt(0),
				question: [],
				owner: '',
				spotLeft: BigInt(0),
				totalspot: BigInt(0),
				rewardLeft: BigInt(0),
				brandName: '',
				postId: BigInt(0)
			};
			alert('Post Info Page Error : ' + result.err);
		}
	}
</script>

{#if $authMethods.isAuthenticated}
	<Breadcrumb aria-label="Solid background breadcrumb example" solid>
		<BreadcrumbItem href="/brand" home>Home</BreadcrumbItem>
		<BreadcrumbItem>Post Info</BreadcrumbItem>
	</Breadcrumb>
	{#await callGetAPostAndFeedbacks()}
		<div class="text-center m-5"><Spinner color="purple" size={'12'} /></div>
	{:then _}
		<div class="flex justify-center m-5">
			<Card
				size="md"
				class={post.spotLeft.toString() === '0'
					? 'bg-green-300 basis-full'
					: 'bg-indigo-300 basis-full'}
			>
				<div class="flex justify-center">
					<h5 class="mb-2 text-2xl font-semibold tracking-tight text-gray-900 dark:text-white">
						Post Info
					</h5>
				</div>
				<div class="mb-3 text-xl text-purple-700">
					{post.brandName}
				</div>

				<div class="mb-3">
					<Badge large color="green">Post Id</Badge>
					<span class="font-medium px-2">{post.postId.toString()}</span>
				</div>

				<div class="mb-3">
					<Badge large border>Reward Left</Badge>
					<span class="font-medium px-2">{post.rewardLeft}</span>
				</div>
				<div class="mb-7">
					<Badge large color="indigo">Feedbacks Got</Badge>
					<span class="font-medium px-2 text-gray-700">{post.filledspot}</span>
				</div>
				<div class="mb-7">
					<Badge large color="indigo">Spot Filled / Total Spots</Badge>
					<span class="font-medium px-2 text-gray-700"
						>{post.filledspot + ' / ' + post.totalspot}</span
					>
				</div>
				{#each post.question as question, index}
					<p class="mb-3 text-base font-medium text-gray-700 dark:text-gray-400 leading-tight">
						<Badge large class="font-semibold" rounded color="purple"
							>{'Question ' + (index + 1)}</Badge
						>

						{question}
					</p>
				{/each}
				<p class="font-normal text-base py-1">
					{convertNanosecondsToReadableDate(post.created.toString())}
				</p>
			</Card>
		</div>

		<Accordion class="m-5" activeClass="bg-[#FCF5ED]">
			<AccordionItem class="bg-[#FCF5ED]">
				<span slot="header" class="text-base flex gap-2">
					<svg
						class="mt-0.5 w-[23px] h-[23px] text-gray-800 dark:text-white"
						aria-hidden="true"
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 20 20"
					>
						<path
							stroke="currentColor"
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M15 17v1a.97.97 0 0 1-.933 1H1.933A.97.97 0 0 1 1 18V5.828a2 2 0 0 1 .586-1.414l2.828-2.828A2 2 0 0 1 5.828 1h8.239A.97.97 0 0 1 15 2M6 1v4a1 1 0 0 1-1 1H1m13.14.772 2.745 2.746M18.1 5.612a2.086 2.086 0 0 1 0 2.953l-6.65 6.646-3.693.739.739-3.692 6.646-6.646a2.087 2.087 0 0 1 2.958 0Z"
						/>
					</svg>
					<span class="text-xl">Feedbacks</span>
				</span>
				<div class="flex flex-wrap justify-evenly">
					{#each feedbacks as feedback, index}
						<Card
							size="md"
							class={feedback.isAIvalidationPass
								? 'ml-2 mb-2 basis-full bg-green-300'
								: 'ml-2 mb-2 basis-full bg-red-300'}
						>
							<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="30"
									height="30"
									fill="currentColor"
									class="bi bi-person-circle inline mr-3 mt-0"
									viewBox="0 0 16 16"
								>
									<path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0" />
									<path
										fill-rule="evenodd"
										d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1"
									/>
								</svg>{feedback.userName}
							</h5>
							{#each feedback.feedback as text, index}
								<p
									class="bg-[#ffe0d6] rounded-lg p-3 mb-3 text-base font-normal text-gray-700 dark:text-gray-400 leading-tight"
								>
									<Badge large class="font-semibold me-1" rounded color="indigo"
										>{'Feedback ' + (index + 1)}</Badge
									>

									{text}
								</p>
							{/each}
							<div class="flex justify-between">
								<p class="mt-[1.375rem] font-light text-sm">
									{convertNanosecondsToReadableDate(feedback.created.toString())}
								</p>
								{#if feedback.isAIvalidationPass}
									<Badge border rounded color="green"
										>AI Validation Passed<svg
											class="w-6 h-6 text-gray-800 dark:text-white ml-2"
											aria-hidden="true"
											xmlns="http://www.w3.org/2000/svg"
											fill="none"
											viewBox="0 0 21 21"
										>
											<path
												stroke="currentColor"
												stroke-linecap="round"
												stroke-linejoin="round"
												stroke-width="2"
												d="m6.072 10.072 2 2 6-4m3.586 4.314.9-.9a2 2 0 0 0 0-2.828l-.9-.9a2 2 0 0 1-.586-1.414V5.072a2 2 0 0 0-2-2H13.8a2 2 0 0 1-1.414-.586l-.9-.9a2 2 0 0 0-2.828 0l-.9.9a2 2 0 0 1-1.414.586H5.072a2 2 0 0 0-2 2v1.272a2 2 0 0 1-.586 1.414l-.9.9a2 2 0 0 0 0 2.828l.9.9a2 2 0 0 1 .586 1.414v1.272a2 2 0 0 0 2 2h1.272a2 2 0 0 1 1.414.586l.9.9a2 2 0 0 0 2.828 0l.9-.9a2 2 0 0 1 1.414-.586h1.272a2 2 0 0 0 2-2V13.8a2 2 0 0 1 .586-1.414Z"
											/>
										</svg></Badge
									>
								{:else}
									<Badge border rounded color="red"
										>AI Validation Failed<svg
											xmlns="http://www.w3.org/2000/svg"
											width="20"
											height="20"
											fill="currentColor"
											class="bi bi-x-circle ml-1"
											viewBox="0 0 16 16"
										>
											<path
												d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"
											/>
											<path
												d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708"
											/>
										</svg></Badge
									>
								{/if}
							</div>
						</Card>
					{/each}
				</div>
			</AccordionItem>
		</Accordion>
	{/await}
{/if}
