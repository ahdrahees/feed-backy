// Base
import Array "mo:base/Array";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";

// mops - map
import Map "mo:map/Map";
import StableBuffer "mo:StableBuffer/StableBuffer";

import T "Types";
import Constants "Constants";
import U "Utils";
import Brands "Brands";
import Feedbacks "Feedbacks";

// import icp_ledger_canister "canister:icp_ledger_canister";
import IcpLedgerInterface "service/icp-ledger-interface";

// import service "ic:ryjl3-tyaaa-aaaaa-aaaba-cai";

actor feedbacky {
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
	type TransferResult = Result.Result<Nat64, Text>;

	// Variables
	let { phash; nhash } = Map;
	let icpLedgerCanister : IcpLedgerInterface.Self = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");

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

	stable let withdrawHistoryMap : T.WithdrawHistoryMap = Map.new(phash);

	// brand
	public shared ({ caller }) func registerBrand(
		args : T.BrandRegisterArg
	) : async RegisterResult {
		// Anonymous users cannot register
		if (Principal.isAnonymous(caller)) return #err("Anonymous can not register");
		_register(brandMap, caller, args);
	};

	// brand only
	public shared ({ caller }) func post(questions : [Text], feedbacksNos : Nat) : async PostResult {

		if (Principal.isAnonymous(caller)) return #err("Anonymous Not Allowed");
		await* _post(brandMap, caller, postMap, questions, feedbacksNos);
	};

	// Anyone -- get A Post by postId
	public query func getPost(postId : Nat) : async QueryPostResult {
		// Anonymous users can query Post
		Brands.getPost(postMap, postId);
	};

	// brand only -- get brand details
	public shared query ({ caller }) func queryBrand() : async QueryBrandResult {
		if (Principal.isAnonymous(caller)) return #err(#AnonymousNotAllowed);

		Brands.queryBrand(brandMap, caller, Principal.fromActor(feedbacky));
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
	//
	public shared query ({ caller }) func checkUserType() : async Text {
		switch (Map.get(registerMap, phash, caller)) {
			case (?value) { value };
			case (null) { "Not Registered" };
		};
	};

	// user only
	public shared ({ caller }) func checkMyBalance() : async Nat {
		switch (Map.get(registerMap, phash, caller)) {
			case (?"User") {
				switch (Map.get(userMap, phash, caller)) {
					case (?value) { value.balance };
					case (null) { 0 };
				};
			};
			case (_) { 0 };
			// case (null) {};
		};
	};

	public shared query ({ caller }) func getBrandBasicInfo() : async T.Result<T.BrandBasicInfo, Text> {
		switch (Map.get(brandMap, phash, caller)) {
			case (?brand) {
				#ok({
					brandName = brand.name;
					industry = brand.industry;
					productOrServiceCategory = brand.productOrServiceCategory;
					targetAudience = brand.targetAudience;
					account = U.toAccount(Principal.fromActor(feedbacky), (10 + brand.id));
				});
			};
			case (null) { #err("Please Register as Brand") };
		};
	};

	public shared query ({ caller }) func numberOfBrands() : async Nat {
		Map.size(brandMap);
	};

	public shared query ({ caller }) func numberOfUsers() : async Nat {
		Map.size(userMap);
	};

	public shared func accounts(num : Nat) : async Text {
		let array = Array.init<Nat8>(32, 0);
		var decimal = num;
		var i = 0;

		while (decimal > 0) {
			array[31 -i] := Nat8.fromNat(decimal % 256);
			decimal := decimal / 256;
			i += 1;
		};

		let accountArg : IcpLedgerInterface.Account = {
			owner = Principal.fromActor(feedbacky);
			subaccount = ?Blob.fromArrayMut(array);
		};
		let account = await icpLedgerCanister.account_identifier(accountArg);

		return U.toHex(Blob.toArray(account));
	};

	public shared ({ caller }) func transferICP(to : Blob, amount : IcpLedgerInterface.Tokens) : async TransferResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (?brand) {
				let transferArgs : IcpLedgerInterface.TransferArgs = {
					to;
					fee : IcpLedgerInterface.Tokens = {
						e8s = 10_000 : Nat64;
					};
					memo : Nat64 = Nat64.fromNat(brand.id);
					from_subaccount : ?Blob = U.toSubAccount(10 + brand.id);
					created_at_time : ?IcpLedgerInterface.TimeStamp = ?{
						timestamp_nanos = Nat64.fromIntWrap(Time.now()) : Nat64;
					};
					amount;
				};
				let tx_response = await icpLedgerCanister.transfer(transferArgs);
				switch (tx_response) {
					case (#Ok(value)) { #ok(value) };
					case (#Err(error)) { #err("ICP transfer Error.") };
				};

			};
			case (null) { #err("Brand only method") };
		};
	};

	public shared ({ caller }) func withdrawRewardPoints(to : Blob) : async TransferResult {
		switch (Map.get(userMap, phash, caller)) {
			case (?user) {
				let icpRewardPerFeedback : Nat64 = Nat64.fromNat(500_000);
				let amount : IcpLedgerInterface.Tokens = {
					e8s = (Nat64.fromNat(user.balance) / 10) * icpRewardPerFeedback : Nat64;
				};
				let transferArgs : IcpLedgerInterface.TransferArgs = {
					to;
					fee : IcpLedgerInterface.Tokens = {
						e8s = 10_000 : Nat64;
					};
					memo : Nat64 = Nat64.fromNat(user.id);
					from_subaccount : ?Blob = U.toSubAccount(0);
					created_at_time : ?IcpLedgerInterface.TimeStamp = ?{
						timestamp_nanos = Nat64.fromIntWrap(Time.now()) : Nat64;
					};
					amount;
				};
				let tx_response = await icpLedgerCanister.transfer(transferArgs);
				var blockIndex : Nat64 = 0;
				switch (tx_response) {
					case (#Ok(value)) { blockIndex := value };
					case (#Err(error)) { return #err("ICP transfer Error.") };
				};
				let withdrawPoints = user.balance;
				user.balance := 0;

				switch (Map.get(withdrawHistoryMap, phash, caller)) {
					case (?buffer) {
						StableBuffer.add(buffer, { blockIndex; withdrawPoints });
					};
					case (null) {
						let stBuffer = StableBuffer.init<T.WithdrawHistory>();
						StableBuffer.add(stBuffer, { blockIndex; withdrawPoints });
						Map.set(withdrawHistoryMap, phash, caller, stBuffer);
					};
				};
				#ok(blockIndex);
			};
			case (null) { #err("User only method") };
		};
	};

	public shared ({ caller }) func icpAccountAddress() : async Blob {
		switch (Map.get(brandMap, phash, caller)) {
			case (?brand) {
				await icpLedgerCanister.account_identifier(U.toAccount(Principal.fromActor(feedbacky), 10 + brand.id));
			};
			case (null) { Blob.fromArray([]) };
		};
	};

	public shared ({ caller }) func icpBalanceOf() : async Nat {
		switch (Map.get(brandMap, phash, caller)) {
			case (?brand) {
				await icpLedgerCanister.icrc1_balance_of(U.toAccount(Principal.fromActor(feedbacky), 10 + brand.id));
			};
			case (null) { 0 };
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

	private func calculatePostCostInICP(questionNos : Nat, feedbacksNos : Nat) : Nat {
		let decimals : Nat = 10 ** 8;
		let icpRewardPerFeedback : Nat = 500_000; // 0.005 in ICP 8 Decimals
		let icpFeePerFeedback : Nat = 166_666; // 0.00166666 in ICP 8 Decimals
		let icpCostPerFeedback : Nat = 666_666; // 0.00666666 in ICP 8 Decimals

		return (questionNos * feedbacksNos * icpCostPerFeedback);
	};

	private func _post(brandMap : BrandMap, _owner : Principal, postMap : PostMap, text : [Text], feedbacksNos : Nat) : async* PostResult {
		switch (Map.get(brandMap, phash, _owner)) {
			case (null) { #err("User Not Found") };
			case (?brand) {
				if (feedbacksNos == 0) { return #err("Error: Number of Feedbacks Atleast 1") };
				let postCostInICP : Nat = calculatePostCostInICP(text.size(), feedbacksNos);

				let accountArg : IcpLedgerInterface.Account = U.toAccount(Principal.fromActor(feedbacky), (10 + brand.id));
				let balance : Nat = await icpLedgerCanister.icrc1_balance_of(accountArg);

				// amount is ICP // rewards = amount * 333 * 10 ;
				if (balance < postCostInICP) {
					let textBalance = Float.toText(Float.fromInt(balance) / (10 ** 8));
					let textCost = Float.toText(Float.fromInt(postCostInICP) / (10 ** 8));
					#err("Low Balance " # textBalance # " ICP less than post cost " # textCost # " ICP.");
				} else {
					let postId = postCount + 1;
					let created = Time.now();
					let transferArg : IcpLedgerInterface.TransferArg = {
						to = U.defaultAccount(Principal.fromActor(feedbacky));
						fee = null;
						memo = ?Text.encodeUtf8(Nat.toText(postId));
						from_subaccount = U.toSubAccount(10 + brand.id);
						created_at_time = ?Nat64.fromIntWrap(created);
						amount = postCostInICP;
					};
					let tx_response : IcpLedgerInterface.Result = await icpLedgerCanister.icrc1_transfer(transferArg);

					var blockIndex : Nat = 0;
					switch (tx_response) {
						case (#Ok(value)) { blockIndex := value };
						case (#Err(error)) { return #err("ICP transfer Error.") };
					};

					let newPost : Post = {
						postId;
						created;
						owner = brand.owner;
						brandName = brand.name;
						question = text;
						var reward = (text.size() * feedbacksNos * 10);
						var feedbackList = List.nil<FeedbackId>();
						var status = #Open;
						blockIndex;
					};

					Map.set(postMap, nhash, newPost.postId, newPost);
					postCount += 1;
					// brandmap update method 1 if type is Brand    (brand mutation)
					brand.lastPost := newPost.created;
					brand.postList := List.push(newPost.postId, brand.postList);

					#ok();
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
						let points : Nat = post.question.size() * 10;

						if (post.reward < points) {
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
								post.reward := post.reward - points;
							};
							post.feedbackList := List.push<FeedbackId>(newFeedback.feedbackId, post.feedbackList);
							if (post.reward < points) {
								post.reward := 0; // newly updated
								post.status := #Closed(Time.now());
								closedPostList := List.push(post.postId, closedPostList);
							};

							// user mutation
							if (aiValidation) {
								user.balance := user.balance + points;
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
