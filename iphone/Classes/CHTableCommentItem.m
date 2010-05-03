//
//  CHTableCommentItem.m
//  spyglass
//
//  Created by 17FEET on 3/25/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableCommentItem.h"

////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableCommentItem
@synthesize imageURL = _imageURL, backgroundColor = _backgroundColor;
@end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation CHTableCommentItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	CHTableCommentItem *item = object;
	TTStyledText* text = item.text;
	if (!text.font) {
		text.font = TTSTYLEVAR(font);
	}
	
	NSInteger imageSideLength = 52;
	text.width = tableView.width - 105;
	if (!!item.imageURL)
	{
		text.width -= imageSideLength;
	}
	CGFloat height = text.height;
	if (!!item.imageURL && height < imageSideLength) 
		height = imageSideLength;
	
	return height;
}

- (TTImageView*)imageView2 {
	if (!_imageView2) {
		_imageView2 = [[TTImageView alloc] init];
		//    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
		//    _imageView2.style = TTSTYLE(threadActorIcon);
		[self.contentView addSubview:_imageView2];
	}
	return _imageView2;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	NSInteger left;
	if (_imageView2) {
		_imageView2.frame = CGRectMake(5, 5, 42, 42);
		left = _imageView2.right + 5;
	} else {
		left = 10;
	}
	
	CHTableCommentItem* item = self.object;
	NSInteger imageSideLength = 52;
	item.text.width = self.contentView.bounds.size.width - imageSideLength - 30;
	_label.frame = CGRectMake(left, item.margin.top, item.text.width, item.text.height + item.padding.top + item.padding.bottom);
	_label.backgroundColor = [UIColor clearColor];
}

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		CHTableCommentItem* item = object;
		self.contentView.backgroundColor = item.backgroundColor;
		
		if (!!item.imageURL) {
			self.imageView2.urlPath = item.imageURL;
		}
		
		_label.text = item.text;
		_label.contentInset = item.padding;
		
		[self setNeedsLayout];
	}  
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_imageView2);
	[super dealloc];
}

@end

