//
//  LoginViewController.h
//  chiive
//
//  Created by 17FEET on 6/16/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "FBConnect/FBConnect.h"
#import "CHTableItem.h"

@class RootViewController;
@class UserSession;
@class CHActivityLabel;

@interface LoginViewController : TTTableViewController <TTModelDelegate, UITextFieldDelegate, FBSessionDelegate> {
	RootViewController		*_rootViewController;
	
	UserSession				*_userSession;
	FBSession					*_session;
	TTButton					*_submitButton;
	UITextField				*_loginField;
	UITextField				*_passwordField;
	CHActivityLabel			*_activityLabel;
}

@property (nonatomic, assign)		RootViewController	*rootViewController;
@property (nonatomic, readonly)	UserSession			*userSession;
@property (nonatomic, readonly)	TTButton				*submitButton;
@property (nonatomic, readonly)	UITextField			*loginField;
@property (nonatomic, readonly)	UITextField			*passwordField;
@property (nonatomic, readonly)	CHActivityLabel		*activityLabel;

@end


@interface LoginDataSource : CHSectionedDataSource
@end

@interface ClearStyledTextItem : TTStyledTextTableItemCell
@end