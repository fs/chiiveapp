//
//  InviteFriendsSearchViewController.h
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "InviteFriendsAbstractViewController.h"
#import "UserSearchModel.h"

@interface UserSearchSectionedDataSource : InviteFriendsDataSource <UITextFieldDelegate>
{
	UITextField		*_searchField;
}
@property (nonatomic, readonly)	UITextField		*searchField;
@end

@interface InviteFriendsSearchViewController : InviteFriendsAbstractViewController
@end
