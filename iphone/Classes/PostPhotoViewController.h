//
//  PostPhotoViewController.h
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@class CHCameraBarButtonItem;

@interface PostPhotoViewController : TTPhotoViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, TTPostControllerDelegate, UIAlertViewDelegate> {
	CHCameraBarButtonItem	*_cameraBarButtonItem;
	UIButton				*_commentsButton;
}

@property (nonatomic, readonly) CHCameraBarButtonItem	*cameraBarButtonItem;
@property (nonatomic, readonly) UIButton				*commentsButton;

@end
