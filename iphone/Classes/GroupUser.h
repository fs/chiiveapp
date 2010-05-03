//
//  GroupUser.h
//  chiive
//
//  Created by 17FEET on 2/9/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;
@class User;

@interface GroupUser : NSManagedObject
@property (nonatomic, retain) Group	*group;
@property (nonatomic, retain) User	*user;
@end
