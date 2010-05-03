//
//  RESTModel+Retrieval.h
//  chiive
//
//  Created by 17FEET on 2/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"


@interface RESTModel (Retrieval)

// A flag to destroy records from the database if removed from list of children. False by default.
@property (readonly)			BOOL				destroyChildrenOnRemove;

// Core Data request objects
@property (nonatomic, readonly) NSEntityDescription	*requestEntity;
@property (nonatomic, readonly) NSArray				*sortDescriptors;
@property (nonatomic, readonly) NSPredicate			*requestPredicate;

@property (nonatomic, readonly) NSString			*childName;
@property (nonatomic, readonly) NSString			*childrenName;

/**
 * The REST GET path for the list of children.
 */
@property (nonatomic, readonly) NSString			*childrenURL;
@property (nonatomic, readonly) TTURLRequest		*childrenRequest;


/**
 * Retrieve a child object with the given ID.
 * Retrieves objects directly from NSManagedObject store.
 */
+ (NSArray *)getChildrenWithUUIDs:(NSArray *)UUIDs limit:(NSUInteger)limit;
+ (NSArray *)getChildrenWithUUIDs:(NSArray *)UUIDs;
+ (RESTObject *)getChildWithUUID:(NSString *)UUID;

- (RESTObject *)getChildWithUUID:(NSString *)UUID;

/**
 * Get the first child in the set, either from memory or the database.
 */
- (RESTObject *)getFirstChild;

/**
 * Calls a "destroy" on all children, but does not remove from the list.
 */
- (void)destroyChildren;

@end
