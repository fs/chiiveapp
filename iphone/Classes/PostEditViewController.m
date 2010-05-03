//
//  PostEditViewController.m
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RESTModelComplete.h"
#import "PostEditViewController.h"
#import "CLController.h"
#import "UploadQueue.h"
#import "Post.h"
#import "Group.h"
#import "Global.h"
#import "GroupEditViewController.h"
#import "ManagedObjectsController.h"


@implementation PostEditViewController
@synthesize photo = _photo, imageView = _imageView,
			post = _post, group = _group, sourceType = _sourceType;


///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal

- (void)createPostWithPhoto:(UIImage *)savedPhoto
{
	Post *newPost = (Post *)[ManagedObjectsController objectWithClass:[Post class]];
	self.post = newPost;
	
	self.post.caption = @"";
	
	if ([[CLController getInstance] location] != nil) 
	{
		self.post.latitude = [NSNumber numberWithDouble:[[CLController getInstance] latitude]];
		self.post.longitude = [NSNumber numberWithDouble:[[CLController getInstance] longitude]];
	}
	else
	{
		self.post.latitude = [NSNumber numberWithDouble:37.7899];
		self.post.longitude = [NSNumber numberWithDouble:-122.4047];
	}
	
	self.post.captured_at = [NSDate date];
	self.post.photoFileName = @"image.jpg";
	self.post.user = [Global getInstance].currentUser;
	self.post.delegate = self;
	
	// the post save process involves resizing and saving the photo to disk, blocking the UI. 
	// This is okay, but we perform the save after a delay to allow the UI to update to "saving..." mode first.
	//[post performSelector:@selector(saveWithPhoto:) withObject:savedPhoto afterDelay:0.1];
	
	[self.post saveWithPhoto:savedPhoto];
}

- (void)addPostWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
	self.sourceType = sourceType;
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = self.sourceType;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setSourceType:(UIImagePickerControllerSourceType)type
{
	_sourceType = type;
	_sourceTypeIsSet = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated
{
	[self retain];
	UIWindow* window = view.window ? view.window : [UIApplication sharedApplication].keyWindow;
	
	self.view.transform = TTRotateTransformForOrientation(TTInterfaceOrientation());;
	self.view.frame = [UIScreen mainScreen].applicationFrame;
	
	[self.superController viewWillAppear:animated];
	[window addSubview:self.view];
	[self.superController viewDidAppear:animated];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated
{
	// if there was a new photo taken with the camera, save it to the photos album
	if (UIImagePickerControllerSourceTypeCamera == self.sourceType && !!self.photo)
	{
		NSLog(@"Save original to album started");
		UIImageWriteToSavedPhotosAlbum(self.photo, nil, nil, nil);
	}
	
	// remove the photo
	self.photo = nil;
	
	UIViewController *superController = self.superController;
	superController.popupViewController = nil;
	
	if (animated) {
		[superController viewWillAppear:animated];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:TT_TRANSITION_DURATION];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop)];
		
		self.view.frame = CGRectOffset(self.view.frame, 0, self.view.frame.size.height);
		
		[UIView commitAnimations];
	} else {
		[self.view removeFromSuperview];
		[self release];
		[superController viewWillAppear:animated];
		[superController viewDidAppear:animated];
	}
}

- (void)hideAnimationDidStop
{
	UIViewController *superController = self.superController;
	[self.view removeFromSuperview];
	[self release];
	[superController viewDidAppear:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	self.wantsFullScreenLayout = YES;
	[super loadView];
	
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	_imageView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_imageView];
	
	UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
	loadingView.backgroundColor = [UIColor blackColor];
	loadingView.alpha = .7;
	
	UILabel *loadingText = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, loadingView.frame.size.width - 20, 30)] autorelease];
	loadingText.textAlignment = UITextAlignmentCenter;
	loadingText.textColor = [UIColor whiteColor];
	loadingText.backgroundColor = [UIColor clearColor];
	loadingText.font = [UIFont systemFontOfSize:14];
	loadingText.text = @"Saving image...";
	[loadingView addSubview:loadingText];
	
	UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] init] autorelease];
	[activityView sizeToFit];
	activityView.frame = CGRectOffset(activityView.frame, round((loadingView.frame.size.width - activityView.frame.size.width) * 0.5), 50);
	[activityView startAnimating];
	[loadingView addSubview:activityView];
	
	[self.view addSubview:loadingView];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	self.view.hidden = !self.photo;
	self.imageView.image = self.photo;
	
	if ([self.modalViewController isMemberOfClass:[UINavigationController class]])
		_shouldDismissView = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// if the screen needs to be dismissed
	if (_shouldDismissView)
		[self dismissPopupViewControllerAnimated:NO];
	
	// if there is already a photo, create the new post
	else if (!!self.photo)
		[self createPostWithPhoto:self.photo];
	
	// if there are options for camera or library, present them
	else if (_sourceTypeIsSet)
		[self addPostWithSourceType:self.sourceType];
	
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[[[[UIActionSheet alloc] initWithTitle:nil
									 delegate:self 
							cancelButtonTitle:@"Cancel" 
					   destructiveButtonTitle:nil 
							otherButtonTitles:@"Take Photo", @"Choose From Library", nil] autorelease]
		 showInView:self.view];
	
	// if no options, just show the available option
	else
		[self addPostWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	self.imageView.image = nil;
	self.photo = nil;
	
	[[UploadQueue getInstance] load:TTURLRequestCachePolicyNone more:NO];
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_imageView);
	[super viewDidUnload];
}

/**
 * Use dealloc to release these objects so that we don't lose new data to be posted.
 */
- (void)dealloc
{
	[_post setDelegate:nil];
	TT_RELEASE_SAFELY(_post);
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_photo);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissModalViewController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	_shouldDismissView = YES;
	[self dismissModalViewController];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PostDelegate

- (void)postDidFinishSaving:(Post *)post
{
	[self.post setDelegate:nil];
	
	// if there's no group, show a modal create group screen
	if (!self.group)
	{
		GroupEditViewController *viewController = [[[GroupEditViewController alloc] init] autorelease];
		
		self.group = (Group *)[ManagedObjectsController objectWithClass:[Group class]];		
		[self.group.friendModel insertNewChild:[Global getInstance].currentUser];
		post.group = self.group;
		[self.group.postModel insertNewChild:post];
		
		viewController.group = self.group;
		
		UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
		[self presentModalViewController:navigationController animated:YES];
	}
	// if we have a group already, just add it to the queue and dismiss
	else
	{
		self.post.group = self.group;
		[self.group.postModel insertNewChild:post];
		
		// trigger a finish load notification to the group's delegates
		// [self.group didFinishLoad];
		
		[[UploadQueue getInstance] addObjectToQueue:self.post];
		
		// re-launch photo creation
		//[self addPostWithSourceType:self.sourceType];
		
		// DEPRECATED: dismiss the edit screen to return to the group
		[self dismissPopupViewControllerAnimated:YES];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
		[self addPostWithSourceType:UIImagePickerControllerSourceTypeCamera];
	else if (buttonIndex == 1)
		[self addPostWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (2 == buttonIndex)
		[self dismissPopupViewControllerAnimated:NO];
}

@end
