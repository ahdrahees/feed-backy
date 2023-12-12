import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";



// mops - map
import Map "mo:map/Map";

import T "Types";
import Constants "Constants";
import U "Utils";



module {
    type List<T> = List.List<T>;
    type Post = T.Post;
    type PostMap = T.PostMap;
    type UserMap = T.UserMap;
    type FeedbackMap = T.FeedbackMap;
    
    type PostId = T.PostId;
    type FeedbackId = T.FeedbackId;
    type QueryUser = T.QueryUser;

    let {phash;nhash} = Map;

    public func queryUser(userMap : UserMap, principal : Principal) : T.QueryUserResult{
        switch(Map.get(userMap, phash, principal)) {
            case(null) { #err(#UserNotFound) };
            case(?user) { 
                let queryUser : QueryUser = {
                   id = user.id;
                   principal;
                   name = user.name;
                   balance = user.balance;
                   lastFeedback = user.lastFeedback;
                   totalFeedback = List.size<FeedbackId>(user.feedbackList);
                };
                #ok(queryUser);
            };
        };
    };

    public func getFeedbacksByUser(userMap : UserMap, principal : Principal, feedbackMap : FeedbackMap) : T.UserFeedbacksResult {
        switch(Map.get(userMap, phash, principal)) {
            case(null) { #err(#UserNotFound) };
            case(?user) { 
                #ok(U.feedbackIdListToFeedbackArray(user.feedbackList, feedbackMap))       
            };
        };
    };

    public func getAllUnfilledPosts(userMap : UserMap, postMap : PostMap, closedPostList : List<PostId>, principal : Principal) : T.AllUnfilledPostsResult {
        switch(Map.get(userMap, phash, principal)) {
            case(null) { #err(#UserNotFound) };
            case(?user) { 
                func check(postId : PostId) : Bool {
                    U.isOpenAndUnfilledPost(user, closedPostList, postId);
                };
                let allPostId : List<PostId> = Iter.toList(Map.keys<PostId,Post>(postMap)); // get all postId in the postMap as a List

                let unfilledPostIdList : List<PostId> = List.filter(allPostId, check);

                #ok(U.postIdListToQueryPostArray(unfilledPostIdList, postMap))       
            };
        };
    };

    public func getAFeedbackAndPost(userMap : UserMap, postMap : PostMap, feedbackMap : FeedbackMap, principal : Principal, feedbackId : FeedbackId) : T.AFeedbackAndPostResult {
        switch(Map.get(userMap, phash, principal)) {
            case(null) { #err(#UserNotFound) };
            case(?user) { 
                if(U.isNotInFeedbackList(user.feedbackList, feedbackId)) { return #err(#FeedbackNotInYourList)};
                #ok(U.toFeedbackAndPost(feedbackId, feedbackMap, postMap))       
            };
        };
    };

    public func getAllFeedbackAndPost(userMap : UserMap, postMap : PostMap, feedbackMap : FeedbackMap, principal : Principal) : T.AllFeedbackAndPostResult {
        switch(Map.get(userMap, phash, principal)) {
            case(null) { #err(#UserNotFound) };
            case(?user) { 
                #ok(U.toFeedbackAndPostArray(user.feedbackList, feedbackMap, postMap))       
            };
        };
    };
};