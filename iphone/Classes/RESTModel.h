//
//  ParentModel.h
//  chiive
//
//  Created by Arrel Gray on 9/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTObject.h"

@interface RESTModel : TTURLRequestModel <TTModelDelegate>
{
	BOOL				_isUpdating;
	NSMutableArray		*_children;
}

// flag to toggle delegate notifications during bulk updates
@property (nonatomic, assign)	BOOL				isUpdating;

@property (nonatomic, readonly) NSMutableArray		*children;

@property (nonatomic, readonly)	NSUInteger			numberOfChildren;
@property (nonatomic, readonly)	NSUInteger			numberOfChildrenLoaded;


/**
 * The name of the child class (singular and plural) as appears in REST communications.
 */
@property (assign, readonly)	Class				childClass;



/**
 * Retrieve the table index path of a given child.
 * Returns nil if group not found.
 */
- (NSIndexPath *)getIndexPathOfChild:(RESTObject *)child;

/**
 * Update a child object with a given set of properties.
 * Can also be used so assign a parent relationship.
 */
- (void)updateChild:(RESTObject *)child withProperties:(NSDictionary *)properties;

@end
