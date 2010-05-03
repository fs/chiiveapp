//
//  UploadQueue.h
//  chiive
//
//  Created by Arrel Gray on 9/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@class RESTObject;

@interface UploadQueue : TTModel <TTModelDelegate> {
	NSMutableArray		*_objects;
	NSMutableArray		*_backgroundObjects;
}

@property (nonatomic, readonly) NSMutableArray		*objects; // used for maintaining objects displayed in the list
@property (nonatomic, readonly) NSMutableArray		*backgroundObjects; // used for maintaining objects not displayed to the user
@property (nonatomic, readonly) NSUInteger			numberOfObjects;
@property (nonatomic, readonly) NSUInteger			numberOfBackgroundObjects;

+ (UploadQueue *)getInstance;

- (void)addObjectToQueue:(id<TTModel>)object;
- (void)removeObjectFromQueue:(id<TTModel>)object;
- (void)retrieveManagedChildren;

- (RESTObject *)objectAtIndex:(NSUInteger)index;

@end
