//
//  HelperDetailViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/13/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "HelperDetailViewController.h"
#import "CoreLocation/CoreLocation.h"
#import <Parse/Parse.h>
#import "RouteViewController.h"
#import "MyUser.h"
#import "MySession.h"
#import "ESTIndoorLocationManager.h"
#import "ESTConfig.h"
#import "ESTLocation.h"
#import "ESTLocationBuilder.h"
#define mySession [MySession sharedManager]

@interface HelperDetailViewController () <CLLocationManagerDelegate, ESTIndoorLocationManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *item;
@property (weak, nonatomic) IBOutlet UILabel *locationDetail;
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property BOOL helped;
@property BOOL helpFailed;
@property (weak, nonatomic) IBOutlet UILabel *helperNumber;
@property (weak, nonatomic) IBOutlet UILabel *helperFailNumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *oldLocation;
@property double lat;
@property double lng;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *enteredRegion;
@property BOOL lastNotified;
@property (nonatomic, strong) NSString *group;
@property BOOL enteredNoyes;
@property BOOL enteredTech;
@property int first;
@property int second;
@property int third;
@property int fourth;
@property int fifth;
@property int secondsLeftForSearch;
@property int minutes, seconds;
@property BOOL shouldNotify;
@property CLCircularRegion *regionFord;
@property BOOL enteredROI;

@property (nonatomic, strong) ESTIndoorLocationManager *indoorManager;
@property (nonatomic, strong) ESTLocation *indoorLocation;
@property (nonatomic, strong) ESTLocationBuilder *locationBuilder;

@property BOOL notified;

@end

@implementation HelperDetailViewController
@synthesize didGetNotif;


- (void)sendItemFoundEmailToRequester
{
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil ];
//    
//    NSURL * url = [NSURL URLWithString:@"http://crowdfound.parseapp.com/foundEmail"];
//    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
//    NSString * params = [NSString stringWithFormat:@"name=%@&helperEmail=%@&reqName=%@&email=%@",[MyUser currentUser].username, [MyUser currentUser].email, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
//    NSLog(@"==============email===============, %@", [self.request valueForKeyPath:@"email"]);
//    //TODO change email address and username
//    
//    //    NSString * params = [NSString stringWithFormat:@"name=%@&phone=yk@u.northwestern.edu&reqName=%@&email=%@",[PFUser currentUser].username, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
//    
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"tester", @"name", nil];
//    //    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//    //    [urlRequest setHTTPBody:postData];
//    
//    //    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    }];
//    [dataTask resume];
//    NSLog(@"completed");
    NSDictionary *params = @{
         @"helper":[MyUser currentUser].username,
         @"helperEmail":[MyUser currentUser].email,
         @"requester": @"YK",
         @"requesterEmail":@"yongsung7@gmail.com"
         };
    [PFCloud callFunctionInBackground:@"foundEmail" withParameters:params block:^(NSString *result, NSError *error) {
        if (error){
            NSLog(@"email sent error");
        } else {
            NSLog(@"result :%@", result);
        }
    }];
}

- (void)sendThankEmailToFounder{
    NSDictionary *params = @{
                             @"helper":[MyUser currentUser].username,
                             @"helperEmail":[MyUser currentUser].email
                             };
    [PFCloud callFunctionInBackground:@"thankEmail_Found" withParameters:params block:^(NSString *result, NSError *error) {
        if (error){
            NSLog(@"email sent error");
        } else {
            NSLog(@"result :%@", result);
        }
    }];
}

- (void)sendThankEmailToHelper {
    NSDictionary *params = @{
                             @"helper":[MyUser currentUser].username,
                             @"helperEmail":[MyUser currentUser].email
                             };
    [PFCloud callFunctionInBackground:@"thankEmail_NotFound" withParameters:params block:^(NSString *result, NSError *error) {
        if (error){
            NSLog(@"email sent error");
        } else {
            NSLog(@"result :%@", result);
        }
    }];
}

