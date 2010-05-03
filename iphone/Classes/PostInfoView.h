//
//  PostInfoView.h
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@class Post;

@interface PostInfoView : TTView {
	Post						*_post;
	TTImageView					*_thumbView;
	
	UILabel						*_dateLabel;
	UILabel						*_photoByLabel;
	UIButton					*_authorButton;
	UIButton					*_editButton;
	UILabel						*_separatorLabel;
	UIButton					*_deleteButton;
	
	UIImageView					*_captionSeparatorView;
	UILabel						*_captionLabel;
	TTLabel						*_commentsBubble;
	UILabel						*_commentsLabel;
	TTView						*_borderBottomView;
}

@property (nonatomic, retain)	Post		*post;
@property (nonatomic, readonly)	UIButton	*authorButton;
@property (nonatomic, readonly)	UIButton	*editButton;
@property (nonatomic, readonly)	UIButton	*deleteButton;

@end
