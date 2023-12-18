import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AFeedbackAndPostResult = { 'ok' : FeedbackAndPost } |
  {
    'err' : { 'AnonymousNotAllowed' : null } |
      { 'BrandNotFound' : null } |
      { 'OwnerNotFound' : null } |
      { 'PostNotFound' : null } |
      { 'FeedbackNotInYourList' : null } |
      { 'UserNotFound' : null } |
      { 'TimeRemaining' : bigint }
  };
export type APostAndFeedbacksResult = { 'ok' : PostAndFeedbacks } |
  { 'err' : PostAndFeedbacksError };
export type AllClosedPostsResult = { 'ok' : Array<QueryPost> } |
  { 'err' : Error };
export type AllFeedbackAndPostResult = { 'ok' : Array<FeedbackAndPost> } |
  { 'err' : Error };
export type AllOpenPostsResult = { 'ok' : Array<QueryPost> } |
  { 'err' : Error };
export type AllPostAndFeedbacksResult = { 'ok' : Array<PostAndFeedbacks> } |
  { 'err' : PostAndFeedbacksError };
export type AllUnfilledPostsResult = { 'ok' : Array<QueryPost> } |
  { 'err' : Error };
export interface BrandBasicInfo {
  'productOrServiceCategory' : string,
  'targetAudience' : string,
  'brandName' : string,
  'industry' : string,
}
export type BrandPostsResult = { 'ok' : Array<QueryPost> } |
  { 'err' : Error };
export interface BrandRegisterArg {
  'productOrServiceCategory' : string,
  'targetAudience' : string,
  'brandName' : string,
  'industry' : string,
}
export type Error = { 'AnonymousNotAllowed' : null } |
  { 'BrandNotFound' : null } |
  { 'OwnerNotFound' : null } |
  { 'PostNotFound' : null } |
  { 'UserNotFound' : null } |
  { 'TimeRemaining' : bigint };
export interface Feedback {
  'userName' : string,
  'created' : bigint,
  'isAIvalidationPass' : boolean,
  'feedback' : Array<string>,
  'feedbackId' : FeedbackId,
  'postId' : bigint,
}
export interface FeedbackAndPost { 'post' : QueryPost, 'feedback' : Feedback }
export type FeedbackError = { 'NoSpotLeft' : null } |
  { 'AnonymousNotAllowed' : null } |
  { 'AlreadyFeedbacked' : null } |
  { 'BrandNotFound' : null } |
  { 'OwnerNotFound' : null } |
  { 'PostNotFound' : null } |
  { 'UserNotFound' : null } |
  { 'TimeRemaining' : bigint };
export type FeedbackId = bigint;
export type FeedbackId__1 = bigint;
export type FeedbackResult = { 'ok' : null } |
  { 'err' : FeedbackError };
export interface PostAndFeedbacks {
  'post' : QueryPost,
  'feedbacks' : Array<Feedback>,
}
export type PostAndFeedbacksError = { 'AnonymousNotAllowed' : null } |
  { 'BrandNotFound' : null } |
  { 'OwnerNotFound' : null } |
  { 'PostBelongsTo' : [PostId, string] } |
  { 'PostNotFound' : null } |
  { 'NotABrandOwner' : null } |
  { 'UserNotFound' : null } |
  { 'TimeRemaining' : bigint };
export type PostError = { 'LowBalance' : bigint } |
  { 'AnonymousNotAllowed' : null } |
  { 'BrandNotFound' : null } |
  { 'OwnerNotFound' : null } |
  { 'Reward_Should_Above_10' : null } |
  { 'PostNotFound' : null } |
  { 'UserNotFound' : null } |
  { 'TimeRemaining' : bigint };
export type PostId = bigint;
export type PostResult = { 'ok' : null } |
  { 'err' : PostError };
export interface QueryBrand {
  'id' : bigint,
  'principal' : string,
  'productOrServiceCategory' : string,
  'balance' : bigint,
  'name' : string,
  'targetAudience' : string,
  'totalPosts' : bigint,
  'lastPost' : bigint,
  'industry' : string,
}
export type QueryBrandError = { 'AnonymousNotAllowed' : null } |
  { 'BrandNotFound' : null } |
  { 'OwnerNotFound' : null } |
  { 'PostNotFound' : null } |
  { 'NotABrandOwner' : null } |
  { 'UserNotFound' : null } |
  { 'TimeRemaining' : bigint };
export type QueryBrandResult = { 'ok' : QueryBrand } |
  { 'err' : QueryBrandError };
export interface QueryPost {
  'created' : bigint,
  'filledspot' : bigint,
  'question' : Array<string>,
  'owner' : string,
  'spotLeft' : bigint,
  'totalspot' : bigint,
  'rewardLeft' : bigint,
  'brandName' : string,
  'postId' : bigint,
}
export type QueryPostResult = { 'ok' : QueryPost } |
  { 'err' : Error };
export interface QueryUser {
  'id' : bigint,
  'principal' : string,
  'balance' : bigint,
  'name' : string,
  'totalFeedback' : bigint,
  'lastFeedback' : bigint,
}
export type QueryUserResult = { 'ok' : QueryUser } |
  { 'err' : Error };
export type RegisterResult = { 'ok' : null } |
  { 'err' : string };
export type Registration = { 'User' : string } |
  { 'Brand' : BrandRegisterArg };
export type Result = { 'ok' : BrandBasicInfo } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export type UserFeedbacksResult = { 'ok' : Array<Feedback> } |
  { 'err' : Error };
export interface _SERVICE {
  'addBalance' : ActorMethod<[bigint], Result_1>,
  'checkMyBalance' : ActorMethod<[], bigint>,
  'checkUserType' : ActorMethod<[], string>,
  'getAFeedbackAndPost' : ActorMethod<[FeedbackId__1], AFeedbackAndPostResult>,
  'getAPostAndFeedbacks' : ActorMethod<[bigint], APostAndFeedbacksResult>,
  'getAllClosedPosts' : ActorMethod<[], AllClosedPostsResult>,
  'getAllFeedbackAndPost' : ActorMethod<[], AllFeedbackAndPostResult>,
  'getAllOpenPosts' : ActorMethod<[], AllOpenPostsResult>,
  'getAllPostAndFeedbacks' : ActorMethod<[], AllPostAndFeedbacksResult>,
  'getAllUnfilledPosts' : ActorMethod<[], AllUnfilledPostsResult>,
  'getBrandBasicInfo' : ActorMethod<[], Result>,
  'getFeedbacksByUser' : ActorMethod<[], UserFeedbacksResult>,
  'getPost' : ActorMethod<[bigint], QueryPostResult>,
  'getPostsByBrand' : ActorMethod<[], BrandPostsResult>,
  'post' : ActorMethod<[Array<string>, bigint], PostResult>,
  'postfeedback' : ActorMethod<
    [bigint, Array<string>, boolean],
    FeedbackResult
  >,
  'queryBrand' : ActorMethod<[], QueryBrandResult>,
  'queryUser' : ActorMethod<[], QueryUserResult>,
  'register' : ActorMethod<[Registration], RegisterResult>,
  'registerBrand' : ActorMethod<[BrandRegisterArg], RegisterResult>,
  'registerUser' : ActorMethod<[string], RegisterResult>,
}
