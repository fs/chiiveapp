//
//  GroupTableUserHeaderView.h
//  chiive
//
//  Created by 17FEET on 10/1/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@class User;
@class Friendship;

@interface GroupTableUserHeaderView : TTView {
	User			*_user;
	TTImageView		*_avatarImageView;
	UILabel			*_friendNameLabel;
	UILabel			*_statusLabel;
	TTButton		*_friendButton;
}

@property (nonatomic, retain)	User			*user;
@property (nonatomic, readonly)	TTButton		*friendButton;

@end
