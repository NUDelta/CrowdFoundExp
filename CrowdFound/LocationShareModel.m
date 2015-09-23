//
//  LocationShareModel.m
//  CrowdFound
//
//  Created by Yongsung on 9/8/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "LocationShareModel.h"

@implementation LocationShareModel

+ (id)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
