<script>
	import { authMethods } from '$lib/auth.store';
	import { GradientButton } from 'flowbite-svelte';
</script>

<div class="flex justify-center h-[70vh] items-center flex-col">
	<h1 class="text-8xl m-5 max-sm:text-5xl">
		Welcome to <span
			class="bg-gradient-to-r from-blue-600 via-green-500 to-indigo-400 inline-block text-transparent bg-clip-text"
			>Feedbacky</span
		>
	</h1>
	<p class="mb-5 text-lg max-sm:text-base">An AI driven platform for both user and brands</p>
	{#if $authMethods.isAuthenticated}
		<GradientButton
			size="xl"
			class="text-2xl font-bold max-sm:text-lg rounded-3xl w-fit"
			on:click={async () => await authMethods.signOut()}
			color="red">Log out</GradientButton
		>
	{:else}
		<GradientButton
			size="xl"
			class="text-2xl max-sm:text-lg rounded-3xl w-fit"
			on:click={async () => await authMethods.signIn()}
			color="greenToBlue">Log in</GradientButton
		>
	{/if}
</div>

<h2 class="text-2xl mt-10 text-center mb-5 font-bold">Key Features</h2>
<div class="flex justify-center flex-wrap max-[600px]:justify-start leading-8">
	<div class="m-5 border-black border-2 p-5 w-[300px] rounded-xl">
		<h3 class="text-xl font-semibold">For Brands:</h3>
		<ul class="ml-5 list-disc">
			<li>AI-powered question generation</li>
			<li>AI validation for feedbacks</li>
			<li>Genuine user insights</li>
		</ul>
	</div>
	<div class="m-5 border-black border-2 p-5 w-[300px] rounded-xl">
		<h3 class="text-xl font-semibold">For Users:</h3>
		<ul class="ml-5 list-disc">
			<li>Rewarding feedbacks</li>
			<li>Shape brands you love</li>
			<li>Trusted AI validation</li>
		</ul>
	</div>
</div>

<style>
</style>
