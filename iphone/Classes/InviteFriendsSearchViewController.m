//
//  InviteFriendsSearchViewController.m
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "InviteFriendsSearchViewController.h"
#import "CHTableItem.h"
#import "UserSearchModel.h"
#import "CHTableUserItem.h"
#import "Global.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserSearchSectionedDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UITextField *)searchField
{
	if (!_searchField)
	{
		_searchField = [[UITextField alloc] init];
		_searchField.placeholder = @"Enter a name";
		_searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_searchField.autocorrectionType = UITextAutocorrectionTypeNo;
		_searchField.delegate = self;
		_searchField.returnKeyType = UIReturnKeySearch;
	}
	return _searchField;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)search:(NSString*)text {
	[(UserSearchModel *)self.model search:text];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableDataSource

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
	
    [self.items removeAllObjects];
    [self.sections removeAllObjects];
	
	[self.sections addObject:@"Search for people on Chiive"];
	[self.items addObject:[NSMutableArray arrayWithObject:self.searchField]];
	
	UserModel *userModel = (UserModel *)self.model;
	
	NSMutableArray *userItems = [NSMutableArray array];
	for (User *child in userModel.children)
		[userItems addObject:[CHTableUserItem itemWithUser:child URL:nil]];
	
	if ([userItems count] > 0)
	{
		[self.sections addObject:@""];
		[self.items addObject:userItems];
	}
	else if ([userModel isLoading])
	{
		[self.sections addObject:@""];
		[self.items addObject:[NSMutableArray arrayWithObject:[TTTableActivityItem itemWithText:@"Searching..."]]];
	}
	else if ([userModel isLoaded])
	{
		[self.sections addObject:@""];
		[self.items addObject:[NSMutableArray arrayWithObject:[TTTableSummaryItem
															   itemWithText:@"No matches found!" URL:nil]]];
	}
	// if we haven't loaded yet and no results, the user hasn't yet searched
	else
	{
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self search:textField.text];
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_searchField);
	[super dealloc];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation InviteFriendsSearchViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// InviteFriendsAbstractViewController

- (void)updateDataSource
{
	UserSearchModel *model = [[[UserSearchModel alloc] init] autorelease];
	model.remote = YES;
	model.user = [Global getInstance].currentUser;
	
	UserSearchSectionedDataSource *ds = (UserSearchSectionedDataSource *)[UserSearchSectionedDataSource dataSourceWithObjects:nil];
	ds.model = model;
	self.dataSource = ds;
	
	[self.dataSource tableViewDidLoadModel:self.tableView];
}

@end
