//
//  FriendsSearchTableViewController.h
//  spyglass
//
//  Created by 17FEET on 4/6/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserTableViewController.h"

@class UserSearchModel;


///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UserSearchListDataSource : UserListDataSource
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface FriendsSearchTableViewController : TTTableViewController <UISearchBarDelegate> {
	TTTableViewController		*_delegate;
}
@property (nonatomic, retain)	TTTableViewController	*delegate;
@end
