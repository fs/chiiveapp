//
//  RESTModel+Retrieval.m
//  chiive
//
//  Created by 17FEET on 2/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "Global.h"
#import "ManagedObjectsController.h"



@implementation RESTModel (Retrieval)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Accessors

- (NSString *)childName
{
	return [[Global getInstance] inflect:self.childClass];
}

- (NSString *)childrenName
{
	return [[Global getInstance] inflectPlural:self.childClass];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Remote

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	// TODO: Handle loading more
	if (more)
		return;
	
	// if we are already loading, stop here
	if ([self isLoading])
		return;
	
	TTURLRequest *request = self.childrenRequest;
	request.timestamp = [NSDate date];
	[[Global getInstance] addDefaultParamsToRequest:request];
	
	// never pull cached requests
	request.cachePolicy = TTURLRequestCachePolicyNone;
	
	//[request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
	[request send];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	
	// parse the children data
	TTURLDataResponse *response = request.response;
	
	[self beginUpdates];
	[self parseChildrenData:response.data];
	[self endUpdates];
	
	// save any managed object changes
	[[ManagedObjectsController getInstance] saveChanges];
	
	// pass along the completion message to the superclass
	[super requestDidFinishLoad:request];
}

- (NSString *)childrenURL
{
	return [NSString stringWithFormat:@"%@%@.json",
			[Global getInstance].sitePath,
			self.childrenName
			];
}

- (TTURLRequest *)childrenRequest
{
	TTURLRequest *request = [TTURLRequest requestWithURL:self.childrenURL delegate:self];
	//NSLog(@"load url: %@", request.URL);
	
	//request.contentType = @"application/json";
	request.httpMethod = @"GET";
	
	// load a new batch if this is old data
	request.cacheExpirationAge = -5000; //self.defaultCacheExpirationAge; //[TTURLCache sharedCache].invalidationAge;
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	
	return request;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Retrieval and sorting

- (NSEntityDescription *)requestEntity
{
	return [ManagedObjectsController entityForName:NSStringFromClass(self.childClass)];
}

- (NSPredicate *)requestPredicate
{
	return nil;
}

- (NSArray *)sortDescriptors
{
	return nil;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Database

+ (NSArray *)getChildrenWithUUIDs:(NSArray *)UUIDs limit:(NSUInteger)limit
{
	RESTModel *model = [[[[self class] alloc] init] autorelease];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[ManagedObjectsController entityForName:NSStringFromClass([model childClass])]];
	[request setPredicate:[NSPredicate predicateWithFormat: @"UUID IN %@", UUIDs]];
	[request setSortDescriptors:model.sortDescriptors];
	if (limit > 0)
		[request setFetchLimit:limit];
	
	
	// Execute the fetch
	NSArray *savedChildren = [[ManagedObjectsController getInstance] executeFetchRequest:request];
	
	return !!savedChildren ? savedChildren : nil;
}

+ (NSArray *)getChildrenWithUUIDs:(NSArray *)UUIDs
{
	return [self getChildrenWithUUIDs:UUIDs limit:0];
}

+ (RESTObject *)getChildWithUUID:(NSString *)UUID
{
	NSArray *savedChildren = [self getChildrenWithUUIDs:[NSArray arrayWithObject:UUID] limit:1];
	return !!savedChildren && [savedChildren count] > 0 ? [savedChildren objectAtIndex:0] : nil;
}

- (RESTObject *)getChildWithUUID:(NSString *)UUID
{
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"UUID == %@", UUID];
	NSArray *filteredChildren = [self.children filteredArrayUsingPredicate:filter];
	if ([filteredChildren count] > 0)
		return [filteredChildren objectAtIndex:0];
	else
		return nil;
}

- (RESTObject *)getFirstChild
{
	if ([self.children count] == 0)
		return nil;
	
	return [self.children objectAtIndex:0];
}

- (BOOL)destroyChildrenOnRemove
{
	return NO;
}

- (void)destroyChildren
{
	[self.children perform:@selector(destroy)];
}

@end
