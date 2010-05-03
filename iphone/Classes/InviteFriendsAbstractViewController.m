//
//  InviteFriendsAbstractViewController.m
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "InviteFriendsAbstractViewController.h"
#import "CHTableUserItem.h"
#import "Friendship.h"
#import "UploadQueue.h"
#import "User.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kInviteCellPadding = 5;

@implementation InviteFriendsTableItemCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	// add height to account for the extra padding added in layoutSubviews
	return [super tableView:tableView rowHeightForObject:object] + kInviteCellPadding * 2;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
	// shift things over so they fit within the rounded corners of the grouped table cell
	CGFloat height = self.contentView.height;
	if (_imageView2) {
		_imageView2.frame = CGRectMake(kInviteCellPadding, kInviteCellPadding, height - kInviteCellPadding * 2, height - kInviteCellPadding * 2);
	}
	
	if (!CGRectEqualToRect(self.textLabel.frame, CGRectZero))
		self.textLabel.frame = TTRectContract(self.textLabel.frame, kInviteCellPadding, 0);
	
	if (!CGRectEqualToRect(self.detailTextLabel.frame, CGRectZero))
		self.detailTextLabel.frame = TTRectContract(self.detailTextLabel.frame, kInviteCellPadding, 0);
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation InviteFriendsDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
{
	if ([object isKindOfClass:[CHTableUserItem class]])
		return [InviteFriendsTableItemCell class];
	else
		return [super tableView:tableView cellClassForObject:object];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation InviteFriendsAbstractViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)updateDataSource
{}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	self.tableViewStyle = UITableViewStyleGrouped;
	[super loadView];
	self.title = @"Find Friends";
	[self updateDataSource];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)showLoading:(BOOL)show
{
	if (show)
	{
		// show the model
		[self showModel:YES];
		
		// load in the temporary data
		[self.dataSource tableViewDidLoadModel:self.tableView];
		[self.tableView reloadData];
	}
}

- (void)showEmpty:(BOOL)show
{
	if (show)
	{
		// show the model
		[self showModel:YES];
		
		// load in the temporary data
		[self.dataSource tableViewDidLoadModel:self.tableView];
		[self.tableView reloadData];
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

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



@end
