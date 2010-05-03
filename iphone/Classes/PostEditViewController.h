//
//  PostEditViewController.h
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "Post.h";
@class Group;

@interface PostEditViewController : TTPopupViewController <PostDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>  {
	Post								*_post;
	Group								*_group;
	UIImage								*_photo;
	UIImageView							*_imageView;
	UIImagePickerControllerSourceType	_sourceType;
	BOOL								_shouldDismissView;
	BOOL								_sourceTypeIsSet;
}

@property (nonatomic, retain) Post								*post;
@property (nonatomic, retain) Group								*group;
@property (nonatomic, retain) UIImage							*photo;
@property (nonatomic, retain) UIImageView						*imageView;
@property (nonatomic, assign) UIImagePickerControllerSourceType	sourceType;

@end
