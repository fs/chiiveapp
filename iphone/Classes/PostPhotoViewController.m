//
//  PostPhotoViewController.m
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "PostPhotoViewController.h"
#import "PostInfoViewController.h"
#import "PostEditViewController.h"
#import "PostPhotoView.h"
#import "PostPhotoLabel.h"
#import "CHCameraBarButtonItem.h"
#import "Post.h"
#import "PostModel.h"
#import "Group.h"
#import "Global.h"
#import "UploadQueue.h"


static NSString *kButtonDelete = @"Delete";
static NSString *kButtonShare = @"Share";
static NSString *kButtonEdit = @"Edit Caption";


///////////////////////////////////////////////////////////////////////////////////////////////////
// Unexposed super functions

@interface PostPhotoViewController (Private)
- (TTPhotoView*)centerPhotoView;
- (void)cancelImageLoadTimer;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation PostPhotoViewController
@synthesize cameraBarButtonItem = _cameraBarButtonItem;


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIButton *)commentsButton
{
	if (!_commentsButton)
	{
		UIImage *commentImage = [UIImage imageNamed:@"toolbar_icon_comment.png"];
		_commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, commentImage.size.width, commentImage.size.height)];
		[_commentsButton addTarget:self action:@selector(commentsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[_commentsButton setBackgroundImage:commentImage forState:UIControlStateNormal];
		[_commentsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		_commentsButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		_commentsButton.titleLabel.textAlignment = UITextAlignmentCenter;
		
	}
	return _commentsButton;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// Accessors

- (Post *)post {
	return (Post *)self.centerPhoto;
}

- (TTPhotoView*)createPhotoView {
	return [[[PostPhotoView alloc] init] autorelease];
}

- (PostPhotoView *)centerPostPhotoView {
	return (PostPhotoView *)[self centerPhotoView];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)commentsButtonWasPressed
{
	PostInfoViewController *viewController = [[[PostInfoViewController alloc] init] autorelease];
	
	id<TTTableViewDataSource> ds = [CommentListDataSource dataSourceWithItems:nil];
	ds.model = self.post;
	viewController.dataSource = ds;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[self presentModalViewController:navController animated:YES];
}

- (void)deleteButtonWasPressed
{
	// if this is the only post in the group
//	if ([self.post.group.postModel.children count] > 1)
//	{
		[[[[UIAlertView alloc] initWithTitle:@"Delete Photo" 
									 message:@"Are you sure you want to delete this photo?" 
									delegate:self
						   cancelButtonTitle:@"Cancel"
						   otherButtonTitles:@"Delete", nil] autorelease] show];
//	}
//	else
//	{
//		[[[[UIAlertView alloc] initWithTitle:@"Cannot Delete Photo" 
//									 message:@"You can't delete the last photo in an event!" 
//									delegate:nil
//						   cancelButtonTitle:@"OK"
//						   otherButtonTitles:nil] autorelease] show];
//	}
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

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Shared photo from Chiive"];
	
	// Attach an image to the email
	NSData *myData = [[TTURLCache sharedCache] dataForURL:[self.centerPhoto URLForVersion:TTPhotoVersionLarge]];
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
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex)
	{
		[self.post deleteRemote];
		
		// exit this screen
//		[self dismissModalViewControllerAnimated:YES];
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewController];
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
	}
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoViewController

/**
 * Replace the loadView method to create a custom toolbar
 */
- (void)loadView {
	[super loadView];
	
	UIBarItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *actionItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																				 target:self action:@selector(actionButtonWasPressed)] autorelease];
	UIBarButtonItem *commentItem = [[[UIBarButtonItem alloc] initWithCustomView:self.commentsButton] autorelease];
//	UIBarButtonItem *commentItem = [[[UIBarButtonItem alloc] initWithImage:commentImage style:UIBarButtonItemStylePlain 
//																	target:self action:@selector(commentButtonWasPressed)] autorelease];
	
	_toolbar.items = [NSArray arrayWithObjects:
					  actionItem, space, _previousButton, space, _nextButton, space, commentItem, nil];
	
	_cameraBarButtonItem = [[CHCameraBarButtonItem alloc] init];
	_cameraBarButtonItem.controller = self;
	self.navigationItem.rightBarButtonItem = _cameraBarButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.post.group.isCurrentUserGroup)
	{
		self.cameraBarButtonItem.enabled = YES;
		self.cameraBarButtonItem.group = self.post.group;
	}
	else
	{
		self.cameraBarButtonItem.enabled = NO;
		self.cameraBarButtonItem.group = nil;
	}
}

/**
 * Leave navbar and caption in place when swiping photos.
 */
- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView {
	[self cancelImageLoadTimer];
	
	/* Leave caption and bars in place when swiping through photos
	[self showCaptions:NO];
	[self showBars:NO animated:YES];
	 */
}
/*
- (void)showBars:(BOOL)show animated:(BOOL)animated {
	_captionControl.hidden = !show;
	[super showBars:show animated:animated];
}
*/
- (void)updateChrome {
	if (_photoSource.numberOfPhotos < 2) {
		self.title = !_photoSource.title || [_photoSource.title isEmptyOrWhitespace] ? @"Untitled" : _photoSource.title;
	} else {
		self.title = [NSString stringWithFormat:
					  TTLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"),
					  _centerPhotoIndex+1, _photoSource.numberOfPhotos];
	}
	
	NSInteger numberOfComments = [self post].commentModel.numberOfChildren;
	NSString *commentsValue;
	commentsValue =  (numberOfComments > 0) ? [NSString stringWithFormat:@"%d", numberOfComments] : @"+";
	
	[_commentsButton setTitle:commentsValue forState:UIControlStateNormal];

	/* Removed super call and replaced with only code used in super call
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	[super updateChrome];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	 */
}

- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (object == self.centerPhoto)
		[self centerPostPhotoView].postCaptionLabel.text = self.centerPhoto.caption;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidUnload {
	TT_RELEASE_SAFELY(_commentsButton);
	TT_RELEASE_SAFELY(_cameraBarButtonItem);
	[super viewDidUnload];
}

@end
