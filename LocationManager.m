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
NSString *group;

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
        fordCoordinate.latitude = 42.057002;
        fordCoordinate.longitude =  -87.676985;
        self.enteredROI = YES;
        self.regionFord = [[CLCircularRegion alloc] initWithCenter:fordCoordinate radius:50 identifier:@"regionFord"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
        locationManager.distanceFilter = 20;
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
        locationManager.distanceFilter = 20;
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
    count = 0;
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
    fordCoordinate.latitude = 42.057002;
    fordCoordinate.longitude =  -87.676985;
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:fordCoordinate.latitude longitude:fordCoordinate.longitude];
    
    CLLocation *myLoc = [[CLLocation alloc]initWithLatitude:theBestLocation.latitude longitude:theBestLocation.longitude];
    CLLocationDistance distance = [myLoc distanceFromLocation:loc];
//
    NSLog(@"distance: %f", distance);
    if (distance <= 100 && count<=500 && theBestLocation.latitude!=0.0) {
        NSLog(@"%d", count);
        [self locationLoggingLatitude:[NSNumber numberWithFloat:theBestLocation.latitude] Longitude: [NSNumber numberWithFloat:theBestLocation.longitude] Accuracy: [NSNumber numberWithFloat:self.myLocationAccuracy]];
        NSLog(@"updating server");
        count++;
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
    
    if (distance>=500) {
        count = 0;
    }
    
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
                    } else if (components.day < 1 && components.hour >= 1 ) {
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

- (void)changeDesiredAccuracy: (NSTimer *)timer {
    CLLocationManager *locationManager = [LocationManager sharedLocationManager];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

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

@end
