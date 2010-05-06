//
//  RESTObject.m
//  chiive
//
//  Created by 17FEET on 10/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTObject.h"
#import "Global.h"
#import "ManagedObjectsController.h"
#import "JSON.h"

@implementation RESTObject
@dynamic createdAt, updatedAt, hasSyncedHolder, isOutdatedHolder, isUploadCompleteHolder, UUID, lastSynced, shouldDeleteHolder;
@synthesize request = _request, isCheckingPreviousUpload = _isCheckingPreviousUpload, 
			requestedTime = _requestedTime, loadedTime = _loadedTime;


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSManagedObject

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
		_delegates = nil;
		// if this is a new object, not retrieved from the database and without an UUID, assign now
		if (nil == self.UUID)
		{
			CFUUIDRef theUUID = CFUUIDCreate(NULL);
			CFStringRef uuidString = CFUUIDCreateString(NULL, theUUID);
			CFRelease(theUUID);
			self.UUID = [(NSString *)uuidString autorelease];
			//NSLog(@"create upload uid for %@", NSStringFromClass([self class]));
		}
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public (URLRequest)

/**
 * The format to insert keys for the parameters passed in an upload request
 */
- (NSString *)paramFormat
{
	return [NSString stringWithFormat:@"%@[%%@]", self.objectName];
}

/**
 * Format the CREATE request for this model object.
 */
- (TTURLRequest *)getCreateRequest
{
	NSString *url = [NSString stringWithFormat:@"%@.json",
					 self.baseURL
					 ];
	
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];
	request.httpMethod = @"POST";
	
	[self setDefaultParamsForRequest:request withFormat:self.paramFormat];
	return request;
}

- (TTURLRequest *)getUpdateRequest
{
	TTURLRequest *request = [self getShowRequest];
	request.httpMethod = @"POST";
	[request.parameters setObject:@"put" forKey:@"_method"];
	
	[self setDefaultParamsForRequest:request withFormat:self.paramFormat];
	
	return request;
}

- (TTURLRequest *)getShowRequest
{
	NSString *url = [NSString stringWithFormat:@"%@.json",
					 self.URL
					 ];
	return [TTURLRequest requestWithURL:url delegate:self];
}

- (TTURLRequest *)getDestroyRequest
{
	TTURLRequest *request = [self getShowRequest];
	request.httpMethod = @"POST";
	[request.parameters setObject:@"delete" forKey:@"_method"];
	return request;
}

/**
 * Forms the upload request, either for RESTful Create or Update.
 * If this is a Create and the request was previously uploaded completely but interrupted before the response,
 * a GET is performed to check to see if the upload was already successful without needing
 * a re-upload of the media (photo) asset.
 */
- (TTURLRequest *)getRequest
{
	TTURLRequest *request;
	
	// if we have not synced, this is a new post and we need to add the photo
	if (!self.hasSynced && self.isUploadComplete)
	{
		// if this may have previously uploaded already,
		// first attempt a show request to pull the server data
		// if this returns blank, we will loop through and do a Create request
		self.isCheckingPreviousUpload = YES;
		request = [self getShowRequest];
	}
	
	// if this is a new post request
	else if (!self.hasSynced)
	{
		self.isCheckingPreviousUpload = NO;
		request = [self getCreateRequest];
	}
	
	else if (self.shouldDelete)
	{
		// if this has been requested to be deleted
		request = [self getDestroyRequest];
	}
	// if we already have synced, but the object is outdated
	else if (self.isOutdated)
	{
		self.isCheckingPreviousUpload = NO;
		request = [self getUpdateRequest];
	}
	// otherwise, this is just a GET request for the latest data
	else
	{
		request = [self getShowRequest];
	}
	
	// set the request parameters
	request.cachePolicy = TTURLRequestCachePolicyNone;
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	
	[[Global getInstance] addDefaultParamsToRequest:request];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	return request;
}

- (void)load
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(load) object:nil];
	[self load:TTURLRequestCachePolicyNone more:NO];
}

/**
 * Create or Update post record on the server.
 */
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	// only load once
	if ([self isLoading])
		return;
	
	// if we have already uploaded completely previously, try checking for the post rather than uploading
	self.request = [self getRequest];
	
	// TODO: Call back to Group to remove this post
	if (nil == self.request)
		return;
	
	self.request.timestamp = [NSDate date];
	
	// never pull cached requests
	self.request.cachePolicy = TTURLRequestCachePolicyNone;
	
	[self.request send];
}