- (IBAction)giongtoHelpButton:(UIButton *)sender {
    NSLog(@"clicked");
    
    //TODO: uncomment
    NSNumber *helpnum = [self.request valueForKeyPath:@"helpCount"];
    int help_int = [helpnum intValue];
    help_int += 1;
    
    PFQuery *requestQuery = [PFQuery queryWithClassName:@"Request"];
    [requestQuery whereKey:@"objectId" equalTo:[self.request valueForKeyPath:@"objectId"]];

    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            PFObject *obj = [objects firstObject];
            NSNumber *help_count = [NSNumber numberWithInt:help_int];
            obj[@"helpCount"] = help_count;
            [obj saveInBackground];
        }
    }];
//        @"rUd9H0TBDr" block:^(PFObject * _Nullable object, NSError * _Nullable error) {
//        NSNumber *help_count = [NSNumber numberWithInt:help_int];
//        object[@"helperCount"] = help_count;
//        [object saveInBackground];
    
    [self appUsageLogging: [NSString stringWithFormat:@"help looking for %@, request ID: %@", [self.request valueForKeyPath:@"item"], [self.request valueForKeyPath:@"objectId"]]];
    self.TimerLabel.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    //FIXME: change time to 60 seconds
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(showThanksAlertview:) userInfo:nil repeats:NO];
}

- (void)timerTick: (NSTimer *)timer {
    if (self.secondsLeftForSearch > 0) {
        self.secondsLeftForSearch--;
        self.minutes = (self.secondsLeftForSearch%3600)/60;
        self.seconds = (self.secondsLeftForSearch%3600)%60;
        self.TimerLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.minutes, self.seconds];
    } else {
        [timer invalidate];
        self.secondsLeftForSearch = 30;
        self.TimerLabel.hidden = YES;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        NSLog(@"clicked YES");
        [self appUsageLogging: [NSString stringWithFormat:@"found %@, request ID: %@", [self.request valueForKeyPath:@"item"], [self.request valueForKeyPath:@"objectId"]]];
        [self sendItemFoundEmailToRequester];
        [self sendThankEmailToFounder];
    } else if (buttonIndex==1) {
        NSLog(@"clicked NO");
        [self appUsageLogging: [NSString stringWithFormat:@"couldn't find %@, request ID: %@", [self.request valueForKeyPath:@"item"], [self.request valueForKeyPath:@"objectId"]]];
        [self sendThankEmailToHelper];
    }
}

- (void)fillDetails
{
    NSString *itemDetailString = [NSString stringWithFormat:@"%@\n%@", [self.request valueForKeyPath:@"item"], [self.request valueForKeyPath:@"detail"]];
    self.item.text = itemDetailString;
    self.item.numberOfLines = 4;
    // sizeToFit gives weird size when label text changes.
    //    [self.item sizeToFit];

    self.locationDetail.numberOfLines = 3;

    self.locationDetail.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"locationDetail"]];
//    [self.locationDetail sizeToFit];
//    NSArray *arr = [[self.request valueForKeyPath:@"detail"] componentsSeparatedByString:@" "];
//    NSMutableArray *muarr = [[NSMutableArray alloc]init];
//    for(int i = 1; i <= [arr count]; i++) {
//        if(i%6!=0)
//        {
//            [muarr addObject:arr[i-1]];
//            [muarr addObject:@" "];
//        }else{
//            [muarr addObject:arr[i-1]];
//            [muarr addObject:@" \n"];
//        }
//    }
}

- (void)appDidEnterForeground {
//  [mySession setHdvc:self];
    NSLog(@"view did enter foreground");
    
    PFQuery *requestQuery = [PFQuery queryWithClassName: @"Request"];
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            self.request = [objects lastObject];
            [self fillDetails];
        }
    }];
