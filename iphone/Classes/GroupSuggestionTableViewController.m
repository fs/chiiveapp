//
//  GroupSuggestionTableViewController.m
//  spyglass
//
//  Created by 17FEET on 4/2/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupSuggestionTableViewController.h"
#import "Group.h"
#import "GroupModel.h"
#import "CHTableGroupItem.h"
#import "CLController.h"
#import "User.h"
#import "UserModel.h"
#import "CHTutorialView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GroupSuggestionDataSource

////////////////////////////////////////////////////////////////////////////////////
// public

- (GroupModel *)groupModel
{
	return (GroupModel *)self.model;
}

////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)setDefaultItems
{
	[self.sections removeAllObjects];
	[self.items removeAllObjects];
	
	// if we haven't yet checked with the server
	if ([self.groupModel isLoading])
	{
		[self.sections addObject:@"Events Nearby"];
		
		self.tutorialView.messageLabel.text = @"Searching for nearby events...";
		[self.tutorialView.actionButton setTitle:@"" forState:UIControlStateNormal];
		[self.tutorialView setNeedsLayout];
		
		[self.items addObject:[NSArray arrayWithObject:self.tutorialView]];
	}
	else
	{
		[self.sections addObject:@"Events Nearby"];
		
		self.tutorialView.messageLabel.text = @"We couldn't find any nearby events.";
		[self.tutorialView.actionButton setTitle:@"Start a New Event" forState:UIControlStateNormal];
		[self.tutorialView setNeedsLayout];
		
		[self.items addObject:[NSArray arrayWithObject:self.tutorialView]];
	}
}

////////////////////////////////////////////////////////////////////////////////////
// TTSectionedDataSource

- (id)initWithItems:(NSArray*)items sections:(NSArray*)sections {
	if (self = [super initWithItems:items sections:sections])
	{
		// if there were no items, insert the default
		if ([items count] == 0 && [sections count] == 0)
			[self setDefaultItems];
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
    
	if (self.groupModel.numberOfChildren == 0)
	{
		[self setDefaultItems];
		return;
	}
	
    [self.items removeAllObjects];
    [self.sections removeAllObjects];
	
	NSMutableArray *activeItems = [NSMutableArray array];
	NSMutableArray *friendItems = [NSMutableArray array];
	NSMutableArray *publicItems = [NSMutableArray array];
	
	
    for (Group *child in self.groupModel.children)
	{
		CHTableGroupItem *item = [CHTableGroupItem itemWithGroup:child URL:@"event"];
		
		if (child.isCurrentUserGroup)
			[activeItems addObject:item];
		
		else
		{
			BOOL isFriendEvent = NO;
			for (User *user in child.friendModel.children) {
				if (user.isMutualFriend)
				{
					isFriendEvent = YES;
					break;
				}
			}
			
			if (isFriendEvent)
				[friendItems addObject:item];
			else
				[publicItems addObject:item];
		}
	}
	
	if ([activeItems count] > 0)
	{
		[self.sections addObject:@"Active Events"];
		[self.items addObject:activeItems];
	}
	
	if ([friendItems count] > 0)
	{
		[self.sections addObject:@"Friends' Events"];
		[self.items addObject:friendItems];
	}
	
	if ([publicItems count] > 0)
	{
		[self.sections addObject:@"Public Events"];
		[self.items addObject:publicItems];
	}
}

////////////////////////////////////////////////////////////////////////////////////
// public

- (CHTutorialView *)tutorialView
{
	if (!_tutorialView)
	{
		_tutorialView = [[CHTutorialView alloc] init];
		UIImage *emptyImage = [UIImage imageNamed:@"tutorial_start_event.png"];
		_tutorialView.backgroundView.frame = CGRectMake(0, 0, emptyImage.size.width, emptyImage.size.height);
		_tutorialView.backgroundView.image = emptyImage;
		
		_tutorialView.frame = CGRectMake(0, 0, 320, 340);
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


@implementation GroupSuggestionTableViewController


////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource
{
	if (dataSource != _dataSource && [dataSource isKindOfClass:[GroupSuggestionDataSource class]])
	{
		GroupSuggestionDataSource *ds = (GroupSuggestionDataSource *)dataSource;
		
		// remove a previously set target
		[ds.tutorialView.actionButton removeTarget:self action:@selector(newEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		
		// add the target
		[ds.tutorialView.actionButton addTarget:self action:@selector(newEventButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	[super setDataSource:dataSource];
}

@end
