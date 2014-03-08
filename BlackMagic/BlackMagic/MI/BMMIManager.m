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
    NSMutableArray* buyableCards = [NSMutableArray new];
    for (BMCard* card in player.fireCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue < player.fireMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.waterCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue < player.waterMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.airCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue < player.airMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.illusionCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue < player.illusionMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.earthCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue < player.earthMana) {
            [buyableCards addObject:card];
        }
    }
    return buyableCards;
}

- (BMCard*) strongestOfCards:(NSArray*)cards{
    BMCard* strongestCard = nil;
    NSInteger strongestValue = -1;
    for (BMCard* card in cards) {
        NSNumber* n = card.cost[@"amount"];
        NSInteger cost = n.integerValue;
        if (cost > strongestValue) {
            strongestValue = cost;
            strongestCard = card;
        }
    }
    return strongestCard;
}

- (BMCard*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy{
    NSArray* buyableCards = [self bayableCardsOfPlayer:player];
    BMCard* strongestCard = [self strongestOfCards:buyableCards];
    return strongestCard;
}

@end