//    PFQuery *query = [MyUser query];
//    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//        if (!error) {
//            if (!object[@"group"]) {
//                self.group = @"a";
//                object[@"group"] = self.group;
//            }
//            else
//                self.group = object[@"group"];
//            NSLog(@"%@",self.group);
//            NSDate *lastNotifiedDate = object[@"lastNotified"];
//            NSLog(@"%@", lastNotifiedDate);
//            if (lastNotifiedDate==NULL) {
//                self.shouldNotify = YES;
//            } else {
//                NSDate *currentDate = [NSDate date];
//                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
//                                                           fromDate:lastNotifiedDate
//                                                             toDate:currentDate
//                                                            options:0];
//                NSLog(@"current date: %@", currentDate);
//                NSLog(@"Difference in date components: %li/%li/%li", (long)components.minute, (long)components.hour, (long)components.day);
//                if (components.day >= 1) {
//                    self.shouldNotify = YES;
//                    NSLog(@"more than a day, so notify");
//                } else if (components.day < 1 && components.hour >= 4 ) {
//                    NSLog(@"more than 4 hours, notify too");
//                    self.shouldNotify = YES;
//                } else {
//                    NSLog(@"do not notify");
//                    //TODO: uncomment this
//                    self.shouldNotify = NO;
//                }
//            }
//            [self appUsageLogging:@"entered foreground"];
//        }
//    }];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
//    [mySession setHdvc:self];
    PFQuery *requestQuery = [PFQuery queryWithClassName: @"Request"];
    [requestQuery orderByAscending:@"helpCount"];
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            self.request = [objects firstObject];
            [self fillDetails];
        }
    }];
//    [self.indoorManager startIndoorLocation:self.location];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.secondsLeftForSearch = 30;
    self.shouldNotify = YES;
    
    [ESTConfig setupAppID:@"CrowdFound" andAppToken:@"2c138ec1f40d00cbaebd2aaac6cf09a8"];
    if([ESTConfig isAuthorized])
        NSLog(@"estimote beacon authorized.");
    
    self.locationBuilder = [ESTLocationBuilder new];
    
//TODO: should change the beacon configuration
    [self.locationBuilder setLocationBoundaryPoints:@[
                                                       [ESTPoint pointWithX:0 y:0],
                                                       [ESTPoint pointWithX:0 y:4],
                                                       [ESTPoint pointWithX:6 y:4],
                                                       [ESTPoint pointWithX:6 y:0]]];
    [self.locationBuilder setLocationOrientation:0];

    
    [self.locationBuilder addBeaconIdentifiedByMac:@"d716de514672" atBoundarySegmentIndex:0 inDistance:2 fromSide:ESTLocationBuilderLeftSide];
    [self.locationBuilder addBeaconIdentifiedByMac:@"fb0ebaacd25c" atBoundarySegmentIndex:1 inDistance:3 fromSide:ESTLocationBuilderLeftSide];
    [self.locationBuilder addBeaconIdentifiedByMac:@"d4e4f58e3f25" atBoundarySegmentIndex:2 inDistance:2 fromSide:ESTLocationBuilderLeftSide];
    [self.locationBuilder addBeaconIdentifiedByMac:@"f3b61bf06f84" atBoundarySegmentIndex:3 inDistance:3 fromSide:ESTLocationBuilderLeftSide];

    self.indoorLocation = [self.locationBuilder build];
    
    self.indoorManager = [[ESTIndoorLocationManager alloc]init];
    self.indoorManager.delegate = self;
    [self.indoorManager startIndoorLocation:self.indoorLocation];
    
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    self.locationManager.distanceFilter = 1;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
//    [self.locationManager startUpdatingHeading];
    
    CLLocationCoordinate2D regionTech; //region tech
    regionTech.latitude = 42.058367;
    regionTech.longitude =  -87.677950;
    
    CLLocationCoordinate2D fordCoordinate; //region ford
    fordCoordinate.latitude = 42.056750; //42.057002;
    fordCoordinate.longitude = -87.676997; //-87.676985;
    
    self.regionFord = [[CLCircularRegion alloc] initWithCenter:fordCoordinate radius:150 identifier:@"regionFord"];
    [self.locationManager startMonitoringForRegion: self.regionFord];
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object[@"group"]) {
                self.group = @"a";
                object[@"group"] = self.group;
            }
            else
                self.group = object[@"group"];
            NSLog(@"%@",self.group);
            NSDate *lastNotifiedDate = object[@"lastNotified"];
            if (lastNotifiedDate == NULL) {
                self.shouldNotify = YES;
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
                if (components.day >= 1) {
                    self.shouldNotify = YES;
                    NSLog(@"more than a day, so notify");
                } else if (components.day < 1 && components.hour >= 3 ) {
                    NSLog(@"more than 4 hours, notify too");
                    self.shouldNotify = YES;
                } else {
                    NSLog(@"do not notify");
                    //TODO: uncomment this
                    self.shouldNotify = NO;
                }
            }
            [self appUsageLogging:@"view did appear"];
        }
    }];    
}

