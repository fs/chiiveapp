//
//  CHTableUploadItemCell.m
//  chiive
//
//  Created by Arrel Gray on 12/29/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableUploadItem.h"
#import "UploadQueue.h"
#import "RESTObject.h"
#import "PostModel.h"
#import "Post.h"
#import "Group.h"
#import "Comment.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMargin = 10;
static const CGFloat kSmallMargin = 6;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableUploadItem
@synthesize model = _model;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHTableUploadItemCell
@synthesize model = _model;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return 60;
}

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		CHTableUploadItem* item = object;
		self.model = item.model;
		self.textLabel.font = [UIFont boldSystemFontOfSize:14];
		self.subtitleLabel.font = [UIFont systemFontOfSize:13];
		
		// don't allow canceling a group upload
		self.cancelButton.hidden = [self.model isKindOfClass:[Group class]];
	}
}

- (void)updateProgressWithRequest:(TTURLRequest *)request
{
	if (!request)
	{
		self.subtitleLabel.text = @"Pending";
		self.progressView.hidden = YES;
	}
	else if (request.totalBytesExpected > 0)
	{
		NSInteger loaded = round((float)request.totalBytesLoaded / 1000);
		NSInteger total = round((float)request.totalBytesExpected / 1000);
		self.subtitleLabel.text = [NSString stringWithFormat:@"Uploading %dK of %dK", loaded, total];
		
		self.progressView.hidden = NO;
		float pct = 90 * (float)request.totalBytesLoaded / (float)request.totalBytesExpected;
		if (pct < 10) pct = 10;
		[self.progressView setValue:pct animated:YES];
	}
	else
	{
		self.subtitleLabel.text = @"Uploading...";
		self.progressView.hidden = NO;
		self.progressView.value = 10;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc {
	[[[_model request] delegates] removeObject:self];
	[[_model delegates] removeObject:self];
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_progressView);
	TT_RELEASE_SAFELY(_progressBackgroundView);
	TT_RELEASE_SAFELY(_cancelButton);
	
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat height = self.contentView.height;
	CGFloat width = self.contentView.width;
	CGFloat left = self.textLabel.frame.origin.x;
	
	if (_imageView2)
	{
		_imageView2.frame = CGRectMake(5, 5, height - 10, height - 10);
		self.textLabel.frame = CGRectMake(left, 5, width - left - 10, 15);
		self.subtitleLabel.frame = CGRectMake(left, 20, width - left - 10, 15);
	}
	
	CGFloat progressHeight = 15;
	CGFloat progressWidth = width - left - kMargin - self.cancelButton.frame.size.width;
	CGFloat top = height - progressHeight - kSmallMargin;
	
	self.progressView.frame = CGRectMake(left, top, progressWidth, progressHeight);
	_progressBackgroundView.frame = self.progressView.frame;
	left += self.progressView.frame.size.width + kSmallMargin;
	
	self.cancelButton.frame = CGRectMake(left, top - 4, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)cancelUpload
{
	[[UploadQueue getInstance] removeObjectFromQueue:self.model];
	[self.model destroy];
}

- (void)cancelButtonWasPressed
{
	[[[[UIAlertView alloc] initWithTitle:@"Cancel Upload" 
								 message:@"Do you want to cancel this upload and delete the photo?" 
								delegate:self
					   cancelButtonTitle:@"No"
					   otherButtonTitles:@"Delete", nil] autorelease] show];
}


////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
		[self cancelUpload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIButton *)cancelButton
{
	if (!_cancelButton)
	{
		UIImage *cancelImage = [UIImage imageNamed:@"button_cancel_small.png"];
		_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cancelImage.size.width, cancelImage.size.height)];
		[_cancelButton addSubview:[[[UIImageView alloc] initWithImage:cancelImage] autorelease]];
		//[_cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
		[_cancelButton addTarget:self action:@selector(cancelButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_cancelButton];
	}
	return _cancelButton;
}

- (UISlider	*)progressView
{
	if (!_progressView) {
		CGRect frame = CGRectMake(63, 42, 202, 15);
		
		_progressBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"slider_outer.png"]
																		   stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0]];
		_progressBackgroundView.frame = frame;
		[self.contentView addSubview:_progressBackgroundView];
		
        _progressView = [[UISlider alloc] initWithFrame:frame];
        [_progressView addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        _progressView.backgroundColor = [UIColor clearColor];	
        UIImage *stetchLeftTrack = [[UIImage imageNamed:@"slider_inner.png"]
									stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        UIImage *stetchRightTrack = [UIImage imageNamed:@"spacer_10x10.png"];
        [_progressView setThumbImage: [UIImage imageNamed:@"spacer_10x10.png"] forState:UIControlStateNormal];
        [_progressView setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [_progressView setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        _progressView.minimumValue = 0.0;
        _progressView.maximumValue = 100.0;
        _progressView.value = 5.0;
		_progressView.userInteractionEnabled = NO;
		
		[self.contentView addSubview:_progressView];
	}
	return _progressView;
}


- (void)setModel:(RESTObject *)model
{
	if (model != _model)
	{
		[[[_model request] delegates] removeObject:self];
		[[_model delegates] removeObject:self];
		
		[model retain];
		[_model retain];
		_model = model;
		
		[[_model delegates] addObject:self];
		[[[_model request] delegates] addObject:self];
		
		[self updateProgressWithRequest:[_model request]];
	}
}

- (RESTObject *)model
{
	return _model;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model
{
	[self updateProgressWithRequest:self.model.request];
	[self.model.request.delegates removeObject:self];
	[self.model.request.delegates addObject:self];
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	self.subtitleLabel.hidden = NO;
	self.subtitleLabel.text = @"Finished!";
	[self.model.request.delegates removeObject:self];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
	self.subtitleLabel.text = @"Error!";
	[self.model.request.delegates removeObject:self];
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
	self.subtitleLabel.text = @"Canceled!";
	[self.model.request.delegates removeObject:self];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidUploadData:(TTURLRequest*)request
{
	[self updateProgressWithRequest:request];
}


@end
