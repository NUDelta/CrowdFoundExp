//
//  LocationManager.m
//  CrowdFound
//
//  Created by Yongsung on 9/8/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "LocationManager.h"
#import <Parse/Parse.h>
#import "MyUser.h"


#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"
int count=0;
int totalcount=0;
int beaconcount=0;
int beaconrangecount=0;
NSString *group;
NSString *logdata;
NSString *beaconlogdata;
NSString *beaconrangedata;

BOOL loggingBeacon;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationManager

+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        }
    }
    return _locationManager;
}

- (id)init {
    if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        CLLocationCoordinate2D fordCoordinate; //region ford
        fordCoordinate.latitude = 42.056750; //42.057002;
        fordCoordinate.longitude =  -87.676997; //-87.676985;

        self.enteredROI = YES;
        self.regionFord = [[CLCircularRegion alloc] initWithCenter:fordCoordinate radius:50 identifier:@"regionFord"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
        //beacon setup
        [ESTConfig setupAppID:@"CrowdFound" andAppToken:@"2c138ec1f40d00cbaebd2aaac6cf09a8"];
        if([ESTConfig isAuthorized])
            NSLog(@"authorized!");
        
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
    
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    
        ESTBeaconRegion* alpha = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                                      major: 23148
                                                                                      minor: 58574
                                                                                 identifier: @"alpha"];
        
        ESTBeaconRegion* bravo = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 38004
                                                                          minor: 53805
                                                                     identifier: @"bravo"];
        
        ESTBeaconRegion* charlie = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 50606
                                                                          minor: 40668
                                                                     identifier: @"charlie"];
        
        ESTBeaconRegion* delta = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 7306
                                                                          minor: 35710
                                                                     identifier: @"delta"];
        
        ESTBeaconRegion* echo = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 31215
                                                                          minor: 51283
                                                                     identifier: @"echo"];
        
        ESTBeaconRegion* foxtrot = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 31478
                                                                          minor: 15717
                                                                     identifier: @"foxtrot"];
        
        ESTBeaconRegion* golf = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 50569
                                                                          minor: 27990
                                                                     identifier: @"golf"];
        
        ESTBeaconRegion* hotel = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                  major: 60315
                                                                  minor: 41424
                                                             identifier: @"hotel"];
        
        ESTBeaconRegion* juliet = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                           major: 60315
                                                                           minor: 41424
                                                                      identifier: @"hotel"];
        
        ESTBeaconRegion* kilo = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major: 49933
                                                                         minor: 14424
                                                                    identifier: @"kilo"];
        
        ESTBeaconRegion* lima = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major: 14424
                                                                         minor: 3132
                                                                    identifier: @"lima"];
        
        ESTBeaconRegion* mike = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major: 30239
                                                                         minor: 57931
                                                                    identifier: @"mike"];
        
        ESTBeaconRegion* november = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                             major: 41702
                                                                             minor: 46832
                                                                        identifier: @"november"];
        
        ESTBeaconRegion* oscar = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                          major: 44582
                                                                          minor: 39941
                                                                     identifier: @"oscar"];
        
    
        [self.beaconManager startRangingBeaconsInRegion:alpha];
        [self.beaconManager startRangingBeaconsInRegion:bravo];
//        [self.beaconManager startRangingBeaconsInRegion:charlie];
        [self.beaconManager startRangingBeaconsInRegion:delta];
        
        [self.beaconManager startRangingBeaconsInRegion:echo];
        [self.beaconManager startRangingBeaconsInRegion:foxtrot];
