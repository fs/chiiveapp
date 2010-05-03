//
//  CLController.m
//  chiive
//
//  Created by 17FEET on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CLController.h"

@implementation CLController
@synthesize locationManager = _locationManager, delegate = _delegate;
@synthesize location = _location, longitude = _latitude, latitude = _longitude;

static CLController *sharedCLController = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (BOOL)hasLocation
{
	return !!self.location;
}

- (void)getLocation {
	//NSLog(@"Start the location manager");
	[self.locationManager startUpdatingLocation];
}

- (CLLocationManager *)locationManager
{
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.delegate = sharedCLController;
	}
	return _locationManager;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	self.location = newLocation;
	self.latitude = newLocation.coordinate.latitude;
	self.longitude = newLocation.coordinate.longitude;
	
	//NSLog([NSString stringWithFormat:@"Location accuracy: %d", self.location.horizontalAccuracy]);
	//NSLog([NSString stringWithFormat:@"Shooting for accuracy: %f", kCLLocationAccuracyNearestTenMeters]);
	
	// TODO: Add timeout for stopping location updates.
	// if we're within 10 meters, stop here
	if (101 > self.location.horizontalAccuracy ) 
	{
		//NSLog(@"Stop updating location!");
		[self.locationManager stopUpdatingLocation];
	}
	else
	{
		//NSLog(@"Continue updating location!");
	}
	
	if (nil != self.delegate)
	{
		[self.delegate locationUpdate:self.location];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	//NSLog(@"Location update error!");
	[self.delegate locationError:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc {
	[self.locationManager release];
    [super dealloc];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// Singleton Setup

+ (CLController*)getInstance {
    @synchronized(self) {
        if (sharedCLController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedCLController;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCLController == nil) {
            sharedCLController = [super allocWithZone:zone];
			return sharedCLController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
