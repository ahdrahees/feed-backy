import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Text "mo:base/Text";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

import Map "mo:map/Map";

import T "Types";

module {

	type List<T> = List.List<T>;

	type Post = T.Post;
	type User = T.User;
	type Feedback = T.Feedback;
	type PostMap = T.PostMap;
	type FeedbackMap = T.FeedbackMap;

	type PostId = T.PostId;
	type FeedbackId = T.FeedbackId;
	type QueryPost = T.QueryPost;
	type PostAndFeedbacks = T.PostAndFeedbacks;
	type FeedbackAndPost = T.FeedbackAndPost;

	// Variables
	let { phash; nhash } = Map;

	public func postToQueryPost(post : Post) : QueryPost {
		let _filledspot = List.size<FeedbackId>(post.feedbackList);
		let _totalspot = _filledspot + (post.reward / 10);
		let queryPost : QueryPost = {
			postId = post.postId;
			created = post.created;
			owner = Principal.toText(post.owner);
			brandName = post.brandName;
			question = post.question;
			rewardLeft = post.reward;
			totalspot = _totalspot;
			filledspot = _filledspot;
			spotLeft = _totalspot - _filledspot;
		};
	};

	public func postIdListToQueryPostArray(postList : List<PostId>, postMap : PostMap) : [QueryPost] {
		if (List.isNil(postList)) { [] } else {
			let buffer = Buffer.Buffer<QueryPost>(0);
			for (postId in List.toIter(postList)) {
				let post = switch (Map.get(postMap, nhash, postId)) {
					case (null) { Debug.trap("Wrong Post Id") };
					case (?v) { v };
				};
				buffer.add(postToQueryPost(post));
			};
			Buffer.toArray(buffer);
		};
	};

	public func feedbackIdListToFeedbackArray(feedbackList : List<FeedbackId>, feedbackMap : FeedbackMap) : [Feedback] {
		if (List.isNil(feedbackList)) { [] } else {
			let buffer = Buffer.Buffer<Feedback>(0);
			for (feedbackId in List.toIter(feedbackList)) {
				let feedback = switch (Map.get(feedbackMap, nhash, feedbackId)) {
					case (null) { Debug.trap("Wrong Feedback Id ") };
					case (?v) { v };
				};
				buffer.add(feedback);
			};
			Buffer.toArray(buffer);
		};
	};

	public func toPostAndFeedbacks(post : Post, feedbackMap : FeedbackMap) : PostAndFeedbacks {
		let feedbacks : [Feedback] = feedbackIdListToFeedbackArray(post.feedbackList, feedbackMap);
		let queryPost : QueryPost = postToQueryPost(post);
		let postAndFeedbacks : PostAndFeedbacks = {
			post = queryPost;
			feedbacks;
		};
	};

	public func toPostAndFeedbacksArray(postList : List<PostId>, postMap : PostMap, feedbackMap : FeedbackMap) : [PostAndFeedbacks] {
		if (List.isNil(postList)) { [] } else {
			let buffer = Buffer.Buffer<PostAndFeedbacks>(0);
			for (postId in List.toIter(postList)) {
				let post = switch (Map.get(postMap, nhash, postId)) {
					case (null) { Debug.trap("Wrong Post Id") };
					case (?v) { v };
				};
				buffer.add(toPostAndFeedbacks(post, feedbackMap));
			};
			Buffer.toArray(buffer);
		};
	};

	// filled
	public func isFeedbacked(user : User, postId : PostId) : Bool {
		if (List.isNil<PostId>(user.postList)) { false } else {
			for (_postId in List.toIter(user.postList)) {
				if (postId == _postId) { return true };
			};
			return false;
		};
	};

	// unfilled
	public func isNotFeedbacked(user : User, postId : PostId) : Bool {
		not isFeedbacked(user, postId);
	};

	public func isInFeedbackList(feedbackList : List<FeedbackId>, feedbackId : FeedbackId) : Bool {
		if (List.isNil(feedbackList)) { false } else {
			for (_feedbackId in List.toIter(feedbackList)) {
				if (feedbackId == _feedbackId) {
					return true;
				};
			};
			return false;
		};
	};

	public func isNotInFeedbackList(feedbackList : List<FeedbackId>, feedbackId : FeedbackId) : Bool {
		not isInFeedbackList(feedbackList, feedbackId);
	};

	public func isClosedPost(closedPostList : List<PostId>, postId : PostId) : Bool {
		if (List.isNil<PostId>(closedPostList)) { false } else {
			for (_postId in List.toIter(closedPostList)) {
				if (postId == _postId) { return true };
			};
			return false;
		};
	};

	public func isOpenPost(closedPostList : List<PostId>, postId : PostId) : Bool {
		not isClosedPost(closedPostList, postId);
	};

	// isOpenAndNotFeedbackedPost
	public func isOpenAndUnfilledPost(user : User, closedPostList : List<PostId>, postId : PostId) : Bool {
		isOpenPost(closedPostList, postId) and isNotFeedbacked(user, postId)
	};

	public func toFeedbackAndPost(feedbackId : FeedbackId, feedbackMap : FeedbackMap, postMap : PostMap) : FeedbackAndPost {
		let feedback = switch (Map.get(feedbackMap, nhash, feedbackId)) {
			case (null) {
				Debug.trap("Wrong Feedback Id ");
			};
			case (?v) { v };
		};
		let _post = switch (Map.get(postMap, nhash, feedback.postId)) {
			case (null) {
				Debug.trap("Wrong Post Id");
			};
			case (?v) { v };
		};

		let feedbackAndPost : FeedbackAndPost = {
			post = postToQueryPost(_post);
			feedback;
		};
	};
	public func toFeedbackAndPostArray(feedbackList : List<FeedbackId>, feedbackMap : FeedbackMap, postMap : PostMap) : [FeedbackAndPost] {
		if (List.isNil(feedbackList)) { [] } else {
			let buffer = Buffer.Buffer<FeedbackAndPost>(0);
			for (feedbackId in List.toIter(feedbackList)) {
				let feedbackAndPost = toFeedbackAndPost(feedbackId, feedbackMap, postMap);
				buffer.add(feedbackAndPost);
			};
			Buffer.toArray(buffer);
		};
	};
};
