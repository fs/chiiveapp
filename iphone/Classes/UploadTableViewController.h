//
//  UploadTableViewController.h
//  chiive
//
//  Created by Arrel Gray on 12/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RootTableViewController.h"
#import "CHTableItem.h"

@class CHTableEmptyView;


@interface CHUploadListDataSource : CHListDataSource
@end


@interface UploadTableViewController : RootTableViewController
{
	CHTableEmptyView	*_tableEmptyView;
}
@property (nonatomic, readonly)	CHTableEmptyView	*tableEmptyView;
@end
