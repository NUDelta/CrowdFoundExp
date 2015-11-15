//
//  LocationManager.h
//  CrowdFound
//
//  Created by Yongsung on 9/8/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"

#import "ESTIndoorLocationManager.h"
#import "ESTConfig.h"
#import "ESTLocation.h"
#import "ESTLocationBuilder.h"
#import "ESTBeacon.h"
#import "ESTBeaconManager.h"
#import "ESTIndoorLocationView.h"
#import "ESTPositionView.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate, ESTIndoorLocationManagerDelegate, ESTBeaconManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) BOOL enteredROI;
@property (nonatomic) CLCircularRegion *regionFord;


@property (nonatomic, strong) ESTIndoorLocationManager *indoorLocationManager;
@property (nonatomic, strong) ESTLocation *indoorLocation;
@property (nonatomic, strong) ESTLocationBuilder *locationBuilder;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;


@end