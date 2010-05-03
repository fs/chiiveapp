//
//  InviteFriendsViewController.h
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@class RootViewController;

@interface InviteFriendsViewController : TTTableViewController <MFMailComposeViewControllerDelegate>
{
	RootViewController		*_rootViewController;
	UIBarButtonItem			*_skipButton;
}
@property (nonatomic, retain)	RootViewController	*rootViewController;
@property (nonatomic, readonly)	UIBarButtonItem		*skipButton;
@end
