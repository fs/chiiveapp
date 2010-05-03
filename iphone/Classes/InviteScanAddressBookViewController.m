//
//  InviteScanAddressBookViewController.m
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "InviteScanAddressBookViewController.h"
#import "UserModel.h"
#import "CHTableItem.h"
#import "CHTableUserItem.h"
#import "Global.h"
#import "User.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ABUserModel

// since we're looking for remote users, do not load any saved users
- (void)loadSavedFriends
{}

- (TTURLRequest *)childrenRequest
{
	TTURLRequest *request = [super childrenRequest];
	request.httpMethod = @"POST";
	
	NSMutableString *emailsValue = [NSMutableString stringWithString:@""];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
	for (int i = 0; i < nPeople; i++) 
	{
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		
		ABMutableMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
		CFIndex numEmails = ABMultiValueGetCount(emails);
		for (CFIndex j = 0; j < numEmails; j++)
		{
			CFStringRef email = ABMultiValueCopyValueAtIndex(emails, j);
			[emailsValue appendFormat:@"%@,", email];
			CFRelease(email);
		}
		CFRelease(emails);
		CFRelease(ref);
	}
	CFRelease(allPeople);
	
	[request.parameters setObject:@"true" forKey:@"nonfriends"];
	[request.parameters setObject:emailsValue forKey:@"email"];
	
	return request;
}

- (NSString *)childrenURL
{
	return [super.childrenURL stringByReplacingOccurrencesOfString:@".json" withString:@"/find_by_email.json"];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ABUserDataSource
- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
	
    [self.items removeAllObjects];
    [self.sections removeAllObjects];
	
	UIImage *itemImage = [UIImage imageNamed:@"table_image_addfriend_addressbook.png"];
	TTTableImageItem *item = [TTTableImageItem itemWithText:@"Scan Address Book" imageURL:@"" defaultImage:itemImage URL:nil];
	
	[self.sections addObject:@"Scanning address book for people who are using Chiive"];
	[self.items addObject:[NSMutableArray arrayWithObject:item]];
	
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


@implementation InviteScanAddressBookViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// InviteFriendsAbstractViewController

- (void)updateDataSource
{
	ABUserModel *model = [[[ABUserModel alloc] init] autorelease];
	model.user = [Global getInstance].currentUser;
	
	ABUserDataSource *ds = (ABUserDataSource *)[ABUserDataSource dataSourceWithObjects:nil];
	ds.model = model;
	self.dataSource = ds;
}

@end