- (void)cancel {
	[self.request cancel];
}

- (void)invalidate:(BOOL)erase {
	self.loadedTime = nil;
}

/**
 * A RESTObject has synced when a positive upload response is received from the server
 */
- (BOOL)hasSynced
{
	return [self.hasSyncedHolder boolValue];
}

- (void)setHasSynced:(BOOL)hasSynced
{
	self.hasSyncedHolder = [NSNumber numberWithBool:hasSynced];
}

/**
 * A RESTObject is outdated if it is marked as outdated or has not yet synced with the server
 */
- (BOOL)isOutdated
{
	return [self.isOutdatedHolder boolValue] || !self.hasSynced;
}

- (void)setIsOutdated:(BOOL)isOutdated
{
	self.isOutdatedHolder = [NSNumber numberWithBool:isOutdated];
}

- (BOOL)isUploadComplete
{
	return [self.isUploadCompleteHolder boolValue];
}

- (void)setIsUploadComplete:(BOOL)value
{
	self.isUploadCompleteHolder = [NSNumber numberWithBool:value];
}

- (BOOL)shouldDelete
{
	return [self.shouldDeleteHolder boolValue];
}

- (void)setShouldDelete:(BOOL)value
{
	self.shouldDeleteHolder = [NSNumber numberWithBool:value];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel Interface

- (NSMutableArray*)delegates {
	if (!_delegates) {
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}

- (BOOL)isLoaded {
	return self.hasSynced && nil == self.request && !!self.loadedTime;
}

- (BOOL)isLoading {
	return nil != self.request;
}

- (BOOL)isLoadingMore {
	return NO;
}

- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format
{
	[request.parameters setObject:self.UUID forKey:[NSString stringWithFormat:format, @"uuid"]];
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel Public

- (NSString *)objectName
{
	return [[Global getInstance] inflect:[self class]];
}

- (NSString *)objectNamePlural
{
	return [[Global getInstance] inflectPlural:[self class]];
}

- (void)didStartLoad {
	//NSLog(@"%@ did start load", NSStringFromClass([self class]));
	[_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad {
	//NSLog(@"%@ did finish load", NSStringFromClass([self class]));
	if (!!self.request)
		self.loadedTime = [[self.request.timestamp copy] autorelease];
	
	self.request = nil;
	self.isOutdated = NO;
	[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)didFailLoadWithError:(NSError*)error {
	self.request = nil;
	[_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
			 withObject:error];
}

- (void)didCancelLoad {
	self.request = nil;
	[_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

- (void)beginUpdates {
	[_delegates perform:@selector(modelDidBeginUpdates:) withObject:self];
}

- (void)endUpdates {
	[_delegates perform:@selector(modelDidEndUpdates:) withObject:self];
}

- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform:@selector(model:didUpdateObject:atIndexPath:) withObject:self
			 withObject:object withObject:indexPath];
}

- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform:@selector(model:didInsertObject:atIndexPath:) withObject:self
			 withObject:object withObject:indexPath];
}

- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform:@selector(model:didDeleteObject:atIndexPath:) withObject:self
			 withObject:object withObject:indexPath];
}

- (void)didChange {
	[_delegates perform:@selector(modelDidChange:) withObject:self];
}


- (id)initWithProperties:(NSDictionary *)properties {
	if (self = [self init]) {
		[self updateWithProperties:properties];
	}
	return self;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

/**
 * The request has begun loading.
 */
- (void)requestDidStartLoad:(TTURLRequest*)request
{
	//NSLog(@"%@ Request %@ Did Start: %d / %d", self.objectName, self.UUID, request.totalBytesLoaded, request.totalBytesExpected);
	[self didStartLoad];
}

/**
 * The request has loaded some more data.
 *
 * Check the totalBytesLoaded and totalBytesExpected properties for details.
 */
- (void)requestDidUploadData:(TTURLRequest*)request
{
	//NSLog(@"%@ Request %@ Did Upload: %d / %d", self.objectName, self.UUID, request.totalBytesLoaded, request.totalBytesExpected);
	if (
		!self.isCheckingPreviousUpload && 
		request.totalBytesLoaded == request.totalBytesExpected && 
		!self.hasSynced
	) {
		self.isUploadComplete = YES;
	}
}

/**
 * The request has loaded data has loaded and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	NSLog(@"%@ Request %@ Did Finish: %d / %d", self.objectName, self.UUID, request.totalBytesLoaded, request.totalBytesExpected);
	BOOL wasCheckingPreviousUpload = self.isCheckingPreviousUpload;
	
	// if we were checking for a previously uploaded post, mark that this is no longer doing so
	self.isCheckingPreviousUpload = NO;
	self.isUploadComplete = NO;
	
	//parse the response
	TTURLDataResponse *response = request.response;
	NSString *responseBody = [[[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding] autorelease];

	// if this was a delete request
	if (self.shouldDelete)
	{
		// verify there were no errors in the response
		if ([responseBody isEmptyOrWhitespace])
		{
			[self didFinishLoad];
			[self destroy];
			
			// save the delete
			[[ManagedObjectsController getInstance] saveChanges];
		}
		else
		{
			[self didFailLoadWithError:nil];
		}
		
		// stop here
		return;
	}
	
	id responseValue = [responseBody JSONValue];
	
	// if the response is an array, it means we returned errors
	if ([responseValue isKindOfClass:[NSArray class]])
	{
		NSError *error = nil;
		if ([responseValue count] > 0)
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
		return;
	}
	
	NSDictionary *json = responseValue;
	NSEnumerator *enumerator = [json keyEnumerator];
	NSString *key = [enumerator nextObject];
	NSDictionary *properties = [json objectForKey:key];
	
	// if there was a null response and we were checkign a previous upload
	if (wasCheckingPreviousUpload && [responseBody isEqualToString:@"null"])
	{
		//NSLog(@"Result for previous upload request was null");
		// reset and loop through again, like this never happened
		self.request = nil;
		[self performSelector:@selector(load) withObject:nil afterDelay:.3];
	}
	// if the data is not well formatted, respond with a failure
	else if (nil == properties || 0 == [properties count])
	{
		//NSLog(@"Result did not return any properties");
		// send back a failure response
		[self didFailLoadWithError:nil];
	}
	else
	{
		//NSLog(@"Result should update properties");
		// update the last synced time, so this can be passed along to sub-children
		self.lastSynced = [[self.request.timestamp copy] autorelease];
		self.loadedTime = [[self.request.timestamp copy] autorelease];
		
		// update the properties
		[self updateWithProperties:properties];
		
		[[ManagedObjectsController getInstance] saveChanges];
		
		// TODO: Handle isOutdated flag changed during an upload
		[self didFinishLoad];
	}
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	NSLog(@"%@ Request %@ Did Fail %d / %d, With Error: %@", self.objectName, self.UUID, request.totalBytesLoaded, request.totalBytesExpected, [error localizedDescription]);
	self.isUploadComplete = NO;
	[self didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	//NSLog(@"%@ Request %@ Did Cancel: %d / %d", self.objectName, self.UUID, request.totalBytesLoaded, request.totalBytesExpected);
	self.isUploadComplete = NO;
	[self didCancelLoad];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString *)baseURL
{
	return [NSString stringWithFormat:@"%@%@",
			[Global getInstance].sitePath,
			self.objectNamePlural
			];
}

- (NSString *)URL
{
	return [NSString stringWithFormat:@"%@/%@",
			self.baseURL,
			self.UUID
			];
}

- (void)updateWithProperties:(NSDictionary *)properties
{
	// update with properties is used for remote server responses, 
	// so the record must be synced with the server (even if out of date)
	self.hasSynced = YES;
	
	if (!![properties objectForKey:@"uuid"])
		self.UUID = [properties objectForKey:@"uuid"];
}

- (void)deleteRemote
{
	// cancel any current action
	[self cancel];
	
	// if this has been synced on the server, delete on the server first
	if (self.hasSynced)
	{
		self.shouldDelete = YES;
		[self load:TTURLRequestCachePolicyNone more:NO];
	}
	// if not yet on the server, just destroy right away
	else
	{
		[self destroy];
	}
}

- (void)destroy
{
	// if already destroyed
	if ([self isDeleted])
		return;
	
	[[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
	[_request cancel];
	
	TT_RELEASE_SAFELY(_request);
	TT_RELEASE_SAFELY(_delegates);
	
	//NSLog(@"Destroy %@, id:%@", NSStringFromClass([self class]), self.UUID);
	[[ManagedObjectsController getInstance] deleteObject:self];
}

- (void)dealloc
{
	[[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
	[_request cancel];
	
	TT_RELEASE_SAFELY(_request);
	TT_RELEASE_SAFELY(_delegates);
	[super dealloc];
}

@end
