//
//  PostInfoViewController.m
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "PostInfoViewController.h"
#import "Post.h"
#import "PostModel.h"
#import "Group.h"
#import "Global.h"
#import "UploadQueue.h"
#import "PostInfoView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static uint kInfoViewHeight = 120;

static NSString *kButtonDelete = @"Delete";
static NSString *kButtonShare = @"Share";
static NSString *kButtonEdit = @"Edit Caption";

///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation PostInfoViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)doneButtonWasPressed
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)authorButtonWasPressed
{
}

- (void)actionButtonWasPressed
{
	if ([self post].user == [Global getInstance].currentUser)
	{
		[[[[UIActionSheet alloc] initWithTitle:nil
									  delegate:self
							 cancelButtonTitle:@"Cancel"
						destructiveButtonTitle:kButtonDelete
							 otherButtonTitles:kButtonEdit, kButtonShare, nil] 
		  autorelease] showInView:self.view];
	}
	else
	{
		[[[[UIActionSheet alloc] initWithTitle:nil
									  delegate:self
							 cancelButtonTitle:@"Cancel"
						destructiveButtonTitle:nil
							 otherButtonTitles:kButtonShare, nil]
		  autorelease] showInView:self.view];
	}
}

- (void)editButtonWasPressed
{
	NSArray *keys = [NSArray arrayWithObjects:@"delegate", @"text", @"title", nil];
	NSArray *objects = [NSArray arrayWithObjects:self, self.post.caption, @"Edit Photo Caption", nil];
	NSDictionary *query = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL:nil query:query] autorelease];
	controller.delegate = self;
	
	[controller showInView:self.view animated:YES];
}

- (void)deleteButtonWasPressed
{
	// if this is the only post in the group
	if ([self.post.group.postModel.children count] > 1)
	{
		[[[[UIAlertView alloc] initWithTitle:@"Delete Photo" 
									 message:@"Are you sure you want to delete this photo?" 
									delegate:self
						   cancelButtonTitle:@"Cancel"
						   otherButtonTitles:@"Delete", nil] autorelease] show];
	}
	else
	{
		[[[[UIAlertView alloc] initWithTitle:@"Cannot Delete Photo" 
									 message:@"You can't delete the last photo in an event!" 
									delegate:nil
						   cancelButtonTitle:@"OK"
						   otherButtonTitles:nil] autorelease] show];
	}
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Shared photo from Chiive"];
	
	// Attach an image to the email
	NSData *myData = [[TTURLCache sharedCache] dataForURL:[self.post URLForVersion:TTPhotoVersionLarge]];
	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"chiive_photo"];
	
	// Fill out the email body text
	NSString *emailBody = @"Check out this photo from Chiive!\n\nChiive is an app that let's everyone share photos when they're out together.\n\nCheck it out at chiive.com.\n\nOr download it on Tunes.\nhttp://itunes.apple.com/us/app/chiive/id362351244?mt=8";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)displayCaptionEditController
{
	NSArray *keys = [NSArray arrayWithObjects:@"delegate", @"text", @"title", nil];
	NSArray *objects = [NSArray arrayWithObjects:self, self.post.caption, @"Edit Photo Caption", nil];
	NSDictionary *query = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL:nil query:query] autorelease];
	controller.delegate = self;
	
	[controller showInView:self.view animated:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (PostInfoView *)postInfoView
{
	if (nil == _postInfoView)
	{
		CGRect infoViewFrame = CGRectMake(0, TT_ROW_HEIGHT, self.view.width, kInfoViewHeight);
		_postInfoView = [[PostInfoView alloc] initWithFrame:infoViewFrame];
		[_postInfoView.authorButton addTarget:self
		 action:@selector(authorButtonWasPressed)
		 forControlEvents:UIControlEventTouchUpInside];
		
		[_postInfoView.editButton addTarget:self 
		 action:@selector(editButtonWasPressed) 
		 forControlEvents:UIControlEventTouchUpInside];
		
		[_postInfoView.deleteButton addTarget:self 
		 action:@selector(deleteButtonWasPressed) 
		 forControlEvents:UIControlEventTouchUpInside];
	}
	return _postInfoView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
	[super loadView];
	self.title = @"Details";
	self.view.backgroundColor = [UIColor whiteColor];
	self.tableView.tableHeaderView = self.postInfoView;
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																						   target:self 
																						   action:@selector(actionButtonWasPressed)] autorelease];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self 
																						   action:@selector(doneButtonWasPressed)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.postInfoView.post = self.post;
}

- (void)viewDidAppear:(BOOL)animated
{
	CGRect frm = self.view.frame;
	frm = self.navigationController.view.frame;
	[super viewDidAppear:animated];
}
- (void)viewDidUnload {
	TT_RELEASE_SAFELY(_postInfoView);
	[super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
	{
		[self.post deleteRemote];
		
		// exit this screen
		[self dismissModalViewControllerAnimated:YES];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewController];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([actionSheet buttonTitleAtIndex:buttonIndex] == kButtonShare)
		[self displayComposerSheet];
	
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kButtonDelete)
		[self deleteButtonWasPressed];
	
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kButtonEdit)
		[self displayCaptionEditController];
}


////////////////////////////////////////////////////////////////////////////////////
// TTPostControllerDelegate

/**
 * The user has posted text and qwan animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text
{
	if (![self.post.caption isEqualToString:text])
	{
		// make sure the text is under the max
		if (text.length > 200)
			text = [text substringWithRange:NSMakeRange(0, 200)];
		
		self.post.caption = text;
		self.post.isOutdated = YES;
		[self.post didChange];
		
		[[UploadQueue getInstance] addObjectToQueue:self.post];
		[self.post load:TTURLRequestCachePolicyNone more:NO];
		
		self.postInfoView.post = nil;
		self.postInfoView.post = self.post;
	}
	return YES;
}

/**
 * The text has been posted.

- (void)postController:(TTPostController*)postController didPostText:(NSString*)text
			withResult:(id)result
{
	NSLog(@"Did Post text '%@'", text);
}
 */

/**
 * The controller was cancelled before posting.

- (void)postControllerDidCancel:(TTPostController*)postController
{
	NSLog(@"Did Cancel");
}
 */

@end
