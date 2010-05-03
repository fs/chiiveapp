//
//  CHTutorialView.m
//  spyglass
//
//  Created by 17FEET on 4/13/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTutorialView.h"


static float kPadding = 15.0;

@implementation CHTutorialView

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)createSubviews
{
	[self addSubview:self.backgroundView];
	[self addSubview:self.titleLabel];
	[self addSubview:self.messageLabel];
	[self addSubview:self.actionButton];
}

- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.textColor = RGBCOLOR(81, 158, 16);
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		_titleLabel.numberOfLines = 0;
	}
	return _titleLabel;
}

- (UILabel *)messageLabel
{
	if (!_messageLabel)
	{
		_messageLabel = [[UILabel alloc] init];
		_messageLabel.textColor = RGBCOLOR(128,128,128);
		_messageLabel.textAlignment = UITextAlignmentCenter;
		_messageLabel.lineBreakMode = UILineBreakModeWordWrap;
		_messageLabel.numberOfLines = 0;
	}
	return _messageLabel;
}

- (UIImageView *)backgroundView
{
	if (!_backgroundView)
	{
		_backgroundView = [[UIImageView alloc] init];
	}
	return _backgroundView;
}

- (TTButton *)actionButton
{
	if (!_actionButton)
	{
		_actionButton = [[TTButton buttonWithStyle:@"largeRoundButton:"] retain];
	}
	return _actionButton;
}

- (float)actionButtonWidth
{
	return 236.0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self createSubviews];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	float labelWidth = self.width - kPadding * 2;
	float top = kPadding;
	
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font 
						constrainedToSize:CGSizeMake(labelWidth, 500)
						lineBreakMode:UILineBreakModeWordWrap];
	self.titleLabel.frame = CGRectMake(kPadding, top, labelWidth, titleSize.height);
	top += titleSize.height;
	
	CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font 
						constrainedToSize:CGSizeMake(labelWidth, 500)
						lineBreakMode:UILineBreakModeWordWrap];
	self.messageLabel.frame = CGRectMake(kPadding, top, labelWidth, messageSize.height);
	top += messageSize.height;
	
	NSString *buttonString = [self.actionButton titleForState:UIControlStateNormal];
	if (!!buttonString && ![buttonString isEmptyOrWhitespace])
	{
		top += kPadding;
		self.actionButton.hidden = NO;
		[self.actionButton sizeToFit];
		self.actionButton.frame = CGRectMake(round((self.width - self.actionButtonWidth) * 0.5), top, self.actionButtonWidth, self.actionButton.height);
	}
	else
	{
		self.actionButton.hidden = YES;
	}
	
	self.backgroundView.frame = CGRectMake(0, self.height - self.backgroundView.height, self.backgroundView.width, self.backgroundView.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init])
	{
		[self createSubviews];
	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_messageLabel);
	TT_RELEASE_SAFELY(_backgroundView);
	TT_RELEASE_SAFELY(_actionButton);
	[super dealloc];
}


@end
