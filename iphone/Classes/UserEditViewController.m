//
//  UserEditViewController.m
//  chiive
//
//  Created by Arrel Gray on 1/3/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserEditViewController.h"
#import "User.h"
#import "Global.h"
#import "JSON.h"
#import "ManagedObjectsController.h"
#import "RootViewController.h"
#import "CHActivityLabel.h"
#import "InviteFriendsViewController.h"
#import "FBLoginTableItemView.h"
#import "UIImage+Resize.h"

static NSString *kLogOutActionSheetTitle = @"Are you sure you want to log out?";
//static NSString *kAnimationId = @"tableResizeAnimation";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserEditTableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if (indexPath.section == 0 && indexPath.row == 0)
//}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	UIView *view = [self tableView:tableView viewForFooterInSection:section];
	if (!view)
		return 0;
	
	return view.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (section == 0)
	{
		NSString *title = @"*Chiive will not display any of your activity on facebook.";
		//		NSString *title = @"Forgot your password? <a href='password'>Click here</a>";
		TTStyledTextLabel* footer = [_footers objectForKey:title];
		if (nil == footer) 
		{
			if (nil == _footers) 
			{
				_footers = [[NSMutableDictionary alloc] init];
			}
			footer = [[[TTStyledTextLabel alloc] init] autorelease];
			footer.text = [TTStyledText textFromXHTML:title];
			footer.font = [UIFont systemFontOfSize:11];
			footer.textColor = RGBCOLOR(81,90,119);
			footer.backgroundColor = [UIColor clearColor];
			footer.contentInset = UIEdgeInsetsMake(5, 18, 0, 0);
			footer.frame = CGRectMake(0, 0, tableView.width, 25);
			[_footers setObject:footer forKey:title];
		}
		return footer;
	}
	return nil;
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserEditViewController
@synthesize user = _user, activityLabel = _activityLabel;


///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)didCreateUser
{
	// set the current user and go to the Nearby screen
	[Global getInstance].currentUser = self.user;
	
	// start by searching for friends
	InviteFriendsViewController *viewController = [[[InviteFriendsViewController alloc] init] autorelease];
	viewController.rootViewController = self.rootViewController;
	
	// show the skip button on the top right
	viewController.navigationItem.rightBarButtonItem = viewController.skipButton;
	
	// remove the back button from the top left
	viewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init] autorelease]] autorelease];
	
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)cancelUpload
{
	[self.user cancel];
}

- (void)showActivity:(BOOL)show
{
	if (show)
	{
		self.activityLabel.hidden = NO;
		
		if (self.user != [Global getInstance].currentUser)
			self.activityLabel.text = @"Creating Account...";
		else
			self.activityLabel.text = @"Saving changes...";
		
		// show the cancel button
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
												   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
												   target:self action:@selector(cancelUpload)] autorelease];
	}
	else
	{
		self.activityLabel.hidden = YES;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.submitButton] autorelease];
	}
}

- (UIView *)leftViewWithText:(NSString *)text
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 22)] autorelease];
	label.font = [UIFont boldSystemFontOfSize:17];
	label.textColor = [UIColor darkGrayColor];
	label.text = text;
	return label;
}

- (UITextField *)defaultTextField
{
	UITextField *field = [[UITextField alloc] init];
	field.placeholder = @"Required";
	field.delegate = self;
	field.returnKeyType = UIReturnKeyNext;
	field.autocorrectionType = UITextAutocorrectionTypeNo;
	field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	field.leftViewMode = UITextFieldViewModeAlways;
	return field;
}

- (void)addAvatarWithCamera:(BOOL)launchWithCamera
{
	UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
	picker.delegate = self;
	picker.sourceType = launchWithCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:picker animated:YES];
}

- (void)updateForm
{
	self.emailField.text = self.user.email;
	self.firstNameField.text = self.user.firstName;
	self.lastNameField.text = self.user.lastName;
	self.newPasswordField.text = @"";
	self.confirmPasswordField.text = @"";
	
	if (!!self.user.URLForAvatar && ![self.user.URLForAvatar isEmptyOrWhitespace])
	{
		[self.avatarButton setTitle:@"   Update your image" forState:UIControlStateNormal];
		self.avatarView.urlPath = self.user.URLForAvatar;
	}
	else
	{
		[self.avatarButton setTitle:@"   Add an image!" forState:UIControlStateNormal];
		self.avatarView.urlPath = nil;
		self.avatarView.defaultImage = [UIImage imageNamed:@"icon_avatar_blank.png"];
	}
}

