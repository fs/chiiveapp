//
//  RESTModel+Addition.m
//  chiive
//
//  Created by 17FEET on 2/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "ManagedObjectsController.h"
#import "NSDictionary+Casting.h"
#import "JSON.h"


#import "GroupModel.h"

@implementation RESTModel (Addition)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parsing

- (void)parseChildrenData:(NSData *)childrenData
{
    // Parse the JSON data that we retrieved from the server.
	NSString *responseBody = [[[NSString alloc] initWithData:childrenData encoding:NSUTF8StringEncoding] autorelease];
	NSArray *list = [responseBody JSONValue];
	[self parseChildrenList:list];
}

- (void)parseChildrenList:(NSArray *)list
{
//	if ([self isKindOfClass:[GroupModel class]])
//		NSLog(@"%@.parseChildrenList %d begin", NSStringFromClass([self class]), [list count]);
	[self parseChildrenList:list withRemove:YES];
//	if ([self isKindOfClass:[GroupModel class]])
//		NSLog(@"%@.parseChildrenList %d end", NSStringFromClass([self class]), [list count]);
}

- (void)parseChildrenList:(NSArray *)list withRemove:(BOOL)remove
{
	if (!list)
		return;
	
	RESTObject *child = nil;
	NSEnumerator *enumerator;
	id key;
	
	// assume we are deleting all the children
	NSMutableArray *previousChildren = [[NSMutableArray alloc] init];
	if (remove)
		previousChildren = [self.children mutableCopy];
	
	// push all of the new children into the dictionary, indexed by UUID
	for (NSDictionary *remoteObject in list) {
		enumerator = [remoteObject keyEnumerator];
		key = [enumerator nextObject];
		NSDictionary *properties = [remoteObject objectForKey:key];
		NSString *UUID = [properties stringForKey:@"uuid"];
		
		// look for the child in the list of previous children
//		NSInteger i = 0;
		child = [self getChildWithUUID:UUID];
		if (child)
		{
			[previousChildren removeObject:child];
		}
		// if it wasn't in the list, look for it in the database
		else
		{
			child = [[self class] getChildWithUUID:UUID];
			
			// insert at the back of the line
			if (!!child)
				[self insertChild:child atIndex:-1];
		}
		
		// if it's not in the database, create a new one
		if (!child)
		{
			child = (RESTObject *)[ManagedObjectsController objectWithClass:self.childClass];
			child.hasSynced = YES;
			// insert at the back of the line
			[self insertChild:child atIndex:-1];
		}
		
//		if (!self.loadedTime)
//			NSLog(@"%@ no loaded time", NSStringFromClass([self class]));
//		
//		// update with the new data
//		if (!self.loadedTime || !child.loadedTime || ![child.loadedTime isEqualToDate:self.loadedTime])
//		{
//			child.loadedTime = self.loadedTime;
			[self updateChild:child withProperties:properties];
//		}
		
		child = nil;
	}
	
	// add back any unsynced children
	for (child in previousChildren)
	{
		// remove any previous children that have synced
		if (child.hasSynced)
			[self removeChild:child];
	}
	
	[previousChildren release];
	[self.children sortUsingDescriptors:self.sortDescriptors];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Insert

- (BOOL)insertNewChild:(RESTObject *)child
{
	// if we do not already have this child
	if (nil == child || [self.children containsObject:child])
		return NO;
	
	// add it to the list
	return [self insertChild:child atIndex:0];
}

- (void)insertChildren:(NSArray *)children
{
	NSEnumerator *enumerator = [children objectEnumerator];
	RESTObject *child;
	while (child = [enumerator nextObject]) {
		[self insertNewChild:child];
	}
	[self.children sortUsingDescriptors:self.sortDescriptors];
}

- (BOOL)insertChild:(RESTObject *)child atIndex:(NSInteger)index
{
	if (!child || [self.children containsObject:child])
		return NO;
	
	if (![[child delegates] containsObject:self])
		[[child delegates] addObject:self];
	
	// TODO: retain index
	if (index == -1)
		[self.children addObject:child];
		
	else if (index < self.numberOfChildrenLoaded)
		[self.children insertObject:child atIndex:index];
	
	else
		[self.children addObject:child];
	
	if (!self.isUpdating)
		[self didInsertObject:child atIndexPath:[self getIndexPathOfChild:child]];
	
	return YES;
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Remove

- (void)removeChildren
{
	for (RESTObject *child in self.children) {
		[[child delegates] removeObject:self];
	}
	[self.children removeAllObjects];
}

- (void)removeChild:(RESTObject *)child
{
	if ([self.children containsObject:child])
	{
		NSIndexPath *path = [self getIndexPathOfChild:child];
		[self.children removeObject:child];
		[self didDeleteObject:child atIndexPath:path];
	}
	
	// remove as a delegate
	[[child delegates] removeObject:self];
	
	// if the child should be destroyed on remove
	if (self.destroyChildrenOnRemove)
	{
		// if we do not call a retain before the destroy, the autoreleasepool throws an error.
		// TODO: Find where we can completely release this object!
//		[child retain];
		[child destroy];
	}
}

@end
