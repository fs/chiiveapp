//
//  RootViewViewController.m
//  chiive
//
//  Created by 17FEET on 8/17/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RootViewController.h"
#import "Global.h"
#import "ManagedObjectsController.h"
#import "RootTabBar.h"

#import "HomeViewController.h"

#import "PostPhotoViewController.h"
#import "GroupPhotosViewController.h"
#import "GroupTableViewController.h"
#import "GroupSuggestionTableViewController.h"

#import "GroupModel.h"
#import "Group.h"

#import "PostEditViewController.h"
#import "GroupEditViewController.h"

#import "UserEditViewController.h"
#import "FriendsTableViewController.h"
#import "UserModel.h"

#import "UploadQueue.h"
#import "UploadTableViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)showGroup:(Group *)group
{
	GroupPhotosViewController *viewController = [[[GroupPhotosViewController alloc] init] autorelease];
	viewController.photoSource = group;
	
	if (!_selectedNavigationController)
		_selectedNavigationController = self.eventsNavigationController;
	else
		self.selectedNavigationController = self.eventsNavigationController;
	
	if ([self.selectedNavigationController.viewControllers count] == 1)
		[self.selectedNavigationController pushViewController:viewController animated:NO];
	
	else
	{
		UIViewController *eventsController = [self.selectedNavigationController.viewControllers objectAtIndex:0];
		self.selectedNavigationController.viewControllers = [NSArray arrayWithObjects:eventsController, viewController, nil];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init])
	{
		[[[UploadQueue getInstance] delegates] addObject:self];
		
		if (!![Global getInstance].currentUser)
		{
			[[UploadQueue getInstance] retrieveManagedChildren];
			[[UploadQueue getInstance] load:TTURLRequestCachePolicyNone more:NO];
		}
	}
	return self;
}

