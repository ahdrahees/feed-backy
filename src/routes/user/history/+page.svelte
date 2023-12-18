<script lang="ts">
	import { getAllFeedbackAndPost } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import type { FeedbackAndPost } from '../../../declarations/backend.did';
	import { Card, Badge, Spinner } from 'flowbite-svelte';
	import { convertNanosecondsToReadableDate } from '../../../stores/unix-to-date';

	let feedbackAndPost: FeedbackAndPost[] = [];

	async function getHistory() {
		const result = await getAllFeedbackAndPost();
		console.log(result);
		if ('ok' in result) {
			feedbackAndPost = result.ok;
		} else if ('err' in result) {
			feedbackAndPost = [];
		}
	}
</script>

{#if $authMethods.isAuthenticated}
	{#await getHistory()}
		<div class="flex h-screen justify-center items-center">
			<Spinner size={'12'} />
		</div>
	{:then _}
		<div class="flex flex-wrap justify-evenly">
			{#each feedbackAndPost as feedPost}
				<Card
					size="md"
					class={feedPost.feedback.isAIvalidationPass
						? 'm-3 bg-[#ffcab9] w-full'
						: 'm-3 bg-[#ffcab9] w-full'}
				>
					<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
						{feedPost.post.brandName}
					</h5>

					{#each feedPost.post.question as question, index}
						<p
							class="bg-[#FFEADD] rounded-lg p-3 mb-3 text-base font-normal text-gray-700 dark:text-gray-400 leading-tight"
						>
							<Badge large class="font-semibold me-1" rounded color="purple"
								>{'Question ' + (index + 1)}</Badge
							>
							{question}
						</p>
						<div class="mb-6">
							<p
								class="bg-[#FCAEAE] rounded-lg p-3 mb-3 text-base font-normal text-gray-700 dark:text-gray-400 leading-tight"
							>
								<Badge large class="font-semibold me-1" rounded color="dark"
									>{'Feedback ' + (index + 1)}</Badge
								>
								{feedPost.feedback.feedback[index]}
							</p>
						</div>
					{/each}

					<div class="flex justify-between">
						<p class="mt-[1.375rem] font-light text-sm">
							{convertNanosecondsToReadableDate(feedPost.feedback.created.toString())}
						</p>
						{#if feedPost.feedback.isAIvalidationPass}
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
									<path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16" />
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
	{/await}
{/if}
