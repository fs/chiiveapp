//
//  CHTableEmptyView.m
//  spyglass
//
//  Created by 17FEET on 4/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableEmptyView.h"


@implementation CHTableEmptyView

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTLabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [[TTLabel alloc] init];
		_titleLabel.style = TTSTYLE(h2);
		_titleLabel.backgroundColor = [UIColor whiteColor];
	}
	return _titleLabel;
}

- (TTLabel *)messageLabel
{
	if (!_messageLabel)
	{
		_messageLabel = [[TTLabel alloc] init];
		_messageLabel.backgroundColor = [UIColor whiteColor];
		
		TTTextStyle *messageStyle = (TTTextStyle *)TTSTYLE(h5);
		messageStyle.lineBreakMode = UILineBreakModeWordWrap;
		messageStyle.numberOfLines = 0;
		_messageLabel.style = messageStyle;
		
	}
	return _messageLabel;
}

- (TTButton *)button
{
	if (!_button)
	{
		_button = [[TTButton buttonWithStyle:@"largeRoundButton:"] retain];
	}
	return _button;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)createSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	[self addSubview:self.titleLabel];
	[self addSubview:self.messageLabel];
	[self addSubview:self.button];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)init
{
	if (self == [super init])
	{
		[self createSubviews];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self == [super initWithFrame:frame])
	{
		[self createSubviews];
	}
	return self;
}

- (void)layoutSubviews
{
	NSInteger padding = 20;
	NSInteger labelWidth = self.width - padding * 2;
	
	self.titleLabel.frame = CGRectMake(padding, padding, labelWidth, 30);
	
	CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font constrainedToSize:CGSizeMake(labelWidth, 500) lineBreakMode:UILineBreakModeWordWrap];
	self.messageLabel.frame = CGRectMake(padding, self.titleLabel.bottom, labelWidth, messageSize.height);
	
	[self.button sizeToFit];
	self.button.frame = CGRectMake(round( (self.width - self.button.width) * 0.5), self.messageLabel.bottom + 15, self.button.width, self.button.height);
}


- (void)dealloc
{
	TT_RELEASE_SAFELY(_button);
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_messageLabel);
	
	[super dealloc];
}
@end
