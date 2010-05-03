//
//  FBLoginTableItemView.m
//  spyglass
//
//  Created by 17FEET on 4/21/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FBLoginTableItemView.h"


@implementation FBLoginTableItemView
@synthesize messageLabel = _messageLabel, loginButton = _loginButton;

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)createSubviews
{
	_messageLabel = [[TTStyledTextLabel alloc] init];
	_messageLabel.font = [UIFont systemFontOfSize:13];
	_messageLabel.text = [TTStyledText textFromXHTML:@"Login with Facebook"];
	_messageLabel.contentInset = UIEdgeInsetsMake(12, 15, 15, 5);
	_messageLabel.textColor = [UIColor blackColor];
	_messageLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_messageLabel];
	
	_loginButton = [[FBLoginButton alloc] initWithFrame:CGRectZero];
	[_loginButton sizeToFit];
	_loginButton.frame = CGRectOffset(_loginButton.frame, 5.0, 7.0);
	[self addSubview:_loginButton];
	
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
	[_messageLabel sizeToFit];
	float left = _loginButton.right - 9;
	_messageLabel.frame = CGRectMake(left, 2, self.width - left + 3, self.height - 2);
	
	[super layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)dealloc
{
	TT_RELEASE_SAFELY(_messageLabel);
	TT_RELEASE_SAFELY(_loginButton);
	[super dealloc];
}

@end
