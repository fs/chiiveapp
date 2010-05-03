//
//  FriendsSearchTableViewController.m
//  spyglass
//
//  Created by 17FEET on 4/6/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FriendsSearchTableViewController.h"
#import "CHTableUserItem.h"
#import "User.h"
#import "Friendship.h"
#import "UploadQueue.h"
#import "UserSearchModel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



@implementation UserSearchListDataSource
- (void)search:(NSString*)text {
	[(UserSearchModel *)self.model search:text];
}
@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



@interface FriendsSearchTableViewController (TTModelViewControllerMethods)
- (void)resetViewStates;
@end

@implementation FriendsSearchTableViewController
@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	[self.delegate didSelectObject:object atIndexPath:indexPath];
}

- (void)didSelectAccessoryButtonForObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	CHTableUserItem *item = object;
	User *friend = item.userInfo;
	
	// create a friendship request
	Friendship *friendship = [[[Friendship alloc] init] autorelease];
	[friendship updateUser:friend withFriendshipType:item.accessoryURL];
	
	// add to the upload queue and load
	[[UploadQueue getInstance] addObjectToQueue:friendship];
	[friendship load:TTURLRequestCachePolicyNone more:NO];
	
	// reload the table data
	[self.dataSource tableViewDidLoadModel:self.tableView];
	[self.tableView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	UserSearchModel *searchModel = (UserSearchModel *)self.dataSource.model;
	searchModel.remote = selectedScope;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

/**
 * Since we use the same model for all types searches, don't invalidate.
 */
- (void)invalidateModel
{
	[self resetViewStates];
}
@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

