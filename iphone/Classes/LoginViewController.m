//
//  LoginViewController.m
//  chiive
//
//  Created by 17FEET on 6/16/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "FBConnect/FBConnect.h"

#import "LoginViewController.h"
#import "Global.h"
#import "UserSession.h"
#import "RootViewController.h"
#import "UserEditViewController.h"
#import "ManagedObjectsController.h"
#import "JSON.h"
#import "User.h"
#import "CHTableItem.h"
#import "CHActivityLabel.h"
#import "FBLoginTableItemView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation LoginDataSource

/**
 * Create clear table cells for the Forgot Password and Facebook cells.
 */
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
{
	if ([object isMemberOfClass:[TTTableStyledTextItem class]])
		return [ClearStyledTextItem class];
	
	return [super tableView:tableView cellClassForObject:object];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ClearStyledTextItem
- (void)layoutSubviews {
	[super layoutSubviews];
	self.backgroundColor = [UIColor clearColor];
	self.backgroundView.hidden = YES;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation LoginViewController
@synthesize rootViewController = _rootViewController;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Internal

- (void)hideKeyboardWasPressed
{
	[self.loginField resignFirstResponder];
	[self.passwordField resignFirstResponder];
}

- (void)onLogInSuccess
{
	[self.rootViewController showNearbyScreen];
}

- (void)signInButtonWasPressed
{
	if ([self.loginField.text isEmptyOrWhitespace] || [self.passwordField.text isEmptyOrWhitespace])
	{
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Oops!" 
															 message:@"Please enter a username and password" 
															delegate:nil
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil] autorelease];
		[alertView show];
		return;
	}
	else
	{
		[self.loginField resignFirstResponder];
		[self.passwordField resignFirstResponder];
		
		self.userSession.login = self.loginField.text;
		self.userSession.password = self.passwordField.text;
		[self.userSession load:TTURLRequestCachePolicyNone more:NO];
	}
}

- (void)cancelUpload
{
	[self.userSession cancel];
}

- (void)showActivity:(BOOL)show
{
	if (show)
	{
		self.activityLabel.hidden = NO;
		self.submitButton.enabled = NO;
		self.navigationItem.leftBarButtonItem.action = @selector(cancelUpload);
	}
	else
	{
		self.activityLabel.hidden = YES;
		self.submitButton.enabled = YES;
		self.navigationItem.leftBarButtonItem.action = @selector(dismissModalViewController);
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		self.tableViewStyle = UITableViewStyleGrouped;
		self.autoresizesForKeyboard = YES;
		
		self.title = @"Back";
		self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo.png"]] autorelease];
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	NSString *sessionProxy = [NSString stringWithFormat:@"%@&fb_request_type=login",[Global getInstance].fbconnectSessionProxy];
	_session = [[FBSession sessionForApplication:[Global getInstance].fbconnectApiKey
								 getSessionProxy:sessionProxy
										delegate:self] retain];
	
	self.statusBarStyle = UIStatusBarStyleBlackOpaque;
	
	[super loadView];
	
	self.tableView.scrollEnabled = NO;
	
	self.submitButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.submitButton] autorelease];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
														initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
														target:self	
														action:@selector(dismissModalViewController)] autorelease];
	
	
	FBLoginTableItemView *fbView = [[[FBLoginTableItemView alloc] init] autorelease];
	fbView.loginButton.session = _session;
		
	self.dataSource = [LoginDataSource dataSourceWithObjects:				   
					   @"Login to start Chiiving",
					   self.loginField,
					   self.passwordField,
					   @"Already connected your account\nto Facebook?",
					   fbView,
					   nil];
	
	self.activityLabel.hidden = YES;
	[self.view addSubview:self.activityLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
#if (TARGET_IPHONE_SIMULATOR)
	[(TTButton *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES];
	self.loginField.text = @"arrel@17feet.com";
	self.passwordField.text = @"";
#endif
}

- (void)viewDidUnload 
{
	[[_session delegates] removeObject:self];
	TT_RELEASE_SAFELY(_session);
	
	TT_RELEASE_SAFELY(_loginField);
	TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_submitButton);
	TT_RELEASE_SAFELY(_activityLabel);
	
    [super viewDidUnload];
}

