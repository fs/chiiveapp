//
//  Global.h
//  chiive
//
//  Created by 17FEET on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@class User;
@class UserModel;
@class Group;
@class GroupModel;


@interface Global : NSObject {
	User							*_currentUser;
	Group							*_currentGroup;
	UIBarButtonItem					*_launcherButton;
}

@property (nonatomic, readonly)	NSString				*sitePath;
@property (nonatomic, readonly)	NSString				*fbconnectApiKey;
@property (nonatomic, readonly)	NSString				*fbconnectSessionProxy;
@property (nonatomic, readonly)	NSString				*appVersionNumber;
@property (nonatomic, readonly) NSString				*defaultQueryString;

@property (nonatomic, readonly)	NSString				*currentUserId;
@property (nonatomic, retain)	Group					*currentGroup;
@property (nonatomic, retain)	User					*currentUser;

+ (Global *)getInstance;

- (void)addDefaultParamsToRequest:(TTURLRequest *)request;
- (NSString *)inflect:(Class)klass;
- (NSString *)inflectPlural:(Class)klass;

- (id)getSessionObjectForKey:(NSString *)key;

@end