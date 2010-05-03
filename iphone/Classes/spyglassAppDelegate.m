//
//  spyglassAppDelegate.m
//  chiive
//
//  Created by 17FEET on 6/10/09.
//  Copyright 17FEET 2009. All rights reserved.
//



#import "spyglassAppDelegate.h"
#import "CLController.h"
#import "ManagedObjectsController.h"
#import "CHDefaultStyleSheet.h"

#import "RootViewController.h"


@implementation spyglassAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	[TTURLCache sharedCache].invalidationAge = 31536000; // 60 * 60 * 24 * 365];
	[TTURLCache sharedCache].maxPixelCount = 800 * 800 * 6; // w * h * numberofphotos
	
	// Start core location
	[[CLController getInstance] getLocation];
	
	// set the style sheet
    [TTStyleSheet setGlobalStyleSheet:[[[CHDefaultStyleSheet alloc] init] autorelease]];
	
	// Add the main view
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_rootViewController = [[RootViewController alloc] init];
	
	[_window addSubview:_rootViewController.selectedNavigationController.view];
	[_window makeKeyAndVisible];
	
	// colorizing for testing
	// _window.backgroundColor = [UIColor redColor];
	
	return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationStatusDelegate

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[[ManagedObjectsController getInstance] saveChanges];
}


- (void)dealloc {
	[_rootViewController release];
	[_window release];
	[super dealloc];
}

@end