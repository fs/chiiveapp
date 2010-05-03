//
//  Friendship.h
//  chiive
//
//  Created by 17FEET on 1/13/10.
//  Copyright 2010 17FEET. All rights reserved.
//


extern NSString *const FRIEND_REQUEST_ACCEPT;
extern NSString *const FRIEND_REQUEST_IGNORE;
extern NSString *const FRIEND_REQUEST_ADD;
extern NSString *const FRIEND_REQUEST_REMOVE;


@class User;

@interface Friendship : TTURLRequestModel {
	NSUInteger	_friendshipId;
	NSUInteger	_fandomId;
	User		*_friend;
}

@property (assign) NSUInteger			friendshipId;
@property (assign) NSUInteger			fandomId;
@property (nonatomic, retain) User		*friend;

- (void)updateUser:(User *)user withFriendshipType:(NSString *)friendshipType;

@end
