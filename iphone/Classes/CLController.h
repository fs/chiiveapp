//
//  CLController.h
//  chiive
//
//  Created by 17FEET on 6/15/09.
//  Copyright 2009 17FEET. All rights reserved.
//

@protocol CLControllerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
@end


@interface CLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager			*_locationManager;
	CLLocation					*_location;
	CLLocationDegrees			_latitude;
	CLLocationDegrees			_longitude;
	id<CLControllerDelegate>	_delegate;
}

@property (nonatomic, retain) CLLocationManager			*locationManager;
@property (nonatomic, retain) CLLocation				*location;
@property (assign)			  CLLocationDegrees			latitude;
@property (assign)			  CLLocationDegrees			longitude;
@property (nonatomic, assign) id <CLControllerDelegate> delegate;

+ (CLController*)getInstance;
- (void)getLocation;
- (BOOL)hasLocation;

@end