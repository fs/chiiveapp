//
//  CHTableCommentItem.h
//  spyglass
//
//  Created by 17FEET on 3/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//


@interface CHTableCommentItem : TTTableStyledTextItem
{
	NSString	*_imageURL;
	UIColor		*_backgroundColor;
}
@property (nonatomic, retain)	NSString	*imageURL;
@property (nonatomic, retain)	UIColor		*backgroundColor;
@end

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

@interface CHTableCommentItemCell : TTStyledTextTableItemCell {
	TTImageView* _imageView2;
}
@property(nonatomic,readonly,retain) TTImageView* imageView2;
@end

