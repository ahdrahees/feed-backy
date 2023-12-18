<script lang="ts">
	import type { BrandRegisterArg, Registration } from '../../declarations/backend.did';
	import { checkUserType, register } from '$lib/api';
	import { goto } from '$app/navigation';
	import { authMethods } from '$lib/auth.store';
	import { Circle3 } from 'svelte-loading-spinners';
	import { Card, Label, Input, Select, GradientButton } from 'flowbite-svelte';

	type RegistrationOption = 'Brand' | 'User';

	let selectedRegistrationType: RegistrationOption;

	let brandName = '';
	let userName = '';
	let message = '';
	$: isValidInput = false;
	$: registerWait = false;

	let regOptions = [
		{ value: 'Brand', name: 'Brand' },
		{ value: 'User', name: 'User' }
	];
	let productOrServiceCategory = '';
	let targetAudience = '';
	let industry = '';

	function validateInput() {
		const registerButton = document.getElementById('register-button') as HTMLButtonElement;

		if (selectedRegistrationType === 'Brand') {
			if (brandName.length < 3) {
				registerButton.disabled = true;
				message = 'Please fill atleast 3 characters for Brand Name';
				isValidInput = false;
				return message;
			}
			if (industry.length < 3) {
				registerButton.disabled = true;
				message = 'Please fill atleast 3 characters for Industry';
				isValidInput = false;
				return message;
			}
			if (productOrServiceCategory.length < 3) {
				registerButton.disabled = true;
				message = 'Please fill atleast 3 characters for Product / Service Category';
				isValidInput = false;
				return message;
			}
			if (targetAudience.length < 3) {
				registerButton.disabled = true;
				message = 'Please fill atleast 3 characters for Target Audience';
				isValidInput = false;
				return message;
			}
		} else if (selectedRegistrationType === 'User') {
			if (userName.length < 6) {
				registerButton.disabled = true;
				message = 'Please fill atleast 6 characters';
				isValidInput = false;
				return message;
			}
		}
		registerButton.disabled = false;
		isValidInput = true;
		message = '';
		return message;
	}

	async function callRegister() {
		let brandRegisterArg: BrandRegisterArg = {
			productOrServiceCategory,
			targetAudience,
			brandName,
			industry
		};
		let arg: Registration;
		if (!$authMethods.isAuthenticated) {
			alert('Please Login with Internet Identity First');
			return 0;
		}

		if (selectedRegistrationType === 'Brand') {
			if (brandName.length < 3) {
				alert('Please fill atleast 3 characters for Brand Name');
				return 0;
			}
			if (industry.length < 3) {
				alert('Please fill atleast 3 characters for Industry');
				return 0;
			}
			if (productOrServiceCategory.length < 3) {
				alert('Please fill atleast 3 characters for Product / Service Category');
				return 0;
			}
			if (targetAudience.length < 3) {
				alert('Please fill atleast 3 characters for Target Audience');
				return 0;
			}

			arg = { Brand: brandRegisterArg };
			console.log(brandRegisterArg);
		} else if (selectedRegistrationType === 'User') {
			if (userName.length < 6) {
				alert('Please fill atleast 6 characters');
				return 0;
			}
			arg = { User: userName };
		} else {
			alert('Please select Brand or User');
			return 0;
		}

		registerWait = true;
		const result = await register(arg);

		if ('ok' in result) {
			const usertype: string = await checkUserType();
			if (usertype === 'Brand') {
				goto('/brand');
			} else if (usertype === 'User') {
				goto('/user');
			} else {
				goto('/register');
			}
		} else if ('err' in result) {
			alert('Error: ' + result.err);
		}
		registerWait = false;
	}
</script>

