//
//  CommentTableViewController.h
//  chiive
//
//  Created by 17FEET on 12/4/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableItem.h"

@class FTTextInputBar;
@class Post;

@interface CommentListDataSource : CHListDataSource
@end

@interface CommentTableViewController : TTTableViewController <UITextFieldDelegate> {
	FTTextInputBar		*_commentField;
}

@property (nonatomic, readonly) FTTextInputBar		*commentField;
@property (nonatomic, readonly)	Post				*post;

@end
