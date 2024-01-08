import { get } from 'svelte/store';
import type {
	AFeedbackAndPostResult,
	APostAndFeedbacksResult,
	AllClosedPostsResult,
	AllFeedbackAndPostResult,
	AllOpenPostsResult,
	AllPostAndFeedbacksResult,
	AllUnfilledPostsResult,
	BrandPostsResult,
	BrandRegisterArg,
	FeedbackId__1,
	FeedbackResult,
	PostResult,
	QueryBrandResult,
	QueryPostResult,
	QueryUserResult,
	RegisterResult,
	Registration,
	Result,
	Result_1,
	Tokens,
	TransferResult,
	UserFeedbacksResult
} from '../declarations/backend.did';
import { authMethods } from './auth.store';
import type {
	Account,
	AccountIdentifier,
	Icrc1Tokens
} from '../declarations/icp_ledger_canister/icp_ledger_canister.did';

export const addBalance = async (add: bigint): Promise<Result_1> => {
	const actor = get(authMethods).actor;
	return actor.addBalance(add);
};

export const checkMyBalance = async (): Promise<bigint> => {
	const actor = get(authMethods).actor;
	return actor.checkMyBalance();
};
export const checkUserType = async (): Promise<string> => {
	const actor = get(authMethods).actor;
	return actor.checkUserType();
};

export const getAFeedbackAndPost = async (fbId: FeedbackId__1): Promise<AFeedbackAndPostResult> => {
	const actor = get(authMethods).actor;
	return actor.getAFeedbackAndPost(fbId);
};

export const getAPostAndFeedbacks = async (postId: bigint): Promise<APostAndFeedbacksResult> => {
	const actor = get(authMethods).actor;
	return actor.getAPostAndFeedbacks(postId);
};

export const getAllClosedPosts = async (): Promise<AllClosedPostsResult> => {
	const actor = get(authMethods).actor;
	return actor.getAllClosedPosts();
};

export const getAllFeedbackAndPost = async (): Promise<AllFeedbackAndPostResult> => {
	const actor = get(authMethods).actor;
	return actor.getAllFeedbackAndPost();
};

export const getAllOpenPosts = async (): Promise<AllOpenPostsResult> => {
	const actor = get(authMethods).actor;
	return actor.getAllOpenPosts();
};

export const getAllPostAndFeedbacks = async (): Promise<AllPostAndFeedbacksResult> => {
	const actor = get(authMethods).actor;
	return actor.getAllPostAndFeedbacks();
};

export const getAllUnfilledPosts = async (): Promise<AllUnfilledPostsResult> => {
	const actor = get(authMethods).actor;
	return actor.getAllUnfilledPosts();
};

export const getBrandBasicInfo = async (): Promise<Result> => {
	const actor = get(authMethods).actor;
	return actor.getBrandBasicInfo();
};

export const getFeedbacksByUser = async (): Promise<UserFeedbacksResult> => {
	const actor = get(authMethods).actor;
	return actor.getFeedbacksByUser();
};

export const getPost = async (postId: bigint): Promise<QueryPostResult> => {
	const actor = get(authMethods).actor;
	return actor.getPost(postId);
};

export const getPostsByBrand = async (): Promise<BrandPostsResult> => {
	const actor = get(authMethods).actor;
	return actor.getPostsByBrand();
};

export const myWalletAddress = async (): Promise<Uint8Array | number[]> => {
	const actor = get(authMethods).actor;
	return actor.myWalletAddress();
};

export const post = async (questions: Array<string>, reward: bigint): Promise<PostResult> => {
	const actor = get(authMethods).actor;
	return actor.post(questions, reward);
};

export const postfeedback = async (
	postId: bigint,
	feedbacks: Array<string>,
	isAIValidationPass: boolean
): Promise<FeedbackResult> => {
	const actor = get(authMethods).actor;
	return actor.postfeedback(postId, feedbacks, isAIValidationPass);
};

export const queryBrand = async (): Promise<QueryBrandResult> => {
	const actor = get(authMethods).actor;
	return actor.queryBrand();
};

export const queryUser = async (): Promise<QueryUserResult> => {
	const actor = get(authMethods).actor;
	return actor.queryUser();
};

export const register = async (args: Registration): Promise<RegisterResult> => {
	const actor = get(authMethods).actor;
	return actor.register(args);
};

export const registerBrand = async (args: BrandRegisterArg): Promise<RegisterResult> => {
	const actor = get(authMethods).actor;
	return actor.registerBrand(args);
};

export const registerUser = async (name: string): Promise<RegisterResult> => {
	const actor = get(authMethods).actor;
	return actor.registerUser(name);
};

export const transferICP = async (
	to: Uint8Array | number[],
	amount: Tokens
): Promise<TransferResult> => {
	const actor = get(authMethods).actor;
	return actor.transferICP(to, amount);
};

export const withdrawRewardPoints = async (to: Uint8Array | number[]): Promise<TransferResult> => {
	const actor = get(authMethods).actor;
	return actor.withdrawRewardPoints(to);
};

export const icpBalanceOf = async (account: Account): Promise<Icrc1Tokens> => {
	const icpLedger = get(authMethods).icpLedger;
	return icpLedger.icrc1_balance_of(account);
};

export const icpAccountAddress = async (account: Account): Promise<AccountIdentifier> => {
	const icpLedger = get(authMethods).icpLedger;
	return icpLedger.account_identifier(account);
};
