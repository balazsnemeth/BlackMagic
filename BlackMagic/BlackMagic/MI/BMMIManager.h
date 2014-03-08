//
//  BMMIManager.h
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCard.h"
#import "BMPlayer.h"

@interface BMMIManager : NSObject

+ (BMMIManager*) sharedManager;

- (BMCard*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy;

@end
