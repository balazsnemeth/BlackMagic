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
#import "BMMIResult.h"

@interface BMMIManager : NSObject

+ (BMMIManager*) sharedManager;

- (BMMIResult*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy inTurn:(NSInteger)turnCount;

@end
