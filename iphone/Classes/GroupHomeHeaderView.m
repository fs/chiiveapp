//
//  GroupHomeHeaderView.m
//  chiive
//
//  Created by 17FEET on 2/17/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupHomeHeaderView.h"
#import "Global.h"
#import "Group.h"
#import "GroupUser.h"
#import "GroupModel.h"
#import "PostModel.h"
#import "User.h"
#import "UserModel.h"
#import "UploadQueue.h"
#import "ManagedObjectsController.h"
#import "GroupPeopleViewController.h"
#import "GroupPhotosViewController.h"
#import "UserTableViewController.h"


@implementation GroupHomeHeaderView
@synthesize photosButton = _photosButton, peopleButton = _peopleButton, headerView = _headerView,
			controller = _controller, group = _group, paddingBottom = _paddingBottom;



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateGroupData
{
	self.titleLabel.text = self.group.prettyTitle;
	
	if (self.group.numberOfPhotos > 1)
		[self.photosButton setTitle:[NSString stringWithFormat:@"%d Photos", self.group.numberOfPhotos] forState:UIControlStateNormal];
	else
		[self.photosButton setTitle:@"Photos" forState:UIControlStateNormal];
	
	if (self.group.friendModel.numberOfChildren > 1)
		[self.peopleButton setTitle:[NSString stringWithFormat:@"%d People", self.group.friendModel.numberOfChildren] forState:UIControlStateNormal];
	else
		[self.peopleButton setTitle:@"People" forState:UIControlStateNormal];
	
	self.joinEventView.hidden = !(self.group.isSuggestedGroup && !self.group.isCurrentUserGroup);
	
	[self setNeedsLayout];
}

- (void)photosButtonWasPressed
{
	// Create the photos view
	GroupPhotosViewController *viewController = [[[GroupPhotosViewController alloc] init] autorelease];
	viewController.photoSource = self.group;
	
	// replace the this view controller with the people view controller
	NSMutableArray *viewControllers = [[self.controller.navigationController.viewControllers mutableCopy] autorelease];
	[viewControllers removeLastObject];
	[viewControllers addObject:viewController];
	self.controller.navigationController.viewControllers = viewControllers;
}

- (void)peopleButtonWasPressed
{
	// Push the thumbs view controller for this group into the stack
	GroupPeopleViewController *viewController = [[[GroupPeopleViewController alloc] init] autorelease];
	
	// manually set the cache key and loaded time so that the model does not try to load remotely
	self.group.friendModel.loadedTime = [NSDate date];
	
	GroupPeopleListDataSource *dataSource = [[[GroupPeopleListDataSource alloc] init] autorelease];
	dataSource.model = self.group;
	viewController.dataSource = dataSource;
	
	// replace the this view controller with the people view controller
	NSMutableArray *viewControllers = [[self.controller.navigationController.viewControllers mutableCopy] autorelease];
	[viewControllers removeLastObject];
	[viewControllers addObject:viewController];
	self.controller.navigationController.viewControllers = viewControllers;
}

- (void)joinEventButtonWasPressed
{
	self.group.isOutdated = YES;
	
	// create the association
	if (!self.group.isCurrentUserGroup)
	{
		// insert the user into the group's attendees
		UserModel *fm = _group.friendModel;
		[fm insertNewChild:[Global getInstance].currentUser];
		[fm.children sortUsingDescriptors:[fm sortDescriptors]];
		
		// insert the group into the user's group list
		GroupModel *gm = [Global getInstance].currentUser.groupModel;
		[gm insertNewChild:_group];
		[gm.children sortUsingDescriptors:[gm sortDescriptors]];
		
		// save the changes
		[[ManagedObjectsController getInstance] saveChanges];
	}
	[self.group didChange];
	
	// add to the queue and start the remote save
	[[UploadQueue getInstance] addObjectToQueue:self.group];
	[self.group load:TTURLRequestCachePolicyNone more:NO];
}

