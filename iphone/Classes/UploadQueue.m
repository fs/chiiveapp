//
//  UploadQueue.m
//  chiive
//
//  Created by Arrel Gray on 9/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "UploadQueue.h"
#import "Global.h"
#import "RESTObject.h"
#import "ManagedObjectsController.h"
#import "Group.h"
#import "Post.h"
#import "Comment.h"
#import "PostModel.h"
#import "Friendship.h"


@implementation UploadQueue

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UploadQueue

- (NSMutableArray *)objects
{
	if (nil == _objects)
		_objects = [[NSMutableArray alloc] init];
	return _objects;
}

- (NSUInteger)numberOfObjects
{
	return [self.objects count];
}

- (NSMutableArray *)backgroundObjects
{
	if (nil == _backgroundObjects)
		_backgroundObjects = [[NSMutableArray alloc] init];
	return _backgroundObjects;
}

- (NSUInteger)numberOfBackgroundObjects
{
	return [self.backgroundObjects count];
}

- (RESTObject *)objectAtIndex:(NSUInteger)index
{
	if (index < self.numberOfObjects)
		return [self.objects objectAtIndex:index];
	
	return nil;
}

- (BOOL)objectIsLoaded:(id<TTModel>)object
{
	if ([object isLoading])
		return NO;
	
	if ([object isKindOfClass:[RESTObject class]])
	{
		RESTObject *restObject = (RESTObject *)object;
		if (!restObject.hasSynced)
			return NO;
		
		if (restObject.isOutdated)
			return NO;
	}
	
	return [object isLoaded];
}

- (void)cancelLoadAfterDelay
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(onLoadAfterDelay) object:nil];
}
- (void)loadAfterDelay
{
	[self cancelLoadAfterDelay];
	[self performSelector:@selector(onLoadAfterDelay)
			   withObject:nil afterDelay:0.5];
}

- (void)onLoadAfterDelay
{
	[self load:TTURLRequestCachePolicyNone more:NO];
}

- (void)addObjectToQueue:(id<TTModel>)object
{
	if ([object	isKindOfClass:[Friendship class]])
	{
		if (![self.backgroundObjects containsObject:object])
		{
			[self.backgroundObjects addObject:object];
			[[object delegates] addObject:self];
		}
		return;
	}
	
	if ([self.objects containsObject:object])
		return;
	
	// if this is a post
	if ([object isKindOfClass:[Post class]])
	{
		Post *post = (Post *)object;
		
		// if it's group is unsynced, make sure it's added to the list first
		if (!!post.group && !post.group.hasSynced)
		{
			[self addObjectToQueue:post.group];
		}
	}
	
	[self.objects addObject:object];
	[[object delegates] addObject:self];
	
	// notify delegates
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:object] inSection:0];
	[self didInsertObject:object atIndexPath:indexPath];
}

- (void)removeObjectFromQueue:(id<TTModel>)object
{
	// if this is a background object
	if ([self.backgroundObjects containsObject:object])
	{
		// remove from the list and stop
		[[object delegates] removeObject:self];
		[self.backgroundObjects removeObject:object];
	}
	
	// if this is not in the list of main objects
	if (![self.objects containsObject:object])
		return;
	
	[[object delegates] removeObject:self];
	
	// grab the path and remove
	// NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:object] inSection:0];
	[self.objects removeObject:object];
	
	// notify delegates
	[self didFinishLoad];
	
//	[self didDeleteObject:object atIndexPath:indexPath];
}

- (void)addUnsyncedObjectsWithClass:(Class)klass
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[ManagedObjectsController entityForName:NSStringFromClass(klass)]];
	[request setPredicate:[NSPredicate predicateWithFormat: @"hasSyncedHolder != 1 OR hasSyncedHolder == NULL OR isOutdatedHolder == 1 OR shouldDeleteHolder == 1"]];
	
	// Execute the fetch
	NSArray *savedChildren = [[ManagedObjectsController getInstance] executeFetchRequest:request];
	
	if (!!savedChildren)
	{
		for (RESTObject *child in savedChildren) {
			[self addObjectToQueue:child];
		}
	}
}

- (void)retrieveManagedChildren
{
	[self addUnsyncedObjectsWithClass:[Group class]];
	[self addUnsyncedObjectsWithClass:[Post class]];
	[self addUnsyncedObjectsWithClass:[Comment class]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTModel

- (BOOL)isLoading
{
	for (RESTObject *object in self.objects)
	{
		if ([object isLoading])
			return YES;
	}
	return NO;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	// cancel any delayed requests
	[self cancelLoadAfterDelay];
	
	if (more)
		return;
	
	// only load one at a time
	if ([self isLoading])
		return;
	
	// if loading is paused, loop around
	if ([TTURLRequestQueue mainQueue].suspended)
		[self loadAfterDelay];
	
	while (self.numberOfObjects > 0)
	{
		// load up the next post in the queue
		TTModel *nextObject = [self.objects objectAtIndex:0];
		
		// If this item is already synced, not outdated, and not currently loading
		if ([self objectIsLoaded:nextObject])
		{
			// remove from the list of items in the queue
			[self removeObjectFromQueue:nextObject];
			nextObject = nil;
		}
		// if this item needs to be uploaded, trigger now and break the loop
		else
		{
			[nextObject load:TTURLRequestCachePolicyNone more:NO];
			return;
		}
	}
	
	// if we have background objects to load
	while (self.numberOfBackgroundObjects > 0)
	{
		// load up the next post in the queue
		TTModel *nextObject = [self.backgroundObjects objectAtIndex:0];
		if ([self objectIsLoaded:nextObject])
		{
			// remove from the list of items in the queue
			[self removeObjectFromQueue:nextObject];
			nextObject = nil;
		}
		// if this item needs to be uploaded, trigger now and break the loop
		else
		{
			[nextObject load:TTURLRequestCachePolicyNone more:NO];
			return;
		}
	}
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model
{
	if ([self.objects containsObject:model])
		[self didStartLoad];
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	// remove current object from queue
	[self removeObjectFromQueue:model];
	
	// notify delegates
	//[self didFinishLoad];
	
	// loop through again
	[self load:TTURLRequestCachePolicyNone more:NO];
}

/**
 * If the model failed to upload, just stop here and wait for the user to re-initiate.
 */
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error
{
	NSLog(@"Upload Queue did fail with error: %@", [error localizedDescription]);
	
	if ([self.objects containsObject:model])
		[self didFailLoadWithError:error];
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
	if ([self.objects containsObject:model])
		[self didCancelLoad];
}

- (void)modelDidChange:(id<TTModel>)model
{
	if ([model isKindOfClass:[RESTObject class]])
	{
		// if the model is a child that was destroyed, remove from the list
		RESTObject *child = (RESTObject *)model;
		if ([child isDeleted])
			[self removeObjectFromQueue:child];
	}
	
	if ([self.objects containsObject:model])
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:model] inSection:0];
		[self didUpdateObject:model atIndexPath:indexPath];
	}
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Singleton Setup

static UploadQueue *sharedInstance = nil;

+ (UploadQueue *)getInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
			return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
