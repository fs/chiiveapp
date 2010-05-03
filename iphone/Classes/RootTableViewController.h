//
//  RootTableViewController.h
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//
//  Used to provide basic tab bar display and top-left refresh button display
//  for reloading and showing status of model updates.
//

@class RootTabBar;
@class RootViewController;

@interface RootTableViewController : TTTableViewController {
	RootViewController	*_rootViewController;
	RootTabBar			*_tabBar;
}

@property (nonatomic, retain)	RootViewController	*rootViewController;
@property (nonatomic, readonly)	RootTabBar			*tabBar;

- (void)showLoaderPreview:(BOOL)show;

@end
