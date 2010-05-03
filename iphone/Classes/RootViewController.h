//
//  HomeViewController.h
//  chiive
//
//  Created by 17FEET on 8/17/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@class PostEditViewController;

@interface RootViewController : TTViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate, TTModelDelegate> {
	UINavigationController		*_selectedNavigationController;
	UINavigationController		*_nearbyNavigationController;
	UINavigationController		*_eventsNavigationController;
	UINavigationController		*_friendsNavigationController;
	UINavigationController		*_uploadsNavigationController;
	UINavigationController		*_settingsNavigationController;
	UINavigationController		*_homeNavigationController;
	PostEditViewController		*_newPostViewController;
}

@property (nonatomic, assign)	UINavigationController		*selectedNavigationController;
@property (nonatomic, readonly) UINavigationController		*nearbyNavigationController;
@property (nonatomic, readonly) UINavigationController		*eventsNavigationController;
@property (nonatomic, readonly) UINavigationController		*friendsNavigationController;
@property (nonatomic, readonly) UINavigationController		*uploadsNavigationController;
@property (nonatomic, readonly) UINavigationController		*settingsNavigationController;
@property (nonatomic, readonly) UINavigationController		*homeNavigationController;

- (void)showNearbyScreen;
- (void)logOut;

@end
