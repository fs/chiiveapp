//
//  PostTableItemThumbView.h
//  chiive
//
//  Created by Arrel Gray on 11/26/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@protocol PostThumbViewDelegate;
@class Post;
@class GroupTableItemCell;



@interface PostThumbView : UIControl {
	TTImageView					*_imageView;
	TTView						*_backgroundView;
	Post						*_post;
	id<PostThumbViewDelegate>	_delegate;
}

@property (nonatomic, retain) Post						*post;
@property (nonatomic, assign) id<PostThumbViewDelegate>	delegate;

@end


@protocol PostThumbViewDelegate

- (void)postThumbView:(PostThumbView *)thumb didSelectPost:(Post *)post;

@end

