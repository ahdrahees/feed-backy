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
</script>

<Navbar let:NavContainer color="primary">
	<NavContainer class="border px-5 py-2 rounded-lg bg-white dark:bg-gray-600">
		<NavBrand href="/user">
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
			<span class="ms-1 self-center whitespace-nowrap text-2xl font-semibold">Feed Backy</span>
		</NavBrand>
		<NavHamburger />
		<NavUl>
			<NavLi href="/user/account"
				><Button class="border-0 bg-transparent px-0 hover:bg-transparent" color="alternative"
					>Account</Button
				></NavLi
			>
			<NavLi href="/user/history"
				><Button class="border-0 bg-transparent px-0 hover:bg-transparent" color="alternative"
					>History</Button
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
	</NavContainer>
</Navbar>
<slot />
