//
//  UserModel.h
//  chiive
//
//  Created by Arrel Gray on 9/19/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"

@class User;
@class Group;

@interface UserModel : RESTModel {
	User					*_user;
	Group					*_group;
	NSInteger				_numberOfFriendRequests;
}

@property (nonatomic, retain)	User				*user;
@property (nonatomic, retain)	Group				*group;
@property (nonatomic, readonly)	NSString			*userList;
@property (nonatomic, readonly)	NSInteger			numberOfFriendRequests;

- (void)loadSavedFriends;

@end
