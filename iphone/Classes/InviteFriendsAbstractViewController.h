//
//  InviteFriendsAbstractViewController.h
//  spyglass
//
//  Created by 17FEET on 4/5/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableItem.h"
#import	"CHTableUserItem.h"

@interface InviteFriendsTableItemCell : CHTableUserItemCell
@end

@interface InviteFriendsDataSource : CHSectionedDataSource
@end

@interface InviteFriendsAbstractViewController : TTTableViewController
- (void)updateDataSource;
@end
