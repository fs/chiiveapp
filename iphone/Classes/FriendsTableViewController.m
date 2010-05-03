//
//  FriendsTableViewController.m
//  chiive
//
//  Created by 17FEET on 2/18/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "FriendRequestsTableViewController.h"
#import "InviteFriendsViewController.h"
#import "UserModel.h"
#import "UserSearchModel.h"
#import "Friendship.h"
#import "UploadQueue.h"
#import "CHTableEmptyView.h"
#import "Group.h"
#import "User.h"
#import "Global.h"
#import "CHDefaultStyleSheet.h"
#import "CHTableUserItem.h"
#import "FriendsTableHeaderView.h"
#import "FriendsSearchTableViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



@implementation UserFriendsDataSource
@synthesize selectedObject = _selectedObject, tableView = _tableView;

- (UserModel *)userModel
{
	if ([self.model isKindOfClass:[Group class]])
		return [(Group *)self.model friendModel];
	
	else if ([self.model isKindOfClass:[UserModel class]])
		return (UserModel *)self.model;
	
	else
		return nil;
}

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
	[super tableViewDidLoadModel:tableView];
	
	[self.items removeAllObjects];
	
	for (User *child in self.userModel.children)
	{
		if (child.isMutualFriend)
			[self.items addObject:[CHTableUserItem itemWithUser:child URL:@"user"]];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.tableView = tableView;
	TTTableItem *item = [self.items objectAtIndex:indexPath.row];
	if ([item.userInfo isKindOfClass:[User class]])
	{
		self.selectedObject = item.userInfo;
		[[[[UIAlertView alloc] initWithTitle:@"Remove friend" 
									 message:@"Are you sure you want to remove this friend?" 
									delegate:self
						   cancelButtonTitle:@"Cancel" 
						   otherButtonTitles:@"Remove", nil] autorelease] show];
	}
}

////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
	{
		// create a friendship request
		Friendship *friendship = [[[Friendship alloc] init] autorelease];
		[friendship updateUser:self.selectedObject withFriendshipType:FRIEND_REQUEST_REMOVE];
		
		// add to the upload queue so that it is not removed from memory
		[[UploadQueue getInstance] addObjectToQueue:friendship];
		[friendship load:TTURLRequestCachePolicyNone more:NO];
		
		// remove from the list of friends, which nullifies the friendship/fandom ids
		[self.userModel removeChild:self.selectedObject];
		
		// remove the item from the table view
		NSInteger count = [self.items count];
		for (NSInteger i=0; i < count; i++) {
			CHTableUserItem *item = [self.items objectAtIndex:i];
			if (item.userInfo == self.selectedObject)
			{
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0]; 
				[self.items removeObject:item];
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
				break;
			}
		}
	}
	self.selectedObject = nil;
	self.tableView = nil;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_selectedObject);
	[super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FriendsTableViewDragRefreshDelegate
- (UIEdgeInsets)insetsShow
{
	FriendsTableViewController *controller = (FriendsTableViewController *)self.controller;
	return UIEdgeInsetsMake(60.0f + controller.friendsHeaderView.height, 0.0f, 0.0f, 0.0f);
}
- (UIEdgeInsets)insetsHide
{
	FriendsTableViewController *controller = (FriendsTableViewController *)self.controller;
	return UIEdgeInsetsMake(controller.friendsHeaderView.height, 0.0f, 0.0f, 0.0f);
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FriendsTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIBarButtonItem *)addFriendsBarButtonItem
{
	if (!_addFriendsBarButtonItem)
	{
		_addFriendsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Friends" 
																	style:UIBarButtonItemStylePlain
																   target:self 
																   action:@selector(addButtonWasPressed)];
	}
	return _addFriendsBarButtonItem;
}

- (void)updateRequestsView
{
	// if we have friend requests, push it into the list first
	NSInteger numRequests = [(UserModel *)self.model numberOfFriendRequests];
	FriendsTableViewDragRefreshDelegate *delegate = (FriendsTableViewDragRefreshDelegate *)self.tableView.delegate;
	self.friendsHeaderView.numberOfRequests = numRequests;
	
	if (numRequests > 0 && self.friendsHeaderView.hidden)
	{
		self.friendsHeaderView.hidden = NO;
		self.friendsHeaderView.frame = CGRectMake(0, -TT_TOOLBAR_HEIGHT, self.tableView.width, TT_TOOLBAR_HEIGHT);
		
		// adjust the pull to refresh view according to the new friends header height
		delegate.headerView.frame = CGRectOffset(delegate.headerView.frame, 0, -self.friendsHeaderView.height);
		
		// TODO: Adjust current insets rather than resetting, handling any animations
		self.tableView.contentInset = delegate.insetsHide;
		
	}
	else if (0 == numRequests && !self.friendsHeaderView.hidden)
	{
		// adjust the pull to refresh view according to current friends header height
		delegate.headerView.frame = CGRectOffset(delegate.headerView.frame, 0, self.friendsHeaderView.height);
		
		self.friendsHeaderView.hidden = YES;
		self.friendsHeaderView.frame = CGRectZero;
		
		// TODO: Adjust current insets rather than resetting, handling any animations
		self.tableView.contentInset = delegate.insetsHide;
	}
}
- (FriendsTableHeaderView *)friendsHeaderView
{
	if (!_friendsHeaderView)
	{
		_friendsHeaderView = [[FriendsTableHeaderView alloc] initWithFrame:CGRectZero];
		[_friendsHeaderView addTarget:self action:@selector(didSelectFriendsRequests) forControlEvents:UIControlEventTouchUpInside];
		_friendsHeaderView.hidden = YES;
		[self.tableView addSubview:_friendsHeaderView];
	}
	return _friendsHeaderView;
}

