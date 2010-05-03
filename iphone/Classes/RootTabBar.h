//
//  RootTabBar.h
//  spyglass
//
//  Created by 17FEET on 3/24/10.
//  Copyright 2010 17FEET. All rights reserved.
//

extern NSUInteger const TAB_TAG_HOME;
extern NSUInteger const TAB_TAG_EVENTS;
extern NSUInteger const TAB_TAG_FRIENDS;
extern NSUInteger const TAB_TAG_UPLOADS;
extern NSUInteger const TAB_TAG_SETTINGS;


@class RootTableViewController;

@interface RootTabBar : UITabBar <TTModelDelegate>
{
	UITabBarItem 				*_itemHome;
	UITabBarItem 				*_itemEvents;
	UITabBarItem 				*_itemFriends;
	UITabBarItem 				*_itemUploads;
	UITabBarItem 				*_itemSettings;
}

- (void)setController:(RootTableViewController *)controller;

@end
