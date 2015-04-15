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
#define mySession [MySession sharedManager]

@interface HelperDetailViewController () <CLLocationManagerDelegate>
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


@property BOOL notified;

@end

@implementation HelperDetailViewController
@synthesize didGetNotif;

- (IBAction)helpButton:(UIButton *)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:@"Thanks for finding the item!" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
    
    //testing!!!!!!!!!!!
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            CLLocation *newLocation =[[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            CLLocationDistance distance = [newLocation distanceFromLocation: self.oldLocation];
            NSString *locationCoordinate = [NSString stringWithFormat:@"found at %f, %f", geoPoint.latitude, geoPoint.longitude];

            PFQuery *query = [PFQuery queryWithClassName:@"Request"];
            NSLog(@"Request ID: %@", [self.request valueForKeyPath:@"objectId"]);
            
            [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
                
                if (!error) {
                    int first = [[object valueForKeyPath:@"first"]intValue];
                    int second = [[object valueForKeyPath:@"second"]intValue];
                    int third = [[object valueForKeyPath:@"third"]intValue];
                    int fourth = [[object valueForKeyPath:@"fourth"]intValue];
                    int fifth = [[object valueForKeyPath:@"fifth"]intValue];
                    
                    NSLog(@"%d, %d, %d, %d, %d",first, second, third, fourth, fifth);
                    if ([self.group isEqualToString:@"c"]){
                        if (self.enteredNoyes) {
                            if (distance>=20) {
                                int value = [object[@"first"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"first"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];

                            } else if (distance>=90) {
                                int value = [object[@"second"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"second"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];

                            } else if (distance>=150) {
                                int value = [object[@"third"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"third"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];

                            } else if (distance>=260){
                                int value = [object[@"fourth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fourth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];

                            } else if (distance>=300) {
                                int value = [object[@"fifth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fifth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];
                            }
                        }
                        
                        if (self.enteredTech) {
                            if (distance>=20){
                                int value = [object[@"fifth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fifth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];

                                
                            } else if (distance>=90) {
                                int value = [object[@"fourth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fourth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];

                            } else if (distance>=150) {
                                int value = [object[@"third"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"third"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];

                                
                            } else if (distance>=220) {
                                int value = [object[@"second"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"second"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];

                            } else if (distance >=300) {
                                int value = [object[@"first"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"first"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];

                            }
                        }
                    } else if ([self.group isEqualToString:@"b"] || [self.group isEqualToString:@"a"]) {
                        CLLocationCoordinate2D region1; //region 1
                        region1.latitude = 42.058430;
                        region1.longitude = -87.682089;
                        
                        CLLocationCoordinate2D region2; //region 2
                        region2.latitude = 42.058405;
                        region2.longitude =  -87.680936;
                        
                        CLLocationCoordinate2D region3; //region 3
                        region3.latitude = 42.058389;
                        region3.longitude =  -87.680139;
                        
                        CLLocationCoordinate2D region4; //region 4
                        region4.latitude = 42.058385;
                        region4.longitude =  -87.679187;
                        
                        CLLocationCoordinate2D region5; //region 5
                        region5.latitude = 42.058381;
                        region5.longitude =  -87.678396;
                        
                        CLLocationCoordinate2D region6; //region tech
                        region6.latitude = 42.058375;
                        region6.longitude =  -87.677574;
                        
                        CLCircularRegion *regionOne = [[CLCircularRegion alloc] initWithCenter:region1 radius:20 identifier:@"Region1"];
//                        [self.locationManager startMonitoringForRegion: regionOne];
                        
                        CLCircularRegion *regionTwo = [[CLCircularRegion alloc] initWithCenter:region2 radius:20 identifier:@"Region2"];
//                        [self.locationManager startMonitoringForRegion: regionTwo];
                        
                        CLCircularRegion *regionThree = [[CLCircularRegion alloc] initWithCenter:region3 radius:20 identifier:@"Region3"];
//                        [self.locationManager startMonitoringForRegion: regionThree];
                        
                        CLCircularRegion *regionFour = [[CLCircularRegion alloc] initWithCenter:region4 radius:20 identifier:@"Region4"];
//                        [self.locationManager startMonitoringForRegion: regionFour];
                        
                        CLCircularRegion *regionFive = [[CLCircularRegion alloc] initWithCenter:region5 radius:20 identifier:@"Region5"];
//                        [self.locationManager startMonitoringForRegion: regionFive];
                        CLLocationCoordinate2D coordinate;
                        coordinate.latitude = geoPoint.latitude;
                        coordinate.longitude = geoPoint.longitude;
                        if ([regionOne containsCoordinate:coordinate]) {
                            int value = [object[@"first"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"first"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];

                        } else if ([regionTwo containsCoordinate:coordinate]) {
                            int value = [object[@"second"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"second"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];

                        } else if ([regionThree containsCoordinate:coordinate]) {
                            int value = [object[@"third"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"third"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];

                        } else if ([regionFour containsCoordinate:coordinate]) {
                            int value = [object[@"fourth"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"fourth"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];

                        } else if ([regionFive containsCoordinate:coordinate]) {
                            int value = [object[@"fifth"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"fifth"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];

                        } else {
                        }
                    } else {
                    }
                    object[@"helper"] = [PFUser currentUser].username;
                    object[@"helperId"] = [PFUser currentUser].objectId;
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    array = object[@"helpers"];
                    [array addObject:[PFUser currentUser].objectId];
                    object[@"helpers"] = array;
                    if(!self.helped){
                        int value = [object[@"helpCount"] intValue];
                        NSNumber *helpCount = [NSNumber numberWithInt:value+1];
                        object[@"helpCount"] = helpCount;
                    }
                    [object saveInBackground];
                    self.helped = YES;
                } else {
                    NSLog(@"ERROR!");
                }
            }];
            self.greyOverlay.hidden = true;
            self.blueOverlay.hidden = true;
            self.foundLabel.hidden =true;
            self.notFoundLabel.hidden = true;
            [mySession setDidGetNotif:NO];
            self.didGetNotif = NO;
        }
    }];

}

//Help fail count
- (IBAction)noButton:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:@"Thanks for your time!" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            CLLocation *newLocation =[[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            CLLocationDistance distance = [newLocation distanceFromLocation: self.oldLocation];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Request"];
            NSLog(@"Request ID: %@", [self.request valueForKeyPath:@"objectId"]);
            NSString *locationCoordinate = [NSString stringWithFormat:@"failed at %f, %f", geoPoint.latitude, geoPoint.longitude];
            [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
                
                if (!error) {
                    int first = [[object valueForKeyPath:@"first"]intValue];
                    int second = [[object valueForKeyPath:@"second"]intValue];
                    int third = [[object valueForKeyPath:@"third"]intValue];
                    int fourth = [[object valueForKeyPath:@"fourth"]intValue];
                    int fifth = [[object valueForKeyPath:@"fifth"]intValue];
                    
                    NSLog(@"%d, %d, %d, %d, %d",first, second, third, fourth, fifth);
                    if ([self.group isEqualToString:@"c"]){
                        if (self.enteredNoyes) {
                            if (distance>=20) {
                                int value = [object[@"first"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"first"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];
                            } else if (distance>=90) {
                                int value = [object[@"second"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"second"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];
                            } else if (distance>=150) {
                                int value = [object[@"third"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"third"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];
                            } else if (distance>=260){
                                int value = [object[@"fourth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fourth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];
                            } else if (distance>=300) {
                                int value = [object[@"fifth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fifth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];
                            }
                        }
                        
                        if (self.enteredTech) {
                            if (distance>=20){
                                int value = [object[@"fifth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fifth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];
                            } else if (distance>=90) {
                                int value = [object[@"fourth"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"fourth"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];
                            } else if (distance>=150) {
                                int value = [object[@"third"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"third"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];

                            } else if (distance>=220) {
                                int value = [object[@"second"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"second"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];

                            } else if (distance >=300) {
                                int value = [object[@"first"] intValue];
                                NSNumber *count = [NSNumber numberWithInt:value+1];
                                object[@"first"] = count;
                                [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];

                            }
                        }
                    } else if ([self.group isEqualToString:@"b"] || [self.group isEqualToString:@"a"]) {
                        CLLocationCoordinate2D region1; //region 1
                        region1.latitude = 42.058430;
                        region1.longitude = -87.682089;
                        
                        CLLocationCoordinate2D region2; //region 2
                        region2.latitude = 42.058405;
                        region2.longitude =  -87.680936;
                        
                        CLLocationCoordinate2D region3; //region 3
                        region3.latitude = 42.058389;
                        region3.longitude =  -87.680139;
                        
                        CLLocationCoordinate2D region4; //region 4
                        region4.latitude = 42.058385;
                        region4.longitude =  -87.679187;
                        
                        CLLocationCoordinate2D region5; //region 5
                        region5.latitude = 42.058381;
                        region5.longitude =  -87.678396;
                        
                        CLLocationCoordinate2D region6; //region tech
                        region6.latitude = 42.058375;
                        region6.longitude =  -87.677574;
                        
                        CLCircularRegion *regionOne = [[CLCircularRegion alloc] initWithCenter:region1 radius:20 identifier:@"Region1"];
                        //                        [self.locationManager startMonitoringForRegion: regionOne];
                        
                        CLCircularRegion *regionTwo = [[CLCircularRegion alloc] initWithCenter:region2 radius:20 identifier:@"Region2"];
                        //                        [self.locationManager startMonitoringForRegion: regionTwo];
                        
                        CLCircularRegion *regionThree = [[CLCircularRegion alloc] initWithCenter:region3 radius:20 identifier:@"Region3"];
                        //                        [self.locationManager startMonitoringForRegion: regionThree];
                        
                        CLCircularRegion *regionFour = [[CLCircularRegion alloc] initWithCenter:region4 radius:20 identifier:@"Region4"];
                        //                        [self.locationManager startMonitoringForRegion: regionFour];
                        
                        CLCircularRegion *regionFive = [[CLCircularRegion alloc] initWithCenter:region5 radius:20 identifier:@"Region5"];
                        //                        [self.locationManager startMonitoringForRegion: regionFive];
                        CLLocationCoordinate2D coordinate;
                        coordinate.latitude = geoPoint.latitude;
                        coordinate.longitude = geoPoint.longitude;
                        if ([regionOne containsCoordinate:coordinate]) {
                            int value = [object[@"first"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"first"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region first", locationCoordinate]];

                        } else if ([regionTwo containsCoordinate:coordinate]) {
                            int value = [object[@"second"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"second"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region second", locationCoordinate]];

                        } else if ([regionThree containsCoordinate:coordinate]) {
                            int value = [object[@"third"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"third"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region third", locationCoordinate]];

                        } else if ([regionFour containsCoordinate:coordinate]) {
                            int value = [object[@"fourth"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"fourth"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fourth", locationCoordinate]];

                        } else if ([regionFive containsCoordinate:coordinate]) {
                            int value = [object[@"fifth"] intValue];
                            NSNumber *count = [NSNumber numberWithInt:value+1];
                            object[@"fifth"] = count;
                            [self appUsageLogging: [NSString stringWithFormat:@"%@; Region fifth", locationCoordinate]];

                        } else {
                        }
                    } else {
                    }
                    object[@"helper"] = [PFUser currentUser].username;
                    object[@"helperId"] = [PFUser currentUser].objectId;
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    array = object[@"helpers"];
                    [array addObject:[PFUser currentUser].objectId];
                    object[@"helpers"] = array;
                    if(!self.helped){
                        int value = [object[@"helpCount"] intValue];
                        NSNumber *helpCount = [NSNumber numberWithInt:value+1];
                        object[@"helpCount"] = helpCount;
                    }
                    [object saveInBackground];
                    self.helped = YES;
                } else {
                    NSLog(@"ERROR!");
                }
            }];
            self.greyOverlay.hidden = true;
            self.blueOverlay.hidden = true;
            self.foundLabel.hidden =true;
            self.notFoundLabel.hidden = true;
            [mySession setDidGetNotif:NO];
            self.didGetNotif = NO;
        }
    }];

    self.greyOverlay.hidden = true;
    self.blueOverlay.hidden = true;
    self.foundLabel.hidden = true;
    self.notFoundLabel.hidden = true;
//    [mySession setDidGetNotif:NO];
    self.didGetNotif = NO;

}

- (void)fillDetails
{
    self.item.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"item"]];
    [self.item sizeToFit];
    self.locationDetail.numberOfLines = 3;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude: [[self.request valueForKeyPath:@"lat"] floatValue]
                                                longitude: [[self.request valueForKeyPath:@"lng"] floatValue]];
    
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            self.location.text = [NSString stringWithFormat:@"%f, %f", [[self.request valueForKeyPath:@"lat"] floatValue], [[self.request valueForKeyPath:@"lng"] floatValue]];
            return;
            
        }
        if(placemarks && placemarks.count > 0)
        {
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            NSString *addressTxt = [NSString stringWithFormat:@"%@ %@,%@ %@",
                                    [topResult subThoroughfare],[topResult thoroughfare],
                                    [topResult locality], [topResult administrativeArea]];
            NSLog(@"%@",addressTxt);
            self.location.text = [NSString stringWithFormat:@"%@", addressTxt];
            [self.location sizeToFit];
        }
    }];
    //    self.location.text = [NSString stringWithFormat:@"%f, %f", [[self.request valueForKeyPath:@"lat"] floatValue], [[self.request valueForKeyPath:@"lng"] floatValue]];
    self.locationDetail.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"locationDetail"]];
    [self.locationDetail sizeToFit];
    NSArray *arr = [[self.request valueForKeyPath:@"detail"] componentsSeparatedByString:@" "];
    NSMutableArray *muarr = [[NSMutableArray alloc]init];
    for(int i = 1; i <= [arr count]; i++) {
        if(i%6!=0)
        {
            [muarr addObject:arr[i-1]];
            [muarr addObject:@" "];
        }else{
            [muarr addObject:arr[i-1]];
            [muarr addObject:@" \n"];
        }
    }
    NSString *detailstring = [muarr componentsJoinedByString:@""];
    
    self.itemDescription.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"detail"]];
    self.itemDescription.text = [NSString stringWithFormat:@"%@", detailstring];
    [self.itemDescription sizeToFit];
    self.helperNumber.text = [NSString stringWithFormat:@"Helper number: %d", [[self.request valueForKeyPath:@"helpCount"] intValue]];
    self.helperFailNumber.text = [NSString stringWithFormat:@"Number of Helper couldn't find: %d", [[self.request valueForKeyPath:@"helpFailCount"] intValue]];
    // Do any additional setup after loading the view.
    
    PFQuery *query = [PFQuery queryWithClassName: @"Request"];
    [query whereKey:@"objectId" equalTo:[self.request valueForKeyPath:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if([objects count]>0){
                self.request = objects[0];
                PFFile *imageFile = objects[0][@"image"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(!error) {
                        UIImage *image = [UIImage imageWithData: data];
                        self.imageView.image = image;
                        NSLog(@"image!");
                        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                    }
                }];
            }
            
        }
    }];

}

- (void)appDidEnterForeground {
//    [mySession setHdvc:self];
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            //            int notifCount = [object[@"notifNum"] intValue];
            //            NSLog(@"%d", notifCount);
            //            NSNumber *value = [NSNumber numberWithInt:notifCount+1];
            if (!object[@"group"]) {
                self.group = @"a";
                object[@"group"] = self.group;
            }
            else
                self.group = object[@"group"];
            NSLog(@"%@",self.group);
            [self appUsageLogging:self.group];
        }
    }];
    
    if (self.didGetNotif) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                self.oldLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                [self appUsageLogging: [NSString stringWithFormat:@"App open %f, %f", geoPoint.latitude, geoPoint.longitude]];
                //            self.lat = geoPoint.latitude;
                //            self.lng = geoPoint.longitude;
                //            [self getHeadingForDirectionFromCoordinate:oldLoc toCoordinate:plex];
            }
        }];
        self.greyOverlay.hidden = false;
        self.blueOverlay.hidden = false;
        self.foundLabel.hidden =false;
        self.notFoundLabel.hidden = false;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [mySession setHdvc:self];
//    if (self.didGetNotif) {
//        self.greyOverlay.hidden = false;
//        self.blueOverlay.hidden = false;
//        self.foundLabel.hidden =false;
//        self.notFoundLabel.hidden = false;
//    }
    //group a = baseline
    //group b = history
    //group c = pretracking + history
//    self.group = @"b";
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            //            int notifCount = [object[@"notifNum"] intValue];
            //            NSLog(@"%d", notifCount);
            //            NSNumber *value = [NSNumber numberWithInt:notifCount+1];
            if (!object[@"notification"]) {
                self.group = @"a";
                object[@"group"] = self.group;
            }
            else
                self.group = object[@"group"];
//            [self appUsageLogging:self.group];
//            NSDate *lastNotifiedDate = object[@"lastNotified"];
//            NSLog(@"%@", lastNotifiedDate);
//            NSDate *currentDate = [NSDate date];
//            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
//                                                       fromDate:lastNotifiedDate
//                                                         toDate:currentDate
//                                                        options:0];
//            NSLog(@"Difference in date components: %i/%i/%i", components.minute, components.hour, components.day);
            [object saveInBackground];
        } else {
            NSLog(@"ERROR!");
        }
    }];
//
//    PFQuery *requestQuery = [PFQuery queryWithClassName: @"Request"];
//    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
//            NSMutableArray *object = [[NSMutableArray alloc]init];
//            object = [objects firstObject];
//            
//            NSString * region      = @"region";
//            NSString * count   = @"count";
//            
//            NSMutableArray * array = [NSMutableArray array];
//            
//            NSDictionary * dict;
//            dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                    @"first", region, [object valueForKeyPath:@"first"], count, nil];
//            [array addObject:dict];
//            
//            dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                    @"second", region, [object valueForKeyPath:@"second"], count, nil];
//            [array addObject:dict];
//
//            dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                    @"third", region, [object valueForKeyPath:@"third"], count, nil];
//            [array addObject:dict];
//
//            dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                    @"fourth", region, [object valueForKeyPath:@"fourth"], count, nil];
//            [array addObject:dict];
//
//            dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                    @"fifth", region, [object valueForKeyPath:@"fifth"], count, nil];
//            [array addObject:dict];
//
//            
//            NSSortDescriptor * frequencyDescriptor = [[NSSortDescriptor alloc] initWithKey:count ascending:YES];
//            
//            id obj;
//            NSEnumerator * enumerator = [array objectEnumerator];
////            while ((obj = [enumerator nextObject])) NSLog(@"%@", obj);
//            
//            NSArray * descriptors =
//            [NSArray arrayWithObjects:frequencyDescriptor, nil];
//            NSArray * sortedArray =
//            [array sortedArrayUsingDescriptors:descriptors];
//            
//            NSLog(@"\nSorted ...");
//            
//            enumerator = [sortedArray objectEnumerator];
//            while ((obj = [enumerator nextObject])) NSLog(@"%@", obj);
//
//        }
//    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [mySession setHdvc:self];
    if ([mySession didGetNotif]) {
        self.greyOverlay.hidden = false;
        self.blueOverlay.hidden = false;
        self.foundLabel.hidden =false;
        self.notFoundLabel.hidden = false;
    }
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    //    [self.locationManager requestAlwaysAuthorization];
    //    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 30;
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D region0; //region noyes
    region0.latitude = 42.058444;
    region0.longitude = -87.683134;
    
    CLLocationCoordinate2D region1; //region 1
    region1.latitude = 42.058430;
    region1.longitude = -87.682089;
    
    CLLocationCoordinate2D region2; //region 2
    region2.latitude = 42.058405;
    region2.longitude =  -87.680936;
    
    CLLocationCoordinate2D region3; //region 3
    region3.latitude = 42.058389;
    region3.longitude =  -87.680139;
    
    CLLocationCoordinate2D region4; //region 4
    region4.latitude = 42.058385;
    region4.longitude =  -87.679187;
    
    CLLocationCoordinate2D region5; //region 5
    region5.latitude = 42.058381;
    region5.longitude =  -87.678396;
    
    CLLocationCoordinate2D region6; //region tech
    region6.latitude = 42.058375;
    region6.longitude =  -87.677574;
    
    
    CLCircularRegion *regionNoyes = [[CLCircularRegion alloc] initWithCenter:region0 radius:50 identifier:@"RegionNoyes"];
    [self.locationManager startMonitoringForRegion: regionNoyes];
    
    CLCircularRegion *regionOne = [[CLCircularRegion alloc] initWithCenter:region1 radius:50 identifier:@"Region1"];
    [self.locationManager startMonitoringForRegion: regionOne];
    
    CLCircularRegion *regionTwo = [[CLCircularRegion alloc] initWithCenter:region2 radius:50 identifier:@"Region2"];
    [self.locationManager startMonitoringForRegion: regionTwo];
    
    CLCircularRegion *regionThree = [[CLCircularRegion alloc] initWithCenter:region3 radius:50 identifier:@"Region3"];
    [self.locationManager startMonitoringForRegion: regionThree];
    
    CLCircularRegion *regionFour = [[CLCircularRegion alloc] initWithCenter:region4 radius:50 identifier:@"Region4"];
    [self.locationManager startMonitoringForRegion: regionFour];
    
    CLCircularRegion *regionFive = [[CLCircularRegion alloc] initWithCenter:region5 radius:50 identifier:@"Region5"];
    [self.locationManager startMonitoringForRegion: regionFive];
    
    CLCircularRegion *regionTech = [[CLCircularRegion alloc] initWithCenter:region6 radius:50 identifier:@"RegionTech"];
    [self.locationManager startMonitoringForRegion: regionTech];
    
    CLCircularRegion *regionCenter = [[CLCircularRegion alloc] initWithCenter:region3 radius:300 identifier:@"RegionCenter"];
    [self.locationManager startMonitoringForRegion: regionCenter];
    
    
    PFQuery *query = [PFQuery queryWithClassName: @"Request"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            self.request = [objects firstObject];
//            CLLocationCoordinate2D regionA; //Foster Walker
//            regionA.latitude = [(NSString *)[self.request valueForKeyPath:@"lat"] floatValue];
//            regionA.longitude = [(NSString *)[self.request valueForKeyPath:@"lng"] floatValue];
//            
//            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:regionA radius:50 identifier:@"RegionA"];
//            [self.locationManager startMonitoringForRegion: region];
//            
//            CLLocationCoordinate2D regionB; //Foster Walker
//            regionB.latitude = [(NSString *)[self.request valueForKeyPath:@"lat2"] floatValue];
//            regionB.longitude = [(NSString *)[self.request valueForKeyPath:@"lng2"] floatValue];
//            
//            CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:regionB radius:50 identifier:@"RegionB"];
//            [self.locationManager startMonitoringForRegion: region2];
            [self fillDetails];
        }
    }];
    
//    if([self.request valueForKeyPath:@"item"] == NULL) {
//        NSLog(@"it is empty! ID is %@", self.objectId);
//        PFQuery *query = [PFQuery queryWithClassName: @"Request"];
//        [query whereKey:@"objectId" equalTo:self.objectId];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if(!error){
//                if([objects count]>0){
//                    self.request = objects[0];
//                    NSLog(@"%@", [self.request valueForKeyPath:@"item"]);
//                    [self fillDetails];
//                }
//                
//            }
//        }];
//    } else {
//        NSLog(@"not empty!");
//        [self fillDetails];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([self.group isEqualToString:@"c"]) {
        //    NSLog(@"here!!!!!!!");
        CLLocation* newLocation = [locations lastObject];
        
        NSTimeInterval age = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (age > 120) return;    // ignore old (cached) updates
        
        //    NSTimeInterval age = -[newLocation.timestamp timeIntervalSinceNow];
        //
        //    if (age > 120) return;    // ignore old (cached) updates
        
        if (newLocation.horizontalAccuracy < 0) return;   // ignore invalid udpates
        
        //    // EDIT: need a valid oldLocation to be able to compute distance
        //    if (self.oldLocation == nil || self.oldLocation.horizontalAccuracy < 0) {
        //        self.oldLocation = newLocation;
        //        return;
        //    }
        
        //    NSLog(@"%f", newLocation.coordinate.longitude);
        CLLocationDistance distance = [newLocation distanceFromLocation: self.oldLocation];
//        int middlePoint = [[self.request valueForKeyPath:@"middlePoint"] intValue];
//        
//        int firstQuarterPoint = [[self.request valueForKeyPath:@"firstQuarterPoint"] intValue];
//        
//        int thirdQuarterPoint = [[self.request valueForKeyPath:@"thirdQuarterPoint"] intValue];
//        
//        NSLog(@"distance: %f", distance);
//        NSLog(@"first quarter: %d", firstQuarterPoint);
//        NSLog(@"middle quarter: %d", middlePoint);
//        NSLog(@"third quarter: %d", thirdQuarterPoint);
//        
//        int first = [[self.request valueForKeyPath:@"first"]intValue];
//        int second = [[self.request valueForKeyPath:@"second"]intValue];
//        int third = [[self.request valueForKeyPath:@"third"]intValue];
//        
//        
//        if ([self.enteredRegion isEqualToString:@"RegionA"] && !self.notified) {
//            //if # is the same, Middle, First, Third order
//            if (second <=first || second <= third) {
//                if (distance >= middlePoint && distance < thirdQuarterPoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Middle Point!" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"middle";
//                    self.notified = YES;
//                }
//            }
//            else if (first < second && first <= third) {
//                if (distance>= firstQuarterPoint && distance < middlePoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"first Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"first";
//                    self.notified = YES;
//                }
//            }
//            else if (third < second && third < first) {
//                if (distance >= thirdQuarterPoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"third Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"third";
//                    self.notified = YES;
//                }
//            }
//        } else if ([self.enteredRegion isEqualToString:@"RegionB"] && !self.notified){
//            if (second <=first || second <= third) {
//                if (distance >= middlePoint && distance < thirdQuarterPoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Middle Point!" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"middle";
//                    self.notified = YES;
//                }
//            }
//            else if (third < second && third < first) {
//                if (distance>= firstQuarterPoint && distance < middlePoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"third Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"third";
//                    self.notified = YES;
//                }
//            }
//            else if (first < second && first < third) {
//                if (distance >= thirdQuarterPoint) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"first Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                    [alert show];
//                    self.region = @"first";
//                    self.notified = YES;
//                }
//            }
//        }

        
        PFQuery *requestQuery = [PFQuery queryWithClassName: @"Request"];
        [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                NSMutableArray *object = [[NSMutableArray alloc]init];
                object = [objects firstObject];
                
                int first = [[object valueForKeyPath:@"first"]intValue];
                int second = [[object valueForKeyPath:@"second"]intValue];
                int third = [[object valueForKeyPath:@"third"]intValue];
                int fourth = [[object valueForKeyPath:@"fourth"]intValue];
                int fifth = [[object valueForKeyPath:@"fifth"]intValue];
                
                NSLog(@"%d, %d, %d, %d, %d",first, second, third, fourth, fifth);
                
                if (self.enteredNoyes) {
                    if (!self.notified) {
                        if (first<=second && first<=third && first<=fourth &&first<=fifth && !self.notified) {
                            if (distance>=20) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"first" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region first", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (second < first && second <= third && second <=fourth && second <= fifth ) {
                            if (distance>=90) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"second" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region second", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (third < first && third < second && third <= fourth && third <= fifth ) {
                            if (distance>=150) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"third" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region third", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (fourth < first && fourth < second && fourth < third && fourth <= fifth ) {
                            if (distance>=260){
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"fourth" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region fourth", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }

                        } else if (fifth < fourth && fifth < first && fifth < second && fifth < third ){
                            if (distance>=300) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"fifth" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region fifth", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        }
                    }
                }
                
                if (self.enteredTech) {
                    if (!self.notified) {
                        if (fifth<=second && fifth<=third && fifth<=fourth &&fifth<=first) {
                            if (distance>=20) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"fifth" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region fifth", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (fourth < fifth && fourth <= third && fourth <=second && fourth <= first) {
                            if (distance>=90) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region fourth", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (third < fifth && third < fourth && third <= second && third <= first) {
                            if (distance>=150) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region third", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }

                        } else if (second < fifth && second < fourth && second < third && second <= first) {
                            if (distance>=220) {
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region second", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        } else if (first < fifth && first < fourth && fifth < third && fifth < second){
                            if (distance >=300) {
                                
                                [self testNotif];

//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"distance: %f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                                [alert show];
                                self.notified = YES;
                                [self appUsageLogging:[NSString stringWithFormat:@"notification at %f, %f; Region first", newLocation.coordinate.latitude, newLocation.coordinate.longitude]];

                            }
                        }
                    }
                }
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    PFQuery *query = [MyUser query];
    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            //            int notifCount = [object[@"notifNum"] intValue];
            //            NSLog(@"%d", notifCount);
            //            NSNumber *value = [NSNumber numberWithInt:notifCount+1];
            if (!object[@"group"]) {
                self.group = @"a";
                object[@"group"] = self.group;
            }
            else
                self.group = object[@"group"];
        }
    }];
    
    self.enteredRegion = region.identifier;
    NSLog(@"entered %@", region.identifier);
    if ([region.identifier isEqualToString:@"RegionNoyes"]) {
        self.enteredNoyes = YES;
        self.enteredTech = NO;
        //for old location
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                self.oldLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                NSLog(@"latitude is : %f",self.oldLocation.coordinate.latitude);
                [self appUsageLogging:[NSString stringWithFormat:@"entered Noyes at %f, %f", geoPoint.latitude, geoPoint.longitude]];
                //            self.lat = geoPoint.latitude;
                //            self.lng = geoPoint.longitude;
                //            [self getHeadingForDirectionFromCoordinate:oldLoc toCoordinate:plex];
            }
        }];
    }
    if ([region.identifier isEqualToString:@"RegionTech"]) {
        self.enteredTech = YES;
        self.enteredNoyes = NO;
        //for old location
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                self.oldLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                NSLog(@"latitude is : %f",self.oldLocation.coordinate.latitude);
                [self appUsageLogging:[NSString stringWithFormat:@"entered Tech at %f, %f", geoPoint.latitude, geoPoint.longitude]];

                //            self.lat = geoPoint.latitude;
                //            self.lng = geoPoint.longitude;
                //            [self getHeadingForDirectionFromCoordinate:oldLoc toCoordinate:plex];
            }
        }];
    }
    

    PFQuery *requestQuery = [PFQuery queryWithClassName: @"Request"];
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            NSMutableArray *object = [[NSMutableArray alloc]init];
            object = [objects firstObject];

            int first = [[object valueForKeyPath:@"first"]intValue];
            int second = [[object valueForKeyPath:@"second"]intValue];
            int third = [[object valueForKeyPath:@"third"]intValue];
            int fourth = [[object valueForKeyPath:@"fourth"]intValue];
            int fifth = [[object valueForKeyPath:@"fifth"]intValue];
            
            NSLog(@"%d, %d, %d, %d, %d",first, second, third, fourth, fifth);
    
            if ([self.group isEqualToString:@"a"]) {
                if (!self.lastNotified) {
                    if ([region.identifier isEqualToString:@"Region1"] || [region.identifier isEqualToString:@"Region2"] || [region.identifier isEqualToString:@"Region3"] || [region.identifier isEqualToString:@"Region4"] || [region.identifier isEqualToString:@"Region5"])
                    {
                        [self testNotif];
//                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                        [alert show];
                        [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                        self.lastNotified = YES;
                    }
                }

            } else if ([self.group isEqualToString:@"b"]) {
                if (self.enteredNoyes) {
                    if (!self.lastNotified) {
                        if (first<=second && first<=third && first<=fourth &&first<=fifth && [region.identifier isEqualToString:@"Region1"] && !self.lastNotified) {
                            [self testNotif];
                            
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at%@", region.identifier]];

                            self.lastNotified = YES;
                        } else if (second < first && second <= third && second <=fourth && second <= fifth && [region.identifier isEqualToString:@"Region2"] && !self.lastNotified) {
                            [self testNotif];
                            
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at%@", region.identifier]];

                            self.lastNotified = YES;
                        } else if (third < first && third < second && third <= fourth && third <= fifth && [region.identifier isEqualToString:@"Region3"] && !self.lastNotified) {
                            [self testNotif];
                            
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];

                            self.lastNotified = YES;
                        } else if (fourth < first && fourth < second && fourth < third && fourth <= fifth && [region.identifier isEqualToString:@"Region4"] && !self.lastNotified) {
                            [self testNotif];
                            
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];

                            self.lastNotified = YES;
                        } else if (fifth < fourth && fifth < first && fifth < second && fifth < third && [region.identifier isEqualToString:@"Region5"] && !self.lastNotified){
                            [self testNotif];
                            
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];

                            self.lastNotified = YES;
                        }
                    }
                }
                if (self.enteredTech) {
                    if (!self.lastNotified) {
                        if (fifth<=second && fifth<=third && fifth<=fourth &&fifth<=first && [region.identifier isEqualToString:@"Region5"] && !self.lastNotified) {
                            [self testNotif];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            self.lastNotified = YES;
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                        } else if (fourth < fifth && fourth <= third && fourth <=second && fourth <= first && [region.identifier isEqualToString:@"Region4"] && !self.lastNotified) {
                            [self testNotif];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                            self.lastNotified = YES;
                        } else if (third < fifth && third < fourth && third <= second && third <= first && [region.identifier isEqualToString:@"Region3"] && !self.lastNotified) {
                            [self testNotif];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                            self.lastNotified = YES;
                        } else if (second < fifth && second < fourth && second < third && second <= first && [region.identifier isEqualToString:@"Region2"] && !self.lastNotified) {
                            [self testNotif];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                            self.lastNotified = YES;
                        } else if (first < fifth && first < fourth && fifth < third && fifth < second && [region.identifier isEqualToString:@"Region1"] && !self.lastNotified){
                            [self testNotif];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//                            [alert show];
                            [self appUsageLogging:[NSString stringWithFormat:@"notification at %@", region.identifier]];
                            self.lastNotified = YES;
                        }
                    }
                }
            }
        }
    }];

//    PFQuery *query = [MyUser query];
//    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//        if (!error) {
////            int notifCount = [object[@"notifNum"] intValue];
////            NSLog(@"%d", notifCount);
////            NSNumber *value = [NSNumber numberWithInt:notifCount+1];
//            NSDate *date = [NSDate date];
//            object[@"lastNotified"] = date;
//            [object saveInBackground];
//        } else {
//            NSLog(@"ERROR!");
//        }
//    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Exited Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//    [alert show];
//    NSLog(@"exited %@", region.identifier);
    if ([region.identifier isEqualToString:@"RegionCenter"] || [region.identifier isEqualToString:@"RegionTech"] || [region.identifier isEqualToString:@"RegionNoyes"]) {
        self.lastNotified = NO;
    }
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}


- (void)testNotif
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    //    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
    //    localNotif.userInfo = dictionary;
    localNotif.alertBody = [NSString stringWithFormat:@"I lost item. Would you like to help?"];
    localNotif.alertAction = @"Testing notification based on regions";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    if (localNotif) {
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

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
