//
//  CHAvatarView.m
//  chiive
//
//  Created by Arrel Gray on 3/20/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHAvatarView.h"
#import "User.h"

@implementation CHAvatarView

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self addSubview:self.avatarBackground];
		[self addSubview:self.avatarImageView];
	}
	return self;
}

- (void)layoutSubviews
{
	self.avatarBackground.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	self.avatarImageView.frame = CGRectMake(1, 1, self.frame.size.width - 2, self.frame.size.height - 2);
	[super layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString *)urlPath
{
	return self.avatarImageView.urlPath;
}

- (void)setUrlPath:(NSString *)urlPath
{
	self.avatarImageView.urlPath = urlPath;
}

- (UIView *)avatarBackground
{
	if (!_avatarBackground)
	{
		_avatarBackground = [[UIView alloc] init];
		_avatarBackground.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
	}
	return _avatarBackground;
}

- (UIView *)avatarImageView
{
	if (!_avatarImageView)
	{
		_avatarImageView = [[TTImageView alloc] init];
	}
	return _avatarImageView;
}

@end
