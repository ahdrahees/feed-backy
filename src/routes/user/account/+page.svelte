<script lang="ts">
	import { queryUser } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Breadcrumb, BreadcrumbItem, Card, Badge } from 'flowbite-svelte';
	import type { QueryUser } from '../../../declarations/backend.did';
	import { convertNanosecondsToReadableDate } from '../../../stores/unix-to-date';
	import { onMount } from 'svelte';

	let userInfo: QueryUser = {
		id: BigInt(0),
		principal: '',
		balance: BigInt(0),
		name: '',
		totalFeedback: BigInt(0),
		lastFeedback: BigInt(0)
	};

	async function getUserInfo() {
		const resutl = await queryUser();
		if ('ok' in resutl) {
			userInfo = resutl.ok;
		} else if ('err' in resutl) {
			userInfo = {
				id: BigInt(0),
				principal: '',
				balance: BigInt(0),
				name: '',
				totalFeedback: BigInt(0),
				lastFeedback: BigInt(0)
			};
		}
	}
	onMount(async () => {
		await getUserInfo();
	});
</script>

<Breadcrumb class="bg-[#fff5f2] p-3 pl-5" aria-label="Default breadcrumb example">
	<BreadcrumbItem href="/user" home>Home</BreadcrumbItem>
	<BreadcrumbItem>Account</BreadcrumbItem>
</Breadcrumb>
{#if $authMethods.isAuthenticated}
	{#await getUserInfo() then _}
		<div class="flex justify-center h-[60vh] items-center">
			<Card class="bg-[#f4bdbd]" size="xl">
				<div class="flex justify-center">
					<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
						Account Info
					</h5>
				</div>
				<div class="mb-3">
					<Badge large color="green">Name</Badge>
					<span class="font-medium px-2">{userInfo.name}</span>
				</div>
				<div class="mb-3">
					<Badge large color="green">Principal</Badge>
					<span class="font-medium px-2">{userInfo.principal}</span>
				</div>
				<div class="mb-3">
					<Badge large border>Balance</Badge>
					<span class="font-medium px-2">{userInfo.balance.toString()}</span>
				</div>
				<div class="mb-3">
					<Badge large color="indigo">Total Feedbacks</Badge>
					<span class="font-medium px-2">{userInfo.totalFeedback}</span>
				</div>
				<div class="mb-3">
					<Badge large color="indigo">Last Feedback</Badge>
					<span class="font-medium px-2"
						>{convertNanosecondsToReadableDate(userInfo.lastFeedback.toString())}</span
					>
				</div>
			</Card>
		</div>
	{/await}
{/if}
