import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";
import Error "mo:base/Error";
import Principal "mo:base/Principal";

// mops - map;
import Map "mo:map/Map";

import T "Types";
import Constants "Constants";
import U "Utils";

module {
	// Types
	type List<T> = List.List<T>;
	type BrandMap = T.BrandMap;
	type PostMap = T.PostMap;
	type FeedbackMap = T.FeedbackMap;
	type PostId = T.PostId;
	type QueryPostResult = T.QueryPostResult;
	type QueryBrand = T.QueryBrand;
	type QueryBrandResult = T.QueryBrandResult;

	// Variables
	let { phash; nhash } = Map;

	// 10 token for a feedback
	public func getPost(postMap : PostMap, postId : PostId) : QueryPostResult {
		switch (Map.get(postMap, nhash, postId)) {
			case (null) { #err(#PostNotFound) };
			case (?post) {
				#ok(U.postToQueryPost(post));
			};
		};
	};

	public func queryBrand(brandMap : BrandMap, caller : Principal) : QueryBrandResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				if (not (caller == brand.owner)) return #err(#NotABrandOwner);
				let _queryBrand : QueryBrand = {
					id = brand.id;
					principal = Principal.toText(brand.owner);
					name = brand.name;
					balance = brand.balance;
					lastPost = brand.lastPost;
					totalPosts = List.size<PostId>(brand.postList);

					industry = brand.industry;
					productOrServiceCategory = brand.productOrServiceCategory;
					targetAudience = brand.targetAudience;
				};
				#ok(_queryBrand);
			};
		};
	};

	// brand is not a post owner (postId, principal)
	public func getAPostAndFeedbacks(brandMap : BrandMap, postMap : PostMap, feedbackMap : FeedbackMap, caller : Principal, postId : PostId) : T.APostAndFeedbacksResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				if (not (caller == brand.owner)) return #err(#NotABrandOwner);
				switch (Map.get(postMap, nhash, postId)) {
					case (null) { #err(#PostNotFound) };
					case (?post) {
						if (not (brand.owner == post.owner)) {
							return #err(#PostBelongsTo(post.postId, post.brandName));
						};

						#ok(U.toPostAndFeedbacks(post, feedbackMap));
					};
				};
			};
		};
	};

	public func getAllPostAndFeedbacks(brandMap : BrandMap, postMap : PostMap, feedbackMap : FeedbackMap, caller : Principal) : T.AllPostAndFeedbacksResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				if (not (caller == brand.owner)) return #err(#NotABrandOwner);
				#ok(U.toPostAndFeedbacksArray(brand.postList, postMap, feedbackMap));
			};
		};
	};

	public func getPostsbyBrand(brandMap : BrandMap, postMap : PostMap, caller : Principal) : T.BrandPostsResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				#ok(U.postIdListToQueryPostArray(brand.postList, postMap));
			};
		};
	};

	public func getAllOpenPosts(brandMap : BrandMap, postMap : PostMap, closedPostList : List<PostId>, caller : Principal) : T.AllOpenPostsResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				func isOpenPost(postId : PostId) : Bool {
					U.isOpenPost(closedPostList, postId);
				};
				let openPosts : List<PostId> = List.filter(brand.postList, isOpenPost); // gives open posts in brand postList
				#ok(U.postIdListToQueryPostArray(openPosts, postMap));
			};
		};
	};

	public func getAllClosedPosts(brandMap : BrandMap, postMap : PostMap, closedPostList : List<PostId>, caller : Principal) : T.AllOpenPostsResult {
		switch (Map.get(brandMap, phash, caller)) {
			case (null) { #err(#BrandNotFound) };
			case (?brand) {
				func isClosedPost(postId : PostId) : Bool {
					U.isClosedPost(closedPostList, postId);
				};
				let closedPosts : List<PostId> = List.filter(brand.postList, isClosedPost); // gives closed posts in brand postList
				#ok(U.postIdListToQueryPostArray(closedPosts, postMap));
			};
		};
	};
};
