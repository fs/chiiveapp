//
//  CommentsButtonView.m
//  chiive
//
//  Created by 17FEET on 9/23/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CommentsButtonView.h"


@implementation CommentsButtonView

- (id)initWIthNumberOfComments:(NSUInteger)number
{
	if (self = [self init]) {
		self.numberOfComments = number;
	}
	return self;
}

- (id)init
{
	if (self = [super init]) {
		icon = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		icon.defaultImage = [UIImage imageNamed:@"icon_comment_bubble.png"];
		[self addSubview:icon];
		
		numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -3, 30, 30)];
		numberLabel.font = [UIFont boldSystemFontOfSize:14];
		numberLabel.textColor = [UIColor whiteColor];
		numberLabel.textAlignment = UITextAlignmentCenter;
		numberLabel.opaque = NO;
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.text = @"0";
		[self addSubview:numberLabel];
	}
	return self;
}

- (NSUInteger)numberOfComments {
	return numberOfComments;
}

- (void)setNumberOfComments:(NSUInteger)number {
	if (number != numberOfComments) {
		numberOfComments = number;
		numberLabel.text = [NSString stringWithFormat:@"%d", numberOfComments];
	}
}

@end
