//
//  GroupListViewController.m
//  spyglass
//
//  Created by 17FEET on 8/25/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "HomeViewController.h"
#import "GroupListViewController.h"
#import "GroupTableViewCell.h"
#import "Group.h"
#import "Global.h"

@implementation GroupListViewController

- (Class) classRepresented {
	return [Group class];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	GroupTableViewCell *cell = (GroupTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupTableViewCell" owner:self options:nil];
		
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (GroupTableViewCell *) currentObject;
				break;
			}
		}
    }
	
	cell.group = [collection objectAtIndex:indexPath.row];
	//NSLog([NSString stringWithFormat:@"Num of posts: %d", cell.group.numberOfPhotos]);
	//[cell.group postList];
	return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Group *group = [collection objectAtIndex:indexPath.row];
	[homeViewController didSelectGroup:group];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	GroupTableViewCell *cell = (GroupTableViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
	return cell.group.userId == [[Global getSessionObjectForKey:@"userId"] intValue];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
