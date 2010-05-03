//
//  User.h
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTObject.h"

@class GroupUser;
@class GroupModel;
@class UserModel;

@interface User : RESTObject {
	// store password in memory (just for creating accounts), not in the DB
	NSString				*_password;

	GroupModel				*_groupModel;
	GroupModel				*_suggestedGroupModel;
	UserModel				*_friendModel;
	
	// store local image of avatar for creating/updating
	UIImage					*_avatarImage;
}

@property (nonatomic, retain)	NSString				*login;
@property (nonatomic, retain)	NSString				*email;
@property (nonatomic, retain)	NSString				*firstName;
@property (nonatomic, retain)	NSString				*lastName;
@property (nonatomic, retain)	NSString				*name;
@property (nonatomic, retain)	NSString				*password;
@property (nonatomic, retain)	NSNumber				*facebookUid;
@property (nonatomic, retain)	NSNumber				*friendshipId;
@property (nonatomic, retain)	NSNumber				*fandomId;
@property (nonatomic, retain)	NSString				*URLForAvatar;
@property (nonatomic, retain)	NSString				*singleAccessToken;

@property (nonatomic, readonly)	NSString				*displayName;

@property (nonatomic, readonly)	NSUInteger				numGroups;
@property (nonatomic, readonly)	NSUInteger				numLocalGroups;
@property (nonatomic, assign)		NSUInteger				numRemoteGroups;
@property (nonatomic, retain)		NSNumber				*numRemoteGroupsHolder;

@property (nonatomic, readonly)	NSUInteger				numPosts;
@property (nonatomic, assign)		NSUInteger				numRemotePosts;
@property (nonatomic, retain)		NSNumber				*numRemotePostsHolder;

@property (nonatomic, readonly)	NSUInteger				numFriends;
@property (nonatomic, assign)		NSUInteger				numRemoteFriends;
@property (nonatomic, retain)		NSNumber				*numRemoteFriendsHolder;

@property (nonatomic, readonly)	NSUInteger				numFriendRequests;
@property (nonatomic, assign)		NSUInteger				numRemoteFriendRequests;
@property (nonatomic, retain)		NSNumber				*numRemoteFriendRequestsHolder;


@property (nonatomic, retain)		NSSet					*groupUsers;

@property (nonatomic, readonly)	BOOL					isFriend;
@property (nonatomic, readonly)	BOOL					isFan;
@property (nonatomic, readonly)	BOOL					isMutualFriend;

@property (nonatomic, retain)		UIImage				*avatarImage;

@property (nonatomic, readonly)	GroupModel				*groupModel;
@property (nonatomic, readonly)	GroupModel				*suggestedGroupModel;
@property (nonatomic, readonly)	UserModel				*friendModel;

@end

@interface User (GroupUsersMethods)
- (void)addGroupUsersObject:(GroupUser *)value;
- (void)removeGroupUsersObject:(GroupUser *)value;
- (void)addGroupUsers:(NSSet *)value;
- (void)removeGroupUsers:(NSSet *)value;
@end

