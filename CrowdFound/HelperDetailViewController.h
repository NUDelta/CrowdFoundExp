//
//  HelperDetailViewController.h
//  CrowdFound
//
//  Created by Yongsung on 11/13/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HelperDetailViewController : UIViewController
@property BOOL didGetNotif;
@property (strong, nonatomic) NSArray *request;
@property (strong, nonatomic) NSArray *requests;
@property (weak, nonatomic) IBOutlet UILabel *greyOverlay;
@property (strong, nonatomic) NSString *objectId;
@property (weak, nonatomic) IBOutlet UIButton *notFoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueOverlay;
@property (weak, nonatomic) IBOutlet UIButton *foundLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimerLabel;

+ (CLLocationManager *)sharedLocationManager;

@end
