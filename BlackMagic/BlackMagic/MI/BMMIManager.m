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

/**Primo taktika:
 1. Ha nincs még elég szörnyem, akkor a legerőssebb szörnyeket kipakolom!
 2. Ha megteltek a szörnyek, akkor a mana-m szerinti legerőssebb kártyát kijátszom!
 3. Ha nincs még elég manam, akkor skippelek! - return nil!
 4.
 */

- (NSArray*) bayableCardsOfPlayer:(BMPlayer*)player{
    NSMutableArray* buyableCard = [NSMutableArray new];
    for (BMCard* card in player.fireCards) {
        if (card.cost[@"amount"] < player.fireMana) {
            [buyableCard addObject:card];
        }
    }
    
}

- (BMCard*) strongestCreature:(BMPlayer*)player{
    
    
}

- (BMCard*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy{
    
}

@end