<div class="bg-[#d7bfff]">
	<div class="flex justify-end">
		{#if $authMethods.isAuthenticated}
			<GradientButton class="m-5" on:click={async () => await authMethods.signOut()} color="red"
				>Log out</GradientButton
			>
		{:else}
			<GradientButton class="m-5" on:click={async () => await authMethods.signIn()} color="blue"
				>Log in</GradientButton
			>
		{/if}
	</div>

	<div class="flex justify-center h-screen items-center">
		<Card class="w-full max-w-md bg-[#d9c8f6]">
			<form class="flex flex-col space-y-6" action="/">
				<h3 class="text-xl font-semibold text-gray-900 dark:text-white">Please register as</h3>
				<Label class="font-semibold">
					Select an option
					<Select
						class="mt-2 font-semibold text-lg"
						items={regOptions}
						bind:value={selectedRegistrationType}
					/>
				</Label>
				{#if selectedRegistrationType === 'User'}
					<div class="mb-6">
						<Label
							for="default-input"
							class={isValidInput
								? 'block mb-2 font-semibold text-md'
								: 'text-lg font-bold text-red-500 block mb-2'}>Name</Label
						>
						<Input
							bind:value={userName}
							on:input={validateInput}
							class={isValidInput
								? 'font-medium'
								: 'font-medium  ring ring-red-500 ring-offset-4 ring-offset-red-300'}
							id="default-input"
							placeholder="Name"
						/>
					</div>
					<div class="text-red-500">
						{message}
					</div>
				{:else if selectedRegistrationType === 'Brand'}
					<div class="mb-6">
						<Label
							for="default-input"
							class={isValidInput || !message.includes('Brand Name')
								? 'block mb-2 font-semibold text-md'
								: 'text-lg font-bold text-red-500 block mb-2'}>Brand Name</Label
						>
						<Input
							bind:value={brandName}
							on:input={validateInput}
							class={isValidInput || !message.includes('Brand Name')
								? 'font-medium'
								: 'font-medium  ring ring-red-500 ring-offset-4 ring-offset-red-300'}
							id="default-input"
							placeholder="Brand Name"
						/>
					</div>
					<div class="mb-6">
						<Label
							for="default-input"
							class={isValidInput || !message.includes('Industry')
								? 'block mb-2 font-semibold text-md'
								: 'text-lg font-bold text-red-500 block mb-2'}>Industry / Vertical</Label
						>
						<Input
							bind:value={industry}
							on:input={validateInput}
							class={isValidInput || !message.includes('Industry')
								? 'font-medium'
								: 'font-medium  ring ring-red-500 ring-offset-4 ring-offset-red-300'}
							id="default-input"
							placeholder="Brand Name"
						/>
					</div>
					<div class="mb-6">
						<Label
							for="default-input"
							class={isValidInput || !message.includes('Product / Service Category')
								? 'block mb-2 font-semibold text-md'
								: 'text-lg font-bold text-red-500 block mb-2'}>Product / Service Category</Label
						>
						<Input
							bind:value={productOrServiceCategory}
							on:input={validateInput}
							class={isValidInput || !message.includes('Product / Service Category')
								? 'font-medium'
								: 'font-medium  ring ring-red-500 ring-offset-4 ring-offset-red-300'}
							id="default-input"
							placeholder="Brand Name"
						/>
					</div>
					<div class="mb-6">
						<Label
							for="default-input"
							class={isValidInput || !message.includes('Target Audience')
								? 'block mb-2 font-semibold text-md'
								: 'text-lg font-bold text-red-500 block mb-2'}>Target Audience</Label
						>
						<Input
							bind:value={targetAudience}
							on:input={validateInput}
							class={isValidInput || !message.includes('Target Audience')
								? 'font-medium'
								: 'font-medium  ring ring-red-500 ring-offset-4 ring-offset-red-300'}
							id="default-input"
							placeholder="Brand Name"
						/>
					</div>
					<div class="text-red-500">
						{message}
					</div>
				{/if}

				<div class="col py-2">
					{#if registerWait}
						<div class="flex justify-center">
							<Circle3 />
						</div>
					{:else}
						<GradientButton
							on:click={async () => {
								await callRegister();
							}}
							class="w-full"
							color="purpleToBlue"
							type="submit"
							id="register-button">Register</GradientButton
						>
					{/if}
				</div>
			</form>
		</Card>
	</div>
</div>