//        [self.beaconManager startRangingBeaconsInRegion:golf];
        [self.beaconManager startRangingBeaconsInRegion:hotel];
        
        [self.beaconManager startRangingBeaconsInRegion:juliet];
        [self.beaconManager startRangingBeaconsInRegion:kilo];
        [self.beaconManager startRangingBeaconsInRegion:lima];
        [self.beaconManager startRangingBeaconsInRegion:mike];
        [self.beaconManager startRangingBeaconsInRegion:november];
        [self.beaconManager startRangingBeaconsInRegion:oscar];
        
        self.locationBuilder = [ESTLocationBuilder new];
        [self.locationBuilder setLocationBoundaryPoints:@[
                                                          [ESTPoint pointWithX:0 y:0],
                                                          [ESTPoint pointWithX:0 y:34],
                                                          [ESTPoint pointWithX:8 y:34],
                                                          [ESTPoint pointWithX:8 y:0]]];
        
        
        //alpha
        [self.locationBuilder addBeaconIdentifiedByMac:@"d8bae4ce5a6c" atBoundarySegmentIndex:3 inDistance:8 fromSide:ESTLocationBuilderLeftSide];
        
        //november
        [self.locationBuilder addBeaconIdentifiedByMac:@"d2a4b6f0a2e6" atBoundarySegmentIndex:0 inDistance:7 fromSide:ESTLocationBuilderLeftSide];
        
        //bravo
        [self.locationBuilder addBeaconIdentifiedByMac:@"d166d22d9474" atBoundarySegmentIndex:0 inDistance:14 fromSide:ESTLocationBuilderLeftSide];
        
        //charlie
        //    [self.locationBuilder addBeaconIdentifiedByMac:@"cc9f9edcc5ae" atBoundarySegmentIndex:0 inDistance:12 fromSide:ESTLocationBuilderLeftSide];
        
        //delta
        [self.locationBuilder addBeaconIdentifiedByMac:@"eef38b7e1c8a" atBoundarySegmentIndex:0 inDistance:21 fromSide:ESTLocationBuilderLeftSide];
        
        
        //kilo
        [self.locationBuilder addBeaconIdentifiedByMac:@"db363858c30d" atBoundarySegmentIndex:0 inDistance:28 fromSide:ESTLocationBuilderLeftSide];
        
        //juliet
        [self.locationBuilder addBeaconIdentifiedByMac:@"f20ae6b72829" atBoundarySegmentIndex:1 inDistance:0 fromSide:ESTLocationBuilderLeftSide];
        
        
        //echo
        [self.locationBuilder addBeaconIdentifiedByMac:@"e9ebc85379ef" atBoundarySegmentIndex:3 inDistance:0 fromSide:ESTLocationBuilderLeftSide];
        
        //oscar
        [self.locationBuilder addBeaconIdentifiedByMac:@"d78c9c05ae26" atBoundarySegmentIndex:2 inDistance:7 fromSide:ESTLocationBuilderRightSide];
        
        //foxtrot
        [self.locationBuilder addBeaconIdentifiedByMac:@"ca813d657af6" atBoundarySegmentIndex:2 inDistance:14 fromSide:ESTLocationBuilderRightSide];
        
        //golf
        //    [self.locationBuilder addBeaconIdentifiedByMac:@"e64b6d56c589" atBoundarySegmentIndex:2 inDistance:12 fromSide:ESTLocationBuilderRightSide];
        
        //hotel
        [self.locationBuilder addBeaconIdentifiedByMac:@"f567a1d0eb9b" atBoundarySegmentIndex:2 inDistance:21 fromSide:ESTLocationBuilderRightSide];
        
        //    //mike
        [self.locationBuilder addBeaconIdentifiedByMac:@"ed50e24b761f" atBoundarySegmentIndex:2 inDistance:28 fromSide:ESTLocationBuilderRightSide];
        
        //lima
        [self.locationBuilder addBeaconIdentifiedByMac:@"d1740c3cea23" atBoundarySegmentIndex:1 inDistance:8 fromSide:ESTLocationBuilderLeftSide];

        
        [self.locationBuilder setLocationOrientation:350];
        
        [self.locationBuilder setLocationName:@"Delta Lab"];
        
        self.indoorLocation = [self.locationBuilder build];
        self.indoorLocationManager = [[ESTIndoorLocationManager alloc]init];
        self.indoorLocationManager.delegate = self;
        [self.indoorLocationManager startIndoorLocation:self.indoorLocation];
    }
    return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
    locationManager.delegate = self;
    if (self.enteredROI) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    } else {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        locationManager.distanceFilter = 80;
    }

    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
//    [locationManager startMonitoringForRegion:self.regionFord];
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }

    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
    locationManager.delegate = self;

    if (self.enteredROI) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    } else {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        locationManager.distanceFilter = 80;
    }
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
//    [locationManager startMonitoringForRegion:self.regionFord];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationManager sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
            [locationManager startMonitoringForRegion:self.regionFord];
        }
    }
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
    [locationManager stopUpdatingLocation];
