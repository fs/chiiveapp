//
//  UserModel.m
//  chiive
//
//  Created by Arrel Gray on 9/19/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "UserModel.h"
#import "User.h"
#import "Group.h"
#import "Global.h"
#import "GroupUser.h"
#import "ManagedObjectsController.h"


@implementation UserModel
@synthesize user = _user, group = _group;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (NSString *)userList
{
	NSMutableString *list = [NSMutableString stringWithString:@""];
	NSInteger count = 1;
	NSInteger max = 2;
	NSInteger total = self.numberOfChildren;
	if (total == max + 1) max++;
	
	for (User *user in self.children) {
		NSString *person = user.displayName;
		if (count == 1)
			[list appendFormat:@"%@", person];
		else if (count == max && count < total)
		{
			[list appendFormat:@", %@, and %d more", person, total - count];
			break;
		}
		else
			[list appendFormat:@", %@", person];
		count++;
	}
	return list;
}

- (NSInteger)numberOfFriendRequests
{
	// TODO: Cache this value and update as friends are added/removed!
	_numberOfFriendRequests = 0;
	
	for (User *user in self.children)
		if (user.isFan && !user.isFriend)
			_numberOfFriendRequests++;
		
	return _numberOfFriendRequests;
}

- (void)loadSavedFriends
{
	// if this is not the current user, do not load any saved friends
	if (_user != [Global getInstance].currentUser)
		return;

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:self.requestEntity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"fandomId > 0"]];
	
	// Execute the fetch
	NSArray *savedChildren = [[ManagedObjectsController getInstance] executeFetchRequest:request];
	if (!!savedChildren)
	{
		[self beginUpdates];
		[self insertChildren:savedChildren];
		[self.children sortUsingDescriptors:self.sortDescriptors];
		[self endUpdates];
		[self didFinishLoad];
	}
	[request release];
}	

- (void)setUser:(User *)user
{
	if (user != _user)
	{
		[self removeChildren];
		
		[user retain];
		[_user release];
		_user = user;
		
		[self loadSavedFriends];
	}
}

- (void)setGroup:(Group *)group
{
	if (group != _group)
	{
		[self removeChildren];
		
		[group retain];
		[_group release];
		_group = group;
		
		[self beginUpdates];
		for (GroupUser *groupUser in self.group.groupUsers) {
			[self insertChild:groupUser.user atIndex:0];
		}
		[self.children sortUsingDescriptors:self.sortDescriptors];
		[self endUpdates];
		[self didFinishLoad];
	}
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTModel (Children)

- (Class)childClass
{
	return [User class];
}

- (NSString *)childrenURL
{
	// if no user, nothing to search for
	if (!self.user)
		return nil;
	
	return [NSMutableString stringWithFormat:@"%@users/%@/friends.json",
			[Global getInstance].sitePath,
			self.user.UUID
			];
}

- (NSArray *)sortDescriptors
{
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
	return [NSArray arrayWithObject:sortDescriptor];
}

- (BOOL)insertChild:(RESTObject *)child atIndex:(NSInteger)index
{
	// create the group user association if needed
	if (!!self.group && ![self.children containsObject:child])
	{
		NSPredicate *filter = [NSPredicate predicateWithFormat: @"group == %@", self.group];
		NSSet *groupUsersFiltered = [[(User *)child groupUsers] filteredSetUsingPredicate:filter];
		
		// if no relationship was found
		if (!groupUsersFiltered || [groupUsersFiltered count] == 0)
		{
			// create the relationship
			GroupUser *groupUser = (GroupUser *)[ManagedObjectsController objectWithClass:[GroupUser class]];
			groupUser.group = self.group;
			groupUser.user = (User *)child;
		}
	}
	
	return [super insertChild:child atIndex:index];
}

- (void)removeChild:(RESTObject *)child
{
	[super removeChild:child];
	
	// if this user was removed from the current user's friend list, it means all friend IDs should be removed
	if (self.user == [Global getInstance].currentUser)
	{
		User *childUser = (User *)child;
		childUser.fandomId = nil;
		childUser.friendshipId = nil;
	}
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_user);
	TT_RELEASE_SAFELY(_group);
	[super dealloc];
}

@end