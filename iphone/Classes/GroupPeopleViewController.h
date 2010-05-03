//
//  GroupPeopleViewController.h
//  chiive
//
//  Created by 17FEET on 2/17/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserTableViewController.h"
#import "CHTableItem.h"

@class Group;
@class GroupHomeHeaderView;
@class GroupHomeToolbar;
@class CHCameraBarButtonItem;
@class CHTutorialView;


@interface GroupPeopleListDataSource : CHListDataSource {
	CHTutorialView		*_tutorialView;
}
@property (nonatomic, readonly)	CHTutorialView		*tutorialView;
@end

@interface GroupPeopleViewController : UserTableViewController <UIActionSheetDelegate> {
	CHCameraBarButtonItem	*_cameraBarButtonItem;
	GroupHomeHeaderView		*_groupHomeHeaderView;
	GroupHomeToolbar		*_groupHomeToolbar;
}

@property (nonatomic, readonly)	Group					*group;
@property (nonatomic, readonly) GroupHomeHeaderView		*groupHomeHeaderView;
@property (nonatomic, readonly) GroupHomeToolbar		*groupHomeToolbar;
@property (nonatomic, readonly) CHCameraBarButtonItem	*cameraBarButtonItem;

@end
