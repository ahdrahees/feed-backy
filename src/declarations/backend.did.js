export const idlFactory = ({ IDL }) => {
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const FeedbackId__1 = IDL.Nat;
  const QueryPost = IDL.Record({
    'created' : IDL.Int,
    'filledspot' : IDL.Nat,
    'question' : IDL.Vec(IDL.Text),
    'owner' : IDL.Text,
    'spotLeft' : IDL.Nat,
    'totalspot' : IDL.Nat,
    'rewardLeft' : IDL.Nat,
    'brandName' : IDL.Text,
    'postId' : IDL.Nat,
  });
  const FeedbackId = IDL.Nat;
  const Feedback = IDL.Record({
    'userName' : IDL.Text,
    'created' : IDL.Int,
    'isAIvalidationPass' : IDL.Bool,
    'feedback' : IDL.Vec(IDL.Text),
    'feedbackId' : FeedbackId,
    'postId' : IDL.Nat,
  });
  const FeedbackAndPost = IDL.Record({
    'post' : QueryPost,
    'feedback' : Feedback,
  });
  const AFeedbackAndPostResult = IDL.Variant({
    'ok' : FeedbackAndPost,
    'err' : IDL.Variant({
      'AnonymousNotAllowed' : IDL.Null,
      'BrandNotFound' : IDL.Null,
      'OwnerNotFound' : IDL.Null,
      'PostNotFound' : IDL.Null,
      'FeedbackNotInYourList' : IDL.Null,
      'UserNotFound' : IDL.Null,
      'TimeRemaining' : IDL.Int,
    }),
  });
  const PostAndFeedbacks = IDL.Record({
    'post' : QueryPost,
    'feedbacks' : IDL.Vec(Feedback),
  });
  const PostId = IDL.Nat;
  const PostAndFeedbacksError = IDL.Variant({
    'AnonymousNotAllowed' : IDL.Null,
    'BrandNotFound' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'PostBelongsTo' : IDL.Tuple(PostId, IDL.Text),
    'PostNotFound' : IDL.Null,
    'NotABrandOwner' : IDL.Null,
    'UserNotFound' : IDL.Null,
    'TimeRemaining' : IDL.Int,
  });
  const APostAndFeedbacksResult = IDL.Variant({
    'ok' : PostAndFeedbacks,
    'err' : PostAndFeedbacksError,
  });
  const Error = IDL.Variant({
    'AnonymousNotAllowed' : IDL.Null,
    'BrandNotFound' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'PostNotFound' : IDL.Null,
    'UserNotFound' : IDL.Null,
    'TimeRemaining' : IDL.Int,
  });
  const AllClosedPostsResult = IDL.Variant({
    'ok' : IDL.Vec(QueryPost),
    'err' : Error,
  });
  const AllFeedbackAndPostResult = IDL.Variant({
    'ok' : IDL.Vec(FeedbackAndPost),
    'err' : Error,
  });
  const AllOpenPostsResult = IDL.Variant({
    'ok' : IDL.Vec(QueryPost),
    'err' : Error,
  });
  const AllPostAndFeedbacksResult = IDL.Variant({
    'ok' : IDL.Vec(PostAndFeedbacks),
    'err' : PostAndFeedbacksError,
  });
  const AllUnfilledPostsResult = IDL.Variant({
    'ok' : IDL.Vec(QueryPost),
    'err' : Error,
  });
  const BrandBasicInfo = IDL.Record({
    'productOrServiceCategory' : IDL.Text,
    'targetAudience' : IDL.Text,
    'brandName' : IDL.Text,
    'industry' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : BrandBasicInfo, 'err' : IDL.Text });
  const UserFeedbacksResult = IDL.Variant({
    'ok' : IDL.Vec(Feedback),
    'err' : Error,
  });
  const QueryPostResult = IDL.Variant({ 'ok' : QueryPost, 'err' : Error });
  const BrandPostsResult = IDL.Variant({
    'ok' : IDL.Vec(QueryPost),
    'err' : Error,
  });
  const PostError = IDL.Variant({
    'LowBalance' : IDL.Nat,
    'AnonymousNotAllowed' : IDL.Null,
    'BrandNotFound' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'Reward_Should_Above_10' : IDL.Null,
    'PostNotFound' : IDL.Null,
    'UserNotFound' : IDL.Null,
    'TimeRemaining' : IDL.Int,
  });
  const PostResult = IDL.Variant({ 'ok' : IDL.Null, 'err' : PostError });
  const FeedbackError = IDL.Variant({
    'NoSpotLeft' : IDL.Null,
    'AnonymousNotAllowed' : IDL.Null,
    'AlreadyFeedbacked' : IDL.Null,
    'BrandNotFound' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'PostNotFound' : IDL.Null,
    'UserNotFound' : IDL.Null,
    'TimeRemaining' : IDL.Int,
  });
  const FeedbackResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : FeedbackError,
  });
  const QueryBrand = IDL.Record({
    'id' : IDL.Nat,
    'principal' : IDL.Text,
    'productOrServiceCategory' : IDL.Text,
    'balance' : IDL.Nat,
    'name' : IDL.Text,
    'targetAudience' : IDL.Text,
    'totalPosts' : IDL.Nat,
    'lastPost' : IDL.Int,
    'industry' : IDL.Text,
  });
  const QueryBrandError = IDL.Variant({
    'AnonymousNotAllowed' : IDL.Null,
    'BrandNotFound' : IDL.Null,
    'OwnerNotFound' : IDL.Null,
    'PostNotFound' : IDL.Null,
    'NotABrandOwner' : IDL.Null,
    'UserNotFound' : IDL.Null,
    'TimeRemaining' : IDL.Int,
  });
  const QueryBrandResult = IDL.Variant({
    'ok' : QueryBrand,
    'err' : QueryBrandError,
  });
  const QueryUser = IDL.Record({
    'id' : IDL.Nat,
    'principal' : IDL.Text,
    'balance' : IDL.Nat,
    'name' : IDL.Text,
    'totalFeedback' : IDL.Nat,
    'lastFeedback' : IDL.Int,
  });
  const QueryUserResult = IDL.Variant({ 'ok' : QueryUser, 'err' : Error });
  const BrandRegisterArg = IDL.Record({
    'productOrServiceCategory' : IDL.Text,
    'targetAudience' : IDL.Text,
    'brandName' : IDL.Text,
    'industry' : IDL.Text,
  });
  const Registration = IDL.Variant({
    'User' : IDL.Text,
    'Brand' : BrandRegisterArg,
  });
  const RegisterResult = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'addBalance' : IDL.Func([IDL.Nat], [Result_1], []),
    'checkMyBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'checkUserType' : IDL.Func([], [IDL.Text], ['query']),
    'getAFeedbackAndPost' : IDL.Func(
        [FeedbackId__1],
        [AFeedbackAndPostResult],
        ['query'],
      ),
    'getAPostAndFeedbacks' : IDL.Func(
        [IDL.Nat],
        [APostAndFeedbacksResult],
        ['query'],
      ),
    'getAllClosedPosts' : IDL.Func([], [AllClosedPostsResult], ['query']),
    'getAllFeedbackAndPost' : IDL.Func(
        [],
        [AllFeedbackAndPostResult],
        ['query'],
      ),
    'getAllOpenPosts' : IDL.Func([], [AllOpenPostsResult], ['query']),
    'getAllPostAndFeedbacks' : IDL.Func(
        [],
        [AllPostAndFeedbacksResult],
        ['query'],
      ),
    'getAllUnfilledPosts' : IDL.Func([], [AllUnfilledPostsResult], ['query']),
    'getBrandBasicInfo' : IDL.Func([], [Result], ['query']),
    'getFeedbacksByUser' : IDL.Func([], [UserFeedbacksResult], ['query']),
    'getPost' : IDL.Func([IDL.Nat], [QueryPostResult], ['query']),
    'getPostsByBrand' : IDL.Func([], [BrandPostsResult], ['query']),
    'post' : IDL.Func([IDL.Vec(IDL.Text), IDL.Nat], [PostResult], []),
    'postfeedback' : IDL.Func(
        [IDL.Nat, IDL.Vec(IDL.Text), IDL.Bool],
        [FeedbackResult],
        [],
      ),
    'queryBrand' : IDL.Func([], [QueryBrandResult], ['query']),
    'queryUser' : IDL.Func([], [QueryUserResult], ['query']),
    'register' : IDL.Func([Registration], [RegisterResult], []),
    'registerBrand' : IDL.Func([BrandRegisterArg], [RegisterResult], []),
    'registerUser' : IDL.Func([IDL.Text], [RegisterResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
