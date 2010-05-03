//
//  CHCameraBarButtonItem.m
//  chiive
//
//  Created by 17FEET on 3/19/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHCameraBarButtonItem.h"
#import "PostEditViewController.h"

@implementation CHCameraBarButtonItem
@synthesize controller = _controller, group = _group;


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id)initWithController:(UIViewController *)controller
{
	if (self = [self init]) 
	{
		self.controller = controller;
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init]) 
	{
		UIImage *cameraImage = [UIImage imageNamed:@"icon_table_header_camera.png"];
		UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[cameraButton setBackgroundImage:cameraImage forState:UIControlStateNormal];
		cameraButton.frame = CGRectMake(0, 0, cameraImage.size.width, cameraImage.size.height);
		
		[cameraButton addTarget:self action:@selector(cameraButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		self.customView = cameraButton;
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)cameraButtonWasPressed
{
	PostEditViewController *viewController = [[[PostEditViewController alloc] init] autorelease];
	viewController.superController = self.controller;
	viewController.group = self.group;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		viewController.sourceType = UIImagePickerControllerSourceTypeCamera;
	else
		viewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	self.controller.popupViewController = viewController;
	[viewController showInView:self.controller.navigationController.view animated:NO];
}

@end