- (CHTableEmptyView *)tableEmptyView
{
	if (!_tableEmptyView)
	{
		_tableEmptyView = [[CHTableEmptyView alloc] initWithFrame:self.tableView.frame];
		_tableEmptyView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_black_patterned.png"]];
		_tableEmptyView.titleLabel.style = TTSTYLEVAR(h2Inverse);
		_tableEmptyView.titleLabel.backgroundColor = [UIColor clearColor];
		_tableEmptyView.messageLabel.style = TTSTYLEVAR(h5Inverse);
		_tableEmptyView.messageLabel.backgroundColor = [UIColor clearColor];
		
		_tableEmptyView.titleLabel.text = @"Chiive is more fun with friends!";
		_tableEmptyView.messageLabel.text = @"Why don't you add some now?";
		
		[_tableEmptyView.button setTitle:@"Add Friends" forState:UIControlStateNormal];
		[_tableEmptyView.button addTarget:self action:@selector(addButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}	
	return _tableEmptyView;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)didSelectFriendsRequests
{
	FriendRequestsTableViewController *viewController = [[[FriendRequestsTableViewController alloc] init] autorelease];
	
	UserRequestsDataSource *ds = (UserRequestsDataSource *)[UserRequestsDataSource dataSourceWithItems:nil];
	ds.model = self.model;
	viewController.dataSource = ds;
	
	[self.navigationController pushViewController:viewController animated:YES];
}

/**
 * Since we want to pre-populate the current list of friends in the search controller,
 * reset the search controller's datasource whenever it's updated or intialized in this controller.
 */
- (void)updateDataSource
{
	if (!!self.dataSource && !!self.searchViewController)
	{
		UserSearchListDataSource *ds = (UserSearchListDataSource *)[UserSearchListDataSource dataSourceWithItems:nil];
		
		_searchModel = [[UserSearchModel alloc] init];
		_searchModel.userModel = (UserModel *)self.dataSource.model;
		ds.model = _searchModel;
		
		self.searchViewController.dataSource = ds;
	}
}

- (void)addButtonWasPressed
{
	InviteFriendsViewController *viewController = [[[InviteFriendsViewController alloc] init] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	
	FriendsSearchTableViewController* searchController = [[[FriendsSearchTableViewController alloc] init] autorelease];
	searchController.delegate = self;
	
	self.searchViewController = searchController;
	[self updateDataSource];
	
	_searchController.searchBar.delegate = searchController;
	_searchController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Friends", @"Everyone", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.userModel.user == [Global getInstance].currentUser)
		self.navigationItem.rightBarButtonItem = self.addFriendsBarButtonItem;
	
	// refresh on appear to update any friendship state changes from other screens (accept or remove friendship)
	[self refresh];
	
	[self updateRequestsView];
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_tableEmptyView);
	TT_RELEASE_SAFELY(_addFriendsBarButtonItem);
	TT_RELEASE_SAFELY(_friendsHeaderView);
	TT_RELEASE_SAFELY(_searchModel);
	[super viewDidUnload];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate {
	return [[[FriendsTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource
{
	[super setDataSource:dataSource];
	[self updateDataSource];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)canShowModel {
	return [[(UserModel *)self.model children] count] > 0;
}

- (void)showModel:(BOOL)show
{
	if (show)
	{
		self.emptyView = nil;
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
		self.tableView.tableHeaderView = _searchController.searchBar;
		self.tableView.separatorColor = TTSTYLEVAR(tableSeparatorColor);
	}
	else
	{
		self.tableView.tableHeaderView = nil;
	}
	
	[super showModel:show];
}

- (void)setEmptyView:(UIView*)view {
	if (_emptyView)
	{
		self.navigationItem.leftBarButtonItem = nil;
		self.tableView.separatorColor = [UIColor clearColor];
	}
	[super setEmptyView:view];
}

- (void)showEmpty:(BOOL)show
{
	if (show && self.userModel.user == [Global getInstance].currentUser)
		self.emptyView = self.tableEmptyView;

	else
		self.emptyView = nil;
}

- (void)showError:(BOOL)show
{
	// only show an error if we can't show the model
	if ([self canShowModel])
		return;
	
	if (show && self.userModel.user == [Global getInstance].currentUser)
		self.emptyView = self.tableEmptyView;

	else
		self.emptyView = nil;
}

- (void)showLoading:(BOOL)show {
	if ([[(UserModel *)self.model children] count] > 0)
		[self showModel:YES];
	else
		[self showEmpty:YES];
}

- (void)didLoadModel:(BOOL)firstTime
{
	[self updateRequestsView];
	[super didLoadModel:firstTime];
}

@end