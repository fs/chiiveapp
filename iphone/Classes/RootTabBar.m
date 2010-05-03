//
//  RootTabBar.m
//  spyglass
//
//  Created by 17FEET on 3/24/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RootTabBar.h"
#import "RootTableViewController.h"
#import "GroupTableViewController.h"
#import "UserTableViewController.h"
#import "UserEditViewController.h"
#import "UploadTableViewController.h"
#import "GroupSuggestionTableViewController.h"
#import "GroupModel.h"
#import "UserModel.h"
#import "UploadQueue.h"
#import "Global.h"
#import "User.h"

NSUInteger const TAB_TAG_HOME		= 0;
NSUInteger const TAB_TAG_EVENTS		= 1;
NSUInteger const TAB_TAG_FRIENDS	= 2;
NSUInteger const TAB_TAG_UPLOADS	= 3;
NSUInteger const TAB_TAG_SETTINGS	= 4;


@implementation RootTabBar

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateBadges
{
	NSInteger uploads = [[UploadQueue getInstance].objects count];
	if (uploads > 0)
		_itemUploads.badgeValue = [NSString stringWithFormat:@"%d", uploads];
	else
		_itemUploads.badgeValue = nil;

	NSInteger friendRequests = [Global getInstance].currentUser.friendModel.numberOfFriendRequests;
	if (friendRequests > 0)
		_itemFriends.badgeValue = [NSString stringWithFormat:@"%d", friendRequests];
	else
		_itemFriends.badgeValue = nil;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init])
	{
		CGSize applicationFrameSize = TTApplicationFrame().size;
		self.frame = CGRectMake(0, 0, applicationFrameSize.width, TT_TOOLBAR_HEIGHT + 10);
		[[[UploadQueue getInstance] delegates] addObject:self];
		[[[Global getInstance].currentUser.friendModel delegates] addObject:self];

		_itemHome = [[UITabBarItem alloc] initWithTitle:@"Nearby" 
																image:[UIImage imageNamed:@"tab_bar_icon_home.png"] 
																  tag:TAB_TAG_HOME];
		_itemEvents = [[UITabBarItem alloc] initWithTitle:@"Events" 
																  image:[UIImage imageNamed:@"tab_bar_icon_events.png"] 
																	tag:TAB_TAG_EVENTS];
		_itemFriends = [[UITabBarItem alloc] initWithTitle:@"Friends" 
																   image:[UIImage imageNamed:@"tab_bar_icon_friends.png"] 
																	 tag:TAB_TAG_FRIENDS];
		_itemUploads = [[UITabBarItem alloc] initWithTitle:@"Uploads" 
																   image:[UIImage imageNamed:@"tab_bar_icon_uploads.png"] 
																	 tag:TAB_TAG_UPLOADS];
		_itemSettings = [[UITabBarItem alloc] initWithTitle:@"Settings" 
																	image:[UIImage imageNamed:@"tab_bar_icon_settings.png"] 
																	  tag:TAB_TAG_SETTINGS];
		
		self.items = [NSArray arrayWithObjects:_itemHome, _itemEvents, _itemFriends, _itemUploads, _itemSettings, nil];
		
		[self updateBadges];
	}
	return self;
}

- (void)dealloc
{
	[[[UploadQueue getInstance] delegates] removeObject:self];
	[[[Global getInstance].currentUser.friendModel delegates] removeObject:self];
	
	TT_RELEASE_SAFELY(_itemHome);
	TT_RELEASE_SAFELY(_itemEvents);
	TT_RELEASE_SAFELY(_itemFriends);
	TT_RELEASE_SAFELY(_itemUploads);
	TT_RELEASE_SAFELY(_itemSettings);
	
	[super dealloc];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setController:(RootTableViewController *)controller
{
	if ([controller isKindOfClass:[UserEditViewController class]])
		self.selectedItem = _itemSettings;

	else if ([controller isKindOfClass:[UploadTableViewController class]])
		self.selectedItem = _itemUploads;
	
	else if ([controller isKindOfClass:[UserTableViewController class]])
		self.selectedItem = _itemFriends;

	else if ([controller isKindOfClass:[GroupSuggestionTableViewController class]])
		self.selectedItem = _itemHome;

	else
		self.selectedItem = _itemEvents;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model
{
	[self updateBadges];
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	[self updateBadges];
}

@end
