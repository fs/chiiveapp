//
//  UserTableViewController.m
//  chiive
//
//  Created by 17FEET on 9/21/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RootTableViewController.h"
#import "UserTableViewController.h"
#import "UserModel.h"
#import "User.h"
#import "GroupTableViewController.h"
#import "GroupModel.h"
#import "Global.h"
#import "CHTableItem.h"
#import "CHTableUserItem.h"
#import "InviteFriendsViewController.h"
#import "GroupPhotosViewController.h"
#import "Friendship.h"
#import "Group.h"
#import "PostModel.h"
#import "Post.h"
#import "UploadQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserListDataSource
- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
    [self.items removeAllObjects];
	
	UserModel *userModel;
	if ([self.model isKindOfClass:[Group class]])
		userModel = [(Group *)self.model friendModel];
	else
		userModel = (UserModel *)self.model;
    
	for (User *child in userModel.children)
	{
		NSString *itemUrl = nil;
		if (child != [Global getInstance].currentUser)
			itemUrl = @"user";
		
		[self.items addObject:[CHTableUserItem itemWithUser:child URL:itemUrl]];
	}
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation UserTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)addButtonWasPressed
{
	InviteFriendsViewController *viewController = [[[InviteFriendsViewController alloc] init] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (UserModel *)userModel
{
	if ([self.model isKindOfClass:[UserModel class]])
		return (UserModel *)self.model;
	else if ([self.model isKindOfClass:[Group class]])
		return [(Group *)self.model friendModel];
	else
		return nil;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// RootTableViewController

- (void)showLoaderPreview:(BOOL)show
{
	if (self.userModel.user == [Global getInstance].currentUser)
		[super showLoaderPreview:show];
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.title = @"Friends";
}

- (void)viewWillAppear:(BOOL)animated
{
	// remove any previous filtering of the group
	self.userModel.group.postModel.filterByUser = nil;
	[super viewWillAppear:animated];
}




////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)shouldLoad
{
	// if we've already displayed and the group model does not have a load time
	return _isViewAppearing && !self.userModel.loadedTime;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectAccessoryButtonForObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	CHTableUserItem *item = object;
	User *friend = item.userInfo;
	
	// create a friendship request
	Friendship *friendship = [[[Friendship alloc] init] autorelease];
	[friendship updateUser:friend withFriendshipType:item.accessoryURL];
	
	// add to the upload queue and load
	[[UploadQueue getInstance] addObjectToQueue:friendship];
	[friendship load:TTURLRequestCachePolicyNone more:NO];
	
	// reload the table data
	[self.dataSource tableViewDidLoadModel:self.tableView];
	[self.tableView reloadData];
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	// don't select the empty table row
	if (![object isKindOfClass:[CHTableUserItem class]])
		return;
	
	CHTableUserItem *item = (CHTableUserItem *)object;
	if (!!item.URL)
	{
		CHTableUserItem *item = (CHTableUserItem *)object;
		User *user = (User *)item.userInfo;
		
		// if we're within a group
//		if (!!self.userModel.group)
//		{
//			GroupPhotosViewController *viewController = [[[GroupPhotosViewController alloc] init] autorelease];
//			PostModel *postModel = self.userModel.group.postModel;
//			postModel.filterByUser = user;
//			viewController.photoSource = postModel;
//			
//			//push into the UINavigationController stack
//			[self.navigationController pushViewController:viewController animated:YES];
//		}
//		else
//		{
			// create the group table view controller
			GroupTableViewController *viewController = [[[GroupTableViewController alloc] init] autorelease];
			
			// set the data source
			id<TTTableViewDataSource> ds = [GroupDataSource dataSourceWithObjects:nil];
			ds.model = user;
			viewController.dataSource = ds;
			
			//push into the UINavigationController stack
			[self.navigationController pushViewController:viewController animated:YES];
//		}
	}
	
	// notify the table that the row was selected
	[super didSelectObject:object atIndexPath:indexPath];
}

@end
