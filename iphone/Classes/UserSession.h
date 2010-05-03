//
//  UserSession.h
//  chiive
//
//  Created by Arrel Gray on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@interface UserSession : TTURLRequestModel {
	NSUInteger	_userId;
	NSString	*_login;
	NSString	*_password;
	NSString	*_userName;
	NSString	*_email;
	NSNumber	*_facebookUid;
	NSString	*_singleAccessToken;
}

@property (assign) NSUInteger			userId;
@property (nonatomic, retain) NSString	*login;
@property (nonatomic, retain) NSString	*password;
@property (nonatomic, retain) NSString	*userName;
@property (nonatomic, retain) NSString	*email;
@property (nonatomic, retain) NSNumber	*facebookUid;
@property (nonatomic, retain) NSString	*singleAccessToken;


@end
