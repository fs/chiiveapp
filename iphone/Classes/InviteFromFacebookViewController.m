//
//  InviteFromFacebookViewController.m
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "InviteFromFacebookViewController.h"
#import "FBConnect/FBConnect.h"
#import "Global.h"
#import "CHTableItem.h"
#import "User.h"
#import "UserModel.h"
#import "CHTableUserItem.h"
#import "JSON.h"
#import "FBLoginTableItemView.h"
#import "UserTableViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FacebookUserModel

// since we're looking for remote facebook friends, do not load any saved users
- (void)loadSavedFriends
{}

- (NSString *)childrenURL
{
	return [NSMutableString stringWithFormat:@"%@users/%@/friends.json?facebook=yes&nonfriends=yes",
			[Global getInstance].sitePath,
			self.user.UUID
			];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FacebookUserDataSource
- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
	
    [self.items removeAllObjects];
    [self.sections removeAllObjects];
	
	[self.sections addObject:@""];
	
	UIImage *fbImage = [UIImage imageNamed:@"table_image_addfriend_facebook.png"];
	TTTableImageItem *fbItem = [TTTableImageItem itemWithText:@"Finding Facebook Friends" imageURL:@"" defaultImage:fbImage URL:nil];
	[self.items addObject:[NSMutableArray arrayWithObject:fbItem]];
	
	UserModel *userModel = (UserModel *)self.model;
	
	NSMutableArray *userItems = [NSMutableArray array];
	for (User *child in userModel.children)
		[userItems addObject:[CHTableUserItem itemWithUser:child URL:nil]];
	
	if ([userItems count] > 0)
	{
		[self.sections addObject:@""];
		[self.items addObject:userItems];
	}
	else if ([userModel isLoading])
	{
		[self.sections addObject:@""];
		[self.items addObject:[NSMutableArray arrayWithObject:[TTTableActivityItem itemWithText:@"Searching..."]]];
	}
	else
	{
		[self.sections addObject:@""];
		[self.items addObject:[NSMutableArray arrayWithObject:[TTTableSummaryItem
															   itemWithText:@"No matches found!" URL:nil]]];
	}
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation InviteFromFacebookViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// InviteFriendsAbstractViewController

- (void)updateDataSource
{
	NSNumber *fbUid = [Global getInstance].currentUser.facebookUid;
	if (!fbUid || [fbUid intValue] == 0)
	{
		FBLoginTableItemView *fbView = [[[FBLoginTableItemView alloc] init] autorelease];
		fbView.loginButton.session = _session;
		
		self.dataSource = [CHSectionedDataSource dataSourceWithObjects:
						   @"",
						   fbView,
						   nil
						   ];
	}
	else
	{
		FacebookUserModel *model = [[[FacebookUserModel alloc] init] autorelease];
		model.user = [Global getInstance].currentUser;
		
		FacebookUserDataSource *ds = (FacebookUserDataSource *)[FacebookUserDataSource dataSourceWithObjects:nil];
		ds.model = model;
		self.dataSource = ds;
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	_session = [[FBSession sessionForApplication:[Global getInstance].fbconnectApiKey
								 getSessionProxy:[Global getInstance].fbconnectSessionProxy
										delegate:self] retain];
	[super loadView];
}

- (void)viewDidUnload
{
	[_session.delegates removeObject:self];
	TT_RELEASE_SAFELY(_session);
	
	[super viewDidUnload];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

- (void)session:(FBSession *)session didLogin:(FBUID)uid
{
	NSString *userData = session.metaData;
	NSDictionary *json = [userData JSONValue];
	if (!userData || [userData isEmptyOrWhitespace] || [userData isEqualToString:@"null"] || ![json isKindOfClass:[NSDictionary class]])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
									 message:@"There was a problem connecting to your account."
									delegate:nil
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		// Parse the JSON data that we retrieved from the server.
		NSDictionary *json = [session.metaData JSONValue];
		NSDictionary *results = [json objectForKey:@"user"];
		
		[[Global getInstance].currentUser updateWithProperties:results];
		
		if (!![Global getInstance].currentUser.facebookUid && [[Global getInstance].currentUser.facebookUid intValue] != 0)
		{
			[self updateDataSource];
		}
		else
		{
			[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
										 message:@"There was a problem connecting to your account."
										delegate:nil
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil] autorelease] show];
		}
	}
	
	// we don't need a local session, so log out
	[_session logout];
}

@end
