//
//  PostPhotoView.h
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@class Post;
@class PostPhotoLabel;

@interface PostPhotoView : TTPhotoView <TTPostControllerDelegate> {
	BOOL					_isCommentPanelVisible;
	CGPoint					_touchLocation;
}

@property (nonatomic, readonly) Post				*post;
@property (assign, readonly)	BOOL				isUserPhoto;
@property (assign, readonly)	BOOL				isCommentPanelVisible;
@property (nonatomic, readonly) PostPhotoLabel		*postCaptionLabel;

- (void)didEndTouches:touches;
- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch;

@end
