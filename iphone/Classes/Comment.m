//
//  Comment.m
//  chiive
//
//  Created by 17FEET on 9/28/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "Comment.h"
#import "RESTObject.h"
#import "Global.h"
#import "User.h"
#import "UserModel.h"
#import "Post.h"
#import "PostModel.h"
#import "Group.h"
#import "GroupModel.h"

@implementation Comment
@dynamic body, post, user;


///////////////////////////////////////////////////////////////////////////////////////////////////
// RESTObject

- (NSString *)URL
{
	if (!self.post)
		return nil;
	
	else
		return [NSString stringWithFormat:@"%@/comments/%@.json",
				self.post.URL,
				self.UUID
				];
}

- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format
{
	[super setDefaultParamsForRequest:request withFormat:format];
	
	[request.parameters setObject:self.body forKey:@"comment[body]"];
	[request.parameters setObject:self.UUID forKey:@"comment[uuid]"];
	[request.parameters setObject:self.post.UUID forKey:@"comment[commentable_id]"];
	[request.parameters setObject:@"Post" forKey:@"comment[commentable_type]"];
}

- (void)updateWithProperties:(NSDictionary *)properties
{
	[super updateWithProperties:properties];

	if (nil != [properties objectForKey:@"body"])
		self.body = [properties objectForKey:@"body"];

	if (nil != [properties objectForKey:@"user_uuid"] && (nil == self.user || self.user.UUID != [properties objectForKey:@"user_uuid"]))
		self.user = (User *)[UserModel getChildWithUUID:[properties objectForKey:@"user_uuid"]];
}

@end
