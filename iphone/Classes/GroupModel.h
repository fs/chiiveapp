//
//  GroupModel.h
//  chiive
//
//  Created by 17FEET on 8/27/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"


@class Post;
@class User;

@interface GroupModel : RESTModel <TTModelDelegate> {
	User					*_user;
	BOOL					_isSuggestedList;
	BOOL					_delayedLoading;
}

@property (nonatomic, retain)	User				*user;
@property (nonatomic)			BOOL				isSuggestedList;

@end
