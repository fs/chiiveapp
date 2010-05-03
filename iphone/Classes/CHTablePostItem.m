//
//  CHTablePostItem.m
//  chiive
//
//  Created by 17FEET on 3/23/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTablePostItem.h"
#import "Post.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsTableViewCell (PostUploadFeedback)

- (void)assignPhotoAtIndex:(int)index toView:(TTThumbView*)thumbView {
	id<TTPhoto> photo = [_photo.photoSource photoAtIndex:index];
	CHPostThumbView *postThumbView = (CHPostThumbView *)thumbView;

	if (photo) {
		// assign the post to the view if the post has not synced with the server
		if ([photo isKindOfClass:[Post class]] && ![(Post *)photo hasSynced])
			postThumbView.post = (Post *)photo;
		else
			postThumbView.post = nil;
		
		thumbView.thumbURL = [photo URLForVersion:TTPhotoVersionThumbnail];
		thumbView.hidden = NO;
	} else {
		postThumbView.post = nil;
		
		thumbView.thumbURL = nil;
		thumbView.hidden = YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Custom table cells (copy of 

- (void)setColumnCount:(NSInteger)columnCount {
	if (_columnCount != columnCount) {
		if (columnCount > _columnCount) {
			for (TTThumbView* thumbView in _thumbViews) {
				[thumbView removeFromSuperview];
			}
			[_thumbViews removeAllObjects];
		}
		
		_columnCount = columnCount;
		
		for (NSInteger i = _thumbViews.count; i < _columnCount; ++i) {
			TTThumbView* thumbView = [[[CHPostThumbView alloc] init] autorelease];
			[thumbView addTarget:self action:@selector(thumbTouched:)
				forControlEvents:UIControlEventTouchUpInside];
			[self.contentView addSubview:thumbView];
			[_thumbViews addObject:thumbView];
			if (_photo) {
				[self assignPhotoAtIndex:_photo.index+i toView:thumbView];
			}
		}
	}
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHPostThumbView
@synthesize post = _post;

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateProgressWithRequest:(TTURLRequest *)request
{
	self.progressMask.hidden = NO;
	self.progressView.hidden = NO;
	
	if (!request)
	{
		self.progressView.frame = CGRectMake(0, 70, 5, 5);
	}
	else if (request.totalBytesExpected > 0)
	{
		float pct = 0.9 * (float)request.totalBytesLoaded / (float)request.totalBytesExpected;
		if (pct < 0.1) pct = 0.1;
		self.progressView.frame = CGRectMake(0, 70, 75 * pct, 5);
	}
	else
	{
		self.progressView.frame = CGRectMake(0, 70, 5, 5);
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPost:(Post *)post
{
	if (post != _post)
	{
		[[[_post request] delegates] removeObject:self];
		[[_post delegates] removeObject:self];
		[post retain];
		[_post release];
		_post = post;
		
		if (!_post)
		{
			self.progressMask.hidden = YES;
			self.progressView.hidden = YES;
		}
		else
		{
			[[_post delegates] addObject:self];
			[[[_post request] delegates] addObject:self];
			[self updateProgressWithRequest:[_post request]];
		}
	}
}
- (UIView *)progressView
{
	if (!_progressView)
	{
		_progressView = [[UIView alloc] initWithFrame:CGRectZero];
		_progressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
		_progressView.userInteractionEnabled = NO;
		[self addSubview:_progressView];
	}
	return _progressView;
}
- (UIView *)progressMask
{
	if (!_progressMask)
	{
		_progressMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
		_progressMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
		_progressMask.userInteractionEnabled = NO;
		[self addSubview:_progressMask];
	}
	return _progressMask;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model
{
	[[[self.post request] delegates] removeObject:self];
	[[[self.post request] delegates] addObject:self];
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	[[[self.post request] delegates] removeObject:self];
	self.progressMask.hidden = YES;
	self.progressView.hidden = YES;
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
	[[[self.post request] delegates] removeObject:self];
	self.progressMask.hidden = NO;
	self.progressView.frame = CGRectMake(0, 70, 5, self.height);
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
	[[[self.post request] delegates] removeObject:self];
	
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidUploadData:(TTURLRequest*)request
{
	[self updateProgressWithRequest:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)dealloc
{
	TT_RELEASE_SAFELY(_post);
	TT_RELEASE_SAFELY(_progressView);
	TT_RELEASE_SAFELY(_progressMask);
	[super dealloc];
}


@end

