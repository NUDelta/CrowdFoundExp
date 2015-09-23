//
//  AppDelegate.h
//  CrowdFound
//
//  Created by Yongsung on 11/10/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
extern NSString *localReceived;

@property LocationManager *locationManager;
@property (nonatomic) NSTimer* locationUpdateTimer;

@end

