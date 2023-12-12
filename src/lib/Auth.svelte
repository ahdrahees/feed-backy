<script>
	import { authMethods } from "./auth.store";

    $: isAuthenticated = $authMethods.isAuthenticated
</script>

{#if isAuthenticated}
<button on:click={ async ()=> await authMethods.signOut()}>LogOut</button>
{:else} 
<button on:click={async () => await authMethods.signIn()}>Login</button>
{/if}
