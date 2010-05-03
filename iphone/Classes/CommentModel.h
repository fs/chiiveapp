//
//  CommentModel.h
//  chiive
//
//  Created by 17FEET on 12/3/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"

@class Post;

@interface CommentModel : RESTModel {
	Post	*_post;
}

@property (nonatomic, retain) Post	*post;

@end
