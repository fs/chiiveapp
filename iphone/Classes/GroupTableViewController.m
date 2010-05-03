//
//  GroupTableViewController.m
//  chiive
//
//  Created by 17FEET on 8/26/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "GroupTableViewController.h"
#import "GroupModel.h"
#import "GroupTableUserHeaderView.h"
#import "Group.h"
#import "Post.h"
#import "PostModel.h"
#import "UserModel.h"
#import "Global.h"
#import "GroupUser.h"
#import "UploadQueue.h"
#import "GroupPhotosViewController.h"
#import "GroupEditViewController.h"
#import "ManagedObjectsController.h"
#import "CHTableGroupItem.h"
#import "Friendship.h"
#import "CHTableEmptyView.h"
#import "ManagedObjectsController.h"
#import "CHTutorialView.h"
#import "CHDefaultStyleSheet.h"


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

static NSInteger	kRecentEventsMax = 3;


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupActiveTableHeaderView
- (id)initWithTitle:(NSString*)title {
	if (self = [super initWithTitle:title]) {
		self.backgroundColor = [UIColor clearColor];
		self.style = TTSTYLE(tableActiveHeader);
		
		_label.textColor = TTSTYLEVAR(tableHeaderActiveTextColor);
		_label.shadowColor = nil;
	}
	return self;
}
@end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupTableViewDelegate
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (tableView.style == UITableViewStylePlain && TTSTYLEVAR(tableHeaderTintColor)) {
		if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
			NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
			if (title.length > 0) {
				TTTableHeaderView* header = [_headers objectForKey:title];
				if (nil == header) {
					if (nil == _headers) {
						_headers = [[NSMutableDictionary alloc] init];
					}
					if ([title isEqualToString:@"Active Events"])
						header = [[[GroupActiveTableHeaderView alloc] initWithTitle:title] autorelease];
					else
						header = [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
					[_headers setObject:header forKey:title];
				}
				return header;
			}
		}
	}
	return nil;
}
@end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupDataSource

