//
//  GroupPhotosViewController.m
//  chiive
//
//  Created by 17FEET on 12/2/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "GroupPhotosViewController.h"
#import "GroupEditViewController.h"
#import "GroupInfoViewController.h"
#import "Group.h"
#import "PostModel.h"
#import "User.h"
#import "UserModel.h"
#import "Post.h"
#import "Global.h"
#import "GroupPeopleViewController.h"
#import "FormatterHelper.h"
#import "PostEditViewController.h"
#import "PostPhotoViewController.h"
#import "GroupHomeHeaderView.h"
#import "GroupHomeUserFilteredHeaderView.h"
#import "GroupHomeToolbar.h"
#import "CHCameraBarButtonItem.h"
#import "CHTableViewDragRefreshDelegate.h"
#import "CHTablePostItem.h"
#import "CHTutorialView.h"


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

static CGFloat kThumbnailRowHeight = 79;

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupPhotosThumbsDataSource

- (float)tutorialViewHeight
{
	return self.group.isCurrentUserGroup ? 304 : 244;
}

- (Group *)group
{
	if ([_photoSource isKindOfClass:[Group class]])
		return (Group *)_photoSource;
	else
		return [(PostModel *)_photoSource group];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (_photoSource.maxPhotoIndex < 0)
	{
		tableView.rowHeight = [self tutorialViewHeight];
		return 1;
	}
	else
	{
		tableView.rowHeight = kThumbnailRowHeight;
		return [super tableView:tableView numberOfRowsInSection:section];
	}
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath 
{
	if (_photoSource.maxPhotoIndex < 0)
		return self.tutorialView;
	else
		return [super tableView:tableView objectForRowAtIndexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////////////
// public

- (CHTutorialView *)tutorialView
{
	if (!_tutorialView)
	{
		_tutorialView = [[CHTutorialView alloc] init];
		
		UIImage *emptyImage = [UIImage imageNamed:@"tutorial_add_photos.png"];
		_tutorialView.backgroundView.frame = CGRectMake(0, 0, emptyImage.size.width, emptyImage.size.height);
		_tutorialView.backgroundView.image = emptyImage;
	}
	
	if (!self.group.isCurrentUserGroup)
	{
		_tutorialView.frame = CGRectMake(0, 0, 320, [self tutorialViewHeight]);
		_tutorialView.messageLabel.text = @"Join and take the first photo.";
	}
	else
	{
		_tutorialView.frame = CGRectMake(0, 0, 320, [self tutorialViewHeight]);
		[_tutorialView.actionButton setTitle:@"Take a Picture" forState:UIControlStateNormal];
		
		if (self.group.owner != [Global getInstance].currentUser)
			_tutorialView.messageLabel.text = @"Welcome to the party!";
		
		else if ([[Global getInstance].currentUser.groupUsers count] == 1)
			_tutorialView.messageLabel.text = @"Sweet. You created your first event!";
		
		else
			_tutorialView.messageLabel.text = @"Sweet. You created an event!";
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


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupPhotosViewController
@synthesize groupHomeHeaderView = _groupHomeHeaderView, groupHomeToolbar = _groupHomeToolbar,
			cameraBarButtonItem = _cameraBarButtonItem;

////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		self.statusBarStyle = UIStatusBarStyleBlackOpaque;
		self.navigationBarStyle = UIBarStyleBlackOpaque;
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////////
// TTThumbsViewController

- (TTPhotoViewController*)createPhotoViewController {
	TTPhotoViewController *viewController = [[[PostPhotoViewController alloc] init] autorelease];
	return viewController;
}

/**
 * Inset the bottom of the table to account for the bottom toolbar
 */
- (void)updateTableLayout {
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, TTToolbarHeight(), 0);
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, TTToolbarHeight(), 0);
}

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
	[super setPhotoSource:photoSource];
	self.title = @"Photos";
}



////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)didRefreshModel {
	[super didRefreshModel];
	self.title = @"Photos";
}



////////////////////////////////////////////////////////////////////////////////////
// public

- (Group *)group
{
	return (Group *)self.photoSource;
}

- (GroupHomeHeaderView *)groupHomeHeaderView
{
	if (!_groupHomeHeaderView)
	{
		_groupHomeHeaderView = [[GroupHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 10)];
		_groupHomeHeaderView.controller = self;
		_groupHomeHeaderView.photosButton.enabled = NO;
		_groupHomeHeaderView.paddingBottom = 4;
	}
	return _groupHomeHeaderView;
}

- (GroupHomeUserFilteredHeaderView *)groupHomeUserFilteredHeaderView
{
	if (!_groupHomeUserFilteredHeaderView)
	{
		_groupHomeUserFilteredHeaderView = [[GroupHomeUserFilteredHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 35)];
	}
	return _groupHomeUserFilteredHeaderView;
}

- (GroupHomeToolbar *)groupHomeToolbar
{
	if (!_groupHomeToolbar)
	{
		_groupHomeToolbar = [[GroupHomeToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TTBarsHeight() - TTToolbarHeight(), self.view.frame.size.width, TTToolbarHeight())];
		_groupHomeToolbar.controller = self;
	}
	return _groupHomeToolbar;
}



////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)cameraButtonWasPressed
{
	[self.cameraBarButtonItem cameraButtonWasPressed];
}




////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

/**
 * Show the model data while loading.
 */
- (void)showLoading:(BOOL)show {
	[self showModel:YES];
}

/**
 * Don't show errors in the body
 */
- (void)showError:(BOOL)show {
}

- (id<UITableViewDelegate>)createDelegate {
	return [[[CHThumbsTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (id<TTTableViewDataSource>)createDataSource {
	GroupPhotosThumbsDataSource *ds = [[[GroupPhotosThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
	[ds.tutorialView.actionButton addTarget:self action:@selector(cameraButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	
	return ds;
}



////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidChange:(id<TTModel>)model {
	[super modelDidChange:model];
	self.cameraBarButtonItem.enabled = self.group.isCurrentUserGroup;
}



////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.title = @"Photos";
	
	// add a bottom navigation bar
	[self.view addSubview:self.groupHomeToolbar];
	
	// update the top nav bar
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo.png"]] autorelease];
	
	// add the camera button
	_cameraBarButtonItem = [[CHCameraBarButtonItem alloc] initWithController:self];
	self.navigationItem.rightBarButtonItem = _cameraBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.group.lastSynced)
		[self.group load:TTURLRequestCachePolicyNone more:NO];
	else
		self.group.loadedTime = self.group.lastSynced;
	
	if (!self.group.postModel.filterByUser)
	{
		self.groupHomeHeaderView.group = self.group;
		self.tableView.tableHeaderView = self.groupHomeHeaderView;
	}
	else
	{
		self.groupHomeUserFilteredHeaderView.group = self.group;
		self.tableView.tableHeaderView = self.groupHomeUserFilteredHeaderView;
	}
	
	self.groupHomeToolbar.group = self.group;
	self.cameraBarButtonItem.group = self.group;
	
	self.navigationItem.rightBarButtonItem.enabled = self.group.isCurrentUserGroup;
	
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_groupHomeHeaderView);
	TT_RELEASE_SAFELY(_groupHomeUserFilteredHeaderView);
	TT_RELEASE_SAFELY(_groupHomeToolbar);
	TT_RELEASE_SAFELY(_cameraBarButtonItem);
	[super viewDidUnload];
}

@end
