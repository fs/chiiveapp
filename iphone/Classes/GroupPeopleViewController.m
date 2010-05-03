//
//  GroupPeopleViewController.m
//  chiive
//
//  Created by 17FEET on 2/17/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupPeopleViewController.h"
#import "GroupHomeHeaderView.h"
#import "GroupHomeToolbar.h"
#import "GroupInfoViewController.h"
#import "Group.h"
#import "PostModel.h"
#import "CHTableItem.h"
#import "CHTableUserItem.h"
#import "GroupPhotosViewController.h"
#import "FormatterHelper.h"
#import "PostEditViewController.h"
#import "GroupEditViewController.h"
#import "CHTableViewDragRefreshDelegate.h"
#import "CHCameraBarButtonItem.h"
#import "UserModel.h"
#import "Global.h"
#import "CHTutorialView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation GroupPeopleListDataSource

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
    [self.items removeAllObjects];
	
	UserModel *userModel;
	if ([self.model isKindOfClass:[Group class]])
		userModel = [(Group *)self.model friendModel];
	else
		userModel = (UserModel *)self.model;
    
	NSMutableDictionary *userPhotoCounts = nil;
	userPhotoCounts = [NSMutableDictionary dictionary];
	for (Post *post in userModel.group.postModel.children) {
		if (![userPhotoCounts objectForKey:post.user.UUID])
			[userPhotoCounts setObject:[NSNumber numberWithInt:1] forKey:post.user.UUID];
		else
		{
			NSInteger count = [(NSNumber *)[userPhotoCounts objectForKey:post.user.UUID] intValue] + 1;
			[userPhotoCounts setObject:[NSNumber numberWithInt:count] forKey:post.user.UUID];
		}
	}
	
	for (User *child in userModel.children)
	{
		NSString *itemUrl = nil;
		if (child != [Global getInstance].currentUser)
			itemUrl = @"user";
		
		CHTableUserItem *item = [CHTableUserItem itemWithUser:child URL:itemUrl];
		
		NSNumber *photoCount = [userPhotoCounts objectForKey:child.UUID];
		if (!photoCount)
			[item setNumberOfPhotos:0];
		else
			[item setNumberOfPhotos:[photoCount intValue]];
		
		[self.items addObject:item];
	}
	
	// if you're the only one here
	if ([userModel.children count] == 1 && [userModel.children objectAtIndex:0] == [Global getInstance].currentUser)
	{
		[self.items removeAllObjects];
		[self.items addObject:self.tutorialView];
	}
}


////////////////////////////////////////////////////////////////////////////////////
// public

- (CHTutorialView *)tutorialView
{
	if (!_tutorialView)
	{
		_tutorialView = [[CHTutorialView alloc] initWithFrame:CGRectMake(0, 0, 320, 305)];
		
		_tutorialView.titleLabel.text = @"Get this party started!";
		_tutorialView.messageLabel.text = @"More friends means more photos.";
		
		UIImage *emptyImage = [UIImage imageNamed:@"tutorial_add_attendees.png"];
		_tutorialView.backgroundView.frame = CGRectMake(0, 0, emptyImage.size.width, emptyImage.size.height);
		_tutorialView.backgroundView.image = emptyImage;
	}
	return _tutorialView;
}


////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_tutorialView);
	[super dealloc];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation GroupPeopleViewController
@synthesize groupHomeHeaderView = _groupHomeHeaderView, groupHomeToolbar = _groupHomeToolbar, cameraBarButtonItem = _cameraBarButtonItem;

- (id)init {
	if (self = [super init]) {
		self.statusBarStyle = UIStatusBarStyleBlackOpaque;
		self.hidesBottomBarWhenPushed = NO;
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (Group *)group
{
	return (Group *)self.model;
}

- (GroupHomeHeaderView *)groupHomeHeaderView
{
	if (!_groupHomeHeaderView)
	{
		_groupHomeHeaderView = [[GroupHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 10)];
		_groupHomeHeaderView.controller = self;
		_groupHomeHeaderView.peopleButton.enabled = NO;
	}
	return _groupHomeHeaderView;
}

- (GroupHomeToolbar *)groupHomeToolbar
{
	if (!_groupHomeToolbar)
	{
		_groupHomeToolbar = [[GroupHomeToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TTToolbarHeight(), self.view.frame.size.width, TTToolbarHeight())];
		_groupHomeToolbar.controller = self;
	}
	return _groupHomeToolbar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

/**
 * Show the model data while loading.
 */
- (void)showLoading:(BOOL)show {
	[self showModel:YES];
}

/**
 * Don't show errors in the main area.
 */
- (void)showError:(BOOL)show {
}

- (id<UITableViewDelegate>)createDelegate {
	return [[[CHTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidChange:(id<TTModel>)model {
	[super modelDidChange:model];
	self.cameraBarButtonItem.enabled = self.group.isCurrentUserGroup;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	self.variableHeightRows = YES;
	
	[super loadView];
	
	self.title = @"People";
	
	// add a bottom navigation bar
	[self.view addSubview:self.groupHomeToolbar];
	
	// Inset the bottom of the table to account for the bottom toolbar
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, TTToolbarHeight(), 0);
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, TTToolbarHeight(), 0);
	
	// update the top bar items
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo.png"]] autorelease];
	
	_cameraBarButtonItem = [[CHCameraBarButtonItem alloc] initWithController:self];
	self.navigationItem.rightBarButtonItem = _cameraBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.group.postModel.filterByUser = nil;
	
	self.groupHomeHeaderView.group = self.group;
	self.groupHomeToolbar.group = self.group;
	self.cameraBarButtonItem.group = self.group;
	
	self.tableView.tableHeaderView = self.groupHomeHeaderView;	
	self.navigationItem.rightBarButtonItem.enabled = self.group.isCurrentUserGroup;
	
	[super viewWillAppear:animated];
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_groupHomeHeaderView);
	TT_RELEASE_SAFELY(_groupHomeToolbar);
	TT_RELEASE_SAFELY(_cameraBarButtonItem);
	[super viewDidUnload];
}

@end