- (void)dealloc
{
	[[_userSession delegates] removeObject:self];
	TT_RELEASE_SAFELY(_userSession);
	[super dealloc];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ([string isEmptyOrWhitespace] && (range.location == 0 && range.length == 1))
	{
		self.submitButton.enabled = NO;
		return YES;
	}
	else 
	{
		self.submitButton.enabled = YES;
		NSArray *requiredFields = [NSArray arrayWithObjects:self.loginField, self.passwordField, nil];
		for (UITextField *field in requiredFields) 
		{
			if (field != textField && [field.text isEmptyOrWhitespace])
			{
				self.submitButton.enabled = NO;
				return YES;
			}
		}
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.loginField)
	{
		[self.passwordField becomeFirstResponder];
		return NO;
	}
	else
	{
		[self.passwordField resignFirstResponder];
		[self signInButtonWasPressed];
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model {
	[self showActivity:YES];
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
	[self showActivity:NO];
	
	[self.loginField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	[self onLogInSuccess];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
	[self showActivity:NO];
	
	NSString *errorMessage;
	
	if (![error.userInfo objectForKey:NSLocalizedDescriptionKey])
		errorMessage = @"Error logging in.\nPlease try again.";
	else
		errorMessage = [NSString stringWithFormat:@"%@.\nPlease try again.", error.localizedDescription];
	[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
								 message:errorMessage
								delegate:nil
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
	
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
	[self showActivity:NO];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (UserSession *)userSession
{
	if (nil == _userSession)
	{
		_userSession = [[UserSession alloc] init];
		[[_userSession delegates] addObject:self];
	}
	return _userSession;
}

- (TTButton *)submitButton
{
	if (!_submitButton)
	{
		_submitButton = [[TTButton buttonWithStyle:@"roundButton:" title:@"Login"] retain];
		[_submitButton sizeToFit];
		[_submitButton addTarget:self action:@selector(signInButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _submitButton;
}

- (UITextField *)loginField
{
	if (!_loginField)
	{
		_loginField = [[UITextField alloc] init];
		_loginField.placeholder = @"Email";
		_loginField.delegate = self;
		_loginField.returnKeyType = UIReturnKeyNext;
		_loginField.font = TTSTYLEVAR(font);
		_loginField.keyboardType = UIKeyboardTypeEmailAddress;
		_loginField.autocorrectionType = UITextAutocorrectionTypeNo;
		_loginField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	}
	return _loginField;
}

- (UITextField *)passwordField
{
	if (!_passwordField)
	{
		_passwordField = [[UITextField alloc] init];
		_passwordField.placeholder = @"Password";
		_passwordField.delegate = self;
		_passwordField.secureTextEntry = YES;
		_passwordField.returnKeyType = UIReturnKeyGo;
		_passwordField.font = TTSTYLEVAR(font);
	}
	return _passwordField;
}

- (CHActivityLabel *)activityLabel
{
	if (!_activityLabel)
	{
		_activityLabel = [[CHActivityLabel alloc] initWithFrame:self.view.bounds];
		_activityLabel.text = @"Logging in...";
	}
	return _activityLabel;
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
									 message:@"We didn't find a matching account.\nLogin with the email and password you used to sign up."
									delegate:nil
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		// Parse the JSON data that we retrieved from the server.
		NSDictionary *json = [session.metaData JSONValue];
		NSDictionary *results = [json objectForKey:@"user"];
		
		User *user = (User *)[ManagedObjectsController objectWithClass:[User class]];
		[user updateWithProperties:results];
		
		if (!!user.facebookUid && [user.facebookUid intValue] != 0)
		{
			[Global getInstance].currentUser = user;
			[self onLogInSuccess];
		}
		else
		{
			[[ManagedObjectsController getInstance] deleteObject:user];
			[[[[UIAlertView alloc] initWithTitle:@"Oops!" 
										 message:@"No matching account was found."
										delegate:nil
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil] autorelease] show];
		}
	}
	
	// we don't need a local session, so log out
	[_session logout];
}

@end
