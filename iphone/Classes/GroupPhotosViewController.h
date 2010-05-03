//
//  GroupPhotosViewController.h
//  chiive
//
//  Created by 17FEET on 12/2/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@class Group;
@class GroupHomeHeaderView;
@class GroupHomeToolbar;
@class CHCameraBarButtonItem;
@class GroupHomeUserFilteredHeaderView;
@class CHTutorialView;

@interface GroupPhotosThumbsDataSource : TTThumbsDataSource {
	CHTutorialView		*_tutorialView;
}
@property (nonatomic, readonly)	CHTutorialView		*tutorialView;
@property (nonatomic, readonly)	Group				*group;
@end


@interface GroupPhotosViewController : TTThumbsViewController {
	CHCameraBarButtonItem				*_cameraBarButtonItem;
	GroupHomeHeaderView					*_groupHomeHeaderView;
	GroupHomeUserFilteredHeaderView		*_groupHomeUserFilteredHeaderView;
	GroupHomeToolbar					*_groupHomeToolbar;
}

@property (nonatomic, readonly)	Group							*group;
@property (nonatomic, readonly) GroupHomeHeaderView				*groupHomeHeaderView;
@property (nonatomic, readonly) GroupHomeToolbar				*groupHomeToolbar;
@property (nonatomic, readonly) GroupHomeUserFilteredHeaderView	*groupHomeUserFilteredHeaderView;
@property (nonatomic, readonly) CHCameraBarButtonItem			*cameraBarButtonItem;

@end
