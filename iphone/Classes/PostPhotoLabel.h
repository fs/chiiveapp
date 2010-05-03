//
//  PostPhotoLabel.h
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@class Post;
@class CommentsButtonView;

@interface PostPhotoLabel : TTLabel {
	Post						*_post;
	TTImageView					*_avatarImageView;
	UILabel						*_userNameLabel;
	UILabel						*_captionLabel;
}

@property (nonatomic, retain)	Post		*post;

- (CGRect)captionFrame;

@end
