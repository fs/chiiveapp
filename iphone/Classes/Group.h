//
//  Post.h
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTObject.h"

@class Post;
@class User;
@class UserModel;
@class PostModel;
@class GroupUser;

typedef enum {
	GroupPrivacyWhoCanJoinAll,
	GroupPrivacyWhoCanJoinFriends
} GroupPrivacyWhoCanJoin;

NSString * const GroupPrivacyWhoCanJoin_toString[2];


@interface Group : RESTObject <TTPhotoSource> {
	PostModel				*_postModel;
	UserModel				*_friendModel;
	
	GroupPrivacyWhoCanJoin	_privacyWhoCanJoin;
}

// Owner
@property (nonatomic, retain)	User					*owner;
@property (assign, readonly)	BOOL					isCurrentUserGroup;
@property (nonatomic, retain)	NSNumber				*isSuggestedGroupHolder;
@property (nonatomic, assign)	BOOL					isSuggestedGroup;

// Attributes
@property (nonatomic, copy)		NSString				*title;
@property (nonatomic, retain)	NSDate					*happenedAt;
@property (nonatomic, retain)	NSNumber				*longitude;
@property (nonatomic, retain)	NSNumber				*latitude;
@property (nonatomic, assign)	GroupPrivacyWhoCanJoin	privacyWhoCanJoin;

// Counters
@property (nonatomic, readonly)	NSUInteger				numPosts;
@property (nonatomic, readonly)	NSUInteger				numLocalPosts;
@property (nonatomic, assign)	NSUInteger				numRemotePosts;
@property (nonatomic, retain)	NSNumber				*numRemotePostsHolder;

@property (nonatomic, readonly)	NSUInteger				numUsers;
@property (nonatomic, assign)	NSUInteger				numRemoteUsers;
@property (nonatomic, retain)	NSNumber				*numRemoteUsersHolder;

// Relationships
@property (nonatomic, retain)	NSSet					*posts;
@property (nonatomic, readonly) PostModel				*postModel;
@property (nonatomic, retain)	NSSet					*groupUsers;
@property (nonatomic, readonly) UserModel				*friendModel;

// Formatted accessors
@property (nonatomic, readonly)	NSString				*prettyTitle;

- (void)checkIn;
- (void)insertPost:(Post *)post;
- (void)removePost:(Post *)post;
- (BOOL)isActive;

/**
 * Comparison function for sorting lists of groups
 */
- (NSComparisonResult)happenedAtCompare:(Group *)group;

@end

@interface Group (GroupUsersMethods)
- (void)addGroupUsersObject:(GroupUser *)value;
- (void)removeGroupUsersObject:(GroupUser *)value;
- (void)addGroupUsers:(NSSet *)value;
- (void)removeGroupUsers:(NSSet *)value;
@end