- (void)showThanksAlertview: (NSTimer *)timer{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:@"Thanks for looking the item. Have you found the item?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles: @"NO", nil];
    [alert show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* newLocation = [locations lastObject];

    if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 65.0) return;   // ignore invalid udpates

    NSTimeInterval age = -[newLocation.timestamp timeIntervalSinceNow];
    if (age > 20) return;    // ignore old (cached) updates
    
    //    NSTimeInterval age = -[newLocation.timestamp timeIntervalSinceNow];
    //
    //    if (age > 120) return;    // ignore old (cached) updates
    
    //    // EDIT: need a valid oldLocation to be able to compute distance
    //    if (self.oldLocation == nil || self.oldLocation.horizontalAccuracy < 0) {
    //        self.oldLocation = newLocation;
    //        return;
    //    }
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = newLocation.coordinate.latitude;
    coordinate.longitude = newLocation.coordinate.longitude;
    
    CLLocationCoordinate2D fordCoordinate; //region ford
    fordCoordinate.latitude = 42.056750;
    fordCoordinate.longitude =  -87.676997;
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:fordCoordinate.latitude longitude:fordCoordinate.longitude];

    CLLocationDistance distance = [newLocation distanceFromLocation:loc];

//    [self locationLoggingLatitude:[NSNumber numberWithFloat:newLocation.coordinate.latitude] Longitude: [NSNumber numberWithFloat:newLocation.coordinate.longitude] Accuracy: [NSNumber numberWithFloat:newLocation.horizontalAccuracy]];
    
    if ([self.group isEqualToString:@"a"]) {
        if (distance <=20.0) {
            if(self.shouldNotify) {
                NSLog(@"distance: %f", distance);
                [self sendNotification];
                [self appUsageLogging:[NSString stringWithFormat:@"%@ notification at %f, %f\rdistance is: %f", self.group, newLocation.coordinate.latitude, newLocation.coordinate.longitude, distance]];
                self.shouldNotify = NO;
            }
        }
    } else {
        if (distance <=40.0) {
            if(self.shouldNotify) {
                NSLog(@"distance: %f", distance);
                [self sendNotification];
                [self appUsageLogging:[NSString stringWithFormat:@"%@ notification at %f, %f\rdistance is: %f", self.group, newLocation.coordinate.latitude, newLocation.coordinate.longitude, distance]];
                self.shouldNotify = NO;
            }
        }
//        else if (distance>40) {
////            [self appUsageLogging:[NSString stringWithFormat:@"%@ notification at %f, %f\rdistance is: %f", self.group, newLocation.coordinate.latitude, newLocation.coordinate.longitude, distance]];
//            NSLog(@"location logging");
//            [self locationLoggingLatitude: [NSNumber numberWithFloat:newLocation.coordinate.latitude] Longitude: [NSNumber numberWithFloat:newLocation.coordinate.longitude] Accuracy: [NSNumber numberWithFloat:newLocation.horizontalAccuracy]];
//        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
//    [self testEnterNotification:region.identifier];
    if ([region.identifier isEqualToString:@"regionFord"]) {
//        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.distanceFilter = 1;
        NSLog(@"entered ROI");
        self.enteredROI = YES;
        [self appUsageLogging: [NSString stringWithFormat:@"entered region with desired accuracy of :%f", self.locationManager.desiredAccuracy]];
    }
    
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object[@"group"]) {
                self.group = @"a";
                object[@"group"] = self.group;
            }
            else
                self.group = object[@"group"];
            NSLog(@"%@",self.group);
            NSDate *lastNotifiedDate = object[@"lastNotified"];
            if (lastNotifiedDate == NULL) {
                self.shouldNotify = YES;
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
                if (components.day >= 1) {
                    self.shouldNotify = YES;
                    NSLog(@"more than a day, so notify");
                } else if (components.day < 1 && components.hour >= 3 ) {
                    NSLog(@"more than 4 hours, notify too");
                    self.shouldNotify = YES;
                } else {
                    NSLog(@"do not notify");
                    //TODO: uncomment this
                    self.shouldNotify = NO;
                }
            }
            [self appUsageLogging:@"view did appear"];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"regionFord"]) {
//        [self.locationManager stopUpdatingLocation];
//        [self.locationManager startMonitoringSignificantLocationChanges];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        self.locationManager.distanceFilter = 80;
        //FIXME: remove self.shouldNotify
        self.shouldNotify = YES;
        NSLog(@"exited ROI");
//        [self testExitNotification:region.identifier];
        [self appUsageLogging: [NSString stringWithFormat:@"exited region with desired accuracy of :%f", self.locationManager.desiredAccuracy]];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return NO;
}

