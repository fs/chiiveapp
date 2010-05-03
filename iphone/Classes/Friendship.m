//
//  Friendship.m
//  chiive
//
//  Created by 17FEET on 1/13/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "Friendship.h"
#import "Global.h"
#import "User.h"
#import "JSON.h"
#import "ManagedObjectsController.h"


NSString *const FRIEND_REQUEST_ACCEPT = @"accept";
NSString *const FRIEND_REQUEST_IGNORE = @"ignore";
NSString *const FRIEND_REQUEST_ADD = @"add";
NSString *const FRIEND_REQUEST_REMOVE = @"remove";


@implementation Friendship
@synthesize friendshipId = _friendshipId, friend = _friend, fandomId = _fandomId;


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)updateUser:(User *)user withFriendshipType:(NSString *)friendshipType
{
	// If the user is not a saved object
	if ([user managedObjectContext] != [ManagedObjectsController getInstance].managedObjectContext)
	{
		if (FRIEND_REQUEST_ADD == friendshipType || FRIEND_REQUEST_ACCEPT == friendshipType)
		{
			// TODO: make sure the user is a saved object
			
		}
	}

	// if we are adding as a friend
	if ((FRIEND_REQUEST_ADD == friendshipType || FRIEND_REQUEST_ACCEPT == friendshipType) && 0 == [user.friendshipId intValue])
	{
		self.friend = user;
		
		// if no friendhsip yet, set a placeholder friend ID
		user.friendshipId = [NSNumber numberWithInt:-1];
	}

	// if we are removing a current friend
	else if (FRIEND_REQUEST_REMOVE == friendshipType && [user.friendshipId intValue] > 0)
	{
		self.friendshipId = [user.friendshipId intValue];
		
		// remove the friendship id
		user.friendshipId = [NSNumber numberWithInt:0];
	}

	// if we are ignoring a request
	else if (FRIEND_REQUEST_IGNORE == friendshipType && [user.fandomId intValue] > 0)
	{
		self.fandomId = [user.fandomId intValue];
		
		// remove the fandom id
		user.fandomId = [NSNumber numberWithInt:0];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	TTURLRequest *request = [TTURLRequest requestWithURL:nil delegate:self];
	
	// if we have a friendshipId, we are destroying a friendship
	if (self.friendshipId > 0)
	{
		request.URL = [NSString stringWithFormat:@"%@friendships/%d.json",
					   [Global getInstance].sitePath,
					   self.friendshipId
					   ];
		
		[request.parameters setObject:@"delete" forKey:@"_method"];
	}
	
	// if we have a fandom Id, we are ignoring a friendship request
	else if (self.fandomId > 0)
	{
		request.URL = [NSString stringWithFormat:@"%@friendships/%d.json",
					   [Global getInstance].sitePath,
					   self.fandomId
					   ];
		
		[request.parameters setObject:@"delete" forKey:@"_method"];
	}
	
	// if we just have a friend, we are creating a friendship
	else if (nil != self.friend && self.friend.hasSynced)
	{
		request.URL = [NSString stringWithFormat:@"%@friendships.json?friend_id=%@",
					   [Global getInstance].sitePath,
					   self.friend.UUID
					   ];
		
		[request.parameters setObject:[NSString stringWithFormat:@"%@", self.friend.UUID] forKey:@"friend_id"];
	}
	
	// if we have neither, there is nothing to load!
	else
	{
		// TODO: Handle failures for insufficient data
		[self didFailLoadWithError:nil];
		return;
	}
	
	request.cachePolicy = TTURLRequestCachePolicyNone;
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	request.httpMethod = @"POST";
	[[Global getInstance] addDefaultParamsToRequest:request];
	
	[request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

/**
 * Handle the friendship creation or destroy.
 */
- (void)requestDidFinishLoad:(TTURLRequest*)request {
	
	// if we were creating a friendship, update the friend's data
	if (!!self.friend)
	{
		TTURLDataResponse *response = request.response;
		NSString *responseBody = [[[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary *json = [responseBody JSONValue];
		
		NSEnumerator *enumerator = [json keyEnumerator];
		NSString *key = [enumerator nextObject];
		NSDictionary *properties = [json objectForKey:key];
		
		if ([key isEqualToString:self.friend.UUID])
			[self.friend updateWithProperties:properties];
	}
	
	[super requestDidFinishLoad:request];
}

@end
