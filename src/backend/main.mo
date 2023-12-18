// Base
import Array "mo:base/Array";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";

// mops - map
import Map "mo:map/Map";

import T "Types";
import Constants "Constants";
import U "Utils";
import Brands "Brands";
import Feedbacks "Feedbacks";

actor {
	// Types
	type Brand = T.Brand;
	type Post = T.Post;
	type User = T.User;
	type Feedback = T.Feedback;
	type BrandMap = T.BrandMap;
	type PostMap = T.PostMap;
	type UserMap = T.UserMap;
	type FeedbackMap = T.FeedbackMap;
	type RegisterResult = T.RegisterResult;
	type PostResult = T.PostResult;
	type FeedbackResult = T.FeedbackResult;

	type PostId = T.PostId;
	type FeedbackId = T.FeedbackId;
	type QueryPostResult = T.QueryPostResult;
	type QueryBrandResult = T.QueryBrandResult;

	// Variables
	let { phash; nhash } = Map;

	// Stable Variables
	stable var brandCount : Nat = 0;
	stable var userCount : Nat = 0;
	stable var postCount : Nat = 0;
	stable var feedbackCount : Nat = 0;

	stable let brandMap : BrandMap = Map.new<Principal, Brand>(phash);
	stable let postMap : PostMap = Map.new<PostId, Post>(nhash);
	stable let userMap : UserMap = Map.new<Principal, User>(phash);
	stable let feedbackMap : FeedbackMap = Map.new<FeedbackId, Feedback>(nhash);

	stable let registerMap = Map.new<Principal, Text>(phash);

	stable var closedPostList : List.List<PostId> = List.nil<PostId>();

	// brand
	public shared ({ caller }) func registerBrand(
		args : T.BrandRegisterArg
	) : async RegisterResult {
		// Anonymous users cannot register
		if (Principal.isAnonymous(caller)) return #err("Anonymous can not register");
		_register(brandMap, caller, args);
	};

	// brand only
	public shared ({ caller }) func post(questions : [Text], reward : Nat) : async PostResult {

		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		_post(brandMap, caller, postMap, questions, reward);
	};

	// Anyone -- get A Post by postId
	public query func getPost(postId : Nat) : async QueryPostResult {
		// Anonymous users can query Post
		Brands.getPost(postMap, postId);
	};

	// brand only -- get brand details
	public shared query ({ caller }) func queryBrand() : async QueryBrandResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.queryBrand(brandMap, caller);
	};

	// user
	public shared ({ caller }) func registerUser(name : Text) : async RegisterResult {
		// Anonymous users cannot register
		if (Principal.isAnonymous(caller)) return #err("Anonymous users cannot register");
		_registerUser(userMap, caller, name);
	};

	// user only
	public shared ({ caller }) func postfeedback(postId : Nat, feedback : [Text], aiValidation : Bool) : async FeedbackResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		_postFeedback(userMap, caller, postMap, postId, feedbackMap, feedback, aiValidation);
	};

	// user only -- get user details
	public shared query ({ caller }) func queryUser() : async T.QueryUserResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Feedbacks.queryUser(userMap, caller);
	};

	// user only -- all feedback by user
	public shared query ({ caller }) func getFeedbacksByUser() : async T.UserFeedbacksResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Feedbacks.getFeedbacksByUser(userMap, caller, feedbackMap);
	};

	// brand only -- get all post of a brand
	public shared query ({ caller }) func getPostsByBrand() : async T.BrandPostsResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.getPostsbyBrand(brandMap, postMap, caller);
	};

	// brand only -- get a post and all its feedbacks
	public shared query ({ caller }) func getAPostAndFeedbacks(postId : Nat) : async T.APostAndFeedbacksResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.getAPostAndFeedbacks(brandMap, postMap, feedbackMap, caller, postId);
	};

	// brand only -- get all posts and its feedbacks
	public shared query ({ caller }) func getAllPostAndFeedbacks() : async T.AllPostAndFeedbacksResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.getAllPostAndFeedbacks(brandMap, postMap, feedbackMap, caller);
	};

	// user only -- get all posts that are open and user Unfilled
	public shared query ({ caller }) func getAllUnfilledPosts() : async T.AllUnfilledPostsResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Feedbacks.getAllUnfilledPosts(userMap, postMap, closedPostList, caller);
	};

	// user and brand
	public shared ({ caller }) func register(reg : T.Registration) : async RegisterResult {
		if (Principal.isAnonymous(caller)) return #err("Anonymous users cannot register");
		switch (reg) {
			case (#Brand args) { _register(brandMap, caller, args) };
			case (#User name) { _registerUser(userMap, caller, name) };
		};
	};

	// brand -- get all open posts of a brand
	public shared query ({ caller }) func getAllOpenPosts() : async T.AllOpenPostsResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.getAllOpenPosts(brandMap, postMap, closedPostList, caller);
	};

	// brand -- get all closed posts of a brand
	public shared query ({ caller }) func getAllClosedPosts() : async T.AllClosedPostsResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Brands.getAllClosedPosts(brandMap, postMap, closedPostList, caller);
	};

	// user
	public shared query ({ caller }) func getAFeedbackAndPost(feedbackId : FeedbackId) : async T.AFeedbackAndPostResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Feedbacks.getAFeedbackAndPost(userMap, postMap, feedbackMap, caller, feedbackId);
	};

	// user
	public shared query ({ caller }) func getAllFeedbackAndPost() : async T.AllFeedbackAndPostResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);
		Feedbacks.getAllFeedbackAndPost(userMap, postMap, feedbackMap, caller);
	};
	////////
	public shared query ({ caller }) func checkUserType() : async Text {
		switch (Map.get(registerMap, phash, caller)) {
			case (?value) { value };
			case (null) { "Not Registered" };
		};
	};

	public shared query ({ caller }) func checkMyBalance() : async Nat {
		switch (Map.get(registerMap, phash, caller)) {
			case (?"User") {
				switch (Map.get(userMap, phash, caller)) {
					case (?value) { value.balance };
					case (null) { 0 };
				};
			};
			case (?"Brand") {
				switch (Map.get(brandMap, phash, caller)) {
					case (?value) { value.balance };
					case (null) { 0 };
				};
			};
			case (_) { 0 };
			// case (null) {};
		};
	};

	public shared ({ caller }) func addBalance(add : Nat) : async T.Result<Nat, Text> {
		return #err("Adimin only method");
		// switch (Map.get(brandMap, phash, caller)) {
		//     case (?value) { value.balance += add; #ok(value.balance) };
		//     case (null) { #err("user not founc") };
		// };
	};

	public shared query ({ caller }) func getBrandBasicInfo() : async T.Result<T.BrandBasicInfo, Text> {
		switch (Map.get(brandMap, phash, caller)) {
			case (?value) {
				#ok({
					brandName = value.name;
					industry = value.industry;
					productOrServiceCategory = value.productOrServiceCategory;
					targetAudience = value.targetAudience;
				});
			};
			case (null) { #err("Please Register as Brand") };
		};
	};

	// Private functions
	private func _register(
		brandMap : BrandMap,
		_owner : Principal,
		{
			brandName : Text;
			industry : Text;
			productOrServiceCategory : Text;
			targetAudience : Text;
		}
	) : RegisterResult {
		if (Map.get(registerMap, phash, _owner) == ?"User") {
			return #err("Already registerd as User");
		};

		switch (Map.get(brandMap, phash, _owner)) {
			case (?brand) {
				#err("Already registerd as brand " # brand.name);
			};
			case (null) {
				brandCount += 1;
				let newBrand : Brand = {
					id = brandCount;
					owner = _owner;
					name = brandName;
					var balance = 1000;
					var lastPost = 0;
					var postList = List.nil<PostId>();
					industry;
					productOrServiceCategory;
					targetAudience;
				};
				Map.set(brandMap, phash, _owner, newBrand);
				Map.set(registerMap, phash, _owner, "Brand");
				#ok();

			};
		};
	};

	private func _post(brandMap : BrandMap, _owner : Principal, postMap : PostMap, text : [Text], amount : Nat) : PostResult {
		switch (Map.get(brandMap, phash, _owner)) {
			case (null) { #err(#UserNotFound) };
			case (?brand) {
				if (amount < 10) { return #err(#Reward_Should_Above_10) };
				if (List.size(brand.postList) == 0) {
					postCount += 1;
					let newPost : Post = {
						postId = postCount;
						created = Time.now();
						owner = brand.owner;
						brandName = brand.name;
						question = text;
						var reward : Nat = 10000;
						var feedbackList = List.nil<FeedbackId>();
						var status = #Open;
					};
					Map.set(postMap, nhash, newPost.postId, newPost);

					// brandmap update method 1 if type is Brand    (brand mutation)
					brand.lastPost := newPost.created;
					brand.postList := List.push(newPost.postId, brand.postList);

					#ok()

				} else {
					if (brand.balance < amount) {
						#err(#LowBalance(brand.balance));
					} else {
						postCount += 1;
						let newPost : Post = {
							postId = postCount;
							created = Time.now();
							owner = brand.owner;
							brandName = brand.name;
							question = text;
							var reward = amount;
							var feedbackList = List.nil<FeedbackId>();
							var status = #Open

						};
						Map.set(postMap, nhash, newPost.postId, newPost);

						// brandmap update method 1 if type is Brand    (brand mutation)
						brand.balance := brand.balance - amount;
						brand.lastPost := newPost.created;
						brand.postList := List.push(newPost.postId, brand.postList);

						#ok();
					};
				};
			};
		};
	};

	private func _registerUser(userMap : UserMap, _principal : Principal, _name : Text) : RegisterResult {
		if (Map.get(registerMap, phash, _principal) == ?"Brand") {
			return #err("Already registerd as Brand");
		};

		switch (Map.get(userMap, phash, _principal)) {
			case (?user) { #err("Already registerd as user " # user.name) };
			case (null) {
				userCount += 1;
				let newUser : User = {
					id = userCount;
					principal = _principal;
					name = _name;
					var balance = 0;
					var lastFeedback = 0;
					var feedbackList = List.nil<FeedbackId>();
					var postList = List.nil<PostId>();
				};
				Map.set(userMap, phash, _principal, newUser);
				Map.set(registerMap, phash, _principal, "User");
				#ok();
			};
		};
	};
	// private function
	private func _postFeedback(userMap : UserMap, _principal : Principal, postMap : PostMap, postId : PostId, feedbackMap : FeedbackMap, _feedback : [Text], aiValidation : Bool) : FeedbackResult {
		switch (Map.get(userMap, phash, _principal)) {
			case (null) { #err(#UserNotFound) };
			case (?user) {
				if (U.isFeedbacked(user, postId)) { return #err(#AlreadyFeedbacked) };
				switch (Map.get(postMap, nhash, postId)) {
					case (null) { #err(#PostNotFound) };
					case (?post) {
						if (post.reward < 10) {
							post.status := #Closed(Time.now());
							closedPostList := List.push(post.postId, closedPostList);
							#err(#NoSpotLeft);
						} else {
							feedbackCount += 1;
							let newFeedback : Feedback = {
								feedbackId = feedbackCount;
								postId = post.postId;
								created = Time.now();
								feedback = _feedback;
								userName = user.name;
								isAIvalidationPass = aiValidation;
							};
							Map.set(feedbackMap, nhash, newFeedback.feedbackId, newFeedback);

							// post mutation
							if (aiValidation) {
								post.reward := post.reward - 10;
							};
							post.feedbackList := List.push<FeedbackId>(newFeedback.feedbackId, post.feedbackList);
							if (post.reward < 10) {
								post.reward := 0; // newly updated
								post.status := #Closed(Time.now());
								closedPostList := List.push(post.postId, closedPostList);
							};

							// user mutation
							if (aiValidation) {
								user.balance := user.balance + 10;
							};
							user.lastFeedback := newFeedback.created;
							user.feedbackList := List.push<FeedbackId>(newFeedback.feedbackId, user.feedbackList);
							user.postList := List.push<PostId>(newFeedback.postId, user.postList);
							#ok();
						};
					};
				};
			};
		};
	};

};
