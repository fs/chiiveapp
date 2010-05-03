//
//  GroupHomeHeaderView.h
//  chiive
//
//  Created by 17FEET on 2/17/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;

@interface GroupHomeHeaderView : UIView <TTModelDelegate> {
	TTTableViewController	*_controller;
	Group					*_group;
	NSInteger				_paddingBottom;
	
	UIView					*_joinEventView;
	UILabel					*_joinEventLabel;
	TTButton				*_joinEventButton;
	
	UIView					*_headerView;
	UILabel					*_titleLabel;
	UIButton				*_photosButton;
	UIButton				*_peopleButton;
}

@property (nonatomic, retain)	TTTableViewController	*controller;
@property (nonatomic, retain)	Group					*group;
@property (nonatomic, assign)	NSInteger				paddingBottom;

@property (nonatomic, readonly)	UIView					*joinEventView;
@property (nonatomic, readonly)	UILabel					*joinEventLabel;
@property (nonatomic, readonly)	TTButton				*joinEventButton;

@property (nonatomic, readonly)	UIView					*headerView;
@property (nonatomic, readonly)	UILabel					*titleLabel;
@property (nonatomic, readonly)	UIButton				*photosButton;
@property (nonatomic, readonly)	UIButton				*peopleButton;

@end
