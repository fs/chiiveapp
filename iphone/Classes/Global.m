//
//  Global.m
//  spyglass
//
//  Created by 17FEET on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//


#if (TARGET_IPHONE_SIMULATOR)
//static NSString* kSitePath = @"http://ec2-174-129-74-75.compute-1.amazonaws.com/";
static NSString* kSitePath = @"http://localhost:3000/";
static NSString* kFbConnectApiKey = @"81939b58bf646c63622e61f8a5e35cce";
#else
static NSString* kSitePath = @"http://chiive.com/";
static NSString* kFbConnectApiKey = @"3ac68699d53f2a48347f58d8c7cccc6c";
#endif

static NSString* kGetSessionProxyPath = @"facebook";
static NSString* kCurrentUserUUID = @"currentUserUUID";
static NSString* kCurrentGroupUUID = @"currentGroupUUID";


#import "Global.h"
#import "ManagedObjectsController.h"
#import "User.h"
#import "Group.h"
#import "GroupModel.h"
#import "GroupUser.h"
#import "UserModel.h"
#import "UploadQueue.h"

@implementation Global

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (NSString *)defaultQueryString
{
	if (!self.currentUser)
		return [NSString stringWithFormat:@"client_type=iphone&client_version=%@", 
				self.appVersionNumber];
	else
		return [NSString stringWithFormat:@"user_credentials=%@&client_type=iphone&client_version=%@", 
				self.currentUser.singleAccessToken,
				self.appVersionNumber];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Global Accessors

- (NSString*)sitePath
{
	return kSitePath;
}

- (NSString*)fbconnectApiKey
{
	return kFbConnectApiKey;
}

- (NSString*)fbconnectSessionProxy
{
	NSMutableString *proxyString = [NSMutableString stringWithFormat:@"%@%@",
									self.sitePath,
									kGetSessionProxyPath];
	
	// include the default query params
	[proxyString appendFormat:@"?%@", [self defaultQueryString]];
	
	return proxyString;
}

- (NSString *)appVersionNumber
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)inflect:(Class)klass
{
	return [NSStringFromClass(klass) lowercaseString];
}

- (NSString *)inflectPlural:(Class)klass
{
	return [NSString stringWithFormat:@"%@s", [self inflect:klass]];
}

- (void)addDefaultParamsToRequest:(TTURLRequest *)request
{
//	if ([request.httpMethod isEqualToString:@"POST"] || 
//		[request.httpMethod isEqualToString:@"PUT"])
//	{
//		[request.parameters setObject:self.appVersionNumber forKey:@"client_version"];
//		[request.parameters setObject:@"iphone" forKey:@"client_type"];
//		
//		if (!!self.currentUser)
//			[request.parameters setObject:self.currentUser.singleAccessToken forKey:@"user_credentials"];
//	}
//	else
//	{
		NSString *queryFormat = (0 == [request.URL rangeOfString:@"?"].length) ? @"%@?%@" : @"%@&%@";
		request.URL = [NSString stringWithFormat:queryFormat, 
					   request.URL,
					   [self defaultQueryString]];
//	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Getters and Setters

- (NSString *)currentUserId
{
	if (nil != self.currentUser)
		return self.currentUser.UUID;
	return nil;
}

- (Group *)currentGroup
{
	if (nil == _currentGroup)
	{
		// if the model ID is zero (not yet uploaded) check by UUID
		NSString *groupUUID = [self getSessionObjectForKey:kCurrentGroupUUID];
		Group *potentialCurrentGroup = nil;
		
		if (nil != groupUUID)
			potentialCurrentGroup = (Group *)[GroupModel getChildWithUUID:groupUUID];
		
		// make sure this is still a legit current group
		if (!!potentialCurrentGroup &&
			[potentialCurrentGroup isCurrentUserGroup] && 
			[potentialCurrentGroup isActive]
		)
		{
			_currentGroup = [potentialCurrentGroup retain];
		}
	}
	return _currentGroup;
}

- (void)setCurrentGroup:(Group *)group
{
	if (group == _currentGroup)
		return;
	
	[group retain];
	[_currentGroup release];
	_currentGroup = group;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// if we are removing the group
	if (nil == _currentGroup)
	{
		[prefs removeObjectForKey:kCurrentGroupUUID];	
	}
	// if we are assigning the group
	else
	{
		[prefs setObject:_currentGroup.UUID forKey:kCurrentGroupUUID];
	}
}

- (User *)currentUser
{
	if (nil == _currentUser)
	{
		NSString *uuid = [self getSessionObjectForKey:kCurrentUserUUID];
		if (!!uuid)
		{
			_currentUser = (User *)[UserModel getChildWithUUID:uuid];
			[_currentUser retain];
		}
	}
	
	return _currentUser;
}

- (void)setCurrentUser:(User *)user
{
	if (user == _currentUser)
		return;
	
	[user retain];
	[_currentUser release];
	_currentUser = user;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// if we are removing the user
	if (nil == user)
	{
		[prefs removeObjectForKey:kCurrentUserUUID];
	}
	// if we are assigning the user
	else
	{
		[prefs setObject:user.UUID forKey:kCurrentUserUUID];
	}
	
	// save the new user if there was one
	[[ManagedObjectsController getInstance] saveChanges];
}

- (id)getSessionObjectForKey:(NSString *)key
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs objectForKey:key];
}

- (void)setSessionObject:(id)object forKey:(NSString *)key
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:object forKey:key];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Singleton Setup

static Global *sharedInstance = nil;

+ (Global *)getInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
			return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
