export function calculatePostCostInICP(questionNos: number, feedbacksNos: number): number {
	// let icpRewardPerFeedback = 0.005;
	// let icpFeePerFeedback = 0.00166666;
	// let icpCostPerFeedback = 0.00666666;

	let decimals = 10 ** 8;
	let icpRewardPerFeedback = 500_000;
	let icpFeePerFeedback = 166_666;
	let icpCostPerFeedback = 666_666;

	return questionNos * feedbacksNos * icpCostPerFeedback;
}
