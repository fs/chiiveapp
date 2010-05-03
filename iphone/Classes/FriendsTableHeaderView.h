//
//  FriendsTableHeaderView.h
//  chiive
//
//  Created by 17FEET on 3/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class UserModel;

@interface FriendsTableHeaderView : UIControl {
	TTView			*_backgroundView;
	NSInteger		_numberOfRequests;
	UIImageView		*_alertImageView;
	UIImageView		*_disclosureImageView;
	UILabel			*_numberOfRequestsLabel;
	UILabel			*_viewLabel;
}

@property (nonatomic, assign)	NSInteger	numberOfRequests;

@end
