//
//  Post.m
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "Post.h"
#import "PostModel.h"
#import "Group.h"
#import "GroupModel.h"
#import "Global.h"
#import "ManagedObjectsController.h";
#import "ImageResizeAndSaveOperation.h"
#import "FormatterHelper.h"
#import "JSON.h"
#import "CommentModel.h"
#import "Comment.h"
#import "UserModel.h"
#import "NSDictionary+Casting.h"

@implementation Post
@dynamic caption, captured_at, longitude, latitude, photoPath, photoFileName, comments, user, group;
@synthesize delegate = _delegate;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (NSString *)getPhotoFileName
{
	if (!self.photoFileName || [self.photoFileName isEmptyOrWhitespace] || [self.photoFileName isEqualToString:@"<null>"])
		self.photoFileName = @"image.jpg";
	return self.photoFileName;
}

- (NSString *)getPhotoPath
{
	if (!self.photoPath || [self.photoPath isEmptyOrWhitespace] || [self.photoPath isEqualToString:@"<null>"])
		self.photoPath = self.UUID;
	
	return self.photoPath;
}

- (void)moveDataForUrls:(NSArray *)previousUrls toUrls:(NSArray *)newUrls
{
	NSUInteger numUrls = [previousUrls count];
	for (NSUInteger i=0; i<numUrls; i++)
	{
		if ([[TTURLCache sharedCache] hasDataForURL:[previousUrls objectAtIndex:i]])
		{
			[[TTURLCache sharedCache] moveDataForURL:[previousUrls objectAtIndex:i] toURL:[newUrls objectAtIndex:i]];
		}
	}
}

- (void)updatePhotoFileName:(NSString *)fileName
{
	// if this is a change
	if (!!self.photoFileName && ![self.photoPath isEmptyOrWhitespace] && ![fileName isEqualToString:self.photoFileName])
	{
		NSArray *previousUrls = [NSArray arrayWithObjects:
									 [self URLForVersion:TTPhotoVersionThumbnail],
									 [self URLForVersion:TTPhotoVersionSmall],
									 [self URLForVersion:TTPhotoVersionMedium],
									 [self URLForVersion:TTPhotoVersionLarge],
									 nil];
		
		self.photoFileName = fileName;
		
		NSArray *newUrls = [NSArray arrayWithObjects:
									 [self URLForVersion:TTPhotoVersionThumbnail],
									 [self URLForVersion:TTPhotoVersionSmall],
									 [self URLForVersion:TTPhotoVersionMedium],
									 [self URLForVersion:TTPhotoVersionLarge],
									 nil];
		
		[self moveDataForUrls:previousUrls toUrls:newUrls];
	}
	else
	{
		self.photoFileName = fileName;
	}
}