//    [locationManager stopMonitoringForRegion:self.regionFord];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation * newLocation = [locations lastObject];
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    
    //if the location data is more than 20 seconds or horizontal accuracy is greater than 20.0 meters.
    if (locationAge > 20.0 || newLocation.horizontalAccuracy > 65.0 || newLocation.horizontalAccuracy < 0)
    {
        return;
    }
    
    self.myLocation = newLocation.coordinate;
    self.myLocationAccuracy = newLocation.horizontalAccuracy;
    
    
    CLLocationCoordinate2D fordCoordinate; //region ford
    fordCoordinate.latitude = 42.056750; //42.057002;
    fordCoordinate.longitude = -87.676997; //-87.676985;
    
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:fordCoordinate.latitude longitude:fordCoordinate.longitude];
    
    CLLocation *myLoc = [[CLLocation alloc]initWithLatitude:self.myLocation.latitude longitude:self.myLocation.longitude];
    CLLocationDistance distance = [myLoc distanceFromLocation:loc];
    //
    NSLog(@"distance: %f", distance);
    if (distance <= 100 && self.myLocation.latitude!=0.0) {
        NSLog(@"%d", count);
        NSDate *currentDate = [NSDate date];
        if (logdata == NULL || [logdata isEqualToString:@""])
            logdata = [NSString stringWithFormat:@"%f, %f, %f, %@", self.myLocation.latitude, self.myLocation.longitude, self.myLocationAccuracy, currentDate];
        logdata = [NSString stringWithFormat:@"%@\n%f, %f, %f, %@", logdata, self.myLocation.latitude, self.myLocation.longitude, self.myLocationAccuracy, currentDate];
        //        [self locationLoggingLatitude:[NSNumber numberWithFloat:theBestLocation.latitude] Longitude: [NSNumber numberWithFloat:theBestLocation.longitude] Accuracy: [NSNumber numberWithFloat:self.myLocationAccuracy]];
        count++;
        totalcount++;
    }
    
//    if (distance > 100) {
//        if (count>0 && count<10)
//            [self logData:logdata];
//        if (beaconcount>0 &&beaconcount<50)
//            [self beaconLogData:beaconlogdata];
//        if (beaconrangecount>0 && beaconrangecount<500)
//            [self beaconRangeLogData:beaconrangedata];
//    }
    
//    NSLog(@"%@", logdata);

//    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//    [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"LATITUDE"];
//    [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"LONGITUDE"];
//    [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"ACCURACY"];

    //Add the vallid location with good accuracy into an array
    //Every 1 minute, I will select the best location based on accuracy and send to server
//    [self.shareModel.myLocationArray addObject:dict];
//    NSLog(@"locationManager didUpdateLocations");
//    
//    for(int i=0;i<locations.count;i++){
//        CLLocation * newLocation = [locations objectAtIndex:i];
//        CLLocationCoordinate2D theLocation = newLocation.coordinate;
//        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
//        
//        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//        
//        if (locationAge > 30.0)
//        {
//            continue;
//        }
//        
//        //Select only valid location and also location with good accuracy
//        if(newLocation!=nil&&theAccuracy>0
//           &&theAccuracy<2000
//           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
//            
//            self.myLastLocation = theLocation;
//            self.myLastLocationAccuracy= theAccuracy;
//            
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"LATITUDE"];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"LONGITUDE"];
//            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"ACCURACY"];
//            
//            //Add the vallid location with good accuracy into an array
//            //Every 1 minute, I will select the best location based on accuracy and send to server
//            [self.shareModel.myLocationArray addObject:dict];
//        }
//    }
    
    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:50 target:self
                                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                                    userInfo:nil
                                                                     repeats:NO];
    
}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    self.enteredROI = YES;
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object[@"group"]) {
                group = @"a";
                object[@"group"] = group;
            }
            else
                group = object[@"group"];
        }
    }];
    NSLog(@"%@", group);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    self.enteredROI = NO;
    totalcount = 0;
    if (count>0 && count<10)
    {
        [self logData:logdata];
        count = 0;
    }
    if (beaconcount>0 &&beaconcount<50) {
        [self beaconLogData:beaconlogdata];
        beaconcount = 0;
    }
    if (beaconrangecount>0 && beaconrangecount<500)
    {
        [self beaconRangeLogData:beaconrangedata];
        beaconrangecount = 0;
    }
}

//Send the location to Server
- (void)updateLocationToServer {
    
    NSLog(@"updateLocationToServer");
    
    // Find the best location from the array based on accuracy
//    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    
//    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
//        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
//        
//        if(i==0)
//            myBestLocation = currentLocation;
//        else{
//            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
//                myBestLocation = currentLocation;
//            }
//        }
//    }
    
//    myBestLocation = [self.shareModel.myLocationArray lastObject];
    CLLocationCoordinate2D theBestLocation;

    theBestLocation.latitude = self.myLocation.latitude;
    theBestLocation.longitude = self.myLocation.longitude;
    
    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
//    if([self.shareModel.myLocationArray count]==0)
//    {
//        NSLog(@"Unable to get location, use the last known location");
//        self.myLocation=self.myLastLocation;
//        self.myLocationAccuracy=self.myLastLocationAccuracy;
//        
//    }else{
//        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
//        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
//        self.myLocation=theBestLocation;
//        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
//    }
    
    NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",theBestLocation.latitude, theBestLocation.longitude,self.myLocationAccuracy);
    
    CLLocationCoordinate2D fordCoordinate; //region ford
    fordCoordinate.latitude = 42.056750; //42.057002;
    fordCoordinate.longitude = -87.676997; //-87.676985;
    
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:fordCoordinate.latitude longitude:fordCoordinate.longitude];
    
    CLLocation *myLoc = [[CLLocation alloc]initWithLatitude:theBestLocation.latitude longitude:theBestLocation.longitude];
    CLLocationDistance distance = [myLoc distanceFromLocation:loc];
