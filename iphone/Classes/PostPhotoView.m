//
//  PostPhotoView.m
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "Three20/TTImageViewInternal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#import "PostPhotoView.h"
#import "Post.h"
#import "UploadQueue.h"
#import "Global.h"
#import "User.h"
#import "PostPhotoLabel.h"
#import "PostPhotoLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static int kCaptionHeight = 60;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PostPhotoView

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)init
{
	if (self = [super init]) {
		_captionStyle = [[TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.75] next:
			 [TTFourBorderStyle styleWithTop:RGBACOLOR(0, 0, 0, 0.5) width:1 next:
			  [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
			   [TTTextStyle styleWithFont:TTSTYLEVAR(photoCaptionFont) color:TTSTYLEVAR(photoCaptionTextColor)
						  minimumFontSize:0 shadowColor:[UIColor colorWithWhite:0 alpha:0.9]
							 shadowOffset:CGSizeMake(0, 1) textAlignment:UITextAlignmentCenter
						verticalAlignment:UIControlContentVerticalAlignmentCenter
							lineBreakMode:UILineBreakModeTailTruncation numberOfLines:6 next:nil]]]] retain];
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoView


- (BOOL)loadVersion:(TTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
	NSString* URL = [_photo URLForVersion:version];
	if (URL) {
		if ([[TTURLCache sharedCache] hasDataForURL:URL] || fromNetwork) {
			_photoVersion = version;
			self.urlPath = URL;
			return YES;
		}
	}
	return NO;
}

- (PostPhotoLabel *)postCaptionLabel {
	return (PostPhotoLabel *)_captionLabel;
}

- (void)showCaption:(NSString*)caption {
	if (!_captionLabel) {
		_captionLabel = [[PostPhotoLabel alloc] init];
		_captionLabel.opaque = NO;
		_captionLabel.alpha = _hidesCaption ? 0 : 1;
		_captionLabel.userInteractionEnabled = NO;
		[self addSubview:_captionLabel];
	}
	
	self.postCaptionLabel.post = self.post;
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect screenBounds = TTScreenBounds();
	//CGFloat width = self.width;
	CGFloat height = self.height;
	//	CGFloat cx = self.bounds.origin.x + width/2;
	CGFloat cy = self.bounds.origin.y + height/2;
	CGFloat toolbarHeight = TTToolbarHeight();
	CGFloat postCaptionHeight = TT_TOOLBAR_HEIGHT;
	
	// bump the frame down to the bottom of the screen
	// rather than positioned above the (hidden) toolbar
	_statusLabel.frame = CGRectMake(_statusLabel.frame.origin.x, 
									_statusLabel.frame.origin.y + toolbarHeight, 
									_statusLabel.frame.size.width, 
									_statusLabel.frame.size.height);
	
	self.postCaptionLabel.frame = CGRectMake(0,
											 cy + floor(screenBounds.size.height/2 - (toolbarHeight + postCaptionHeight)),
											 screenBounds.size.width,
											 postCaptionHeight);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// PostPhotoView

- (Post *)post {
	if ([self.photo isMemberOfClass:[Post class]])
		return (Post *)self.photo;
	return nil;
}

- (BOOL)isUserPhoto
{
	return self.post.user == [Global getInstance].currentUser;
}

- (BOOL)isCommentPanelVisible
{
	return _isCommentPanelVisible;
}

/**
 * Override the setImage method to disallow resetting a current image (probably a thumbnail preview)
 * with the default "loading" image.
 */
- (void)setImage:(UIImage*)image {
	if (!_image || image != _defaultImage)
		[super setImage:image];
}

- (void)didEndTouches:touches {
	// ignore multitouch events
	if ([touches count] > 1)
		return;
	
	// record the touch's end location
	for (UITouch *touch in touches)
		_touchLocation = [touch locationInView:self.postCaptionLabel];
}

- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch {
	if (_touchLocation.y > 0)
	{
		// if the panel is visible, this is the user's post, and the caption was clicked,
		// open the editor
		if (_isCommentPanelVisible &&
			[Global getInstance].currentUser == self.post.user &&
			_touchLocation.x > self.postCaptionLabel.captionFrame.origin.x &&
			_touchLocation.x < self.postCaptionLabel.captionFrame.origin.x + self.postCaptionLabel.captionFrame.size.width &&
			_touchLocation.y < self.postCaptionLabel.captionFrame.origin.y + self.postCaptionLabel.captionFrame.size.height)
		{
			NSArray *keys = [NSArray arrayWithObjects:@"delegate", @"text", @"title", nil];
			NSArray *objects = [NSArray arrayWithObjects:self, self.post.caption, @"Edit Photo Caption", nil];
			NSDictionary *query = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			
			TTPostController* controller = [[TTPostController alloc] initWithNavigatorURL:nil query:query];
			[controller showInView:self.superview animated:YES];
			controller.delegate = self;
			return;
		}
		else if (_touchLocation.y < kCaptionHeight)
		{
//			[self toggleCommentPanelAnimated:YES];
		}
	}
}

/*
- (void)toggleCommentPanelAnimated:(BOOL)animated {
	_isCommentPanelVisible = !_isCommentPanelVisible;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:TT_TRANSITION_DURATION];
	}
	
	self.postCaptionLabel.frame = _isCommentPanelVisible ? _captionFrameOn : _captionFrameOff;
	
	if (animated) {
		[UIView commitAnimations];
	}
}
*/
/**
 * The user has posted text and qwan animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text
{
	self.post.caption = text;
	self.post.isOutdated = YES;
	
	[[UploadQueue getInstance] addObjectToQueue:self.post];
	[[UploadQueue getInstance] load:TTURLRequestCachePolicyNone more:NO];
	
	return YES;
}

/**
 * The text has been posted.
- (void)postController:(TTPostController*)postController didPostText:(NSString*)text
			withResult:(id)result
{
	NSLog(@"Did Post text '%@'", text);
}
 */


/**
 * The controller was cancelled before posting.
- (void)postControllerDidCancel:(TTPostController*)postController
{
	NSLog(@"Did Cancel");
}
 */

@end