//
//  GroupModel.m
//  chiive
//
//  Created by 17FEET on 8/27/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "GroupModel.h"
#import "Group.h"
#import "Post.h"
#import "UserModel.h"
#import "UploadQueue.h"
#import "PostModel.h"
#import "User.h"
#import "Global.h"
#import "ManagedObjectsController.h"
#import "FormatterHelper.h"
#import "CLController.h"
#import "GroupUser.h"

@implementation GroupModel
@synthesize isSuggestedList = _isSuggestedList, user = _user;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)onLoadAfterDelay
{
	_delayedLoading = NO;
	[self load:TTURLRequestCachePolicyNone more:NO];
}

- (void)cancelLoadAfterDelay
{
	_delayedLoading = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(onLoadAfterDelay) object:nil];
}
- (void)loadAfterDelay
{
	BOOL alreadyLoading = [self isLoading];
	
	[self cancelLoadAfterDelay];
	_delayedLoading = YES;
	[self performSelector:@selector(onLoadAfterDelay)
			   withObject:nil afterDelay:0.3];
	
	if (!alreadyLoading)
		[self didStartLoad];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setUser:(User *)user
{
	if (user != _user)
	{
		[self removeChildren];
		
		[user retain];
		[_user release];
		_user = user;
		
		[self beginUpdates];
		for (GroupUser *groupUser in self.user.groupUsers) {
			[self insertChild:groupUser.group atIndex:-1];
		}
		[self.children sortUsingDescriptors:self.sortDescriptors];
		[self endUpdates];
		[self didFinishLoad];
	}
}

- (void)setIsSuggestedList:(BOOL)isSuggestedList
{
	if (isSuggestedList != _isSuggestedList)
	{
		[self removeChildren];
		
		// reset the user
		[_user release];
		_user = [[Global getInstance].currentUser retain];
		
		_isSuggestedList = isSuggestedList;
		
		[self beginUpdates];
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:self.requestEntity];
		[request setPredicate:[NSPredicate predicateWithFormat:@"isSuggestedGroupHolder == YES"]];
		[request setSortDescriptors:self.sortDescriptors];
		
		// Execute the fetch
		NSArray *savedChildren = [[ManagedObjectsController getInstance] executeFetchRequest:request];
		if (!savedChildren)
			return;
		
		for (Group *group in savedChildren)
		{
			// if this group is no longer active (based on timespan)
			if (![group isActive])
			{
				// if it's one of the current user's groups, flag as no longer suggested
				if (group.isCurrentUserGroup)
					group.isSuggestedGroup = NO;
				
				// if it's not the current user's group, destroy it
				else
					[group destroy];
			}
			else
			{
				[self insertNewChild:group];
			}
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
	return [Group class];
}

- (NSString *)childName
{
	return @"event";
}

- (NSString *)childrenName
{
	return @"events";
}

- (NSString *)childrenURL
{
	if (self.isSuggestedList)
	{
		return [NSString stringWithFormat:@"%@users/%@/suggested.json",
				[Global getInstance].sitePath,
				self.user.UUID
				];
	}
	else
	{
		return [NSString stringWithFormat:@"%@users/%@/%@.json",
				[Global getInstance].sitePath,
				self.user.UUID,
				@"events"
				];
	}	
}

- (TTURLRequest *)childrenRequest
{
	TTURLRequest *request = super.childrenRequest;
	if (self.isSuggestedList)
	{
		request.httpMethod = @"POST";
		request.contentType = nil; //@"application/json";
		[request.parameters setObject:[NSString stringWithFormat:@"%f", [CLController getInstance].latitude] forKey:@"metrics_manager[latitude]"];
		[request.parameters setObject:[NSString stringWithFormat:@"%f", [CLController getInstance].longitude] forKey:@"metrics_manager[longitude]"];
		[request.parameters setObject:[FormatterHelper utcStringFromDateTime:[NSDate date]] forKey:@"metrics_manager[time_at]"];
	}
	
	// load a new batch if this is old data
	request.cacheExpirationAge = -5000; //self.defaultCacheExpirationAge; //[TTURLCache sharedCache].invalidationAge;
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	
	return request;
}

- (void)updateChild:(RESTObject *)child withProperties:properties
{
	// if this is the current user's group, make sure the user is in the group
	if (self.user == [Global getInstance].currentUser)
	{
		Group *childGroup = (Group *)child;
		[childGroup.friendModel insertChild:[Global getInstance].currentUser atIndex:0];
	}
	
	[super updateChild:child withProperties:properties];
	
	if (self.isSuggestedList)
	{
		Group *group = (Group *)child;
		group.isSuggestedGroup = self.isSuggestedList;
	}
}

- (void)insertChildren:(NSArray *)children
{
	[super insertChildren:children];
}

- (void)removeChild:(RESTObject *)child
{
	if (![child isKindOfClass:[Group class]])
		return;
	
	Group *group = (Group *)child;
	
	if (self == [Global getInstance].currentUser.groupModel)
	{
		for (GroupUser *groupUser in group.groupUsers) 
		{
			if (groupUser.user == [Global getInstance].currentUser)
			{
				groupUser.user = nil;
				groupUser.group = nil;
				[[ManagedObjectsController getInstance] deleteObject:groupUser];
				break;
			}
		}
	}
	
	if (self.isSuggestedList)
		group.isSuggestedGroup = NO;
	
	[super removeChild:child];
}

- (NSArray *)sortDescriptors
{
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"happenedAt" ascending:NO] autorelease];
	return [NSArray arrayWithObject:sortDescriptor];
}

- (NSUInteger)numberOfChildren
{
	if (self.isSuggestedList)
		return self.numberOfChildrenLoaded;
	else
		return self.user.numGroups;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTModel (Retrieval)

- (BOOL)destroyChildrenOnRemove
{
	// If this is a suggested list, destroy the children when removed from the list
	return !self.isSuggestedList;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoading
{
	if (_delayedLoading) 
		return YES;
	
	else
		return [super isLoading];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequest

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	if ([super isLoading])
		return;
	
	// if we've already retrieve the managed children, and we're looking for a suggeste list but don't yet have a GPS reading, stop
	if (self.isSuggestedList && ![[CLController getInstance] hasLocation])
	{
		[self loadAfterDelay];
	}
	else
		[super load:cachePolicy more:more];
}

- (void)cancel
{
	[self cancelLoadAfterDelay];
	[super cancel];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate


/**
 * Called by the Group object when the Group's Posts objects have loaded.
 * Or by the UploadQueue object when a post was synced with the server
 */
- (void)modelDidFinishLoad:(id<TTModel>)model
{
	// if this is a child (Group) that was updated, notify the delegates
	if ([model isKindOfClass:[Group class]])
	{
		Group *group = (Group *)model;
		NSIndexPath *indexPath = [self getIndexPathOfChild:group];
		[self didUpdateObject:group atIndexPath:indexPath];
	}
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_user);
	[super dealloc];
}

@end
