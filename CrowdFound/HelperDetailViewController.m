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



@property BOOL notified;

@end

@implementation HelperDetailViewController


- (IBAction)helpButton:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:@"Thanks for finding the item!" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        if (!error) {
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
}
//Help fail count
- (IBAction)noButton:(UIButton *)sender {
    if(!self.helpFailed){
        PFQuery *query = [PFQuery queryWithClassName:@"Request"];
        [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            if (!error) {
                int helpFailCount = [object[@"helpFailCount"] intValue];
                NSLog(@"%d", helpFailCount);
                NSNumber *value = [NSNumber numberWithInt:helpFailCount+1];
                object[@"helpFailCount"] = value;
                if([self.region isEqualToString:@"first"]){
                    int value = [object[@"first"] intValue];
                    NSNumber *firstCount = [NSNumber numberWithInt:value+1];
                    object[@"first"] = firstCount;
                } else if ([self.region isEqualToString:@"middle"]) {
                    int value = [object[@"second"] intValue];
                    NSNumber *secondCount = [NSNumber numberWithInt:value+1];
                    object[@"second"] = secondCount;
                } else if ([self.region isEqualToString:@"third"]) {
                    int value = [object[@"third"] intValue];
                    NSNumber *thirdCount = [NSNumber numberWithInt:value+1];
                    object[@"third"] = thirdCount;
                }
                [object saveInBackground];
                self.helpFailed = YES;
            } else {
                NSLog(@"ERROR!");
            }
        }];
    } else {
        NSLog(@"already clicked!");
    }
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    PFQuery *query = [PFQuery queryWithClassName: @"Request"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            self.request = [objects firstObject];
            CLLocationCoordinate2D regionA; //Foster Walker
            regionA.latitude = [(NSString *)[self.request valueForKeyPath:@"lat"] floatValue];
            regionA.longitude = [(NSString *)[self.request valueForKeyPath:@"lng"] floatValue];
            
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:regionA radius:50 identifier:@"RegionA"];
            [self.locationManager startMonitoringForRegion: region];
            
            CLLocationCoordinate2D regionB; //Foster Walker
            regionB.latitude = [(NSString *)[self.request valueForKeyPath:@"lat2"] floatValue];
            regionB.longitude = [(NSString *)[self.request valueForKeyPath:@"lng2"] floatValue];
            
            CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:regionB radius:50 identifier:@"RegionB"];
            [self.locationManager startMonitoringForRegion: region2];
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
    int middlePoint = [[self.request valueForKeyPath:@"middlePoint"] intValue];
    
    int firstQuarterPoint = [[self.request valueForKeyPath:@"firstQuarterPoint"] intValue];
    
    int thirdQuarterPoint = [[self.request valueForKeyPath:@"thirdQuarterPoint"] intValue];

    NSLog(@"distance: %f", distance);
    NSLog(@"first quarter: %d", firstQuarterPoint);
    NSLog(@"middle quarter: %d", middlePoint);
    NSLog(@"third quarter: %d", thirdQuarterPoint);
    
    int first = [[self.request valueForKeyPath:@"first"]intValue];
    int second = [[self.request valueForKeyPath:@"second"]intValue];
    int third = [[self.request valueForKeyPath:@"third"]intValue];
    
    if ([self.enteredRegion isEqualToString:@"RegionA"] && !self.notified) {
//if # is the same, Middle, First, Third order
        if (second <=first || second <= third) {
            if (distance >= middlePoint && distance < thirdQuarterPoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Middle Point!" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"middle";
                self.notified = YES;
            }
        }
        else if (first < second && first <= third) {
            if (distance>= firstQuarterPoint && distance < middlePoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"first Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"first";
                self.notified = YES;
            }
        }
        else if (third < second && third < first) {
            if (distance >= thirdQuarterPoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"third Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"third";
                self.notified = YES;
            }
        }
    } else if ([self.enteredRegion isEqualToString:@"RegionB"] && !self.notified){
        if (second <=first || second <= third) {
            if (distance >= middlePoint && distance < thirdQuarterPoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Middle Point!" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"middle";
                self.notified = YES;
            }
        }
        else if (third < second && third < first) {
            if (distance>= firstQuarterPoint && distance < middlePoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"third Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"third";
                self.notified = YES;
            }
        }
        else if (first < second && first < third) {
            if (distance >= thirdQuarterPoint) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"first Quarter" message:[NSString stringWithFormat:@"%f", distance] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
                [alert show];
                self.region = @"first";
                self.notified = YES;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    self.enteredRegion = region.identifier;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.oldLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            NSLog(@"latitude is : %f",self.oldLocation.coordinate.latitude);
//            self.lat = geoPoint.latitude;
//            self.lng = geoPoint.longitude;
//            [self getHeadingForDirectionFromCoordinate:oldLoc toCoordinate:plex];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Entered Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DRR" message: [NSString stringWithFormat:@"Exited Region: %@", region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
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
