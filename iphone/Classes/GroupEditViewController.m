//
//  GroupEditViewController.m
//  chiive
//
//  Created by 17FEET on 12/14/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "GroupEditViewController.h"
#import "ManagedObjectsController.h"
#import "User.h"
#import "Global.h"
#import "Group.h"
#import "GroupModel.h"
#import "Post.h"
#import "PostModel.h"
#import "GroupUser.h"
#import "UploadQueue.h"
#import "GroupPhotosViewController.h"
#import "CLController.h"
#import "CHTableItem.h"
#import "WhoCanJoinViewController.h"


@implementation GroupEditViewController
@synthesize group = _group, tempGroupName = _tempGroupName, groupIsNew = _groupIsNew,
			titleField = _titleField, thumbnailView = _thumbnailView, titleLabel = _titleLabel;

////////////////////////////////////////////////////////////////////////////////////////////////
// Internal

- (BOOL)submitForm
{
	// a title is required
	if (!_titleField.text || [_titleField.text isEmptyOrWhitespace])
	{
		[[[[UIAlertView alloc] initWithTitle:@"El Titulo, Por Favor"
									message:@"This baby needs a name!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] autorelease] show];
		return NO;
	}
	
	// if a change was made, push the group into the upload queue
	if (![_titleField.text isEqualToString:self.group.title] || !self.group.hasSynced)
	{
		self.group.title = _titleField.text;
		self.group.isOutdated = YES;
		
		// if it's a new group
		if (self.groupIsNew)
		{
			// if it's new, it should be a suggested (active) group
			self.group.isSuggestedGroup = YES;
			
			// add to the current user's groups and suggested groups
			GroupModel *gm = [Global getInstance].currentUser.groupModel;
			[gm insertNewChild:self.group];
			[gm.children sortUsingDescriptors:[gm sortDescriptors]];
			
			gm = [Global getInstance].currentUser.suggestedGroupModel;
			[gm insertNewChild:self.group];
			[gm.children sortUsingDescriptors:[gm sortDescriptors]];
			
			// set as the current group
			[Global getInstance].currentGroup = self.group;
		}
		
		[self.group didChange];
		
		[[UploadQueue getInstance] addObjectToQueue:self.group];
		
		// if the first post has not synced, add it, too
		if (self.group.postModel.numberOfChildren > 0 && ![(Post *)[self.group.postModel.children objectAtIndex:0] hasSynced])
			[[UploadQueue getInstance] addObjectToQueue:(Post *)[self.group.postModel.children objectAtIndex:0]];
		
		// load the group
		[self.group load:TTURLRequestCachePolicyNone more:NO];
	}
	return YES;
}

- (void)saveButtonWasPressed
{
	// if the form is good, dismiss the screen
	if ([self submitForm])
		[self dismissModalViewController];
}

- (void)cancelButtonWasPressed
{
	// if the group is new
	if (self.groupIsNew)
	{
		// if no data was entered
		if (!self.titleField.text || [self.titleField.text isEmptyOrWhitespace])
		{
			[self.group destroy];
			self.group = nil;
			[self dismissModalViewController];
		}
		else
		{
			NSString *message;
			if (self.group.numPosts > 0)
				message = @"Are you sure? You will lose this photo!";
			else
				message = @"Are you sure?";
			
			// show an alert
			[[[[UIAlertView alloc] initWithTitle:@"Cancel Group" 
										 message:message 
										delegate:self
							   cancelButtonTitle:@"No" 
							   otherButtonTitles:@"Cancel Group", nil] autorelease] show];
		}
	}
	else
	{
		[self dismissModalViewController];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// delete the group and leave the screen
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		[self.group destroy];
		[self dismissModalViewController];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (void)createGroup
{
	_group = (Group *)[ManagedObjectsController objectWithClass:[Group class]];
	[_group retain];
	
	_group.owner = [Global getInstance].currentUser;
	
	// create the association
	if (!self.group.isCurrentUserGroup)
	{
		[_group.friendModel insertNewChild:[Global getInstance].currentUser];
		[[Global getInstance].currentUser.groupModel insertNewChild:_group];
	}
	
	_group.isSuggestedGroup = YES;
	
	_group.latitude = [NSNumber numberWithDouble:[CLController getInstance].latitude];
	_group.longitude = [NSNumber numberWithDouble:[CLController getInstance].longitude];
	_group.happenedAt = [NSDate date];
	self.groupIsNew = YES;
}

/**
 * Creates the model that the controller manages.
 */
- (Group *)group
{
	if (nil == _group)
	{
		[self createGroup];
	}
	return _group;
}

- (UITextField *)titleField
{
	if (nil == _titleField)
	{
		_titleField = [[UITextField alloc] init];
		_titleField.placeholder = @"Name of Event";
		_titleField.delegate = self;
		_titleField.returnKeyType = UIReturnKeyGo;
		_titleField.delegate = self;
	}
	return _titleField;
}

- (UIBarButtonItem *)createButton
{
	if (!_createButton)
	{
		TTButton *btn = [TTButton buttonWithStyle:@"roundButton:" title:(self.group.hasSynced) ? @"Save" : @"Create"];
		[btn sizeToFit];
		[btn addTarget:self action:@selector(saveButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		btn.enabled = NO;
		_createButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
	}
	return _createButton;
}

- (UIBarButtonItem *)cancelButton
{
	if (!_cancelButton)
	{
		_cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																	   target:self action:@selector(cancelButtonWasPressed)];
	}
	return _cancelButton;
}

- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.font = [UIFont systemFontOfSize:17];
		_titleLabel.textColor = [UIColor darkGrayColor];
		_titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.9];
		_titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		_titleLabel.numberOfLines = 2;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.text = @"Name your event so others can easily add their photos.";
	}
	return _titleLabel;
}

- (TTImageView *)thumbnailView
{
	if (!_thumbnailView)
	{
		_thumbnailView = [[TTImageView alloc] init];
	}
	return _thumbnailView;
}





////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init])
	{
		self.title = @"Create Event";
		
		self.tableViewStyle = UITableViewStyleGrouped;
		self.autoresizesForKeyboard = YES;
		self.variableHeightRows = YES;
		
		self.navigationBarStyle = UIBarStyleBlackOpaque;
		self.navigationBarTintColor = nil;
		self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
	}
	return self;
}



////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.tableView.scrollEnabled = NO;
	self.tableView.sectionHeaderHeight = 5;
	
	NSInteger left = 15;
	NSInteger top = 15;
	NSInteger thumbSize = 55;
	
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)] autorelease];
	
	self.thumbnailView.frame = CGRectMake(left, top, thumbSize, thumbSize);
	left += thumbSize + 15;
	top += 5;
	
	self.titleLabel.frame = CGRectMake(left, top, headerView.frame.size.width - left - 15, thumbSize - 5);
	
	[headerView addSubview:self.thumbnailView];
	[headerView addSubview:self.titleLabel];
	
	self.tableView.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
	// if we need to update
	if (self.group.postModel.numberOfChildren > 0)
	{
		Post *post = (Post *)[self.group.postModel.children objectAtIndex:0];
		self.thumbnailView.urlPath = [post URLForVersion:TTPhotoVersionThumbnail];
		self.thumbnailView.hidden = NO;
		self.titleLabel.frame = CGRectMake(self.thumbnailView.right + 15, self.titleLabel.top, self.titleLabel.width, self.titleLabel.height);
	}
	else
	{
		self.thumbnailView.hidden = YES;
		self.titleLabel.frame = CGRectMake(self.thumbnailView.left, self.titleLabel.top, self.titleLabel.width, self.titleLabel.height);
	}
	
	self.dataSource = [CHSectionedDataSource dataSourceWithObjects:
					   @"",
					   self.titleField,
					   @"",
					   [CHTableRightBlueCaptionItem itemWithText:@"Who can Join" 
														  caption:GroupPrivacyWhoCanJoin_toString[self.group.privacyWhoCanJoin]
															  URL:@"join"],
					   nil
					   ];
	
	[super viewWillAppear:animated];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.createButton;
	
	if (!!self.tempGroupName)
		self.titleField.text = self.tempGroupName;
	
	else if (!!self.group)
		self.titleField.text = self.group.title;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.titleField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.tempGroupName = self.titleField.text;
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_titleField);
	TT_RELEASE_SAFELY(_thumbnailView);
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_createButton);
	TT_RELEASE_SAFELY(_cancelButton);
	TT_RELEASE_SAFELY(_tempGroupName);
	
	[super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (indexPath.section == 1)
	{
		WhoCanJoinViewController *controller = [[[WhoCanJoinViewController alloc] init] autorelease];
		controller.group = self.group;
		[self.navigationController pushViewController:controller animated:YES];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// make sure that we haven't hit the max number of chars
	if (textField.text.length >= 128 && range.length == 0)
		return NO;
	
	TTButton *rightBarButtonItem = (TTButton *)self.navigationItem.rightBarButtonItem.customView;
	rightBarButtonItem.enabled = ![string isEmptyOrWhitespace] ||
								  (range.location > 0 || range.length < [_titleField.text length]);
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self submitForm])
		[self dismissModalViewController];
	
	return NO;
}

@end