- (void)locationLoggingLatitude:(NSNumber *)latitude Longitude:(NSNumber *)longitude Accuracy:(NSNumber *)accuracy {
    PFObject *location = [PFObject objectWithClassName:@"Location"];
    NSDate *currentDate = [NSDate date];
    if (latitude==NULL)
        return;
    location[@"username"] = [MyUser currentUser].username;
    location[@"latitude"] = [NSString stringWithFormat:@"%f", [latitude floatValue]];
    location[@"longitude"] = [NSString stringWithFormat:@"%f", [longitude floatValue]];
    location[@"accuracy"] = [NSString stringWithFormat:@"%f", [accuracy floatValue]];
    location[@"userDate"] = currentDate;
    [location saveInBackground];
}

- (void)appUsageLogging: (NSString *)activity {
    if (activity == NULL) {
        return;
    }
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    usage[@"clientDate"] = [NSDate date];
    [usage saveInBackground];
}


- (void)sendNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    //    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
    //    localNotif.userInfo = dictionary;
    localNotif.alertBody = [NSString stringWithFormat:@"Can you please look for %@ that I lost %@? --%@", [self.request valueForKeyPath:@"item"], [self.request valueForKeyPath:@"locationDetail"], [self.request valueForKeyPath:@"username"]];
    localNotif.alertAction = @"Slide to see the lost item and location details";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    if (localNotif) {
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        
        //TODO: after 3 minutes, change desiredAccuracy to Ten meters to prevent battery leak.
//        [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(changeDesiredAccuracy:) userInfo:nil repeats:NO];

        PFQuery *query = [MyUser query];
        [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            if (!error) {
                NSDate *date = [NSDate date];
                object[@"lastNotified"] = date;
                [object saveInBackground];
            } else {
                NSLog(@"ERROR!");
            }
        }];
    }
}


- (void)testEnterNotification: (NSString *)name
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.alertBody = [NSString stringWithFormat:@"Entered: %@", name];
    localNotif.alertAction = @"Testing notification based on regions";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    if (localNotif) {
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

- (void)testExitNotification: (NSString *)name
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.alertBody = [NSString stringWithFormat:@"Exited: %@", name];
    localNotif.alertAction = @"Testing notification based on regions";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    if (localNotif) {
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

- (void)changeDesiredAccuracy: (NSTimer *)timer {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    NSLog(@"heading: %f",newHeading.magneticHeading);
//}

//-(void)indoorLocationManager:(ESTIndoorLocationManager *)manager didUpdatePosition:(ESTOrientedPoint *)position withAccuracy:(ESTPositionAccuracy)positionAccuracy inLocation:(ESTLocation *)location {
//    NSString *str = [NSString stringWithFormat:@"position: %f, %f", position.x, position.y];
//    NSLog(@"position is: %@",str);
////    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:str delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
////    [alert show];
//}

//-(void)indoorLocationManager:(ESTIndoorLocationManager *)manager didFailToUpdatePositionWithError:(NSError *)error
//{
////    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:error.description delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
////    [alert show];
//    if (error.code == ESTIndoorPositionOutsideLocationError)
//    {
//        NSLog(@"It seems you are not in this location.");
//    }
//    else if (error.code == ESTIndoorMagnetometerInitializationError)
//    {
//        NSLog(@"It seems your magnetometer is not working.");
//    }
//    NSLog(@"%@", error.localizedDescription);
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"RouteViewSegue"]) {
        RouteViewController *rvc = [segue destinationViewController];
        rvc.request = self.request;
    }
    
}


@end
