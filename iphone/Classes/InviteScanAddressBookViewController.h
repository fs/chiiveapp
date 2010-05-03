//
//  InviteScanAddressBookViewController.h
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "InviteFriendsAbstractViewController.h"
#import "UserModel.h"

@interface ABUserModel : UserModel
@end

@interface ABUserDataSource : InviteFriendsDataSource
@end

@interface InviteScanAddressBookViewController : InviteFriendsAbstractViewController
@end
