//
//  CHTableItem.h
//  chiive
//
//  Created by Arrel Gray on 1/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;
@class User;


///////////////////////////////////////////////////////////////////////////////////////////////////
// Data Sources

@interface CHListDataSource : TTListDataSource
@end

@interface CHSectionedDataSource : TTSectionedDataSource
@end



///////////////////////////////////////////////////////////////////////////////////////////////////
// Table Item Additions

@interface TTTableLinkedItemCell (CHCategory)
- (void)updateAccessoryType;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
// Table Items

/**
 * Regular table text item with optional Checkmark accessoryType
 */
@interface CHTableTextItem : TTTableTextItem {
	BOOL	_checked;
}
@property (nonatomic, assign) BOOL checked;
@end

@interface CHTableTextItemCell : TTTableTextItemCell
@end

/**
 * Table item with text and caption of type UITableViewCellStyleValue1
 */
@interface CHTableRightBlueCaptionItem : TTTableCaptionItem
@end

@interface CHTableRightBlueCaptionItemCell : TTTableLinkedItemCell
@end

/**
 * Updated styled text item cell that allows for margins within the table cell
 * to properly display in a grouped (rounded-edge) table cell.
 */
@interface CHTableStyledTextItem : TTTableStyledTextItem
@end

@interface CHTableStyledTextItemCell : TTStyledTextTableItemCell
@end


