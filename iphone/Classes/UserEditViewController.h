//
//  UserEditViewController.h
//  chiive
//
//  Created by Arrel Gray on 1/3/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "RootTableViewController.h"
#import "FBConnect/FBConnect.h"

@class User;
@class CHActivityLabel;


@interface UserEditTableViewDelegate : TTTableViewDelegate
{
	NSMutableDictionary		*_footers;
}
@end

@interface UserEditViewController : RootTableViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, FBSessionDelegate> {
	User						*_user;
	NSMutableDictionary		*_userValues;
	
	FBSession					*_session;
	TTButton					*_submitButton;
	UIImage					*_userAvatar;
	TTImageView				*_avatarView;
	UIButton					*_avatarButton;
	UITextField				*_emailField;
	UITextField				*_oldPasswordField;
	UITextField				*_newPasswordField;
	UITextField				*_confirmPasswordField;
	UITextField				*_firstNameField;
	UITextField				*_lastNameField;
	UIControl					*_hideKeyboardControl;
	UIBarButtonItem			*_logOutButton;
	CHActivityLabel			*_activityLabel;
}

@property (nonatomic, retain)	User				*user;
@property (nonatomic, readonly)	NSMutableDictionary	*userValues;
@property (nonatomic, readonly)	TTButton			*submitButton;
@property (nonatomic, readonly)	TTImageView			*avatarView;
@property (nonatomic, readonly)	UIButton			*avatarButton;
@property (nonatomic, readonly)	UITextField			*emailField;
@property (nonatomic, readonly)	UITextField			*oldPasswordField;
@property (nonatomic, readonly)	UITextField			*newPasswordField;
@property (nonatomic, readonly)	UITextField			*confirmPasswordField;
@property (nonatomic, readonly)	UITextField			*firstNameField;
@property (nonatomic, readonly)	UITextField			*lastNameField;
@property (nonatomic, readonly)	UIBarButtonItem		*logOutButton;
@property (nonatomic, readonly)	CHActivityLabel		*activityLabel;

@end

