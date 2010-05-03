//
//  CommentsButtonView.h
//  chiive
//
//  Created by 17FEET on 9/23/09.
//  Copyright 2009 17FEET. All rights reserved.
//



@interface CommentsButtonView : TTView {
	NSUInteger	numberOfComments;
	TTImageView *icon;
	UILabel		*numberLabel;
}

@property (assign) NSUInteger numberOfComments;

- (id)initWIthNumberOfComments:(NSUInteger)number;

@end
