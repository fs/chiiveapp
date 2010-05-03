//
//  InviteFromFacebookViewController.h
//  chiive
//
//  Created by 17FEET on 1/28/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "FBConnect/FBConnect.h"
#import "InviteFriendsAbstractViewController.h"
#import "UserModel.h"

@interface FacebookUserModel : UserModel
@end

@interface FacebookUserDataSource : InviteFriendsDataSource
@end

@interface InviteFromFacebookViewController : InviteFriendsAbstractViewController <FBSessionDelegate>
{
	FBSession	*_session;
}
@end