//
    NSLog(@"distance: %f", distance);
    if (count>=10 && totalcount <=500) {
        [self logData:logdata];
        count = 0;
        logdata = @"";
    }
    
//    if (distance <= 40 && [group isEqualToString:@"b"]) {
//        [self sendNotification: [NSString stringWithFormat:@"%f", distance]];
//        [self appUsageLogging: [NSString stringWithFormat:@"distance is: %f", distance]];
//    }
//    
//    if (distance <= 20 && [group isEqualToString:@"a"]) {
//        [self sendNotification:     [NSString stringWithFormat:@"%f", distance]];
//        [self appUsageLogging: [NSString stringWithFormat:@"distance is: %f", distance]];
//    }
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}

- (void)sendNotification: (NSString *)distance
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    //    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
    //    localNotif.userInfo = dictionary;
    localNotif.alertBody = [NSString stringWithFormat:@"Can you please look for a lost item: %@?", distance];
    localNotif.alertAction = @"Slide to see the lost item and location details";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    if (localNotif) {
        
        //TODO: after 3 minutes, change desiredAccuracy to Ten meters to prevent battery leak.
        PFQuery *query = [MyUser query];
        [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            if (!error) {
                NSDate *lastNotifiedDate = object[@"lastNotified"];
                if (lastNotifiedDate == NULL) {
                    localNotif.applicationIconBadgeNumber = 1;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                    NSDate *date = [NSDate date];
                    object[@"lastNotified"] = date;
//                    [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(changeDesiredAccuracy:) userInfo:nil repeats:NO];
                } else {
                    NSLog(@"%@", lastNotifiedDate);
                    NSDate *currentDate = [NSDate date];
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                                               fromDate:lastNotifiedDate
                                                                 toDate:currentDate
                                                                options:0];
                    NSLog(@"current date: %@", currentDate);
                    NSLog(@"Difference in date components: %ld/%ld/%ld", (long)components.minute, (long)components.hour, (long)components.day);
                    if (components.day > 1) {
                        localNotif.applicationIconBadgeNumber = 1;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//                        [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(changeDesiredAccuracy:) userInfo:nil repeats:NO];
                        NSDate *date = [NSDate date];
                        object[@"lastNotified"] = date;
                        NSLog(@"more than a day, so notify");
                    } else if (components.day < 1 && components.hour >= 3 ) {
                        NSLog(@"more than 4 hours, notify too");
                        localNotif.applicationIconBadgeNumber = 1;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//                        [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(changeDesiredAccuracy:) userInfo:nil repeats:NO];
                        NSDate *date = [NSDate date];
                        object[@"lastNotified"] = date;
                    } else {
                        NSLog(@"do not notify");
                        //TODO: uncomment this
                        //                    self.shouldNotify = NO;
                    }
                }
                [object saveInBackground];
            } else {
                NSLog(@"ERROR!");
            }
        }];
    }
}
//
//- (void)changeDesiredAccuracy: (NSTimer *)timer {
//    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
//    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//}

- (void)locationLoggingLatitude:(NSNumber *)latitude Longitude:(NSNumber *)longitude Accuracy:(NSNumber *)accuracy {
    NSDate *currentDate = [NSDate date];
    NSLog(@"current date: %@", currentDate);
    PFObject *location = [PFObject objectWithClassName:@"Location"];
    if (![MyUser currentUser]) {
        NSLog(@"not signed in");
    }
    else {
        location[@"username"] = [MyUser currentUser].username;
        location[@"latitude"] = [NSString stringWithFormat:@"%f", [latitude floatValue]];
        location[@"longitude"] = [NSString stringWithFormat:@"%f", [longitude floatValue]];
        location[@"accuracy"] = [NSString stringWithFormat:@"%f", [accuracy floatValue]];
        location[@"userDate"] = currentDate;
        [location saveInBackground];
    }
}

