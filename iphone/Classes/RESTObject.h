//
//  RESTObject.h
//  chiive
//
//  Created by 17FEET on 10/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//




@interface RESTObject : NSManagedObject <TTModel, TTURLRequestDelegate> {
	TTURLRequest		*_request;
	NSMutableArray		*_delegates;
	NSDate				*_requestedTime;
	NSDate				*_loadedTime;
	BOOL				_isCheckingPreviousUpload;
}

@property (nonatomic, readonly)	NSString			*objectName;
@property (nonatomic, readonly)	NSString			*objectNamePlural;
@property (nonatomic, readonly) NSString			*paramFormat;

@property (assign)				BOOL				hasSynced;
@property (nonatomic, retain)	NSNumber			*hasSyncedHolder;
@property (nonatomic, retain)	NSDate				*createdAt;
@property (nonatomic, retain)	NSDate				*updatedAt;

@property (nonatomic, readonly) NSString			*baseURL;
@property (nonatomic, readonly) NSString			*URL;
@property (nonatomic, retain)	TTURLRequest		*request;
@property (nonatomic, retain)	NSDate				*requestedTime;
@property (nonatomic, retain)	NSDate				*loadedTime;

@property (nonatomic, retain)	NSString			*UUID;

@property (nonatomic, retain)	NSNumber			*isOutdatedHolder;
@property (assign)				BOOL				isOutdated;
@property (nonatomic, retain)	NSDate				*lastSynced;
@property (nonatomic, retain)	NSNumber			*shouldDeleteHolder;
@property (assign)				BOOL				shouldDelete;

@property (nonatomic, retain)	NSNumber			*isUploadCompleteHolder;
@property (assign)				BOOL				isUploadComplete;
@property (assign)				BOOL				isCheckingPreviousUpload;


/**
 * Pass a dictionary of properties to be assigned to the instance's members.
 */
- (void)updateWithProperties:(NSDictionary *)properties;

/**
 * Proxies the appropriate RESTful request types and adds any required settings.
 */
- (TTURLRequest *)getRequest;
/**
 * Creates a new object
 */
- (TTURLRequest *)getCreateRequest;
/**
 * Updates the members of the object
 */
- (TTURLRequest *)getUpdateRequest;
/**
 * Pulls the latest server info of the object
 */
- (TTURLRequest *)getShowRequest;
/**
 * Destroys the object on the server
 */
- (TTURLRequest *)getDestroyRequest;

/**
 * Assigns default model data to any upload request.
 */
- (void)setDefaultParamsForRequest:(TTURLRequest *)request withFormat:(NSString *)format;

/**
 * Used to delete any child objects from memory.
 */
- (void)destroy;

/**
 * Used to delete the object on the remote server,
 * which triggers a destroy after successful delete.
 */
- (void)deleteRemote;


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel (methods not included in interface protocol)

/**
 * Notifies delegates that the model started to load.
 */
- (void)didStartLoad;

/**
 * Notifies delegates that the model finished loading
 */
- (void)didFinishLoad;

/**
 * Notifies delegates that the model failed to load.
 */
- (void)didFailLoadWithError:(NSError*)error;

/**
 * Notifies delegates that the model canceled its load.
 */
- (void)didCancelLoad;

/**
 * Notifies delegates that the model has begun making multiple updates.
 */
- (void)beginUpdates;

/**
 * Notifies delegates that the model has completed its updates.
 */
- (void)endUpdates;

/**
 * Notifies delegates that an object was updated.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was inserted.
 */
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was deleted.
 */
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that the model changed in some fundamental way.
 */
- (void)didChange;


@end
