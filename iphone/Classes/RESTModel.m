//
//  ParentModel.m
//  chiive
//
//  Created by Arrel Gray on 9/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "RESTObject.h"
#import "Global.h"
#import "ManagedObjectsController.h"
#import "FormatterHelper.h"
#import "JSON.h"
#import "Group.h"
#import "User.h"
#import "UserModel.h"
#import "PostModel.h"

#import "GroupUser.h"

@implementation RESTModel
@synthesize isUpdating = _isUpdating;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoaded
{
	return !!_loadedTime || self.numberOfChildren > 0;
}

- (BOOL)isOutdated
{
	return (!_loadedTime);
}

- (void)beginUpdates {
	self.isUpdating = YES;
	//[super beginUpdates];
}

- (void)endUpdates {
	self.isUpdating = NO;
	//[super endUpdates];
}

/**
 * Don't notify delegates of individual item updates if we are in the midst of an update.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (!self.isUpdating)
		[super didUpdateObject:object atIndexPath:indexPath];
}

- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (!self.isUpdating)
		[super didInsertObject:object atIndexPath:indexPath];
}

- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (!self.isUpdating)
		[super didDeleteObject:object atIndexPath:indexPath];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Child Accessors

- (Class)childClass
{
	return [RESTModel class];
}

- (NSMutableArray *)children
{
	if (nil == _children)
		_children = [[NSMutableArray alloc] init];
	
	return _children;
}

- (NSUInteger)numberOfChildrenLoaded
{
	return [self.children count];
}

/**
 * Checks the number of children in memory by default.
 * Should be subclassed to pull cached counters from RESTObjects.
 */
- (NSUInteger)numberOfChildren
{
	return self.numberOfChildrenLoaded;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Child Data

- (NSIndexPath *)getIndexPathOfChild:(RESTObject *)child
{
	return [NSIndexPath indexPathForRow:[self.children indexOfObject:child] inSection:0];
	
	for (id delegate in _delegates)
	{
		if ([delegate isKindOfClass:[TTTableViewController class]])
		{
			TTTableViewController *controller = (TTTableViewController *)delegate;
			TTListDataSource *source = (TTListDataSource *)controller.dataSource;
			NSIndexPath *path = [source indexPathOfItemWithUserInfo:child.UUID];
			if (nil == path)
				path = [NSIndexPath indexPathForRow:[self.children indexOfObject:child] inSection:0];
			return path;
		}
		else
		{
			return [NSIndexPath indexPathForRow:[self.children indexOfObject:child] inSection:0];
		}
	}
	return nil;
}

- (void)updateChild:(RESTObject *)child withProperties:(NSDictionary *)properties
{
	[child updateWithProperties:properties];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	for (RESTObject *child in self.children) {
		[[child delegates] removeObject:self];
	}
	TT_RELEASE_SAFELY(_children);
	[super dealloc];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

/**
 * Pass through for child model delegate methods.
 */
- (void)didUpdateChild:(RESTObject *)child
{
	NSIndexPath *indexPath = [self getIndexPathOfChild:child];
	if (!!indexPath)
		[self didUpdateObject:child atIndexPath:indexPath];
}

//- (void)modelDidStartLoad:(id<TTModel>)model
//{
//	[self didUpdateChild:(RESTObject *)model];
//}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	[self didUpdateChild:(RESTObject *)model];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
	[self didUpdateChild:(RESTObject *)model];
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
	[self didUpdateChild:(RESTObject *)model];
}

- (void)modelDidChange:(id<TTModel>)model
{
	[self didUpdateChild:(RESTObject *)model];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	[self didUpdateChild:(RESTObject *)model];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	[self didUpdateChild:(RESTObject *)model];
}

@end