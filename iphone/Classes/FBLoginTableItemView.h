//
//  FBLoginTableItemView.h
//  spyglass
//
//  Created by 17FEET on 4/21/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FBConnect/FBConnect.h"


@interface FBLoginTableItemView : UIView {
	TTStyledTextLabel		*_messageLabel;
	FBLoginButton			*_loginButton;
}

@property (nonatomic, readonly) TTStyledTextLabel		*messageLabel;
@property (nonatomic, retain) FBLoginButton			*loginButton;

@end