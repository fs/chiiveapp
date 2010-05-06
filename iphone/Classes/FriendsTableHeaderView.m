//
//  FriendsTableHeaderView.m
//  chiive
//
//  Created by 17FEET on 3/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FriendsTableHeaderView.h"
#import "UserModel.h"
#import "CHDefaultStyleSheet.h"

@implementation FriendsTableHeaderView
@synthesize numberOfRequests = _numberOfRequests;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame])
	{
		_backgroundView = [[TTView alloc] init];
		_backgroundView.style = [TTLinearGradientFillStyle styleWithColor1:TTSTYLEVAR(roundButtonTopColor) 
																	color2:TTSTYLEVAR(roundButtonBottomColor) next:nil];
		_backgroundView.userInteractionEnabled = NO;
		[self addSubview:_backgroundView];
		
		_alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_friend_request.png"]];
		_alertImageView.alpha = 0.7;
		[_backgroundView addSubview:_alertImageView];
		
		_numberOfRequestsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_numberOfRequestsLabel.textColor = [UIColor whiteColor];
		_numberOfRequestsLabel.backgroundColor = [UIColor clearColor];
		_numberOfRequestsLabel.font = [UIFont boldSystemFontOfSize:15];
		[_backgroundView addSubview:_numberOfRequestsLabel];
		
		_viewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_viewLabel.textColor = [UIColor whiteColor];
		_viewLabel.backgroundColor = [UIColor clearColor];
		_viewLabel.font = [UIFont boldSystemFontOfSize:15];
		_viewLabel.text = @"View";
//		[_backgroundView addSubview:_viewLabel];
		
		_disclosureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_disclosure_indicator.png"]];
		_disclosureImageView.alpha = 0.8;
		[_backgroundView addSubview:_disclosureImageView];
		
	}
	return self;
}

- (void)setNumberOfRequests:(NSInteger)numberOfRequests
{
	NSString *formatString = numberOfRequests == 1 ? @"You have %d friend request" : @"You have %d friend requests";
	_numberOfRequestsLabel.text = [NSString stringWithFormat:formatString, numberOfRequests];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_backgroundView.frame = CGRectMake(0, 0, self.width, self.height);
	
	NSInteger padding = 5;
	NSInteger left = padding;
	
	_alertImageView.frame = CGRectMake(padding, (self.height - _alertImageView.height), _alertImageView.width, _alertImageView.height);
	left += _alertImageView.width + padding * 2;
	
	CGSize numberSize = [_numberOfRequestsLabel.text sizeWithFont:_numberOfRequestsLabel.font];
	_numberOfRequestsLabel.frame = CGRectMake(left, 0, numberSize.width, self.height - 2);
	
	_disclosureImageView.frame = CGRectMake(self.width - padding - _disclosureImageView.width, round((self.height - _disclosureImageView.height) * 0.5), 
											_disclosureImageView.width, _disclosureImageView.height);
	
	CGSize viewSize = [_viewLabel.text sizeWithFont:_viewLabel.font];
	_viewLabel.frame = CGRectMake(_disclosureImageView.left - viewSize.width, 0, viewSize.width, self.height - 2);
}
@end
