//
//  MySession.m
//  CrowdFound
//
//  Created by Shana Azria Dev on 4/13/15.
//  Copyright (c) 2015 YK. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MySession.h"

@implementation MySession
@synthesize hdvc;
@synthesize didGetNotif;

+ (id)sharedManager {
    static MySession *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
