//
//  WhoCanJoinViewController.h
//  chiive
//
//  Created by 17FEET on 1/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;

@interface WhoCanJoinViewController : TTTableViewController
{
	Group	*_group;
}

@property (nonatomic, retain) Group		*group;

@end
