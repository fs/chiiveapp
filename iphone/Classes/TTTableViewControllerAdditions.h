//
//  TTTableViewControllerAdditions.h
//  chiive
//
//  Created by 17FEET on 2/22/10.
//  Copyright 2010 17FEET. All rights reserved.
//


@interface TTTableViewController (CHCategory)
/**
 * Tells the controller that the user selected the accessory button of an object in the table.
 * 
 * By default, the object's URLValue will be opened in TTNavigator before this is called, if it has one.
 * This implementation does nothing unless overridden.
 */
- (void)didSelectAccessoryButtonForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end
