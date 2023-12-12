import Map "mo:map/Map";
import Hash "mo:base/Hash";
import List "mo:base/List";
import R "mo:base/Result";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Time "mo:base/Time";


module {
    public type Time = Time.Time;
    public type Result<Ok, Err> = R.Result<Ok, Err>;
    
    public type Map<K,V> = Map.Map<K,V>;
    public type BrandMap = Map<Principal,Brand>;
    public type UserMap = Map<Principal, User>;
    public type PostMap = Map<PostId, Post>;
    public type FeedbackMap = Map<FeedbackId,Feedback>;

    public type Status = {
        #Open;
        #Closed : Time;
    };

    public type Registration = {
        #Brand : Text;
        #User : Text;
    };

    // Brand data
    public type Post = {
        postId: Nat;
        created : Int;
        owner : Principal;
        brandName : Text;
        question : [Text];
        var reward : Nat;
        var feedbackList : List.List<FeedbackId>;   
        var status : Status;
    };

    public type Feedback = {
        feedbackId : FeedbackId;
        postId: Nat;
        created : Int;
        feedback: [Text];
        userName: Text;
    };

    // User data
    public type User = {
        id : Nat;
        principal: Principal;
        name : Text;
        var balance : Int;
        var lastFeedback : Int;
        var feedbackList : List.List<FeedbackId>;   
        var postList : List.List<PostId>;   
    };

    // brandOwner data
    public type Brand = {
        id : Nat;
        owner : Principal;
        name : Text;
        var balance : Nat;
        var lastPost : Int;
        var postList : List.List<PostId>; 
    };

    
    public type PostId = Nat;
    public type FeedbackId = Nat;
  
    //  Results
    public type Error = {
        # TimeRemaining : Int;
        # AnonymousNotAllowed;
        # UserNotFound;
        # BrandNotFound;
        # OwnerNotFound;
        #PostNotFound;
    };

    public type RegisterResult = Result<(), RegisterError>; 

    public type RegisterError = Error or { #AlreadyRegisterd : (Principal, Text)};

    public type PostResult = Result<(), PostError>;
    type PostError = Error or { # LowBalance : Nat;};

    public type FeedbackResult = Result<(), FeedbackError>;
    type FeedbackError = Error or { #NoSpotLeft ; #AlreadyFeedbacked};

    public type QueryPostResult = Result<QueryPost, Error>;

    public type  QueryBrandResult =  Result<QueryBrand, QueryBrandError>;
    type QueryBrandError = Error or { #NotABrandOwner };

    public type QueryUserResult = Result<QueryUser, Error>;

    public type UserFeedbacksResult = Result<[Feedback], Error>;

    public type BrandPostsResult = Result<[QueryPost],Error>;

    public type APostAndFeedbacksResult = Result<PostAndFeedbacks, PostAndFeedbacksError>;
   
    public type PostAndFeedbacksError = Error or { #NotABrandOwner; #PostBelongsTo : (PostId, Text)};

    public type AllPostAndFeedbacksResult = Result<[PostAndFeedbacks], PostAndFeedbacksError>;

    public type AllUnfilledPostsResult = Result<[QueryPost], Error>;

    public type AllOpenPostsResult = Result<[QueryPost], Error> ;
    
    public type AllClosedPostsResult = Result<[QueryPost], Error>;
    
    public type AFeedbackAndPostResult = Result<FeedbackAndPost, Error or {#FeedbackNotInYourList}>;

    public type AllFeedbackAndPostResult = Result<[FeedbackAndPost], Error>;

    // Queries
    public type QueryPost = {
        postId : Nat;
        created : Int;
        owner : Principal;
        brandName : Text;
        question : [Text];
        rewardLeft : Nat;
        totalspot : Nat;
        filledspot : Nat;
        spotLeft : Nat;
    };

    public type QueryBrand = {
        id : Nat;
        owner : Principal;
        name : Text;
        balance : Nat;
        lastPost : Int;
        totalPosts : Nat;
    };

    public type QueryUser = {
        id : Nat;
        principal: Principal;
        name : Text;
        balance : Int;
        lastFeedback : Int;
        totalFeedback : Nat;
    };

    public type PostAndFeedbacks = {
        post : QueryPost;
        feedbacks : [Feedback];
    };
  
    public type  FeedbackAndPost = {
        post : QueryPost;
        feedback : Feedback;
    }

};
