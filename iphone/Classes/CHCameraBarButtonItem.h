//
//  CHCameraBarButtonItem.h
//  chiive
//
//  Created by 17FEET on 3/19/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class Group;

@interface CHCameraBarButtonItem : UIBarButtonItem {
	Group				*_group;
	UIViewController	*_controller;
}

@property (nonatomic, retain)	Group				*group;
@property (nonatomic, retain)	UIViewController	*controller;

- (id)initWithController:(UIViewController *)controller;
- (void)cameraButtonWasPressed;

@end
