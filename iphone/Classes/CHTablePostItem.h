//
//  CHTablePostItem.h
//  chiive
//
//  Created by 17FEET on 3/23/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Post;


@interface TTThumbsTableViewCell (PostUploadFeedback)
@end

@interface CHPostThumbView : TTThumbView <TTModelDelegate, TTURLRequestDelegate>
{
	Post			*_post;
	UIView			*_progressView;
	UIView			*_progressMask;
}
@property (nonatomic, retain)	Post 		*post;
@property (nonatomic, readonly)	UIView 		*progressView;
@property (nonatomic, readonly)	UIView 		*progressMask;
@end

