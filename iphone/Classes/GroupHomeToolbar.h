//
//  GroupHomeToolbar.h
//  chiive
//
//  Created by 17FEET on 3/19/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;


@interface GroupHomeToolbar : UIToolbar <UIActionSheetDelegate> {
	TTViewController		*_controller;
	Group					*_group;
	UIButton				*_infoButton;
	UILabel					*_lastSyncedLabel;
}

@property (nonatomic, assign)	TTViewController	*controller;
@property (nonatomic, retain) 	Group				*group;
@property (nonatomic, readonly) UIButton			*infoButton;
@property (nonatomic, readonly) UILabel				*lastSyncedLabel;


@end
