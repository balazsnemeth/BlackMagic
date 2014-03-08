//
//  BMMIManager.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMMIManager.h"

@implementation BMMIManager


static BMMIManager *sharedMIManager = nil;

+ (BMMIManager*) sharedManager
{
    @synchronized(self)
    {
        if (sharedMIManager == nil)
            sharedMIManager = [[BMMIManager alloc] init];
    }
    return sharedMIManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        ;
    }
    return self;
}



@end