- (GroupModel *)groupModel
{
	return [(User *)self.model groupModel];
}

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
    
	NSMutableArray *activeEvents = [NSMutableArray array];
	NSMutableArray *recentEvents = [NSMutableArray array];
	NSMutableArray *pastEvents = [NSMutableArray array];
	NSMutableArray *eventsGroup = recentEvents;
	
	[self.sections removeAllObjects];
    [self.items removeAllObjects];
	
	if (0 == [self.groupModel.children count])
	{
		[self.sections addObject:@""];
		[self.items addObject:[NSMutableArray arrayWithObject:self.tutorialView]];
	}
	else
	{
		for (Group *child in self.groupModel.children)
		{
			if ([child isActive])
			{
				[activeEvents addObject:[CHTableGroupItem itemWithGroup:child URL:@"group"]];
			}
			else 
			{
				if (eventsGroup == recentEvents && [eventsGroup count] == kRecentEventsMax)
					eventsGroup = pastEvents;
				
				[eventsGroup addObject:[CHTableGroupItem itemWithGroup:child URL:@"group"]];
			}
		}
		
		if ([activeEvents count] > 0)
		{
			[self.sections addObject:@"Active Events"];
			[self.items addObject:activeEvents];
		}
		
		if ([recentEvents count] > 0)
		{
			[self.sections addObject:@"Recent Events"];
			[self.items addObject:recentEvents];
		}
		
		if ([pastEvents count] > 0)
		{
			[self.sections addObject:@"Past Events"];
			[self.items addObject:pastEvents];
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////
// public

- (CHTutorialView *)tutorialView
{
	if (!_tutorialView)
	{
		_tutorialView = [[CHTutorialView alloc] init];
		
		if (self.groupModel.user != [Global getInstance].currentUser)
		{
			_tutorialView.messageLabel.text = [NSString stringWithFormat:@"%@ has no events yet!", self.groupModel.user.displayName];
			[_tutorialView.actionButton setTitle:@"" forState:UIControlStateNormal];
		}
		else
		{
			_tutorialView.messageLabel.text = @"Welcome to Chiive. Let's get started!";
			[_tutorialView.actionButton setTitle:@"Start an Event" forState:UIControlStateNormal];
		}
		
		UIImage *emptyImage = [UIImage imageNamed:@"tutorial_start_event.png"];
		_tutorialView.backgroundView.frame = CGRectMake(0, 0, emptyImage.size.width, emptyImage.size.height);
		_tutorialView.backgroundView.image = emptyImage;
		
		_tutorialView.frame = CGRectMake(0, 0, 320, 360);
	}
	return _tutorialView;
}

////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_tutorialView);
	[super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupEditableDataSource
@synthesize selectedObject = _selectedObject, tableView = _tableView;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	return [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.tableView = tableView;
	
	TTTableItem *item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if ([item.userInfo isKindOfClass:[Group class]])
	{
		self.selectedObject = item.userInfo;
		[[[[UIAlertView alloc] initWithTitle:@"Delete Event" 
									 message:@"You will lose all of your photos in this event." 
									delegate:self
						   cancelButtonTitle:@"Cancel" 
						   otherButtonTitles:@"Delete", nil] autorelease] show];
	}
}



////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
	{
		// remove from the group
		[self.groupModel removeChild:self.selectedObject];
		
		// delete the remote version
		[self.selectedObject deleteRemote];
		
		// remove the item from the table view
		NSInteger numSections = [self.items count];
		for (NSInteger i=0; i < numSections; i++) {
			NSMutableArray *sectionItems = [self.items objectAtIndex:i];
			NSInteger numItems = [sectionItems count];
			for (NSInteger j=0; j < numItems; j++)
			{
				CHTableGroupItem *item = [sectionItems objectAtIndex:j];
				if (item.userInfo == self.selectedObject)
				{
					// TODO: Delete the whole section if this was the last item
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
					[sectionItems removeObject:item];
					[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					break;
				}
			}
		}
	}
	self.selectedObject = nil;
	self.tableView = nil;
}


////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_selectedObject);
	[super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


@implementation GroupTableViewController

////////////////////////////////////////////////////////////////////////////////////
// public

- (User *)user
{
	if ([self.model isKindOfClass:[User class]])
		return (User *)self.model;
	
	else if ([self.model isKindOfClass:[GroupModel class]])
		return [(GroupModel *)self.model user];
	
	else
		return nil;
	
}

- (GroupModel *)groupModel
{
	if ([self.model isKindOfClass:[User class]])
		return [(User *)self.model groupModel];
	
	else if ([self.model isKindOfClass:[GroupModel class]])
		return (GroupModel *)self.model;
	
	else
		return nil;
	
}

- (TTButton *)newEventButton
{
	if (!_newEventButton)
	{
		_newEventButton = [[TTButton buttonWithStyle:@"roundButton:" title:@"New"] retain];
		[_newEventButton sizeToFit];
		[_newEventButton addTarget:self action:@selector(newEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _newEventButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// RootTableViewController

- (void)showLoaderPreview:(BOOL)show
{
	if (self.user == [Global getInstance].currentUser)
		[super showLoaderPreview:show];
}



////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)newEventButtonWasPressed
{
	GroupEditViewController *viewController = [[[GroupEditViewController alloc] init] autorelease];
	[viewController createGroup];
	
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)friendButtonWasPressed
{
	// create a friendship request
	Friendship *friendship = [[[Friendship alloc] init] autorelease];
	[friendship updateUser:self.user withFriendshipType:_friendshipRequestType];
	
	// add to the upload queue and load
	[[UploadQueue getInstance] addObjectToQueue:friendship];
	[friendship load:TTURLRequestCachePolicyNone more:NO];
	
	// reload the table data
	[self.dataSource tableViewDidLoadModel:self.tableView];
	[self.tableView reloadData];
}

- (void)confirmFriendButtonWasPressed
{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Remove Friend" 
														 message:[NSString stringWithFormat:@"Are you sure you want to remove %@ as a friend?", self.user.displayName]
														delegate:self
											   cancelButtonTitle:@"Cancel" 
											   otherButtonTitles:@"Remove", nil] autorelease];
	[alertView show];
}


////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
		[self friendButtonWasPressed];
}




////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.title = @"Events";
	
	if (self.user != [Global getInstance].currentUser)
	{
		NSInteger headerHeight = self.user.isMutualFriend ? 65 : 65;
		GroupTableUserHeaderView *headerView = [[GroupTableUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerHeight)];
		headerView.user = self.user;
		
		_friendshipRequestType = FRIEND_REQUEST_REMOVE;
		[headerView.friendButton addTarget:self action:@selector(confirmFriendButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		
		self.tableView.tableHeaderView = headerView;
		[headerView release];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.user != [Global getInstance].currentUser && !self.user.isMutualFriend)
		[self showEmpty:YES];
	else
		// refresh on appear to update any changes that may have happened elsewhere
		[self refresh];

}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_newEventButton);
	TT_RELEASE_SAFELY(_tableEmptyView);
	[super viewDidUnload];
}




////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)shouldLoad
{
	if (self.user != [Global getInstance].currentUser && !self.user.isMutualFriend)
		return NO;
	
	// if we've already displayed and the group model does not have a load time
	return _isViewAppearing && !self.groupModel.loadedTime;
}

- (void)setModel:(id<TTModel>)model
{
	[super setModel:model];
	if (self.user == [Global getInstance].currentUser)
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.newEventButton] autorelease];
	else
		self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)canShowModel
{
	if ([self.dataSource isKindOfClass:[TTListDataSource class]])
		return [[(TTListDataSource *)self.dataSource items] count] > 0;
	
	if ([self.dataSource isKindOfClass:[TTSectionedDataSource class]])
		return [[(TTSectionedDataSource *)self.dataSource items] count] > 0;
	
	else
		return [super canShowModel];
}


////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate {
	return [[[GroupTableViewDelegate alloc] initWithController:self] autorelease];
}

- (CGRect)rectForOverlayView {
	if (!self.tableView.tableHeaderView)
		return [super rectForOverlayView];
	else
		return TTRectShift(self.tableView.frame, 0, self.tableView.tableHeaderView.frame.size.height);
}

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource
{
	if (dataSource != _dataSource && [dataSource isKindOfClass:[GroupDataSource class]])
	{
		GroupDataSource *ds = (GroupDataSource *)dataSource;
		
		// remove a previously set target
		[ds.tutorialView.actionButton removeTarget:self action:@selector(newEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		
		// add the target
		[ds.tutorialView.actionButton addTarget:self action:@selector(newEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	[super setDataSource:dataSource];
}


- (void)showModel:(BOOL)show
{
	if (show && 
		self.user == [Global getInstance].currentUser && 
		!self.groupModel.isSuggestedList &&
		self.groupModel.numberOfChildren > 0 &&
		[self.navigationController.viewControllers count] < 3)
	{
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	}
	else if (self.navigationItem.leftBarButtonItem == self.editButtonItem)
	{
		self.navigationItem.leftBarButtonItem = nil;
	}
	
	[super showModel:show];
}

- (void)showEmpty:(BOOL)show
{
	if (show && self.user != [Global getInstance].currentUser && !self.user.isMutualFriend)
	{
		NSInteger padding = 20;
		
		TTButton *friendButton;
		UILabel *friendStatusLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		friendStatusLabel.font = [UIFont systemFontOfSize:17];
		friendStatusLabel.textColor = [UIColor blackColor];
//		friendStatusLabel.shadowColor = [UIColor whiteColor];
		friendStatusLabel.lineBreakMode = UILineBreakModeWordWrap;
		friendStatusLabel.numberOfLines = 0;
		friendStatusLabel.textAlignment = UITextAlignmentCenter;
		friendStatusLabel.backgroundColor = [UIColor clearColor];
		
		if (self.user.isFan)
		{
			_friendshipRequestType = FRIEND_REQUEST_ACCEPT;
			friendStatusLabel.text = [NSString stringWithFormat:@"%@ has invited you to be a friend", self.user.displayName];
			friendButton = [TTButton buttonWithStyle:@"largeRoundButton:" title:@"Accept Friend Request"];
		}
		else if (self.user.isFriend)
		{
			_friendshipRequestType = FRIEND_REQUEST_REMOVE;
			friendStatusLabel.text = [NSString stringWithFormat:@"You have invited %@ to be a friend", self.user.displayName];
			friendButton = [TTButton buttonWithStyle:@"largeRoundCancelButton:" title:@"Remove Friend Request"];
		}
		else
		{
			_friendshipRequestType = FRIEND_REQUEST_ADD;
			friendStatusLabel.text = [NSString stringWithFormat:@"Would you like to become friends with %@?", self.user.displayName];
			friendButton = [TTButton buttonWithStyle:@"largeRoundButton:" title:@"Add as Friend"];
		}
		
		CGSize maxSize = CGSizeMake(self.view.width - padding * 2, 300);
		CGSize statusSize = [friendStatusLabel.text sizeWithFont:friendStatusLabel.font constrainedToSize:maxSize lineBreakMode:friendStatusLabel.lineBreakMode];
		friendStatusLabel.frame = CGRectMake(padding, padding * 2, self.view.width - padding * 2, statusSize.height);
		
		[friendButton sizeToFit];
		[friendButton addTarget:self action:@selector(friendButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		friendButton.frame = CGRectMake(round((self.view.width - friendButton.width) *0.5), friendStatusLabel.bottom + padding, friendButton.width, friendButton.height);
		
		UIView *emptyView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.tableView.tableHeaderView.height)] autorelease];
		emptyView.backgroundColor = [UIColor groupTableViewBackgroundColor]; //[UIColor whiteColor];
		[emptyView addSubview:friendStatusLabel];
		[emptyView addSubview:friendButton];
		
		self.emptyView = emptyView;
		
		_tableView.dataSource = nil;
		[_tableView reloadData];
	}
	else
	{
		self.emptyView = nil;
		self.tableView.separatorColor = TTSTYLEVAR(tableSeparatorColor);
	}
}

- (void)showLoading:(BOOL)show
{
	// never show a "Loading" screen. This is handled by the drag-to-refresh header.
	if (show && [self canShowModel])
	{
		self.tableView.separatorColor = TTSTYLEVAR(tableSeparatorColor);
		self.loadingView = nil;
		[self showModel:YES];
	}
	else if (show && self.user == [Global getInstance].currentUser)
	{
		self.tableView.separatorColor = [UIColor clearColor];
//		self.loadingView = self.emptyView;
	}
	else
	{
		self.tableView.separatorColor = TTSTYLEVAR(tableSeparatorColor);
		self.loadingView = nil;
	}
}

- (void)didSelectAccessoryButtonForObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	if ([object isKindOfClass:[CHTableGroupItem class]])
	{
		// grab the row's group
		CHTableGroupItem *item = (CHTableGroupItem *)object;
		Group *group = (Group *)item.userInfo;
		
		// if this is a join event
		if (!group.isCurrentUserGroup)
			[Global getInstance].currentGroup = group;
		
		[self didSelectObject:object atIndexPath:indexPath];
	}
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	if ([object isKindOfClass:[CHTableGroupItem class]])
	{
		// grab the row's group
		CHTableGroupItem *item = (CHTableGroupItem *)object;
		Group *group = (Group *)item.userInfo;
		
		GroupPhotosViewController *viewController = [[[GroupPhotosViewController alloc] init] autorelease];
		viewController.photoSource = group;
		
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else
	{
		[super didSelectObject:object atIndexPath:indexPath];
	}
}

@end
