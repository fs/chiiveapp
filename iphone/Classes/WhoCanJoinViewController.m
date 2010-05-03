//
//  WhoCanJoinViewController.m
//  chiive
//
//  Created by 17FEET on 1/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "WhoCanJoinViewController.h"
#import "CHTableItem.h"
#import "Group.h"

@implementation WhoCanJoinViewController
@synthesize group = _group;

////////////////////////////////////////////////////////////////////////////////////////////////
// Internal

- (id)init
{
	if (self = [super init])
	{
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.title = @"Who can Join";
}

- (void)viewWillAppear:(BOOL)animated
{
	CHTableTextItem *everyone = [CHTableTextItem 
								 itemWithText:GroupPrivacyWhoCanJoin_toString[GroupPrivacyWhoCanJoinAll]];
	everyone.checked = (GroupPrivacyWhoCanJoinAll == self.group.privacyWhoCanJoin);
	
	CHTableTextItem *friends = [CHTableTextItem 
								itemWithText:GroupPrivacyWhoCanJoin_toString[GroupPrivacyWhoCanJoinFriends]];
	friends.checked = (GroupPrivacyWhoCanJoinFriends == self.group.privacyWhoCanJoin);
	
	self.dataSource = [CHListDataSource dataSourceWithObjects:
					   everyone,
					   friends,
					   nil];
	
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
	TT_RELEASE_SAFELY(_group);
	[super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath 
{
	CHListDataSource *ds = (CHListDataSource *)self.dataSource;
	for (CHTableTextItem *item in ds.items) {
		item.checked = item == (CHTableTextItem *)object;
	}
	
	if (0 == indexPath.row)
		self.group.privacyWhoCanJoin = GroupPrivacyWhoCanJoinAll;
	else if (1 == indexPath.row)
		self.group.privacyWhoCanJoin = GroupPrivacyWhoCanJoinFriends;
	
	[self.tableView reloadData];
	
	[super didSelectObject:object atIndexPath:indexPath];
}

@end

