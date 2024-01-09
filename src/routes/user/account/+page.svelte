<script lang="ts">
	import { queryUser, withdrawRewardPoints } from '$lib/api';
	import { authMethods } from '$lib/auth.store';
	import { Breadcrumb, BreadcrumbItem, Card, Badge } from 'flowbite-svelte';
	import type { QueryUser } from '../../../declarations/backend.did';
	import { convertNanosecondsToReadableDate } from '../../../stores/unix-to-date';
	import { Modal, Label, Input } from 'flowbite-svelte';
	import { GradientButton } from 'flowbite-svelte';
	import {
		IconQRCodeScanner,
		IconError,
		toastsStore,
		QRCodeReaderModal
	} from '@dfinity/gix-components';
	import { onMount } from 'svelte';
	import { Modal as GixModal } from '@dfinity/gix-components';

	let userInfo: QueryUser = {
		id: BigInt(0),
		principal: '',
		balance: BigInt(0),
		name: '',
		totalFeedback: BigInt(0),
		lastFeedback: BigInt(0)
	};
	let openWithdrawModel = false;

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

	let isValidAddress: boolean = true;
	let helperIsValidAddress: boolean = false;
	let address: string;

	let transferButtonDisable: boolean = true;

	const fromHexString = (hex: string) => {
		if (hex.substr(0, 2) === '0x') hex = hex.substr(2);
		for (var bytes = [], c = 0; c < hex.length; c += 2) bytes.push(parseInt(hex.substr(c, 2), 16));
		return bytes;
	};
	const isHex = (h: string) => {
		var regexp = /^[0-9a-fA-F]+$/;
		return regexp.test(h);
	};
	const validateAddress = (a: string) => {
		return isHex(a) && a.length === 64;
	};

	function validateUserInputAddress() {
		isValidAddress = validateAddress(address);
		helperIsValidAddress = isValidAddress;
		transferButtonDisable = helperIsValidAddress ? false : true;
	}

	async function withdrawRewardPointsToIcp() {
		let to: number[] = fromHexString(address);

		let result = await withdrawRewardPoints(to);
		if ('ok' in result) {
			await getUserInfo();
		} else if ('err' in result) {
			console.log(result.err);
			alert('Transfer Error : ' + result.err);
		}
	}

	// QR CODE Scanner
	let visible = false;
	// let visible = false;
	let renderQRCodeReader = false;
	let qrCode: any = undefined;

	const close = () => {
		visible = false;
		renderQRCodeReader = false;
	};

	const error = () =>
		toastsStore.show({
			text: 'QR code error',
			level: 'error'
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
					<h5 class="mb-2 text-2xl font-bold tracking-tight dark:text-white">
						<span class=" text-black text-xl">Account Info</span>
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

				<GradientButton color="pinkToOrange" on:click={() => (openWithdrawModel = true)}
					>Withdraw Points</GradientButton
				>
			</Card>
		</div>
	{/await}

	<Modal
		color="primary"
		title="Withdraw Reward Points To ICP"
		size="xs"
		bind:open={openWithdrawModel}
		autoclose
	>
		<Label class="space-y-2">
			<span>Destination</span>
			<Input
				on:input={validateUserInputAddress}
				on:change={validateUserInputAddress}
				bind:value={address}
				type="text"
				placeholder="Address"
				class=" bg-inherit py-4"
			>
				<a href=" " slot="right" on:click={() => (visible = true)}><IconQRCodeScanner /></a>
			</Input>
		</Label>
		{#if !isValidAddress}
			<p>
				<IconError /><span>Please enter a valid address.</span>
			</p>
		{/if}
		<p class="m-1 text-base leading-relaxed text-gray-500 dark:text-gray-400">
			You will receive {(Number(userInfo.balance) / 10) * 0.005} ICP
		</p>
		<svelte:fragment slot="footer">
			<GradientButton
				color="pinkToOrange"
				disabled={transferButtonDisable}
				on:click={async () => await withdrawRewardPointsToIcp()}
				>Withdraw & Transfer ICP</GradientButton
			>
		</svelte:fragment>
	</Modal>

	<GixModal {visible} on:nnsClose={close} on:introend={() => (renderQRCodeReader = true)}>
		<svelte:fragment slot="title">Scan QR Code</svelte:fragment>

		{#if renderQRCodeReader}
			<QRCodeReaderModal
				on:nnsQRCode={({ detail: value }) => {
					const urlParams = new URLSearchParams(window.location.search);
					if (urlParams.has('skip')) {
						return;
					}
					close();
					qrCode = value;
					// address = qrCode ?? '';
					address = qrCode?.toString() ?? '';
					validateUserInputAddress();
				}}
				on:nnsQRCodeError={error}
			/>
		{/if}
	</GixModal>
{/if}

<style lang="scss" global>
	@import '../../../../node_modules/@dfinity/gix-components/dist/styles/global.scss';
</style>
