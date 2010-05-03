//
//  TTTableViewDelegateAdditions.m
//  chiive
//
//  Created by 17FEET on 2/22/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "TTTableViewDelegateAdditions.h"
#import "TTTableViewControllerAdditions.h"

@implementation TTTableViewDelegate (CHCategory)
- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
	id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
	id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	if ([object isKindOfClass:[TTTableLinkedItem class]]) {
		[self.controller didSelectAccessoryButtonForObject:object atIndexPath:indexPath];
	}
}


@end