- (void)dealloc
{
	[[[UploadQueue getInstance] delegates] removeObject:self];
	
	TT_RELEASE_SAFELY(_nearbyNavigationController);
	TT_RELEASE_SAFELY(_eventsNavigationController);
	TT_RELEASE_SAFELY(_friendsNavigationController);
	TT_RELEASE_SAFELY(_uploadsNavigationController);
	TT_RELEASE_SAFELY(_settingsNavigationController);
	TT_RELEASE_SAFELY(_homeNavigationController);
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	if (!!_nearbyNavigationController && _nearbyNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_nearbyNavigationController);
	
	if (!!_eventsNavigationController && _eventsNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_eventsNavigationController);
	
	if (!!_friendsNavigationController && _friendsNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_friendsNavigationController);
	
	if (!!_settingsNavigationController && _settingsNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_settingsNavigationController);
	
	if (!!_uploadsNavigationController && _uploadsNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_uploadsNavigationController);
	
	if (!!_homeNavigationController && _homeNavigationController != self.selectedNavigationController)
		TT_RELEASE_SAFELY(_homeNavigationController);
	
	[super didReceiveMemoryWarning];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if (TAB_TAG_HOME == item.tag)
		self.selectedNavigationController = self.nearbyNavigationController;
	
	else if (TAB_TAG_EVENTS == item.tag)
		self.selectedNavigationController = self.eventsNavigationController;
	
	else if (TAB_TAG_FRIENDS == item.tag)
		self.selectedNavigationController = self.friendsNavigationController;
	
	else if (TAB_TAG_UPLOADS == item.tag)
		self.selectedNavigationController = self.uploadsNavigationController;
	
	else if (TAB_TAG_SETTINGS == item.tag)
		self.selectedNavigationController = self.settingsNavigationController;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (void)showNearbyScreen
{
	// save the modal view controller
	UIViewController *modal = nil;
	if (!!self.selectedNavigationController.modalViewController)
	{
		modal = [self.selectedNavigationController.modalViewController retain];
		[self.selectedNavigationController dismissModalViewControllerAnimated:NO];
	}
	
	self.selectedNavigationController = self.nearbyNavigationController;
	
	// move to the new view controller 
	if (!!modal)
	{
		[self.nearbyNavigationController presentModalViewController:modal animated:NO];
		[self.selectedNavigationController dismissModalViewControllerAnimated:YES];
		[modal release];
	}
	
	// make sure the home view controller has been released after this
	TT_RELEASE_SAFELY(_homeNavigationController);
}

- (void)logOut
{
	// Cancel any uploads in the queue
	NSArray *uploadObjects = [[[UploadQueue getInstance].objects copy] autorelease];
	for (RESTObject *object in uploadObjects) {
		[object cancel];
		[[UploadQueue getInstance] removeObjectFromQueue:object];
	}
	
	// log out of the app
	[Global getInstance].currentUser = nil;
	[Global getInstance].currentGroup = nil;
	
	// return to the home screen
	self.selectedNavigationController = self.homeNavigationController;
	
	// release all the other navigation controllers to reset the app
	TT_RELEASE_SAFELY(_nearbyNavigationController);
	TT_RELEASE_SAFELY(_eventsNavigationController);
	TT_RELEASE_SAFELY(_friendsNavigationController);
	TT_RELEASE_SAFELY(_uploadsNavigationController);
	TT_RELEASE_SAFELY(_settingsNavigationController);
	
	// Clear the database
	[[ManagedObjectsController getInstance] resetData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Tab Navigation Controllers

- (UINavigationController *)selectedNavigationController
{
	if (!_selectedNavigationController)
	{
		// if no user is saved, show the home screen
		if (![Global getInstance].currentUser)
			_selectedNavigationController = self.homeNavigationController;
		
		// if a user, but no current group, go to the nearby screen
		else if (![Global getInstance].currentGroup)
			_selectedNavigationController = self.eventsNavigationController; // nearbyNavigationController;
		
		// if we have a current event, show it
		else
			[self showGroup:[Global getInstance].currentGroup];
	}
	return _selectedNavigationController;
}

- (void)setSelectedNavigationController:(UINavigationController *)navigationController
{
	if (_selectedNavigationController != navigationController)
	{
		[_selectedNavigationController setDelegate:nil];
		[_selectedNavigationController.view removeFromSuperview];
		
		_selectedNavigationController = navigationController;
		[_selectedNavigationController setDelegate:self];
		
		[[UIApplication sharedApplication].keyWindow addSubview:_selectedNavigationController.view];
	}
}

- (UINavigationController *)homeNavigationController
{
	if (nil == _homeNavigationController)
	{
		HomeViewController *viewController = [[[HomeViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		_homeNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _homeNavigationController;
}

- (UINavigationController *)nearbyNavigationController
{
	if (nil == _nearbyNavigationController)
	{
		GroupSuggestionTableViewController *viewController = [[[GroupSuggestionTableViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		
		// set the data source
		id<TTTableViewDataSource> ds = [GroupSuggestionDataSource dataSourceWithObjects:nil];
		ds.model = [Global getInstance].currentUser.suggestedGroupModel;
		viewController.dataSource = ds;
		
		_nearbyNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _nearbyNavigationController;
}

- (UINavigationController *)eventsNavigationController
{
	if (nil == _eventsNavigationController)
	{
		GroupTableViewController *viewController = [[[GroupTableViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		
		// set the data source
		id<TTTableViewDataSource> ds = [GroupEditableDataSource dataSourceWithObjects:nil];
		ds.model = [Global getInstance].currentUser;
		viewController.dataSource = ds;
		
		_eventsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _eventsNavigationController;
}

- (UINavigationController *)friendsNavigationController
{
	if (nil == _friendsNavigationController)
	{
		FriendsTableViewController *viewController = [[[FriendsTableViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		
		// set the data source
		id<TTTableViewDataSource> ds = [UserFriendsDataSource dataSourceWithObjects:nil];
		ds.model = [Global getInstance].currentUser.friendModel;
		viewController.dataSource = ds;
		
		_friendsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _friendsNavigationController;
}

- (UINavigationController *)uploadsNavigationController
{
	if (nil == _uploadsNavigationController)
	{
		UploadTableViewController *viewController = [[[UploadTableViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		
		_uploadsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _uploadsNavigationController;
}

- (UINavigationController *)settingsNavigationController
{
	if (nil == _settingsNavigationController)
	{
		UserEditViewController *viewController = [[[UserEditViewController alloc] init] autorelease];
		viewController.rootViewController = self;
		viewController.user = [Global getInstance].currentUser;
		
		_settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	}
	return _settingsNavigationController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	// if a new group was added to the upload queue, move to that group homepage
	if ([model isMemberOfClass:[UploadQueue class]])
	{
		if ([object isMemberOfClass:[Group class]] &&
			(Group *)object == [Global getInstance].currentGroup &&
			![(Group *)object hasSynced])
		{
			[self showGroup:[Global getInstance].currentGroup];
		}
	}
}

@end
