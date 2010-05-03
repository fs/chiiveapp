//
//  RESTModel+Addition.h
//  chiive
//
//  Created by 17FEET on 2/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"


@interface RESTModel (Addition)
/**
 * Parse lists of children
 */
- (void)parseChildrenData:(NSData *)childrenData;
- (void)parseChildrenList:(NSArray *)list;
- (void)parseChildrenList:(NSArray *)list withRemove:(BOOL)remove;

/**
 * Insert a new child into the front of the list,
 * incrementing both the loaded and total counts.
 * Returns bool representing if the child was successfully added.
 * Returns false if child is already in the list.
 */
- (BOOL)insertNewChild:(RESTObject *)child;
- (void)insertChildren:(NSArray *)children;

/**
 * Insert a newly loaded child at the proper index,
 * incrementing only the loaded count.
 */
- (BOOL)insertChild:(RESTObject *)child atIndex:(NSInteger)index;

/**
 * Remove a specific child from the list,
 * decrementing both the loaded and total counts.
 */
- (void)removeChild:(RESTObject *)child;

/**
 * Remove a specific child from the list,
 * decrementing both the loaded and total counts,
 * and destroy the Managed Object of the record
 */
- (void)removeChild:(RESTObject *)child;

/**
 * Removes all the children from the model, without deleting core data objects.
 */
- (void)removeChildren;

@end
