//
//  Comment.h
//  chiive
//
//  Created by 17FEET on 9/28/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTObject.h"

@class Post;
@class User;

@interface Comment : RESTObject

@property (nonatomic, retain) Post			*post;
@property (nonatomic, retain) User			*user;
@property (nonatomic, retain) NSString		*body;

@end
