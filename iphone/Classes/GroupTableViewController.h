//
//  GroupTableViewController.h
//  chiive
//
//  Created by 17FEET on 8/26/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableItem.h"
#import "RootTableViewController.h"
#import "CHTableViewDragRefreshDelegate.h"

@class User;
@class GroupModel;
@class CHTableEmptyView;
@class CHTutorialView;

@interface GroupActiveTableHeaderView : TTTableHeaderView
@end

@interface GroupTableViewDelegate : CHTableViewDragRefreshDelegate
@end

@interface GroupDataSource : CHSectionedDataSource <UIAlertViewDelegate>
{
	CHTutorialView		*_tutorialView;
}
@property (nonatomic, readonly)	GroupModel			*groupModel;
@property (nonatomic, readonly)	CHTutorialView		*tutorialView;
@end

@interface GroupEditableDataSource : GroupDataSource
{
	UITableView			*_tableView;
	Group					*_selectedObject;
}
@property (nonatomic, assign)	UITableView			*tableView;
@property (nonatomic, retain)	Group				*selectedObject;
@end

@interface GroupTableViewController : RootTableViewController <UIAlertViewDelegate>
{
	CHTableEmptyView	*_tableEmptyView;
	NSString			*_friendshipRequestType;
	TTButton			*_newEventButton;
}
@property (nonatomic, readonly)	User				*user;
@property (nonatomic, readonly)	GroupModel			*groupModel;
@property (nonatomic, readonly)	TTButton			*newEventButton;
@end
