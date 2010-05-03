//
//  HomeViewController.h
//  spyglass
//
//  Created by Arrel Gray on 4/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class RootViewController;

@interface HomeViewController : TTViewController
{
	RootViewController	*_rootViewController;
}
@property (nonatomic, retain) 	RootViewController	*rootViewController;
@end
