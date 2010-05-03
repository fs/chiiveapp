//
//  UserSession.m
//  chiive
//
//  Created by Arrel Gray on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "UserSession.h"
#import "Global.h"
#import "ManagedObjectsController.h"
#import "NSDictionary+Casting.h"
#import "JSON.h"
#import "User.h"
#import "UserModel.h"

@implementation UserSession
@synthesize userId = _userId, login = _login, password = _password, 
			userName = _userName, email = _email, facebookUid = _facebookUid, 
			singleAccessToken = _singleAccessToken;

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	NSString *url = [NSString stringWithFormat:@"%@user_session.json?%@", 
					 [Global getInstance].sitePath,
					 [Global getInstance].defaultQueryString];
	
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];
	
	NSString *body = nil;
	if (nil != self.login && nil != self.password)
		body = [NSString stringWithFormat:@"{\"user_session\":{\"email\":\"%@\",\"password\":\"%@\"}}", self.login, self.password];
	
	else if (!!self.facebookUid)
		body = [NSString stringWithFormat:@"{\"user_session\":{\"fb_sig_session_key\":\"%@\"}}", self.facebookUid];
	
	if (nil == body)
	{
		[self didFailLoadWithError:nil];
	}
	
	request.httpBody = [body dataUsingEncoding:NSUTF8StringEncoding];
	request.cachePolicy = cachePolicy;
	request.contentType = @"application/json";
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	request.httpMethod = @"POST";
	
	[request send];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLDataResponse *response = request.response;
	NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
    // Parse the JSON data that we retrieved from the server.
	id responseValue = [responseBody JSONValue];
    [responseBody release];
    
	// make sure we have a response with one user
	if ([responseValue isKindOfClass:[NSDictionary class]] && 1 == [responseValue count])
	{
		NSEnumerator *enumerator = [responseValue keyEnumerator];
		NSString *key = [enumerator nextObject];
		NSDictionary *properties = [responseValue objectForKey:key];
		
		// see if we already have the user in the DB
		User *user = (User *)[UserModel getChildWithUUID:[properties stringForKey:@"uuid"]];
		if (!user)
		{
			user = (User *)[ManagedObjectsController objectWithClass:[User class]];
			user.UUID = key;
		}
		
		[user updateWithProperties:properties];
		
		user.hasSynced = YES;
		[Global getInstance].currentUser = user;
		
		[super requestDidFinishLoad:request];
	}
	else
	{
		NSError *error = nil;
	
		// if the response is an array, it means we returned errors
		if ([responseValue isKindOfClass:[NSArray class]] && [responseValue count] > 0)
		{
			NSArray *firstError = [responseValue objectAtIndex:0];
			if (!!firstError && [firstError count] > 1)
			{
				NSString *errorDescription = [NSString stringWithFormat:@"%@ %@", 
											  [firstError objectAtIndex:0], 
											  [firstError objectAtIndex:1]];
				NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObject:errorDescription
																		  forKey:NSLocalizedDescriptionKey];
				error = [NSError errorWithDomain:NSURLErrorDomain 
											code:500 // mark as internal server error
										userInfo:errorUserInfo];
			}
		}
		[self didFailLoadWithError:error];
	}
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_login);
	TT_RELEASE_SAFELY(_password);
	TT_RELEASE_SAFELY(_userName);
	TT_RELEASE_SAFELY(_email);
	TT_RELEASE_SAFELY(_facebookUid);
	TT_RELEASE_SAFELY(_singleAccessToken);
	
	[super dealloc];
}

@end
