//
//  GroupEditViewController.h
//  chiive
//
//  Created by 17FEET on 12/14/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableItem.h"

@class Group;

@interface GroupEditViewController : TTTableViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	Group						*_group;
	UITextField					*_titleField;
	TTImageView					*_thumbnailView;
	UILabel						*_titleLabel;
	UIBarButtonItem				*_createButton;
	UIBarButtonItem				*_cancelButton;
	NSString					*_tempGroupName;
	BOOL						_groupIsNew;
}

@property (nonatomic, retain)	Group					*group;
@property (nonatomic, readonly)	UITextField				*titleField;
@property (nonatomic, readonly)	TTImageView				*thumbnailView;
@property (nonatomic, readonly)	UILabel					*titleLabel;
@property (nonatomic, readonly)	UIBarButtonItem			*createButton;
@property (nonatomic, readonly)	UIBarButtonItem			*cancelButton;
@property (nonatomic, copy)		NSString				*tempGroupName;
@property (nonatomic, assign)	BOOL					groupIsNew;

- (void)createGroup;

@end

@interface CHTableLeftCaptionItemCell : TTTableRightCaptionItemCell
@end