- (void)updateDataSource
{
	// if we don't yet have a user assigned
	if (!self.user)
	{
		self.dataSource = [TTSectionedDataSource dataSourceWithObjects:nil];
	}
	// if this is the current user editing their accoutn
	else if (self.user == [Global getInstance].currentUser)
	{
		self.firstNameField.tag = 1;
		self.lastNameField.tag = 2;
		self.emailField.tag = 3;
		
		self.newPasswordField.tag = 100;
		self.confirmPasswordField.tag = 101;
		
		self.dataSource = [TTSectionedDataSource dataSourceWithObjects:				   
						   @"Edit your avatar",
						   self.avatarButton,
						   @"Edit account settings",
						   self.firstNameField,
						   self.lastNameField,
//						   @"",
						   self.emailField,
						   nil];
	}
	// if this is a new user creation
	else
	{
		FBLoginTableItemView *fbView = [[[FBLoginTableItemView alloc] init] autorelease];
		fbView.messageLabel.text = [TTStyledText textFromXHTML:@"Sign up using Facebook"];
		fbView.loginButton.session = _session;
		
		self.firstNameField.tag = 1;
		self.lastNameField.tag = 2;
		self.emailField.tag = 3;
		self.newPasswordField.tag = 4;
		self.confirmPasswordField.tag = 5;
		
		self.dataSource = [TTSectionedDataSource dataSourceWithObjects:				   
						   @"Sign up with one click",
						   fbView,
						   @"Or create an account",
						   self.firstNameField,
						   self.lastNameField,
						   self.emailField,
						   self.newPasswordField,
						   self.confirmPasswordField,
						   nil];
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (RootTabBar *)tabBar
{
	if (!!self.user && self.user == [Global getInstance].currentUser)
		return [super tabBar];
	else
		return nil;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTImageView *)avatarView
{
	if (!_avatarView)
	{
		_avatarView = [[TTImageView alloc] initWithFrame:CGRectMake(0, -4, 40, 40)];
		_avatarView.defaultImage = [UIImage imageNamed:@"icon_avatar_blank.png"];
		_avatarView.userInteractionEnabled = NO;
	}
	return _avatarView;
}
			   
- (UIButton *)avatarButton
{
	if (!_avatarButton)
	{
		_avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 30)];
		[_avatarButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		_avatarButton.backgroundColor = [UIColor clearColor];
		
		[_avatarButton addSubview:self.avatarView];
		_avatarView.urlPath = nil;
		[_avatarButton setTitle:@"   Add an image!" forState:UIControlStateNormal];
		[_avatarButton addTarget:self action:@selector(avatarButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _avatarButton;
}

- (UITextField *)emailField
{
	if (!_emailField)
	{
		_emailField = [self defaultTextField];
		_emailField.returnKeyType = UIReturnKeyDone;
		_emailField.keyboardType = UIKeyboardTypeEmailAddress;
		_emailField.leftView = [self leftViewWithText:@"Email"];
		if (!![self.userValues objectForKey:@"emailField"])
			_emailField.text = [self.userValues objectForKey:@"emailField"];

	}
	return _emailField;
}

- (UITextField *)firstNameField
{
	if (!_firstNameField)
	{
		_firstNameField = [self defaultTextField];
		_firstNameField.leftView = [self leftViewWithText:@"First name"];
		if (!![self.userValues objectForKey:@"firstNameField"])
			_firstNameField.text = [self.userValues objectForKey:@"firstNameField"];
	}
	return _firstNameField;
}

- (UITextField *)lastNameField
{
	if (!_lastNameField)
	{
		_lastNameField = [self defaultTextField];
		_lastNameField.leftView = [self leftViewWithText:@"Last name"];
		if (!![self.userValues objectForKey:@"lastNameField"])
			_lastNameField.text = [self.userValues objectForKey:@"lastNameField"];
	}
	return _lastNameField;
}

- (UITextField *)newPasswordField
{
	if (!_newPasswordField)
	{
		_newPasswordField = [self defaultTextField];
		_newPasswordField.secureTextEntry = YES;
		_newPasswordField.leftView = [self leftViewWithText:@"Password"];
		if (!![self.userValues objectForKey:@"newPasswordField"])
			_newPasswordField.text = [self.userValues objectForKey:@"newPasswordField"];
	}
	return _newPasswordField;
}

- (UITextField *)oldPasswordField
{
	if (!_oldPasswordField)
	{
		_oldPasswordField = [self defaultTextField];
		_oldPasswordField.secureTextEntry = YES;
		_oldPasswordField.leftView = [self leftViewWithText:@"Old Password"];
		if (!![self.userValues objectForKey:@"oldPasswordField"])
			_oldPasswordField.text = [self.userValues objectForKey:@"oldPasswordField"];
	}
	return _oldPasswordField;
}

- (UITextField *)confirmPasswordField
{
	if (!_confirmPasswordField)
	{
		_confirmPasswordField = [self defaultTextField];
		_confirmPasswordField.secureTextEntry = YES;
		_confirmPasswordField.leftView = [self leftViewWithText:@"Repeat"];
		if (!![self.userValues objectForKey:@"confirmPasswordField"])
			_confirmPasswordField.text = [self.userValues objectForKey:@"confirmPasswordField"];
	}
	return _confirmPasswordField;
}

- (UIBarButtonItem *)logOutButton
{
	if (!_logOutButton)
	{
		_logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonWasPressed)];
	}
	return _logOutButton;
}

- (TTButton *)submitButton
{
	if (!_submitButton)
	{
		_submitButton = [[TTButton buttonWithStyle:@"roundButton:" title:@"Submit"] retain];
		[_submitButton addTarget:self action:@selector(submitButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _submitButton;
}

- (NSMutableDictionary *)userValues
{
	if (!_userValues)
		_userValues = [[NSMutableDictionary alloc] init];
	return _userValues;
}

- (void)setUser:(User *)user
{
	if (user != _user)
	{
		[user retain];
		[_user release];
		_user = user;
		
		[self updateForm];
		[self updateDataSource];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	NSString *sessionProxy = [NSString stringWithFormat:@"%@&fb_request_type=create",[Global getInstance].fbconnectSessionProxy];
	_session = [[FBSession sessionForApplication:[Global getInstance].fbconnectApiKey
								 getSessionProxy:sessionProxy
										delegate:self] retain];
	
	self.tableViewStyle = UITableViewStyleGrouped;
	
	[super loadView];
	
	self.autoresizesForKeyboard = YES;
	
	self.title = @"Sign Up";
	
	self.submitButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.submitButton] autorelease];
	
	_hideKeyboardControl = [[UIControl alloc] initWithFrame:CGRectZero];//self.view.bounds];
	_hideKeyboardControl.backgroundColor = [UIColor clearColor];
	[_hideKeyboardControl addTarget:self action:@selector(hideKeyboardWasPressed)
				   forControlEvents:UIControlEventTouchUpInside];
	_hideKeyboardControl.hidden = YES;
	[self.view addSubview:_hideKeyboardControl];
	
	_activityLabel = [[CHActivityLabel alloc] initWithFrame:self.view.bounds];
	_activityLabel.hidden = YES;
	[self.view addSubview:_activityLabel];
	
	[self updateDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	if (!self.user)
	{
		self.user = (User *)[ManagedObjectsController objectWithClass:[User class]];
#if (TARGET_IPHONE_SIMULATOR)
		self.firstNameField.text = @"Arrel";
		self.lastNameField.text = @"Gray";
		self.newPasswordField.text = @"";
		self.confirmPasswordField.text = @"";
		self.emailField.text = @"arrel@17feet.com";
#endif
	}
	
	if (self.user == [Global getInstance].currentUser)
	{
		self.navigationItem.leftBarButtonItem = self.logOutButton;
		[self.submitButton setTitle:@"Save" forState:UIControlStateNormal];
		[self.submitButton sizeToFit];
	}
	else
	{
		[self.submitButton setTitle:@"Create" forState:UIControlStateNormal];
		[self.submitButton sizeToFit];
	}
}

- (void)didReceiveMemoryWarning
{
	// save any custom values entered into the fields 
	if (!!self.firstNameField.text)
		[self.userValues setObject:self.firstNameField.text forKey:@"firstNameField"];
	
	if (!!self.lastNameField.text)
		[self.userValues setObject:self.lastNameField.text forKey:@"lastNameField"];
	
	if (!!self.newPasswordField.text)
		[self.userValues setObject:self.newPasswordField.text forKey:@"newPasswordField"];
	
	if (!!self.confirmPasswordField.text)
		[self.userValues setObject:self.confirmPasswordField.text forKey:@"confirmPasswordField"];
	
	if (!!self.oldPasswordField.text)
		[self.userValues setObject:self.oldPasswordField.text forKey:@"oldPasswordField"];
	
	if (!!self.emailField.text)
		[self.userValues setObject:self.emailField.text forKey:@"emailField"];
	
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[[_session delegates] removeObject:self];
	TT_RELEASE_SAFELY(_session);

	TT_RELEASE_SAFELY(_submitButton);
	TT_RELEASE_SAFELY(_userAvatar);
	TT_RELEASE_SAFELY(_avatarView);
	TT_RELEASE_SAFELY(_avatarButton);
	TT_RELEASE_SAFELY(_emailField);
	TT_RELEASE_SAFELY(_oldPasswordField);
	TT_RELEASE_SAFELY(_newPasswordField);
	TT_RELEASE_SAFELY(_confirmPasswordField);
	TT_RELEASE_SAFELY(_firstNameField);
	TT_RELEASE_SAFELY(_lastNameField);
	TT_RELEASE_SAFELY(_hideKeyboardControl);
	TT_RELEASE_SAFELY(_logOutButton);
	TT_RELEASE_SAFELY(_activityLabel);
	
	[super viewDidUnload];
}

- (void)dealloc
{
	[[_user delegates] removeObject:self];
	TT_RELEASE_SAFELY(_user);
	TT_RELEASE_SAFELY(_userValues);
	[super dealloc];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate
{
	if (![Global getInstance].currentUser)
		return [[[UserEditTableViewDelegate alloc] initWithController:self] autorelease];
	else
		return [super createDelegate];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal

- (void)avatarButtonWasPressed
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[[[[UIActionSheet alloc] initWithTitle:nil
									  delegate:self 
							 cancelButtonTitle:@"Cancel" 
						destructiveButtonTitle:nil 
							 otherButtonTitles:@"Take Photo", @"Choose From Library", nil] autorelease]
		 showInView:self.view];
	
	// if no options, just show the available option
	else
		[self addAvatarWithCamera:NO];
}

- (void)hideKeyboard
{
	[self.firstNameField resignFirstResponder];
	[self.lastNameField resignFirstResponder];	
	[self.emailField resignFirstResponder];
	[self.oldPasswordField resignFirstResponder];
	[self.newPasswordField resignFirstResponder];
	[self.confirmPasswordField resignFirstResponder];
}

- (BOOL)formIsMissingRequiredField
{
	NSMutableArray *requiredFields = [NSMutableArray arrayWithObjects:self.firstNameField, self.lastNameField, self.emailField, nil];
	if (!self.user || !self.user.hasSynced)
	{
		[requiredFields addObject:self.newPasswordField];
		[requiredFields addObject:self.confirmPasswordField];
	}
	
	for (UITextField *field in requiredFields) 
	{
		if ([field.text isEmptyOrWhitespace])
			return YES;
	}
	
	return NO;
}

- (BOOL)formPasswordIsInvalid
{
	// if this is a new user
	if (!self.user || !self.user.hasSynced)
	{
		NSLog(@"new  '%@'", self.newPasswordField.text);
		NSLog(@"conf '%@'", self.confirmPasswordField.text);
		return ![self.newPasswordField.text isEqualToString:self.confirmPasswordField.text];
	}
	
	// if this is an established user that is trying to update the password
	else if (![self.newPasswordField.text isEmptyOrWhitespace] || ![self.confirmPasswordField.text isEmptyOrWhitespace])
	{
		if ([self.oldPasswordField.text isEmptyOrWhitespace])
			return YES;
		
		else if (![self.newPasswordField.text isEqualToString:self.confirmPasswordField.text])
			return YES;
	}
	
	return NO;
}

- (void)submitButtonWasPressed
{
	if ([self formIsMissingRequiredField])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Missing Field" 
									 message:@"Please enter a name, email, and password" 
									delegate:nil
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
		return;
	}
	else if ([self formPasswordIsInvalid])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Password Mismatch" 
									 message:@"Your passwords must match." 
									delegate:nil
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
		return;
	}
	else
	{
		[self hideKeyboard];
		
		self.user.login = self.emailField.text;
		self.user.firstName = self.firstNameField.text;
		self.user.lastName = self.lastNameField.text;
		self.user.email = self.emailField.text;
		
		// if we're updating the password
		if (![self.newPasswordField.text isEmptyOrWhitespace])
			self.user.password = self.newPasswordField.text;
		
		// flag the user as outdated so that it syncs with the server
		self.user.isOutdated = YES;
		
		// add as a delegate and start the load
		[self.user.delegates removeObject:self];
		[self.user.delegates addObject:self];
		
		[self.user load:TTURLRequestCachePolicyNone more:NO];
	}
	
}

- (void)logOutButtonWasPressed
{
	[[[[UIActionSheet alloc] initWithTitle:kLogOutActionSheetTitle
								  delegate:self
						 cancelButtonTitle:@"Cancel" 
					destructiveButtonTitle:nil 
						 otherButtonTitles:@"Log Out", nil] autorelease]
	 showInView:self.view];
}

- (void)logOut
{
	if ([self.navigationController.delegate isKindOfClass:[RootViewController class]])
	{
		// go back to the login screen
		RootViewController *rootViewController = (RootViewController *)self.navigationController.delegate;
		[rootViewController logOut];
	}
}

- (void)hideKeyboardWasPressed
{
	[self hideKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	_hideKeyboardControl.hidden = NO;
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	_hideKeyboardControl.hidden = YES;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSInteger nextTag = textField.tag + 1;
	
	NSMutableArray *fields = [NSMutableArray arrayWithObjects:self.firstNameField, 
							  self.newPasswordField,
							  self.confirmPasswordField,
							  self.emailField,
							  self.lastNameField, nil];
	
	// Try to find next responder
	UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
	
	for (UITextField *field in fields) {
		if (field.tag == nextTag)
		{
			nextResponder = field;
			break;
		}
	}
	
	// Found next responder, so set it.
	if (nextResponder) 
	{
		[nextResponder becomeFirstResponder];
		[self.tableView scrollFirstResponderIntoView];
		// Not found, so remove keyboard.
	}
	else
	{
		[textField resignFirstResponder];
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
	
	/*
	NSMutableArray *orderedFields = [NSMutableArray arrayWithObjects:self.firstNameField, self.lastNameField, nil];
	if (!self.user.hasSynced)
	{
		[orderedFields addObject:self.newPasswordField];
		[orderedFields addObject:self.confirmPasswordField];
	}
	[orderedFields addObject:self.emailField];
	
	for (int i=0; i < [orderedFields count]; i++) {
		UITextField *field = [orderedFields objectAtIndex:i];
		if (field == textField)
		{
			if (i+1 < [orderedFields count])
				[[orderedFields objectAtIndex:i+1] becomeFirstResponder];
			else
				[textField resignFirstResponder];
			
			break;
		}
	}
	return YES;
	 */
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	self.submitButton.enabled = YES;
	return YES;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model
{
	[self showActivity:YES];
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
	[self showActivity:NO];
	
	// if this was the creation of a new user
	if (self.user != [Global getInstance].currentUser)
		[self didCreateUser];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
	[self showActivity:NO];
	
	NSString *errorMessage;
	if (![error.userInfo objectForKey:NSLocalizedDescriptionKey])
		errorMessage = @"Error saving account.\nPlease try again.";
	else
		errorMessage = [NSString stringWithFormat:@"%@.\nPlease try again.", error.localizedDescription];
	
	[[[[UIAlertView alloc] initWithTitle:@"Oops!"
								 message:errorMessage
								delegate:nil
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
	[self showActivity:NO];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.submitButton.enabled = YES;
	
	UIImage *avatarOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
	self.user.avatarImage = [avatarOriginal thumbnailImage:400 transparentBorder:0 cornerRadius:0 interpolationQuality:1];

	self.avatarView.defaultImage = self.user.avatarImage;
	self.avatarView.urlPath = nil;
	[self dismissModalViewController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewController];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// if this is the logout action sheet
	if (kLogOutActionSheetTitle == actionSheet.title)
	{
		if (buttonIndex == 0)
		{
			[self logOut];
		}
	}
	else if (buttonIndex < 2)
	{
		[self addAvatarWithCamera:(buttonIndex == 0)];
	}
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

- (void)session:(FBSession *)session didLogin:(FBUID)uid
{
	NSString *userData = session.metaData;
	NSLog(@"Createa account Data %@", userData);

	NSDictionary *json = [userData JSONValue];
	if (!userData || [userData isEmptyOrWhitespace] || [userData isEqualToString:@"null"] || ![json isKindOfClass:[NSDictionary class]])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
									 message:@"There was a problem creating your account. Please try again."
									delegate:nil
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		// Parse the JSON data that we retrieved from the server.
		NSDictionary *json = [session.metaData JSONValue];
		NSDictionary *results = [json objectForKey:@"user"];
		
		[self.user updateWithProperties:results];
		
		if (!!self.user.facebookUid && [self.user.facebookUid intValue] != 0)
		{
			[self didCreateUser];
		}
		else
		{
			[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
										 message:@"There was a problem creating your account. Please try again."
										delegate:nil
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil] autorelease] show];
		}
	}
	
	// we don't need a local session, so log out
	[_session logout];
}


@end
