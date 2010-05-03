//
//  ImageResizeAndSaveOperation.h
//  chiive
//
//  Created by 17FEET on 7/17/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@class Post;

@interface ImageResizeAndSaveOperation : NSOperation
{
	UIImage		*_originalImage;
	Post		*_post;
	id			_callbackTarget;
	SEL			_callbackSelector;
}

@property (nonatomic, retain)	UIImage	*originalImage;
@property (nonatomic, retain)	Post	*post;
@property (assign)				id		callbackTarget;
@property (assign)				SEL		callbackSelector;

+ (id)queueImageResizeAndSaveWithImage:(UIImage *)image withPost:(Post *)targetPost withCallbackTarget:(id)target withCallbackSelector:(SEL)selector;

@end
