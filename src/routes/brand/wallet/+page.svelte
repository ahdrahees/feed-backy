<script lang="ts">
	import { Breadcrumb, BreadcrumbItem } from 'flowbite-svelte';
	import { IconWallet } from '@dfinity/gix-components';
	import { Copy } from '@dfinity/gix-components';
	import { QRCode } from '@dfinity/gix-components';
	import { Card, Button } from 'flowbite-svelte';
	import { authMethods } from '$lib/auth.store';
	import { icpAccountAddress, icpBalanceOf, queryBrand, transferICP } from '$lib/api';
	import { GradientButton, Label, Input } from 'flowbite-svelte';
	import { Modal } from 'flowbite-svelte';
	import icplogo from '$lib/assets/ICPwhitelogo.svg';
	import { IconQRCodeScanner } from '@dfinity/gix-components';
	import { IconError } from '@dfinity/gix-components';
	import { QRCodeReaderModal } from '@dfinity/gix-components';
	import { toastsStore } from '@dfinity/gix-components';
	import { Modal as GixModal } from '@dfinity/gix-components';
	import type { Tokens } from '../../../declarations/backend.did';
	import { onMount } from 'svelte';
	import type { Account } from '../../../declarations/icp_ledger_canister/icp_ledger_canister.did';

	let receiveModal = false;
	let transferModal = false;

	type SubAccount = Uint8Array | number[];
	let icpWalletAddress = '';
	let account: Account;

	onMount(async () => {
		let result = await queryBrand();
		if ('ok' in result) {
			account = result.ok.account;
			await getMyWalletAddress();
		}
	});

	const toHexString = (subAccount: SubAccount) => {
		return Array.from(subAccount, function (byte) {
			return ('0' + (byte & 0xff).toString(16)).slice(-2);
		}).join('');
	};
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

	async function getMyWalletAddress() {
		icpWalletAddress = toHexString(await icpAccountAddress(account));
		await getCurrentBalance();
	}

	function shortenWalletAddress(address: string) {
		const firstSixChars = address.slice(0, 6);
		const lastFourChars = address.slice(-7);
		const middleEllipsis = '...';
		return firstSixChars + middleEllipsis + lastFourChars;
	}
	let currentBalance: number = 0;

	async function getCurrentBalance() {
		currentBalance = Number(await icpBalanceOf(account));
	}
	let amount: number;
	let address: string;
	let validAmountBool: boolean = true;
	let transferButton: boolean = true;
	let isValidAddress: boolean = true;

	let helperValidAmountBool: boolean = false;
	let helperIsValidAddress: boolean = false;

	function validateAmount() {
		validAmountBool = amount * 10 ** 8 < currentBalance;
		helperValidAmountBool = validAmountBool;
		transferButton = helperValidAmountBool && helperIsValidAddress ? false : true;
	}
	function validateAddress__() {
		isValidAddress = validateAddress(address);
		helperIsValidAddress = isValidAddress;
		transferButton = helperValidAmountBool && helperIsValidAddress ? false : true;
	}
	let detail: string = '';

	async function transferICPTo() {
		let to: number[] = fromHexString(address);
		let transferAmount: Tokens = { e8s: BigInt(amount * 10 ** 8) };
		let result = await transferICP(to, transferAmount);

		if ('ok' in result) {
			await getCurrentBalance();
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

<Breadcrumb aria-label="Solid background breadcrumb example" solid>
	<BreadcrumbItem href="/brand" home>Home</BreadcrumbItem>
	<BreadcrumbItem
		><div class="flex m-0"><IconWallet /><span class="px-2">Wallet</span></div></BreadcrumbItem
	>
</Breadcrumb>

{#if $authMethods.isAuthenticated}
	<!-- {#await getMyWalletAddress() then _} -->
	<div class="flex justify-center mt-5 mx-2">
		<Card size="xl" class="w-full">
			<div class="flex md:flex-row md:justify-between flex-col items-center">
				<div>
					<h5 class="mb-2 text-2xl font-semibold text-gray-900 dark:text-white">
						<div class="flex text-black text-2xl">
							<span class="mr-1"
								><svg
									height="30"
									xmlns="http://www.w3.org/2000/svg"
									xml:space="preserve"
									viewBox="0 0 360 360"
								>
									<style>
										.st2 {
											fill: url(#SVGID_00000124862415668660841950000003391418030906810246_);
										}
										.st3 {
											fill: url(#SVGID_00000122717112889356607870000008762198724658036354_);
										}
									</style>
									<g id="Token_Background">
										<linearGradient
											id="SVGID_1_"
											x1="17.42"
											x2="340.066"
											y1="64.563"
											y2="-59.596"
											gradientTransform="matrix(1 0 0 -1 0 182)"
											gradientUnits="userSpaceOnUse"
										>
											<stop offset="0" stop-color="#292a2e" />
											<stop offset="1" stop-color="#555" />
										</linearGradient>
										<circle cx="180" cy="180" r="180" fill="url(#SVGID_1_)" />
									</g>
									<g id="Infinity_Mark">
										<g id="Infinity_Mark_00000047779289644388080000000014977850130608891561_">
											<path
												fill="#29abe2"
												d="M254.8 217.4c-15.9 0-32.7-10.4-40.9-17.9-9-8.3-33.8-35.1-33.9-35.2-16.2-18.1-38.1-38.2-59.9-38.2-26.2 0-49.1 18.2-55.1 42.2.5-1.6 8.8-23.6 40.1-23.6 15.9 0 32.7 10.4 40.9 17.9 9 8.3 33.8 35.1 33.9 35.2 16.2 18.1 38.1 38.2 59.9 38.2 26.2 0 49.1-18.2 55.1-42.2-.4 1.5-8.8 23.6-40.1 23.6z"
											/>
											<linearGradient
												id="SVGID_00000155854593579107460200000017162200609671622831_"
												x1="149.498"
												x2="72.885"
												y1="228.805"
												y2="149.47"
												gradientUnits="userSpaceOnUse"
											>
												<stop offset=".22" stop-color="#ed1e79" />
												<stop offset=".892" stop-color="#522785" />
											</linearGradient>
											<path
												fill="url(#SVGID_00000155854593579107460200000017162200609671622831_)"
												d="M180 197.8c-.1-.1-7.2-7.8-15.2-16.2-4.3 5.1-10.5 12.1-17.7 18.4-13.3 11.7-22 14.1-27 14.1-18.7 0-34-14.8-34-33.1 0-18.1 15.2-33 34-33.1.7 0 1.5.1 2.5.2-5.6-2.2-11.6-3.6-17.5-3.6-31.3 0-39.6 22-40.1 23.6-1 4.1-1.6 8.4-1.6 12.8 0 30.3 25 55 56.2 55 13 0 27.6-6.7 42.6-19.8 7.1-6.2 13.2-12.9 17.9-18.2 0 0 0-.1-.1-.1z"
											/>
											<linearGradient
												id="SVGID_00000013896904071945135690000000165451973745158586_"
												x1="-313.26"
												x2="-389.873"
												y1="-296.506"
												y2="-375.841"
												gradientTransform="rotate(180 -51.404 -81.632)"
												gradientUnits="userSpaceOnUse"
											>
												<stop offset=".21" stop-color="#f15a24" />
												<stop offset=".684" stop-color="#fbb03b" />
											</linearGradient>
											<path
												fill="url(#SVGID_00000013896904071945135690000000165451973745158586_)"
												d="M180 164.2c.1.1 7.2 7.8 15.2 16.2 4.3-5.1 10.5-12.1 17.7-18.4 13.3-11.7 22-14.1 27-14.1 18.7 0 34 14.8 34 33.1 0 18.1-15.2 33-34 33.1-.7 0-1.5-.1-2.5-.2 5.6 2.2 11.6 3.6 17.5 3.6 31.3 0 39.6-22 40.1-23.6 1-4.1 1.6-8.4 1.6-12.8 0-30.3-25.4-55-56.6-55-13 0-27.2 6.7-42.2 19.8-7.1 6.2-13.2 12.9-17.9 18.2 0 0 0 .1.1.1z"
											/>
										</g>
									</g>
								</svg>
							</span>Internet Computer
						</div>
					</h5>
				</div>
				<div class="flex justify-center">
					<p class="mt-[10px] mr-1 p-o">{shortenWalletAddress(icpWalletAddress)}</p>
					<Copy value={icpWalletAddress} />
				</div>
			</div>
			<div class="mt-5 flex md:flex-row md:justify-between flex-col items-center">
				<p class="mb-3 text-4xl font-normal text-gray-700 dark:text-gray-400 leading-tight">
					{currentBalance / 10 ** 8} <span class="text-base">ICP</span>
				</p>
				<div class="flex justify-center flex-wrap">
					<GradientButton
						class="px-14 py-3 m-1"
						shadow
						color="purple"
						on:click={() => (receiveModal = true)}>Receive</GradientButton
					>
					<Button
						class="px-14 border-2 m-1"
						outline
						color="purple"
						on:click={() => (transferModal = true)}>Transfer</Button
					>
				</div>
			</div>
		</Card>
	</div>
	<!-- {/await} -->
	<Modal title="Receive" bind:open={receiveModal} color="purple" size="xs" autoclose>
		<div class="m-14">
			<QRCode value={icpWalletAddress} ariaLabel="ICP wallet address">
				<img
					width="40"
					role="presentation"
					src={icplogo}
					alt="Test logo"
					loading="lazy"
					slot="logo"
				/>
			</QRCode>
		</div>

		<p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">ICP Address</p>
		<div class="flex justify-center">
			<p class=" mr-1 break-all">{icpWalletAddress}</p>
			<Copy value={icpWalletAddress} />
		</div>
		<svelte:fragment slot="footer">
			<GradientButton
				class="px-14 py-3 m-1 w-full"
				shadow
				color="purple"
				on:click={async () => await getCurrentBalance()}>Finish</GradientButton
			>
		</svelte:fragment>
	</Modal>

	<Modal title="Transfer ICP" bind:open={transferModal} color="purple" size="xs" autoclose>
		<Label class="space-y-2">
			<span>Destination</span>
			<Input
				on:input={validateAddress__}
				on:change={validateAddress__}
				bind:value={address}
				type="text"
				placeholder="Address"
				class="bg-purple-200 py-4"
			>
				<a href=" " slot="right" on:click={() => (visible = true)}><IconQRCodeScanner /></a>
			</Input>
		</Label>
		{#if !isValidAddress}
			<p>
				<IconError /><span>Please enter a valid address.</span>
			</p>
		{/if}

		<div class="mb-6">
			<div class="flex justify-between">
				<Label for="default-input" class=" mb-2 inline-block">Amount</Label>
				<a
					href=" "
					on:click={() => (amount = currentBalance / 10 ** 8 - 0.0001)}
					on:click={validateAmount}>Max</a
				>
			</div>
			<Input
				on:input={validateAmount}
				on:change={validateAmount}
				bind:value={amount}
				type="number"
				placeholder="Amount"
				class="bg-purple-200 py-4"
			/>
		</div>
		{#if !validAmountBool}
			<div class="flex">
				<p>
					<IconError /><span>Sorry, there are not enough funds in this account. </span>
				</p>
			</div>
		{/if}
		<p class="m-1 text-sm leading-relaxed text-gray-500 dark:text-gray-400">
			Transaction Fee (billed to source)
			<br />
			0.00010000 ICP
		</p>
		<svelte:fragment slot="footer">
			<GradientButton
				disabled={transferButton}
				class="px-14 py-3 m-1 w-full"
				shadow
				color="purple"
				on:click={async () => await transferICPTo()}>Transfer</GradientButton
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
					validateAddress__();
				}}
				on:nnsQRCodeError={error}
			/>
		{/if}
	</GixModal>
{/if}

<style lang="scss" global>
	@import '../../../../node_modules/@dfinity/gix-components/dist/styles/global.scss';
</style>
