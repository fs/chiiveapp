//
//  GroupHomeToolbar.m
//  chiive
//
//  Created by 17FEET on 3/19/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupHomeToolbar.h"
#import "Group.h"
#import "Global.h"
#import "GroupEditViewController.h"
#import "GroupInfoViewController.h"
#import "PostEditViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSString *kCancelButtonTitle = @"Cancel";
static NSString *kAddPhotoButtonTitle = @"Add Photo from Library";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GroupHomeToolbar
@synthesize controller = _controller, group = _group;

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)dismissInfoScreen
{
	[self.controller dismissModalViewController];
}

- (void)actionButtonWasPressed
{
	[[[[UIActionSheet alloc] initWithTitle:nil
								  delegate:self 
						 cancelButtonTitle:kCancelButtonTitle 
					destructiveButtonTitle:nil 
						 otherButtonTitles:kAddPhotoButtonTitle, nil] autorelease]
	 showInView:self.controller.view];
}

- (void)infoButtonWasPressed
{
	// Push the edit view controller for this group into the stack
	UIViewController *viewController;
	
	if (self.group.owner == [Global getInstance].currentUser)
	{
		GroupEditViewController *editViewController = [[[GroupEditViewController alloc] init] autorelease];
		editViewController.group = self.group;
		viewController = editViewController;
	}
	else
	{
		GroupInfoViewController *infoViewController = [[GroupInfoViewController alloc] init];
		infoViewController.group = self.group;
		viewController = infoViewController;
	}
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self.controller presentModalViewController:navController animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIButton *)infoButton
{
	if (!_infoButton)
	{
		_infoButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
		[_infoButton addTarget:self action:@selector(infoButtonWasPressed)
			  forControlEvents:UIControlEventTouchUpInside];
	}
	return _infoButton;
}

- (UILabel *)lastSyncedLabel
{
	if (!_lastSyncedLabel)
	{
		_lastSyncedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
		_lastSyncedLabel.textColor = [UIColor whiteColor];
		_lastSyncedLabel.font = [UIFont systemFontOfSize:12];
		_lastSyncedLabel.textAlignment = UITextAlignmentCenter;
		_lastSyncedLabel.backgroundColor = [UIColor clearColor];
	}
	return _lastSyncedLabel;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:frame]) 
	{
		self.barStyle = UIBarStyleBlackTranslucent;
		self.items = [NSMutableArray arrayWithObjects:
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonWasPressed)] autorelease],
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						 [[[UIBarButtonItem alloc] initWithCustomView:self.infoButton] autorelease],
						 nil];
	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_infoButton);
	TT_RELEASE_SAFELY(_lastSyncedLabel);
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([actionSheet buttonTitleAtIndex:buttonIndex] == kAddPhotoButtonTitle)
	{
		PostEditViewController *viewController = [[[PostEditViewController alloc] init] autorelease];
		viewController.superController = self.controller;
		viewController.group = self.group;
		viewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		self.controller.popupViewController = viewController;
		[viewController showInView:self.controller.navigationController.view animated:NO];
	}
}

@end
