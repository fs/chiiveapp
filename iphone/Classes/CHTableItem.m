//
//  CHTableItem.m
//  chiive
//
//  Created by Arrel Gray on 1/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableItem.h"
#import "CHTableUserItem.h"
#import "CHTableUploadItem.h"
#import "CHTableGroupItem.h"


///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kDisclosureIndicatorWidth = 23;


///////////////////////////////////////////////////////////////////////////////////////////////////
// Data Sources

@implementation CHListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
{
	if ([object isKindOfClass:[CHTableRightBlueCaptionItem class]])
		return [CHTableRightBlueCaptionItemCell class];
	else if ([object isKindOfClass:[CHTableTextItem class]])
		return [CHTableTextItemCell class];
	else if ([object isKindOfClass:[CHTableStyledTextItem class]])
		return [CHTableStyledTextItemCell class];
	else if ([object isKindOfClass:[CHTableGroupItem class]])
		return [CHTableGroupItemCell class];
	else if ([object isKindOfClass:[CHTableUserItem class]])
		return [CHTableUserItemCell class];
	else if ([object isKindOfClass:[CHTableUserRequestItem class]])
		return [CHTableUserRequestItemCell class];
	else if ([object isKindOfClass:[CHTableUserInviteItem class]])
		return [CHTableUserInviteItemCell class];
	else if ([object isKindOfClass:[CHTableUploadItem class]])
		return [CHTableUploadItemCell class];
	else
		return [super tableView:tableView cellClassForObject:object];
}

- (NSIndexPath*)tableView:(UITableView*)tableView willUpdateObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath
{
	// if this is a table item class, remove it from the list
	if ([object isKindOfClass:[TTTableItem class]])
	{
		[self.items replaceObjectAtIndex:indexPath.row withObject:object];
		return indexPath;
	}
	else
	{
		return nil;
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willRemoveObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath
{
	// if this is a table item class, remove it from the list
	if ([object isKindOfClass:[TTTableItem class]])
	{
		[self.items removeObjectAtIndex:indexPath.row];
		return indexPath;
	}
	else
	{
		return nil;
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath
{
	// if this is a table item class, remove it from the list
	if ([object isKindOfClass:[TTTableItem class]])
	{
		[self.items insertObject:object atIndex:indexPath.row];
		return indexPath;
	}
	else
	{
		return nil;
	}
}

@end

@implementation CHSectionedDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
{
	if ([object isKindOfClass:[CHTableRightBlueCaptionItem class]])
		return [CHTableRightBlueCaptionItemCell class];
	else if ([object isKindOfClass:[CHTableTextItem class]])
		return [CHTableTextItemCell class];
	else if ([object isKindOfClass:[CHTableStyledTextItem class]])
		return [CHTableStyledTextItemCell class];
	else if ([object isKindOfClass:[CHTableGroupItem class]])
		return [CHTableGroupItemCell class];
	else if ([object isKindOfClass:[CHTableUserItem class]])
		return [CHTableUserItemCell class];
	else if ([object isKindOfClass:[CHTableUserRequestItem class]])
		return [CHTableUserRequestItemCell class];
	else if ([object isKindOfClass:[CHTableUserInviteItem class]])
		return [CHTableUserInviteItemCell class];
	else if ([object isKindOfClass:[CHTableUploadItem class]])
		return [CHTableUploadItemCell class];
	else
		return [super tableView:tableView cellClassForObject:object];
}
@end



///////////////////////////////////////////////////////////////////////////////////////////////////
// Table Item Additions

@implementation TTTableLinkedItemCell (CHCategory)
- (void)updateAccessoryType
{
	if (_item.accessoryURL)
		self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	else if (_item.URL)
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}
@end




///////////////////////////////////////////////////////////////////////////////////////////////////
// Table Items

@implementation CHTableTextItem
@synthesize checked = _checked;
@end

@implementation CHTableTextItemCell
- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		CHTableTextItem *item = (CHTableTextItem *)object;
		if (item.checked)
			self.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			[self updateAccessoryType];
	}
}
@end

@implementation CHTableRightBlueCaptionItem
@end

@implementation CHTableRightBlueCaptionItemCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]) {
		//self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	}
	return self;
}
- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		TTTableCaptionItem* item = object;
		self.textLabel.text = item.text;
		self.detailTextLabel.text = item.caption;
		
		[self updateAccessoryType];
	}
}
@end

@implementation CHTableStyledTextItem
@end

@implementation CHTableStyledTextItemCell
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	TTTableStyledTextItem* item = object;
	if (!item.text.font) {
		item.text.font = TTSTYLEVAR(font);
	}
	
	CGFloat padding = [tableView tableCellMargin]*2 + item.padding.left + item.padding.right;
	if (item.URL) {
		padding += kDisclosureIndicatorWidth;
	}
	
	item.text.width = tableView.width - padding;
	return item.text.height + item.padding.top + item.padding.bottom + item.margin.top + item.margin.bottom;
}

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		[self updateAccessoryType];
	}  
}


- (void)layoutSubviews {
	[super layoutSubviews]; 
	TTTableStyledTextItem* item = self.object; 
	_label.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, 
										 item.margin);
}
@end

