//
//  GroupSuggestionTableViewController.h
//  spyglass
//
//  Created by 17FEET on 4/2/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupTableViewController.h"
#import "CHTableViewDragRefreshDelegate.h"

@class GroupModel;
@class CHTutorialView;


@interface GroupSuggestionDataSource : CHSectionedDataSource
{
	CHTutorialView		*_tutorialView;
}
@property (nonatomic, readonly)	GroupModel			*groupModel;
@property (nonatomic, readonly)	CHTutorialView		*tutorialView;
@end

@interface GroupSuggestionTableViewController : GroupTableViewController
@end
