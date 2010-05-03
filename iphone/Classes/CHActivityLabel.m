//
//  CHActivityLabel.m
//  chiive
//
//  Created by 17FEET on 3/10/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHActivityLabel.h"


@implementation CHActivityLabel

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
		self.font = [UIFont boldSystemFontOfSize:16];
		self.textAlignment = UITextAlignmentCenter;
		self.numberOfLines = 4;
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self addSubview:_activityIndicatorView];
		
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_activityIndicatorView.frame = CGRectMake(round((self.width - _activityIndicatorView.width) * 0.5), 
											  round((self.height - _activityIndicatorView.height) * 0.5), 
											  _activityIndicatorView.width, 
											  _activityIndicatorView.height);
}

- (void)setText:(NSString *)text
{
	[super setText:[NSString stringWithFormat:@"%@\n \n \n ", text]];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	
	if (hidden)
		[_activityIndicatorView stopAnimating];
	else
		[_activityIndicatorView startAnimating];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_activityIndicatorView);
	[super dealloc];
}

@end
