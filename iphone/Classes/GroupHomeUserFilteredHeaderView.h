//
//  GroupHomeUserFilteredHeaderView.h
//  chiive
//
//  Created by Arrel Gray on 3/20/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;
@class CHAvatarView;

@interface GroupHomeUserFilteredHeaderView : UIView <TTModelDelegate> {
	Group					*_group;
	CHAvatarView			*_avatarView;
	UILabel					*_userPhotosLabel;
	TTView					*_backgroundView;
}

@property (nonatomic, retain)	Group					*group;

@end