- (void)beaconLogData: (NSString *)logs {
    PFObject *beacon = [PFObject objectWithClassName:@"Beacon"];
    if (![MyUser currentUser]) {
        NSLog(@"not signed in");
    } else {
        beacon[@"log"] = logs;
        beacon[@"username"] = [MyUser currentUser].username;
        [beacon saveInBackground];
    }
}

- (void)beaconRangeLogData: (NSString *)logs {
    PFObject *beacon = [PFObject objectWithClassName:@"BeaconRange"];
    if (![MyUser currentUser]) {
        NSLog(@"not signed in");
    } else {
        beacon[@"log"] = logs;
        beacon[@"username"] = [MyUser currentUser].username;
        [beacon saveInBackground];
    }
}

- (void)logData: (NSString *)logs {
    PFObject *location = [PFObject objectWithClassName:@"Location"];
    if (![MyUser currentUser]) {
        NSLog(@"not signed in");
    } else {
        location[@"log"] = logs;
//        location[@"clientdate"] = [NSDate date];
        location[@"username"] = [MyUser currentUser].username;
        [location saveInBackground];
    }
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    if (![MyUser currentUser]) {
        NSLog(@"not signed in");
    }
    else {
        usage[@"username"] = [MyUser currentUser].username;
        usage[@"userid"] = [MyUser currentUser].objectId;
        usage[@"activity"] = activity;
        [usage saveInBackground];
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
//    ESTBeacon *beacon = [beacons lastObject];
//    if (beacon!=NULL) {
//        NSNumber *distance = beacon.distance;
//        NSString *name = region.identifier;
//        if ([distance floatValue]<=4.0)
//            [self beaconLogData: beaconlogdata];
//    }
    ESTBeacon *firstBeacon = [beacons firstObject];
    if ([firstBeacon.distance integerValue]!= -1 && [firstBeacon.distance floatValue]!= 0.0) {
        if (beaconrangedata == NULL || [beaconrangedata isEqualToString:@""])
            beaconrangedata = [NSString stringWithFormat:@"%ld,%ld,%ld,%f,%@",(long)[firstBeacon.major integerValue], (long)[firstBeacon.minor integerValue], (long)firstBeacon.rssi, [firstBeacon.distance floatValue], [NSDate date]];
        beaconrangedata = [NSString stringWithFormat:@"%@\n%ld,%ld,%ld,%f,%@",beaconrangedata, (long)[firstBeacon.major integerValue], (long)[firstBeacon.minor integerValue], (long)firstBeacon.rssi, [firstBeacon.distance floatValue], [NSDate date]];
        if (beaconrangecount<=50) {
            beaconrangecount++;
        } else {
            [self beaconRangeLogData:beaconrangedata];
            beaconrangecount = 0;
            beaconrangedata = @"";
        }
        NSLog(@"distance to %ld,%ld,%ld: %@",(long)[firstBeacon.major integerValue], (long)[firstBeacon.minor integerValue], (long)firstBeacon.rssi, [firstBeacon.distance stringValue]);
    }
}


- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager didUpdatePosition:(ESTOrientedPoint *)position withAccuracy:(ESTPositionAccuracy)positionAccuracy inLocation:(ESTLocation *)location {
    NSLog(@"position x: %f, position y: %f, accuracy: %ld", position.x, position.y, positionAccuracy);
    NSDate *currentDate = [NSDate date];
    if (beaconlogdata == NULL || [beaconlogdata isEqualToString:@""])
        beaconlogdata = [NSString stringWithFormat:@"%f, %f, %f, %ld, %@", position.x, position.y, position.orientation, positionAccuracy, currentDate];
    beaconlogdata = [NSString stringWithFormat:@"%@\n%f, %f, %f,%ld, %@", beaconlogdata, position.x, position.y, position.orientation, positionAccuracy, currentDate];

    if (beaconcount<= 50) {
        beaconcount++;
    } else {
        [self beaconLogData:beaconlogdata];
        beaconcount = 0;
        beaconlogdata = @"";
    }
}

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager didFailToUpdatePositionWithError:(NSError *)error {
//    if (error.code == ESTIndoorPositionOutsideLocationError)
//        NSLog(@"It seems you are not in this location.");
//    
//    else if (error.code == ESTIndoorMagnetometerInitializationError)
//        NSLog(@"It seems your magnetometer is not working.");
//    NSLog(@"%@", error.localizedDescription);

//    PFObject *beacon = [PFObject objectWithClassName:@"Beacon"];
//    if (![MyUser currentUser]) {
//        NSLog(@"not signed in");
//    } else {
//        beacon[@"log"] = error.localizedDescription;
//        [beacon saveInBackground];
//    }
}

@end
