//
//  UserSearchModel.h
//  spyglass
//
//  Created by 17FEET on 4/2/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserModel.h"

@interface UserSearchModel : UserModel
{
	UserModel		*_userModel;
	NSString		*_searchText;
	BOOL			_remote;
	
	NSTimer			*_searchDelayTimer;
	NSTimeInterval	_searchDelay;
	
}
@property (nonatomic, retain)	UserModel	*userModel;
@property (nonatomic, retain)	NSString	*searchText;
@property (nonatomic, assign)	BOOL		remote;

- (void)search:(NSString*)text;

@end

