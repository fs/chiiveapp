//
//  User.m
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "User.h"
#import "Global.h"
#import "FormatterHelper.h"
#import "GroupUser.h"
#import "Group.h"
#import "GroupModel.h"
#import "UserModel.h"
#import "NSDictionary+Casting.h"

@implementation User
@dynamic name, login, email, facebookUid, URLForAvatar, singleAccessToken, 
		 numRemotePostsHolder, numRemoteGroupsHolder, numRemoteFriendsHolder, numRemoteFriendRequestsHolder,
		 groupUsers, friendshipId, fandomId,
		 firstName, lastName;
@synthesize password = _password, avatarImage = _avatarImage;



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTObject

- (void)updateWithProperties:(NSDictionary *)properties {
	[super updateWithProperties:properties];
	
	NSArray *groupsList = [properties objectForKey:@"events"];
	if (!!groupsList) {
		[self.groupModel parseChildrenList:groupsList];
		self.groupModel.loadedTime = self.lastSynced;
	}
	
	if (!![properties objectForKey:@"single_access_token"])
		self.singleAccessToken = [properties stringForKey:@"single_access_token"];
	
	if (!![properties objectForKey:@"name"])
		self.name = [properties stringForKey:@"name"];
	
	if (!![properties objectForKey:@"first_name"])
		self.firstName = [properties stringForKey:@"first_name"];
	
	if (!![properties objectForKey:@"last_name"])
		self.lastName = [properties stringForKey:@"last_name"];
	
	if (!![properties objectForKey:@"login"])
		self.login = [properties stringForKey:@"login"];
	
	if (!![properties objectForKey:@"email"])
		self.email = [properties stringForKey:@"email"];
	
	if (!![properties objectForKey:@"avatar"])
		self.URLForAvatar = [properties stringForKey:@"avatar"];
	
	if (!![properties objectForKey:@"facebook_uid"])
		self.facebookUid = [properties numberForKey:@"facebook_uid"];
	
	if (!![properties objectForKey:@"posts_count"])
		self.numRemotePosts = [properties intForKey:@"posts_count"];
	
	if (!![properties objectForKey:@"personal_sets_count"])
		self.numRemoteGroups = [properties intForKey:@"personal_sets_count"];
	
	if (!![properties objectForKey:@"friendship_id"])
		self.friendshipId = [properties numberForKey:@"friendship_id"];
	
	if (!![properties objectForKey:@"fandom_id"])
		self.fandomId = [properties numberForKey:@"fandom_id"];
	
	//	if (!![properties objectForKey:@"shared_events_count"])
//		self.numberOfSharedEvents = [properties intForKey:@"shared_events_count"];
}

- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format
{
	[super setDefaultParamsForRequest:request withFormat:format];
	
	if (!!self.login)
		[request.parameters setObject:self.login forKey:[NSString stringWithFormat:format, @"login"]];
	
	if (!!self.firstName)
		[request.parameters setObject:self.firstName forKey:[NSString stringWithFormat:format, @"first_name"]];
	
	if (!!self.lastName)
		[request.parameters setObject:self.lastName forKey:[NSString stringWithFormat:format, @"last_name"]];

	if (!!self.email)
		[request.parameters setObject:self.email forKey:[NSString stringWithFormat:format, @"email"]];
	
	if (!!self.password && ![self.password isEmptyOrWhitespace])
	{
		[request.parameters setObject:self.password forKey:[NSString stringWithFormat:format, @"password"]];
		[request.parameters setObject:self.password forKey:[NSString stringWithFormat:format, @"password_confirmation"]];
	}
	
	// if we have a new avatar, attach it as well
	if (!!self.avatarImage)
		[request.parameters setObject:self.avatarImage forKey:[NSString stringWithFormat:format, @"avatar_image"]];
}

/**
 * Never destroy the current user, and do not destroy users that still have associated groups.
 */
- (void)destroy
{
	if (![[Global getInstance].currentUserId isEqualToString:self.UUID] && [self.groupUsers count] == 0)
		[super destroy];
}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

/**
 * Pass through update methods called from the GroupModel
 */
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didUpdateObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didInsertObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didDeleteObject:object atIndexPath:indexPath];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public (Models)

- (GroupModel *)groupModel
{
	if (!_groupModel)
	{
		_groupModel = [[GroupModel alloc] init];
		_groupModel.user = self;
		[[_groupModel delegates] addObject:self];
	}
	return _groupModel;
}

- (GroupModel *)suggestedGroupModel
{
	if (!_suggestedGroupModel && self == [Global getInstance].currentUser)
	{
		_suggestedGroupModel = [[GroupModel alloc] init];
		_suggestedGroupModel.isSuggestedList = YES;
	}
	return _suggestedGroupModel;
}

- (UserModel *)friendModel
{
	if (!_friendModel && self == [Global getInstance].currentUser)
	{
		_friendModel = [[UserModel alloc] init];
		_friendModel.user = self;
	}
	return _friendModel;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public (Accessors)

- (NSString *)displayName
{
	if (self == [Global getInstance].currentUser)
		return @"Me";
	
	else if (!self.firstName || !self.lastName || (!self.firstName.length && !self.lastName.length))
		return self.name;
	
	else
		return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSUInteger)numGroups
{
	return self.numRemoteGroups + self.numLocalGroups;
}

- (NSUInteger)numLocalGroups
{
	if (self != [Global getInstance].currentUser)
		return 0;
	
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"hasSynced == NO"];
	return [[self.groupModel.children filteredArrayUsingPredicate:filter] count];
}

- (NSUInteger)numRemoteGroups
{
	return [self.numRemoteGroupsHolder intValue];
}

- (void)setNumRemoteGroups:(NSUInteger)value
{
	self.numRemoteGroupsHolder = [NSNumber numberWithInt:value];
}

- (NSUInteger)numPosts
{
	return self.numRemotePosts;
}

- (NSUInteger)numRemotePosts
{
	return [self.numRemotePostsHolder intValue];
}

- (void)setNumRemotePosts:(NSUInteger)value
{
	self.numRemotePostsHolder = [NSNumber numberWithInt:value];
}

- (NSUInteger)numFriends
{
	return self.numRemoteFriends;
}

- (NSUInteger)numRemoteFriends
{
	return [self.numRemoteFriendsHolder intValue];
}

- (void)setNumRemoteFriends:(NSUInteger)value
{
	self.numRemoteFriendsHolder = [NSNumber numberWithInt:value];
}

- (NSUInteger)numFriendRequests
{
	return self.numRemoteFriendRequests;
}

- (NSUInteger)numRemoteFriendRequests
{
	return [self.numRemoteFriendRequestsHolder intValue];
}

- (void)setNumRemoteFriendRequests:(NSUInteger)value
{
	self.numRemoteFriendRequestsHolder = [NSNumber numberWithInt:value];
}

- (BOOL)isMutualFriend
{
	return self.isFriend && self.isFan;
}

- (BOOL)isFriend
{
	return [self.friendshipId intValue] != 0;
}

- (BOOL)isFan
{
	return [self.fandomId intValue] != 0;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_groupModel);
	TT_RELEASE_SAFELY(_suggestedGroupModel);
	TT_RELEASE_SAFELY(_friendModel);
	[super dealloc];
}

@end
