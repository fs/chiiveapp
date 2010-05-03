//
//  InviteFriendsViewController.m
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "FBConnect/FBConnect.h"

#import "InviteFriendsViewController.h"
#import "InviteScanAddressBookViewController.h"
#import "InviteFromFacebookViewController.h"
#import "InviteFriendsSearchViewController.h"
#import "UserTableViewController.h"
#import "RootViewController.h"
#import "UserModel.h"
#import "Global.h"
#import "User.h"
#import "CHTableItem.h"
#import "Global.h"


static NSString *kAddFromFacebook = @"Add From Facebook";
static NSString *kScanAddressBook = @"Scan Address Book";
static NSString *kFindByName = @"Find by Name";
static NSString *kInviteByEmail = @"Invite by Email";

@implementation InviteFriendsViewController
@synthesize rootViewController = _rootViewController;

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)skipButtonWasPressed
{
	[self.rootViewController showNearbyScreen];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIBarButtonItem *)skipButton
{
	if (!_skipButton)
	{
		TTButton *btn = [TTButton buttonWithStyle:@"roundButton:" title:@"Skip"];
		[btn sizeToFit];
		[btn addTarget:self action:@selector(skipButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		_skipButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
	}
	return _skipButton;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init]) {
		self.tableViewStyle = UITableViewStyleGrouped;
		
		UIImage *fbImage = [UIImage imageNamed:@"table_image_addfriend_facebook.png"];
		TTTableImageItem *fbItem = [TTTableImageItem itemWithText:kAddFromFacebook imageURL:@"" defaultImage:fbImage URL:kAddFromFacebook];
		
		UIImage *abImage = [UIImage imageNamed:@"table_image_addfriend_addressbook.png"];
		TTTableImageItem *abItem = [TTTableImageItem itemWithText:kScanAddressBook imageURL:@"" defaultImage:abImage URL:kScanAddressBook];

		UIImage *nameImage = [UIImage imageNamed:@"table_image_addfriend_find.png"];
		TTTableImageItem *nameItem = [TTTableImageItem itemWithText:kFindByName imageURL:@"" defaultImage:nameImage URL:kFindByName];
		
		UIImage *inviteImage = [UIImage imageNamed:@"table_image_addfriend_invite.png"];
		TTTableImageItem *inviteItem = [TTTableImageItem itemWithText:kInviteByEmail imageURL:@"" defaultImage:inviteImage URL:kInviteByEmail];
		
		self.dataSource = [CHSectionedDataSource dataSourceWithObjects:
						   @"Chiive is better with friends.\nLet's add some.",
						   fbItem,
						   abItem,
						   nameItem,
						   inviteItem,
						   nil
						   ];
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
    [super loadView];
	
	self.tableView.scrollEnabled = NO;
	self.title = @"Invite Friends";
	self.tableView.sectionHeaderHeight = 6;
	
	UIImage *bgImage = [UIImage imageNamed:@"tutorial_invite_new_friends.png"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
	bgImageView.frame = TTRectShift(self.tableView.frame, 0, self.tableView.height - bgImage.size.height);
	[self.tableView addSubview:bgImageView];
//	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tutorial_invite_new_friends.png"]];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = @"Invite Friends";
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.title = @"Invite";
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_rootViewController);
	TT_RELEASE_SAFELY(_skipButton);
	[super viewDidUnload];
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	// create the group table view controller
	CHTableTextItem *item = (CHTableTextItem *)object;
	if (kAddFromFacebook == item.URL)
	{
		InviteFromFacebookViewController *viewController = [[[InviteFromFacebookViewController alloc] init] autorelease];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else if (kScanAddressBook == item.URL)
	{
		InviteScanAddressBookViewController *viewController = [[[InviteScanAddressBookViewController alloc] init] autorelease];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else if (kFindByName == item.URL)
	{
		InviteFriendsSearchViewController *viewController = [[[InviteFriendsSearchViewController alloc] init] autorelease];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else if (kInviteByEmail == item.URL)
	{
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:@"Get Chiiving!"];
		
		// Fill out the email body text
		NSString *emailBody = @"I'm using Chiive and you should too!\n\nChiive is an app that let's everyone share photos when they're out together.\n\nCheck it out at chiive.com.\n\nOr download it on Tunes.\nhttp://itunes.apple.com/us/app/chiive/id362351244?mt=8";
		[picker setMessageBody:emailBody isHTML:NO];
		
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	
	[super didSelectObject:object atIndexPath:indexPath];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewController];
}

@end