//
//  FriendRequestsTableViewController.m
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FriendRequestsTableViewController.h"
#import "UserModel.h"
#import	"User.h"
#import "CHTableUserItem.h"
#import "Group.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation UserRequestsDataSource 
- (void)tableViewDidLoadModel:(UITableView *)tableView
{
	[super tableViewDidLoadModel:tableView];
	
	[self.items removeAllObjects];
	
	UserModel *userModel;
	if ([self.model isKindOfClass:[Group class]])
		userModel = [(Group *)self.model friendModel];
	else
		userModel = (UserModel *)self.model;
	
	for (User *child in userModel.children)
	{
		if (child.isFan && [child.friendshipId intValue] < 1)
			[self.items addObject:[CHTableUserRequestItem itemWithUser:child URL:@"user"]];
	}
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FriendRequestsTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate
{
	// no pull down to refresh
	if (_variableHeightRows) {
		return [[[TTTableViewVarHeightDelegate alloc] initWithController:self] autorelease];
	} else {
		return [[[TTTableViewDelegate alloc] initWithController:self] autorelease];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.tableView.rowHeight = 70.0;
	self.navigationItem.titleView = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	self.title = @"Friend Requests";
}

@end
