//
//  GroupTableUserHeaderView.m
//  chiive
//
//  Created by 17FEET on 10/1/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "GroupTableUserHeaderView.h"
#import "User.h"


@implementation GroupTableUserHeaderView
@synthesize friendButton = _friendButton;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor blackColor];
		
		_avatarImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
		_avatarImageView.defaultImage = [UIImage imageNamed:@"icon_person.png"];
		[self addSubview:_avatarImageView];
		
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_statusLabel.font = [UIFont systemFontOfSize:14];
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.backgroundColor = [UIColor blackColor];
		_statusLabel.lineBreakMode = UILineBreakModeWordWrap;
		_statusLabel.numberOfLines = 2;
		[self addSubview:_statusLabel];
		
		_friendNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_friendNameLabel.font = [UIFont boldSystemFontOfSize:20];
		_friendNameLabel.textColor = [UIColor whiteColor];
		_friendNameLabel.backgroundColor	= [UIColor blackColor];
		[self addSubview:_friendNameLabel];
		
//		_friendButton = [[TTButton buttonWithStyle:@"discreteRoundButton:" title:@"unfriend"] retain];
//		[self addSubview:_friendButton];
		
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NSInteger padding = 10;
	NSInteger top = 5;
	NSInteger left = padding;
	
	_avatarImageView.frame = CGRectMake(left, top, 50, 50);
	top += 5;
	left += _avatarImageView.width + padding * 2;
	
	CGSize maxSize = CGSizeMake(self.width - left - padding, 300);
	CGSize statusSize = [_statusLabel.text sizeWithFont:_statusLabel.font constrainedToSize:maxSize lineBreakMode:_statusLabel.lineBreakMode];
	_statusLabel.frame = CGRectMake(left, top, self.frame.size.width - left - padding, statusSize.height);
	top += _statusLabel.height;
	
	_friendNameLabel.frame = CGRectMake(left, top, self.frame.size.width - left - padding, 25);
	top = _avatarImageView.bottom + 5;
	left = _avatarImageView.left;
	
//	[_friendButton sizeToFit];
//	_friendButton.frame = CGRectMake(left, top, _friendButton.width, _friendButton.height);
}

- (User *)user {
	return _user;
}

- (void)setUser:(User *)user
{
	if (user != _user)
	{
		[user retain];
		[_user release];
		_user = user;
		_avatarImageView.urlPath = _user.URLForAvatar;
		
		if (_user.isMutualFriend)
		{
			_friendNameLabel.hidden = NO;
			//_friendButton.hidden = NO;
			
//			_statusLabel.text = [NSString stringWithFormat:@"You are friends with %@", _user.displayName];
//			_friendNameLabel.text = [NSString stringWithFormat:@"%@ has %d Events", _user.displayName, _user.numGroups];
			
			_statusLabel.text = [NSString stringWithFormat:@"You are friends with"];
			_friendNameLabel.text = _user.displayName;
		}
		else
		{
			_statusLabel.text = [NSString stringWithFormat:@"%@'s information is only available to their friends", _user.displayName];
			_friendNameLabel.hidden = YES;
			//_friendButton.hidden = YES;
		}
	}
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_user);
	TT_RELEASE_SAFELY(_avatarImageView);
	TT_RELEASE_SAFELY(_statusLabel);
	TT_RELEASE_SAFELY(_friendNameLabel);
	TT_RELEASE_SAFELY(_friendButton);
	[super dealloc];
}

@end
