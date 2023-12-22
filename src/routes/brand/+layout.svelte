<script>
	import '../../app.pcss';

	import { authMethods } from '$lib/auth.store';
	import {
		Navbar,
		NavBrand,
		NavLi,
		NavUl,
		NavHamburger,
		GradientButton,
		Button
	} from 'flowbite-svelte';

	async function callsignOut() {
		await authMethods.signOut();
	}
</script>

<Navbar>
	<NavBrand href="/brand">
		<svg
			xmlns="http://www.w3.org/2000/svg"
			width="30"
			height="30"
			fill="currentColor"
			class="bi bi-pencil-square"
			viewBox="0 0 16 16"
		>
			<path
				d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"
			/>
			<path
				fill-rule="evenodd"
				d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5z"
			/>
		</svg>
		<span class="px-2 self-center whitespace-nowrap text-3xl font-bold dark:text-white"
			>Feed Backy</span
		>
	</NavBrand>
	<NavHamburger />
	<NavUl>
		<NavLi href="/brand"
			><Button class="border-0 bg-transparent px-0 hover:bg-transparent" color="alternative"
				>Home</Button
			></NavLi
		>
		<NavLi href="/brand/generate"
			><Button
				class="border-0 bg-transparent px-0 hover:bg-transparent font-medium bg-gradient-to-r from-[#6000ff] via-[#00d6a8] to-[#a66fff] inline-block text-transparent bg-clip-text"
				color="alternative">Generate Post with AI</Button
			></NavLi
		>
		<NavLi href="/brand/newpost"
			><Button class="border-0 bg-transparent px-0 hover:bg-transparent" color="alternative"
				>Create new post</Button
			></NavLi
		>
		{#if $authMethods.isAuthenticated}
			<NavLi on:click={async () => await authMethods.signOut()}
				><GradientButton color="red">Log out</GradientButton></NavLi
			>
		{:else}
			<NavLi on:click={async () => await authMethods.signIn()}
				><GradientButton color="blue">Log in</GradientButton></NavLi
			>
		{/if}
	</NavUl>
</Navbar>
<slot />
