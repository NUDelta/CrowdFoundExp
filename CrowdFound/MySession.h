//
//  MySession.h
//  CrowdFound
//
//  Created by Shana Azria Dev on 4/13/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelperDetailViewController.h"

@interface MySession : NSObject {
    HelperDetailViewController *hdvc;
    BOOL didGetNotif;
}
@property (nonatomic, strong) HelperDetailViewController *hdvc;
@property BOOL didGetNotif;
+ (id)sharedManager;
@end
