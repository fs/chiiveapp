//
//  ImageResizeAndSaveOperation.m
//  chiive
//
//  Created by 17FEET on 7/17/09.
//  Copyright 2009 17FEET. All rights reserved.
//

//#define radians(_DEGREES) (_DEGREES * M_PI / 180);



#import "ImageResizeAndSaveOperation.h"
#import "Post.h"
#import "UIImage+Resize.h"

@implementation ImageResizeAndSaveOperation
@synthesize originalImage = _originalImage, post = _post, 
			callbackTarget = _callbackTarget, callbackSelector = _callbackSelector;

+ (id)queueImageResizeAndSaveWithImage:(UIImage *)image withPost:(Post *)targetPost withCallbackTarget:(id)target withCallbackSelector:(SEL)selector
{
	ImageResizeAndSaveOperation *op = [[[ImageResizeAndSaveOperation alloc] init] autorelease];
	
	// Add an extra retain to the image to save through memory warning errors
	op.originalImage = image;
	op.post = targetPost;
	op.callbackTarget = target;
	op.callbackSelector = selector;
	
	return op;
}

- (void) main {
	NSString *url;
	UIImage *img;
	NSData *data;
	
	CGFloat destW = 800.0;
	CGFloat destH = 800.0;
	
	CGFloat sourceW = self.originalImage.size.width;
	CGFloat sourceH = self.originalImage.size.height;
	
	// skip the first resize
	if (self.originalImage.size.width > destW || self.originalImage.size.height > destH)
	{
		CGFloat widthFactor = destW / sourceW;
		CGFloat heightFactor = destH / sourceH;
		CGFloat scaleFactor = (widthFactor > heightFactor) ? heightFactor : widthFactor;
		
		img = [self.originalImage resizedImage:CGSizeMake(sourceW * scaleFactor, sourceH * scaleFactor) interpolationQuality:1];
	}
	else
	{
		img = self.originalImage;
	}
	
	url = [self.post URLForVersion:TTPhotoVersionLarge];
	
	data = UIImageJPEGRepresentation(img, .8);
	[[TTURLCache sharedCache] storeData:data forURL:url];
	
	img = [self.originalImage thumbnailImage:75.0 transparentBorder:0 cornerRadius:0 interpolationQuality:1];
	url = [self.post URLForVersion:TTPhotoVersionThumbnail];
	data = UIImageJPEGRepresentation(img, .8);
	
	[[TTURLCache sharedCache] storeData:data forURL:url];
	
	// early release the original image to free up memory
	TT_RELEASE_SAFELY(_originalImage);
	
	if ([self.callbackTarget respondsToSelector:self.callbackSelector]) {
		[self.callbackTarget performSelector:self.callbackSelector];
	}
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_originalImage);
	TT_RELEASE_SAFELY(_post);
	[super dealloc];
}

@end
