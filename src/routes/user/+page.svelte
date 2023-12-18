<script lang="ts">
	import { getAllUnfilledPosts } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Card, Spinner, Badge, GradientButton } from 'flowbite-svelte';
	import type { QueryPost } from '../../declarations/backend.did';
	import { ArrowRightOutline } from 'flowbite-svelte-icons';
	import { convertNanosecondsToReadableDate } from '../../stores/unix-to-date';
	import { postMemory } from '../../stores/post-memory';
	import { goto } from '$app/navigation';

	let posts: Array<QueryPost> = [];

	async function getUnfilledPosts() {
		const result = await getAllUnfilledPosts();
		if ('ok' in result) {
			console.log(result.ok);
			posts = result.ok;
		} else if ('err' in result) {
			console.log(result.err);
			posts = [];
		}
	}

	function forwardToFeedbackPage(post: QueryPost) {
		postMemory.update((value) => (value = post));
		goto('/user/feedback');
	}
</script>

{#if $authMethods.isAuthenticated}
	{#await getUnfilledPosts()}
		<div class="text-center"><Spinner color="purple" size={'12'} /></div>
	{:then _}
		<div class="flex flex-col items-center">
			{#each posts as post}
				<Card size="md" class="m-3 bg-[#ffcab9] w-full">
					<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
						{post.brandName}
					</h5>

					{#each post.question as question, index}
						<p
							class="bg-[#ffe0d6] rounded-lg p-3 mb-3 text-base font-normal text-gray-700 dark:text-gray-400 leading-tight"
						>
							<Badge large class="font-semibold me-1" rounded color="purple"
								>{'Question ' + (index + 1)}</Badge
							>

							{question}
						</p>
					{/each}
					<div class="flex justify-between">
						<GradientButton
							class="my-3 w-fit"
							color="pinkToOrange"
							on:click={() => {
								forwardToFeedbackPage(post);
							}}>Feedback <ArrowRightOutline class="w-3.5 h-3.5 ms-2 text-white" /></GradientButton
						>
						<p class="mt-[1.375rem] font-light text-sm">
							{convertNanosecondsToReadableDate(post.created.toString())}
						</p>
					</div>
				</Card>{/each}
		</div>
	{/await}
{/if}
