//
//  Post.h
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "Group.h"
#import "User.h"
#import "RESTObject.h"
#import "CommentModel.h"
#import "RESTModelComplete.h"

@protocol PostDelegate <NSObject>
@optional
- (void)postDidFinishSaving:(Post *)post;
@end


@interface Post : RESTObject <TTPhoto, TTURLRequestDelegate> {
	CommentModel		*_commentModel;
	
	NSOperationQueue	*_imageSavingQueue;
	id<PostDelegate>	_delegate;
}


@property (nonatomic, retain) User				*user;
@property (nonatomic, retain) Group				*group;
@property (nonatomic, retain) NSSet				*comments;

@property (nonatomic, readonly) CommentModel	*commentModel;
@property (nonatomic, assign) id<PostDelegate>	delegate;

@property (nonatomic, retain) NSNumber			*longitude;
@property (nonatomic, retain) NSNumber			*latitude;
@property (nonatomic, copy)	  NSString			*photoFileName;
@property (nonatomic, copy)	  NSString			*photoPath;
@property (nonatomic, copy)	  NSString			*caption;
@property (nonatomic, retain) NSDate			*captured_at;

- (void)saveWithPhoto:(UIImage *)image;
- (void)onResizeAndSavePhotos;

- (NSString *)getPhotoFileName;

- (void)createCommentWithText:(NSString *)text;

- (BOOL)attachPhotoToRequest:(TTURLRequest *)request forKey:(NSString *)key;

@end