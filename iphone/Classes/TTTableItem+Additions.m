//
//  TTTableItem+Additions.m
//  spyglass
//
//  Created by 17FEET on 4/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "TTTableItem+Additions.h"

// If the item in the cell is a UIView, use that view's height for the cell height.
// Otherwise, just return the standard height.
@implementation TTTableFlushViewCell (Additions)
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	// table flush views hold UIView objects.
	// if that UIView object has a height, return that height
	if ([object isKindOfClass:[UIView class]] && [(UIView *)object height] > 1)
		return [(UIView *)object height];
	
	return TT_ROW_HEIGHT;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	// only update the view's frame if it has not already been set
	if (0 == _view.height)
		_view.frame = self.contentView.bounds;
}
@end
