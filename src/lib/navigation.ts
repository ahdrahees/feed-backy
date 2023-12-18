import { goto } from '$app/navigation';
import { checkUserType } from './api';

export const navigateAfterLogin = async () => {
	const result = await checkUserType();
	if (result === 'Brand') {
		goto('/brand');
	} else if (result === 'User') {
		goto('/user');
	} else {
		goto('/register');
	}
};
