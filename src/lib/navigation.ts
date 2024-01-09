import { goto } from '$app/navigation';
import { addressStoreUpdate, balanceStoreUpdate } from '../stores/address-balance-store';
import { checkUserType } from './api';

export const navigateAfterLogin = async () => {
	const result = await checkUserType();
	if (result === 'Brand') {
		goto('/brand');
		await balanceStoreUpdate();
		await addressStoreUpdate();
	} else if (result === 'User') {
		goto('/user');
	} else {
		goto('/register');
	}
};
