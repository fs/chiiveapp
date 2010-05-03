//
//  Group.m
//  chiive
//
//  Created by 17FEET on 8/25/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "Group.h"
#import "RESTObject.h"
#import "GroupModel.h"
#import "UserModel.h"
#import "Post.h"
#import "PostModel.h"
#import "Global.h"
#import "FormatterHelper.h"
#import "JSON.h"
#import "CLController.h"
#import "FormatterHelper.h"
#import "ManagedObjectsController.h"
#import "GroupUser.h"
#import "NSDictionary+Casting.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static const double kRelevantInterval = 21600.0;// 60 * 60 * 6; // seconds * minutes * hours

NSString * const GroupPrivacyWhoCanJoin_toString[] = {
@"Everyone",
@"Friends"
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation Group
@synthesize privacyWhoCanJoin = _privacyWhoCanJoin;
@dynamic title, happenedAt, latitude, longitude,
		 owner, groupUsers, isSuggestedGroupHolder, 
		 numRemotePostsHolder, numRemoteUsersHolder, posts;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource
/*
- (NSString *)title
{
	return self.prettyTitle;
}
*/
/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
-(NSInteger)numberOfPhotos
{
	return self.numPosts;
}

/**
 * The maximum index of photos that have already been loaded.
 */
-(NSInteger)maxPhotoIndex
{
	return self.postModel.maxPhotoIndex;
}

/**
 * Return the Post object at the given index, or nil if out of range.
 */
- (id<TTPhoto>)photoAtIndex:(NSInteger)index
{
	return [self.postModel photoAtIndex:index];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTObject

- (void)updateWithProperties:(NSDictionary *)properties
{
	[super updateWithProperties:properties];
	
	// attendees
	NSArray *friendsList = [properties objectForKey:@"users"];
	if (!!friendsList && [friendsList count] > 0) {
		
		if (!!self.loadedTime)
			self.friendModel.loadedTime = self.loadedTime;
		
		[self.friendModel parseChildrenList:friendsList];
		
		// remove any old groupUser relationships
		for (GroupUser *groupUser in self.groupUsers)
		{
			if (![self.friendModel.children containsObject:groupUser.user])
				[[ManagedObjectsController getInstance] deleteObject:groupUser];
		}
	}
	
	// owner data
	NSDictionary *ownerObject = [properties objectForKey:@"owner"];
	if (!!ownerObject)
	{
		[self.friendModel parseChildrenList:[NSArray arrayWithObject:ownerObject] withRemove:NO];
		
		NSDictionary *ownerData = [ownerObject objectForKey:@"user"];
		NSString *ownerId = [ownerData objectForKey:@"uuid"];
		
		if (!self.owner || ![self.owner.UUID isEqualToString:ownerId])
			self.owner = (User *)[self.friendModel getChildWithUUID:ownerId];
	}
	
	// owner id, to be matched from the users list
	if (nil != [properties objectForKey:@"owner_uuid"])
	{
		NSString *ownerId = [properties stringForKey:@"owner_uuid"];
		if (!self.owner || ![self.owner.UUID isEqualToString:ownerId])
		{
			self.owner = (User *)[self.friendModel getChildWithUUID:ownerId];
			
			if (!self.owner)
			{
				self.owner = (User *)[ManagedObjectsController objectWithClass:[User class]];
				self.owner.UUID = ownerId;
				self.owner.hasSynced = YES;
			}
		}
	}
	
	// posts
	NSArray *postsList = [properties objectForKey:@"posts"];
	if (!!postsList && [postsList count] > 0) {
		self.postModel.loadedTime = self.loadedTime;
		[self.postModel beginUpdates];
		[self.postModel parseChildrenList:postsList];
		[self.postModel endUpdates];
		[self.postModel didFinishLoad];
	}
	
	// single post
	NSDictionary *postObject = [properties objectForKey:@"post"];
	if (!!postObject) {
		[self.postModel parseChildrenList:[NSArray arrayWithObject:postObject] withRemove:NO];
	}
	
	// number of posts on the server
	if (nil != [properties objectForKey:@"posts_count"])
		self.numRemotePosts = [properties intForKey:@"posts_count"];
	
	// number of posts on the server
	if (nil != [properties objectForKey:@"users_count"])
		self.numRemoteUsers = [properties intForKey:@"users_count"];
	
//	if (!self.title)
//	{	
		if (nil != [properties objectForKey:@"title"])
			self.title = [properties objectForKey:@"title"];
		
		if (nil != [properties objectForKey:@"latitude"])
			self.latitude = (NSNumber *)[properties objectForKey:@"latitude"];
		
		if (nil != [properties objectForKey:@"longitude"])
			self.longitude = (NSNumber *)[properties objectForKey:@"longitude"];
		
		//NSLog(@"Timer: Start parse time");
		if (nil != [properties objectForKey:@"time_at"])
		{
			NSString *timeAtString = [properties objectForKey:@"time_at"];
			self.happenedAt = [FormatterHelper dateTimeFromString:timeAtString];
		}
//	}

	//NSLog(@"Timer: Finish parse time");
	
	self.postModel.loadedTime = [NSDate date];
}

- (NSString *)baseURL
{
	return [NSString stringWithFormat:@"%@users/%@/%@",
			[Global getInstance].sitePath,
			self.owner.UUID,
			self.objectNamePlural
			];
}

- (NSString *)objectName
{
	return @"event";
}

- (NSString *)objectNamePlural
{
	return @"events";
}

- (NSString *)paramFormat
{
	return [NSString stringWithFormat:@"%@[personal_sets_attributes][0][%%@]", self.objectName];
}

- (NSString *)rootParamFormat
{
	return [NSString stringWithFormat:@"%@[%%@]", self.objectName];
}

/**
 * For groups, the sync request is a check-in rather than an update.
 * TODO: Add update functionality if current user is also the owner.
 */
- (TTURLRequest *)getUpdateRequest
{
	// always use create requests, which either checks in or updates
//	if (!self.isCurrentUserGroup)
		return [self getCreateRequest];
	
//	else
//		return [super getUpdateRequest];
}

- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format
{
	[super setDefaultParamsForRequest:request withFormat:[self rootParamFormat]];
	
	if (0.0 == [self.latitude doubleValue])
		self.latitude = [NSNumber numberWithDouble:[CLController getInstance].latitude];
	
	if (0.0 == [self.longitude doubleValue])
		self.longitude = [NSNumber numberWithDouble:[CLController getInstance].longitude];
	
	if (!self.happenedAt)
		self.happenedAt = [NSDate date];
	
	if (!self.title)
		self.title = @"Untitled";
	
	
	NSString *public = (GroupPrivacyWhoCanJoinAll == self.privacyWhoCanJoin) ? @"1" : @"0";
	[request.parameters setObject:public forKey:[NSString stringWithFormat:format, @"public"]];
	
	[request.parameters setObject:[NSString stringWithFormat:@"%@", self.latitude] forKey:[NSString stringWithFormat:format, @"latitude"]];
	[request.parameters setObject:[NSString stringWithFormat:@"%@", self.longitude] forKey:[NSString stringWithFormat:format, @"longitude"]];
	[request.parameters setObject:[FormatterHelper utcStringFromDateTime:self.happenedAt] forKey:[NSString stringWithFormat:format, @"time_at"]];
	[request.parameters setObject:self.title forKey:[NSString stringWithFormat:format, @"title"]];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTObject (CoreData)

- (void)deleteRemote
{
	// remove from the user's group lists
	[[Global getInstance].currentUser.groupModel removeChild:self];
	[[Global getInstance].currentUser.suggestedGroupModel removeChild:self];
	
	// remove the current user from the friends list
	[self.friendModel removeChild:[Global getInstance].currentUser];
	
	[super deleteRemote];
}

- (void)destroy
{
	// remove from the user's group lists
	if ([[Global getInstance].currentUser.groupModel.children containsObject:self])
		[[Global getInstance].currentUser.groupModel removeChild:self];
	
	// remove the current user from the friends list
	if ([self.friendModel.children containsObject:[Global getInstance].currentUser])
		[self.friendModel removeChild:[Global getInstance].currentUser];
	
	// don't destroy if this is a suggested group with a user other than the current user
	if (self.isSuggestedGroup)
	{
		for (GroupUser *groupUser in self.groupUsers) {
			if (groupUser.user != [Global getInstance].currentUser)
				return;
		}
		
		// remove from the suggested group if needed
		if ([[Global getInstance].currentUser.suggestedGroupModel.children containsObject:self])
			[[Global getInstance].currentUser.suggestedGroupModel removeChild:self];
	}
	
	[self.postModel destroyChildren];
	
	// destroy the group
	[super destroy];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

/**
 * Pass through update methods called from the PostModel
 */
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didUpdateObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didInsertObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if ([object isKindOfClass:[Post class]])
	{
		Post *post = (Post *)object;
		if (post.hasSynced)
			self.numRemotePosts--;
		// TODO: Enable local post decrement if caching is enabled
		// else
		// 	self.numLocalPosts--;
	}
	[self didDeleteObject:object atIndexPath:indexPath];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (BOOL)isActive
{
	return -[self.happenedAt timeIntervalSinceNow] < kRelevantInterval;
}

- (NSComparisonResult)happenedAtCompare:(Group *)group
{
	return [group.happenedAt compare:self.happenedAt];
}

- (void)checkIn
{
	// set the current global group
	[Global getInstance].currentGroup = self;
	
	// TODO: Sync with server!
}


- (void)insertPost:(Post *)post
{
	[self.postModel insertNewChild:post];
}

- (void)removePost:(Post *)post
{
	[self.postModel removeChild:post];
}

- (PostModel *)postModel
{
	if (nil == _postModel)
	{
		_postModel = [[PostModel alloc] init];
		[[_postModel delegates] addObject:self];
		
		// assign this group to the post model
		_postModel.group = self;
	}
	
	return _postModel;
}

- (UserModel *)friendModel
{
	if (nil == _friendModel)
	{
		_friendModel = [[UserModel alloc] init];
		_friendModel.group = self;
		
		NSEnumerator *friendsEnum = [self.groupUsers objectEnumerator];
		GroupUser *groupUser;
		while ((groupUser = [friendsEnum nextObject]) != nil)
			[_friendModel insertNewChild:groupUser.user];
	}
	return _friendModel;
}

- (NSString *)prettyTitle
{
	return (nil == self.title || [self.title isEmptyOrWhitespace]) ? @"Untitled" : self.title;
}

- (NSString *)timeframe
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:self.happenedAt]; 
}

- (BOOL)isCurrentUserGroup
{
	for (GroupUser *groupUser in self.groupUsers) {
		if (groupUser.user == [Global getInstance].currentUser)
			return YES;
	}
	
	return NO;
}

- (BOOL)isSuggestedGroup
{
	return [self.isSuggestedGroupHolder boolValue];
}

- (void)setIsSuggestedGroup:(BOOL)value
{
	self.isSuggestedGroupHolder = [NSNumber numberWithBool:value];
}

- (NSUInteger)numPosts
{
	return self.numRemotePosts + self.numLocalPosts;
}

- (NSUInteger)numLocalPosts
{
	if (!self.isCurrentUserGroup)
		return 0;
	
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"hasSynced == NO"];
	return [[self.posts filteredSetUsingPredicate:filter] count];
}

- (NSUInteger)numRemotePosts
{
	return [self.numRemotePostsHolder intValue];
}

- (void)setNumRemotePosts:(NSUInteger)value
{
	self.numRemotePostsHolder = [NSNumber numberWithInt:value];
}

- (NSUInteger)numUsers
{
	return self.numRemoteUsers;
}

- (NSUInteger)numRemoteUsers
{
	return [self.numRemoteUsersHolder intValue];
}

- (void)setNumRemoteUsers:(NSUInteger)value
{
	self.numRemoteUsersHolder = [NSNumber numberWithInt:value];
}

- (void) dealloc
{
	[[_postModel delegates] removeObject:self];
	[_postModel release];
	
	[[_friendModel delegates] removeObject:self];
	[_friendModel release];
	[super dealloc];
}

@end
