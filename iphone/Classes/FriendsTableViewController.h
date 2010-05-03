//
//  FriendsTableViewController.h
//  chiive
//
//  Created by 17FEET on 2/18/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserTableViewController.h"
#import "FriendsSearchTableViewController.h"
#import "CHTableViewDragRefreshDelegate.h"
#import "CHTableItem.h"

@class User;
@class UserModel;
@class FriendsTableHeaderView;
@class CHTableEmptyView;


///////////////////////////////////////////////////////////////////////////////////////////////////


@interface UserFriendsDataSource : CHListDataSource <UIAlertViewDelegate>
{
	UITableView			*_tableView;
	User				*_selectedObject;
}
@property (nonatomic, readonly)	UserModel	*userModel;
@property (nonatomic, retain)	User		*selectedObject;
@property (nonatomic, assign)	UITableView	*tableView;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////


@interface FriendsTableViewDragRefreshDelegate : CHTableViewDragRefreshDelegate
@end


///////////////////////////////////////////////////////////////////////////////////////////////////


@interface FriendsTableViewController : UserTableViewController {
	UserSearchModel				*_searchModel;	
	FriendsTableHeaderView		*_friendsHeaderView;
	CHTableEmptyView			*_tableEmptyView;
	UIBarButtonItem				*_addFriendsBarButtonItem;
}
@property (nonatomic, readonly)	FriendsTableHeaderView		*friendsHeaderView;
@property (nonatomic, readonly)	CHTableEmptyView			*tableEmptyView;
@property (nonatomic, readonly)	UIBarButtonItem				*addFriendsBarButtonItem;
@end
