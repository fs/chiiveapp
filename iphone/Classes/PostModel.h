//
//  PostModel.h
//  chiive
//
//  Created by 17FEET on 10/21/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"

@class Group;
@class User;
@class RESTObject;


@interface PostModel : RESTModel <TTPhotoSource> {
	Group				*_group;
	User				*_filterByUser;
	NSMutableArray		*_filteredChildren;
}

@property (nonatomic, retain) Group				*group;
@property (nonatomic, retain) User				*filterByUser;

- (NSUInteger)indexOfChild:(RESTObject *)child;

@end
