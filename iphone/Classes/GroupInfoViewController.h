//
//  GroupInfoViewController.h
//  chiive
//
//  Created by 17FEET on 2/23/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;

@interface GroupInfoViewController : TTViewController {
	Group				*_group;
	TTImageView			*_thumbnailView;
	UILabel				*_titleLabel;
	TTStyledTextLabel	*_ownerLabel;
	UILabel				*_privacyHeaderLabel;
	UILabel				*_privacyLabel;
	TTButton			*_removeMeButton;
}
@property (nonatomic, retain)	Group				*group;
@property (nonatomic, retain)	TTImageView			*thumbnailView;
@property (nonatomic, retain)	UILabel				*titleLabel;
@property (nonatomic, retain)	TTStyledTextLabel	*ownerLabel;
@property (nonatomic, retain)	UILabel				*privacyHeaderLabel;
@property (nonatomic, retain)	UILabel				*privacyLabel;
@property (nonatomic, retain)	TTButton			*removeMeButton;
@end
