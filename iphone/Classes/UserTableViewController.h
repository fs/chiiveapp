//
//  UserTableViewController.h
//  chiive
//
//  Created by 17FEET on 9/21/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableItem.h"
#import "RootTableViewController.h"

@class UserModel;

@interface UserListDataSource : CHListDataSource
@end

@interface UserTableViewController : RootTableViewController
@property (nonatomic, readonly)	UserModel	*userModel;
@end
