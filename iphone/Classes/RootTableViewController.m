//
//  RootTableViewController.m
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RootTableViewController.h"
#import "RootViewController.h"
#import "CHTableViewDragRefreshDelegate.h"
#import "RESTModelComplete.h"
#import "RootTabBar.h"

@interface RootTableViewController (TTTableViewControllerHidden)
- (void)layoutOverlayView;
- (void)layoutBannerView;
- (void)updateTableDelegate;
@end


@implementation RootTableViewController
@synthesize rootViewController = _rootViewController;

////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		self.statusBarStyle = UIStatusBarStyleBlackOpaque;
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)showLoaderPreview:(BOOL)show
{
	if (!show)
	{
		if ([self.tableView.delegate respondsToSelector:@selector(hideLoadingAfterDelay)])
			[self.tableView.delegate performSelector:@selector(hideLoadingAfterDelay)];
	}
	// if this is the first time to show the view
	else if (!self.hasViewAppeared)
	{
		if ([self.tableView.delegate respondsToSelector:@selector(showLoading)])
			[self.tableView.delegate performSelector:@selector(showLoading)];
	}
}

- (RootTabBar *)tabBar
{
	if (!_tabBar && !!self.rootViewController)
	{
		_tabBar = [[RootTabBar alloc] init];
		_tabBar.delegate = self.rootViewController;
		
		NSInteger tabBarHeight = TT_TOOLBAR_HEIGHT + 10;
		CGRect viewFrame = TTNavigationFrame();
		self.tabBar.frame = TTRectShift(viewFrame, 0, viewFrame.size.height - tabBarHeight);
		self.tableView.frame = TTRectContract(viewFrame, 0, tabBarHeight);
		[self.view addSubview:self.tabBar];
	}
	
	[_tabBar setController:self];
	return _tabBar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

//- (CGRect)rectForOverlayView {
//	if (!self.tabBar)
//		return [super rectForOverlayView];
//	else
//		return self.tableView.frame;
//}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)showLoading:(BOOL)empty
{
	// do not show anything for loading by default
}

- (void)showEmpty:(BOOL)empty
{
	// do not show anything for empty by default
}

- (void)showError:(BOOL)empty
{
	// do not show anything for error by default
}

- (void)setEmptyView:(UIView*)view
{
	if (view != _emptyView) 
	{
		if (_emptyView) 
		{
			[_emptyView removeFromSuperview];
			TT_RELEASE_SAFELY(_emptyView);
		}
		_emptyView = [view retain];
		if (_emptyView) 
		{
			// add the view to the table view to allow drag to refresh
			[self.tableView addSubview:_emptyView];
		}
	}
}

- (void)setLoadingView:(UIView*)view 
{
	if (view != _loadingView) 
	{
		if (_loadingView) 
		{
			[_loadingView removeFromSuperview];
			TT_RELEASE_SAFELY(_loadingView);
		}
		_loadingView = [view retain];
		if (_loadingView) 
		{
			// add the view to the table view to allow drag to refresh
			[self.tableView addSubview:_loadingView];
		}
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo.png"]] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
	// make sure our delegate is set up, which shows the Loading... header view
	[self updateTableDelegate];
	
	[self showLoaderPreview:YES];
	
	[super viewWillAppear:animated];
	
	self.tabBar;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (![self.model isLoading])
		[self showLoaderPreview:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.tableView setEditing:NO animated:NO];
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_tabBar);
	[super viewDidUnload];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate {
	return [[[CHTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

@end
