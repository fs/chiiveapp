//
//  PostInfoViewController.h
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "CommentTableViewController.h"

@class PostInfoView;

@interface PostInfoViewController : CommentTableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, TTPostControllerDelegate, UIActionSheetDelegate> {
	PostInfoView		*_postInfoView;
}

@property (nonatomic, readonly) PostInfoView				*postInfoView;

@end