- (void)updatePhotoPath:(NSString *)path
{
	// if this is a change
	if (!!self.photoPath && ![self.photoPath isEmptyOrWhitespace] && ![path isEqualToString:self.photoPath])
	{
		NSArray *previousUrls = [NSArray arrayWithObjects:
								 [self URLForVersion:TTPhotoVersionThumbnail],
								 [self URLForVersion:TTPhotoVersionSmall],
								 [self URLForVersion:TTPhotoVersionMedium],
								 [self URLForVersion:TTPhotoVersionLarge],
								 nil];
		
		self.photoPath = path;
		
		NSArray *newUrls = [NSArray arrayWithObjects:
							[self URLForVersion:TTPhotoVersionThumbnail],
							[self URLForVersion:TTPhotoVersionSmall],
							[self URLForVersion:TTPhotoVersionMedium],
							[self URLForVersion:TTPhotoVersionLarge],
							nil];
		
		[self moveDataForUrls:previousUrls toUrls:newUrls];
	}
	else
	{
		self.photoPath = path;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (CommentModel *)commentModel
{
	if (!_commentModel)
	{
		_commentModel = [[CommentModel alloc] init];
		_commentModel.post = self;
		[_commentModel.delegates addObject:self];
	}
	
	return _commentModel;
}

- (void)createCommentWithText:(NSString *)text
{
	Comment *comment = (Comment *)[ManagedObjectsController objectWithClass:[Comment class]];
	comment.post = self;
	comment.user = [Global getInstance].currentUser;
	comment.body = text;
	
	[self.commentModel insertNewChild:comment];
	[comment load:TTURLRequestCachePolicyNoCache more:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTObject

- (NSString *)baseURL
{
	return [NSString stringWithFormat:@"%@events/%@/posts",
			[Global getInstance].sitePath,
			self.group.UUID
			];
}

- (void)updateWithProperties:(NSDictionary *)properties
{
	[super updateWithProperties:properties];
	
	// removing parsing of date since date formatting is very expensive
	if (!self.captured_at && !![properties objectForKey:@"captured_at"])
	{
		NSString *capturedAtString = [properties objectForKey:@"captured_at"];
		NSDate *capturedAtDate = [FormatterHelper dateTimeFromString:capturedAtString];
		self.captured_at = capturedAtDate;
	}
	
	if (nil != [properties objectForKey:@"event_uuid"])
	{
		NSString *groupUUID = [properties stringForKey:@"event_uuid"];
		self.group = (Group *)[GroupModel getChildWithUUID:groupUUID];
		if (!self.group)
		{
			self.group = (Group *)[ManagedObjectsController objectWithClass:[Group class]];
			self.group.UUID = groupUUID;
		}
	}
	
	if (nil != [properties objectForKey:@"user_uuid"])
	{
		NSString *userUUID = [properties stringForKey:@"user_uuid"];
		self.user = (User *)[UserModel getChildWithUUID:userUUID];
		if (!self.user)
		{
			self.user = (User *)[ManagedObjectsController objectWithClass:[User class]];
			self.user.UUID = userUUID;
		}
	}
	
	// save any posts relationships
	NSArray *commentsList = [properties objectForKey:@"comments"];
	if (!!commentsList && [commentsList count] > 0) {
		[self.commentModel parseChildrenList:commentsList];
		self.commentModel.loadedTime = self.lastSynced;
	}
	
	if (nil != [properties objectForKey:@"latitude"])
		self.latitude = [properties numberForKey:@"latitude"];
	
	if (nil != [properties objectForKey:@"longitude"])
		self.longitude = [properties numberForKey:@"longitude"];
	
	if (nil != [properties objectForKey:@"title"])
		self.caption = [properties stringForKey:@"title"];
	
	if (nil != [properties objectForKey:@"photo_path"])
		[self updatePhotoPath:[properties stringForKey:@"photo_path"]];
	
	if (nil != [properties objectForKey:@"photo_file_name"])
		[self updatePhotoFileName:[properties stringForKey:@"photo_file_name"]];
}

- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format
{
	[super setDefaultParamsForRequest:request withFormat:format];
	
	if (!!self.captured_at)
		[request.parameters setObject:[FormatterHelper utcStringFromDateTime:self.captured_at] forKey:[NSString stringWithFormat:format, @"time_at"]];
	
	if (!!self.latitude)
		[request.parameters setObject:[NSString stringWithFormat:@"%@", self.latitude] forKey:[NSString stringWithFormat:format, @"latitude"]];
	
	if (!!self.longitude)
		[request.parameters setObject:[NSString stringWithFormat:@"%@", self.longitude] forKey:[NSString stringWithFormat:format, @"longitude"]];
	
	if (!self.caption)
		self.caption = @"";
	
	[request.parameters setObject:self.caption forKey:[NSString stringWithFormat:format, @"title"]];
}

/**
 * Format the CREATE request for this model object.
 */
- (TTURLRequest *)getCreateRequest
{
	TTURLRequest *request = [super getCreateRequest];
	if (![self attachPhotoToRequest:request forKey:@"post[photo]"])
	{
		// TODO: Notify UploadQueue
		[self destroy];
		return nil;
	}
	
	return request;
}

/**
 * Destroy any photos that have been cached to the local file system.
 * Delete the associated queue item if it exists.
 */
- (void)destroy
{
	// remove from the parent postmodel
	if (!!self.group && [self.group.postModel.children containsObject:self])
		[self.group.postModel removeChild:self];
	
	[[TTURLCache sharedCache] removeURL:[self URLForVersion:TTPhotoVersionLarge] fromDisk:YES];
	[[TTURLCache sharedCache] removeURL:[self URLForVersion:TTPhotoVersionThumbnail] fromDisk:YES];
	
	// remote associations
	self.group = nil;
	self.user = nil;
	
	[super destroy];
}

- (void)deleteRemote
{
	[super deleteRemote];
	
	// remove from the group
	[self.group	removePost:self];
}





// TTModelDelegate

/**
 * Pass through update methods called from the PostModel
 */
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didUpdateObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self didInsertObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
//	if ([object isKindOfClass:[Comment class]])
//	{
//		Comment *comment = (Comment *)object;
//		if (comment.hasSynced)
//			self.numRemoteComments--;
//	}
	[self didDeleteObject:object atIndexPath:indexPath];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)didFinishLoad
{
	// if we just synced the post, increment the number of remote posts for the group
	if (!self.hasSynced)
	{
		self.group.numRemotePosts++;
	}
	[super didFinishLoad];	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Creation and Update

// TODO: Attach photo as data rather than converting to image then back to data
- (BOOL)attachPhotoToRequest:(TTURLRequest *)request forKey:(NSString *)key
{
	// add the photo data
	NSString *photoUrl = [self URLForVersion:TTPhotoVersionLarge];
	UIImage *photo = [UIImage imageWithData:[[TTURLCache sharedCache] dataForURL:photoUrl]];
	
	// check to make sure there is a photo to save
	if (!photo)
		return NO;
	
	[request.parameters setObject:photo forKey:key];
	return YES;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

/**
 * The photo source that the photo belongs to.
 */
- (id<TTPhotoSource>)photoSource
{
	return self.group.postModel;
}
- (void)setPhotoSource:(id<TTPhotoSource>)photoSource
{
	//TODO: Implement setPhotoSource
}

/**
 * The index of the photo within its photo source.
 */
- (CGSize)size
{
	return CGSizeMake(480.0f, 320.0f);
}
- (void)setSize:(CGSize)size
{
	//TODO: Implement setSize
}

/**
 * Index of post within group list.
 */
- (NSInteger)index
{
	return [self.group.postModel indexOfChild:self];
}
- (void)setIndex:(NSInteger)index
{
	//TODO: Implement setIndex
}

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(TTPhotoVersion)version
{
	//NSLog([NSString stringWithFormat:@"get photo of id: %@", photoId]);
	
	NSString *type;
	if (version == TTPhotoVersionThumbnail || version == TTPhotoVersionSmall)
		type = @"iphone_preview";
	else 
		type = @"iphone";
	
	// if the photo path does not start with http (and is therefor probably hosted outside our app)
	// assume it's using the root of our app's domain as the hosting location
	NSString *imagePathPrefix = [[self getPhotoPath] hasPrefix:@"http"] ? @"" : [Global getInstance].sitePath;
	NSString *imagepath = [NSString stringWithFormat:@"%@%@/%@/%@",
						   imagePathPrefix,
						   [self getPhotoPath],
						   type,
						   [self getPhotoFileName]];
	
	// remove any possible double-slashes
	imagepath = [imagepath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
	
	// clean up the link - get rid of spaces, returns, and tabs...
//	imagepath = [imagepath stringByReplacingOccurrencesOfString:@" " withString:@""];
//	imagepath = [imagepath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//	imagepath = [imagepath stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//	imagepath = [[imagepath componentsSeparatedByString:@"<"] objectAtIndex:0];
	return imagepath;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Photo Handling

/**
 * Cache photo to be associated with the post.
 * If the post has been synced with the live record, modified date of the photo is manually
 *	set to the photoUpdated parameter of the post.
 */
-(void)saveWithPhoto:(UIImage *)image
{
	if (_imageSavingQueue == nil)
		_imageSavingQueue = [[NSOperationQueue alloc] init];
	
	ImageResizeAndSaveOperation *operation = [ImageResizeAndSaveOperation 
										queueImageResizeAndSaveWithImage:image 
										withPost:self
										withCallbackTarget:self
										withCallbackSelector:@selector(onResizeAndSavePhotos)];
//	[operation main];
	[_imageSavingQueue addOperation:operation];
}

/**
 * Listener function for completion of saveWithPhoto photo caching request.
 * Once the callback has been received and the photos are saved,
 * save the record, move the photos to the proper location, and tell the delegate
 * that the save is complete.
 */
- (void)onResizeAndSavePhotos
{
	if ([self.delegate respondsToSelector:@selector(postDidFinishSaving:)])
	{
		[self.delegate postDidFinishSaving:self];
	}
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_commentModel);
	TT_RELEASE_SAFELY(_imageSavingQueue);
	
	[super dealloc];
}

@end