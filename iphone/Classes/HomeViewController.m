//
//  HomeViewController.m
//  spyglass
//
//  Created by Arrel Gray on 4/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "UserEditViewController.h"

@implementation HomeViewController
@synthesize rootViewController = _rootViewController;


///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)loginButtonWasPressed
{
	LoginViewController *viewController = [[[LoginViewController alloc] init] autorelease];
	viewController.rootViewController = self.rootViewController;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[self.navigationController presentModalViewController:navController animated:YES];
}

- (void)signupButtonWasPressed
{
	UserEditViewController *viewController = [[[UserEditViewController alloc] init] autorelease];
	viewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
														initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
														target:self	
														action:@selector(dismissModalViewController)] autorelease];
	viewController.rootViewController = self.rootViewController;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[self.navigationController presentModalViewController:navController animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)createBackground
{
	UIImage *backgroundImage = [UIImage imageNamed:@"tutorial_home.png"];
	UIImageView *backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
	backgroundView.frame = CGRectMake(round((self.view.width - backgroundImage.size.width) * 0.5), self.view.height - backgroundImage.size.height, backgroundImage.size.width, backgroundImage.size.height);
	[self.view addSubview:backgroundView];
	
	float top = 10.0;
	
	UIImage *logoImage = [UIImage imageNamed:@"logo_large.png"];
	UIImageView *logoView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
	logoView.frame = CGRectMake(round((self.view.width - logoImage.size.width) * 0.5), top, logoImage.size.width, logoImage.size.height);
	[self.view addSubview:logoView];
	
	top += logoView.height + 10;
	
	UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
	titleLabel.textColor = RGBCOLOR(128,128,128);
	titleLabel.font = [UIFont systemFontOfSize:18];
//	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = @"All Your Friends.";
	[titleLabel sizeToFit];
	[self.view addSubview:titleLabel];
	
	UILabel *messageLabel = [[[UILabel alloc] init] autorelease];
	messageLabel.textColor = RGBCOLOR(81, 158, 16);
	messageLabel.font = [UIFont systemFontOfSize:18];
//	messageLabel.textAlignment = UITextAlignmentCenter;
	messageLabel.text = @"One Camera.";
	[messageLabel sizeToFit];
	[self.view addSubview:messageLabel];
	
	float labelWidth = titleLabel.width + messageLabel.width + 5;
	float margin = round( (self.view.width - labelWidth) * 0.5);
	titleLabel.frame = CGRectMake(margin, top, titleLabel.width, titleLabel.height);
	messageLabel.frame = CGRectMake(self.view.width - margin - messageLabel.width, top, messageLabel.width, messageLabel.height);
	
}

- (void)createButtons
{
	TTButton *loginButton = [TTButton buttonWithStyle:@"largeRoundButton:" title:@"Login"];
	[loginButton addTarget:self action:@selector(loginButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[loginButton sizeToFit];
	
	TTButton *signupButton = [TTButton buttonWithStyle:@"largeRoundButton:" title:@"Sign Up"];
	[signupButton addTarget:self action:@selector(signupButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[signupButton sizeToFit];
	
	float btnWidth = 140;
	float btnHeight = 45;
	NSInteger top = self.view.height - 15 - btnHeight;
	NSInteger offset = round( (self.view.width - btnWidth * 2 - 10) * 0.5);
	
	loginButton.frame = CGRectMake(offset, top, btnWidth, btnHeight);
	signupButton.frame = CGRectMake(self.view.width - offset - btnWidth, top, btnWidth, btnHeight);
	
	[self.view addSubview:loginButton];
	[self.view addSubview:signupButton];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	self.statusBarStyle = UIStatusBarStyleBlackOpaque;
	[super loadView];
	
	self.navigationController.navigationBarHidden = YES;
	self.view.frame = TTRectShift(self.view.frame, 0, -TT_TOOLBAR_HEIGHT);
	
	[self createBackground];
	[self createButtons];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_rootViewController);
	[super dealloc];
}

@end