- (UIButton *)tabButton
{
	UIImage *buttonBgActive = [UIImage imageNamed:@"tab_group_home_active.png"];
	UIImage *buttonBgInactive = [UIImage imageNamed:@"tab_group_home_inactive.png"];
	
	UIButton *btn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonBgActive.size.width, buttonBgActive.size.height)] autorelease];
	btn.titleEdgeInsets = UIEdgeInsetsMake(8, 0, 0, 0);
	btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	
	[btn setBackgroundImage:buttonBgActive forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	
	[btn setBackgroundImage:buttonBgInactive forState:UIControlStateDisabled];
	[btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
	
	return btn;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setGroup:(Group *)group
{
	if (group != _group)
	{
		[[_group delegates] removeObject:self];
		[group retain];
		[_group release];
		
		_group = group;
		[[_group delegates] addObject:self];
		
		[self updateGroupData];
	}
}

- (UIView *)headerView
{
	if (!_headerView)
	{
		_headerView = [[UIView alloc] initWithFrame:CGRectZero];
		_headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_header_group_home_title.png"]];
		[self addSubview:_headerView];
	}
	return _headerView;
}

- (UIButton *)photosButton
{
	if (!_photosButton)
	{
		_photosButton = [[self tabButton] retain];
		[_photosButton addTarget:self action:@selector(photosButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _photosButton;
}

- (UIButton *)peopleButton
{
	if (!_peopleButton)
	{
		_peopleButton = [[self tabButton] retain];
		[_peopleButton addTarget:self action:@selector(peopleButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _peopleButton;
}

- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.font = [UIFont boldSystemFontOfSize:18];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		_titleLabel.numberOfLines = 0;
	}
	return _titleLabel;
}

- (UIView *)joinEventView
{
	if (!_joinEventView)
	{
		_joinEventView = [[UIView alloc] initWithFrame:CGRectZero];
		_joinEventView.backgroundColor = [UIColor blackColor];
		[self addSubview:_joinEventView];
	}
	return _joinEventView;
}

- (UILabel *)joinEventLabel
{
	if (!_joinEventLabel)
	{
		_joinEventLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_joinEventLabel.font = [UIFont boldSystemFontOfSize:14];
		_joinEventLabel.textColor = [UIColor whiteColor];
		_joinEventLabel.backgroundColor = [UIColor clearColor];
		_joinEventLabel.textAlignment = UITextAlignmentLeft;
		_joinEventLabel.lineBreakMode = UILineBreakModeWordWrap;
		_joinEventLabel.numberOfLines = 2;
		_joinEventLabel.text = @"Add your own photos to this event!";
	}
	return _joinEventLabel;
}

- (TTButton *)joinEventButton
{
	if (!_joinEventButton)
	{
		_joinEventButton = [[TTButton buttonWithStyle:@"smallRoundButton:" title:@"Join"] retain];
		[_joinEventButton sizeToFit];
		[_joinEventButton addTarget:self action:@selector(joinEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _joinEventButton;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
		
		[self.headerView addSubview:self.titleLabel];
		[self.headerView addSubview:self.photosButton];
		[self.headerView addSubview:self.peopleButton];
		
		[self.joinEventView addSubview:self.joinEventLabel];
		[self.joinEventView addSubview:self.joinEventButton];
		self.joinEventView.hidden = YES;
	}
	return self;
}

- (void)layoutSubviews
{
	NSInteger padding = 6;
	
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font 
						constrainedToSize:CGSizeMake(self.width, 100) lineBreakMode:self.titleLabel.lineBreakMode];
	self.titleLabel.frame = CGRectMake(padding, padding * 2, self.width - padding * 2, titleSize.height);
	NSInteger top = padding * 3 + self.titleLabel.height;
	
	self.photosButton.frame = CGRectMake(-5, top, self.photosButton.width, self.photosButton.height);
	self.peopleButton.frame = CGRectMake(5 + self.width - self.peopleButton.width, top, self.peopleButton.width, self.peopleButton.height);
	
	if (!self.joinEventView.hidden)
	{
		NSInteger joinPadding = 10;
		self.joinEventLabel.frame = CGRectMake(joinPadding, joinPadding, self.width - self.joinEventButton.width - joinPadding * 2, 40);
		self.joinEventButton.frame = CGRectMake(self.width - joinPadding - self.joinEventButton.width, 
												joinPadding, 
												self.joinEventButton.width, 
												self.joinEventButton.height);
		self.joinEventView.frame = CGRectMake(0, 0, self.width, self.joinEventLabel.height + joinPadding * 2);
		self.headerView.frame = CGRectMake(0, self.joinEventView.height, self.width, self.photosButton.bottom);
	}
	else
	{
		self.headerView.frame = CGRectMake(0, 0, self.width, self.photosButton.bottom);
	}
	
	[super layoutSubviews];
	
	float frameHeight = self.headerView.height;
	if (!self.joinEventView.hidden)
		frameHeight += self.joinEventView.height;
	
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
							self.width, frameHeight + 4);
	
	// reassign to as the table header view so that the table resizes accordingly
	if (self.controller)
	{
		self.controller.tableView.tableHeaderView = nil;
		self.controller.tableView.tableHeaderView = self;
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidFinishLoad:(id<TTModel>)model {
	[self updateGroupData];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self updateGroupData];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self updateGroupData];
}

- (void)modelDidChange:(id<TTModel>)model {
	[self updateGroupData];
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	[[_group delegates] removeObject:self];
	
	TT_RELEASE_SAFELY(_controller);
	TT_RELEASE_SAFELY(_group);
	
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_photosButton);
	TT_RELEASE_SAFELY(_peopleButton);
	
	TT_RELEASE_SAFELY(_joinEventView);
	TT_RELEASE_SAFELY(_joinEventLabel);
	TT_RELEASE_SAFELY(_joinEventButton);
	
	[super dealloc];
}

@end
