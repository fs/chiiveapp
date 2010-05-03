//
//  UploadTableViewController.m
//  chiive
//
//  Created by Arrel Gray on 12/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "UploadTableViewController.h"
#import "UploadQueue.h"
#import "CHTableUploadItem.h"
#import "RESTObject.h"
#import "Group.h"
#import "Post.h"
#import "PostModel.h"
#import "Comment.h"
#import "CHTableEmptyView.h"



///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHUploadListDataSource
- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [self.items removeAllObjects];
	
	for (RESTObject *child in [(UploadQueue *)self.model objects])
	{
		CHTableUploadItem *item = [[[CHTableUploadItem alloc] init] autorelease];
		item.model = child;
		item.URL = NSStringFromClass([child class]);
		item.defaultImage = [UIImage imageNamed:@"icon_person.png"];
		
		if ([child isKindOfClass:[Post class]])
		{
			Post *post = (Post *)child;
			if (post.shouldDelete)
				item.text = [NSString stringWithFormat:@"Deleting Photo (%@)", post.group.prettyTitle];
			else if (post.hasSynced)
				item.text = [NSString stringWithFormat:@"Updating Photo (%@)", post.group.prettyTitle];
			else
				item.text = [NSString stringWithFormat:@"Adding Photo (%@)", post.group.prettyTitle];
			
			item.imageURL = [post URLForVersion:TTPhotoVersionThumbnail];
		}
		else if ([child isKindOfClass:[Group class]])
		{
			Group *group = (Group *)child;
			if (group.shouldDelete)
				item.text = [NSString stringWithFormat:@"Deleting %@", group.prettyTitle];
			else if (group.hasSynced)
				item.text = [NSString stringWithFormat:@"Updating %@", group.prettyTitle];
			else
				item.text = [NSString stringWithFormat:@"Creating Event: %@", group.prettyTitle];
			
			if (group.postModel.numberOfPhotos > 0)
			{
				Post *post = (Post *)[group.postModel.children objectAtIndex:0];
				item.imageURL = [post URLForVersion:TTPhotoVersionThumbnail];
			}
		}
		else if ([child isKindOfClass:[Comment class]])
		{
			Comment *comment = (Comment *)child;
			item.imageURL = [comment.post URLForVersion:TTPhotoVersionThumbnail];
			
			if (comment.shouldDelete)
				item.text = [NSString stringWithFormat:@"Deleting Comment: %@", comment.body];
			else if (comment.hasSynced)
				item.text = [NSString stringWithFormat:@"Updating Comment: %@", comment.body];
			else
				item.text = [NSString stringWithFormat:@"Adding Comment: %@", comment.body];
		}
		
		[self.items addObject:item];
	}
	
    [super tableViewDidLoadModel:tableView];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation UploadTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
    [super loadView];
	
	CHUploadListDataSource *ds = [[[CHUploadListDataSource alloc] init] autorelease];
	ds.model = [UploadQueue getInstance];
	self.dataSource = ds;
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[UploadQueue getInstance] retrieveManagedChildren];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UploadQueue getInstance] load:TTURLRequestCachePolicyNone more:NO];
}

- (CHTableEmptyView *)tableEmptyView
{
	if (!_tableEmptyView)
	{
		_tableEmptyView = [[CHTableEmptyView alloc] initWithFrame:self.tableView.frame];
		
		_tableEmptyView.titleLabel.text = @"Nothing currently uploading.";
		_tableEmptyView.messageLabel.text = @"When photos are still being uploaded you will see them listed here with their progress.";
		_tableEmptyView.button.hidden = YES;
	}
	return _tableEmptyView;
}

- (void)showEmpty:(BOOL)show
{
	if (show)
	{
		self.tableView.separatorColor = [UIColor clearColor];
		self.emptyView = self.tableEmptyView;
	}
	else
	{
		self.tableView.separatorColor = TTSTYLEVAR(tableSeparatorColor);
		self.emptyView = nil;
	}
}

@end

