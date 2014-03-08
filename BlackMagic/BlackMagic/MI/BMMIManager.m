//
//  BMMIManager.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMMIManager.h"

@implementation BMMIManager

static int const SLOT_COUNT = 6;
static int const NOT_DEFINED = -1;

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

- (BMCard*) strongestOfCards:(NSArray*)cards inType:(NSString*)type{
    BMCard* strongestCard = nil;
    NSInteger strongestValue = -1;
    for (BMCard* card in cards) {
        if ([card.type isEqualToString:type]) {
            NSNumber* n = card.cost[@"amount"];
            NSInteger cost = n.integerValue;
            if (cost > strongestValue) {
                strongestValue = cost;
                strongestCard = card;
            }
        }
    }
    return strongestCard;
}

- (BMMIResult*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy{
    BMMIResult* res = [BMMIResult new];
    res.skipTurn = FALSE;
    NSArray* buyableCards = [self bayableCardsOfPlayer:player];
    BMCard* strongestCreature = [self strongestOfCards:buyableCards inType:CREATURE_TYPE];
    res.card = strongestCreature;
    //hová tegyem?
    //1. Van-e szabad helyem -> ott tudok vagy védekezni, vagy támadni!
    int creaturePlace = NOT_DEFINED;
    if (player.slots.count < SLOT_COUNT) {
        //Van szabad slotom!
        int defenderPosition = NOT_DEFINED;
        int attackPosition = NOT_DEFINED;
        for (int i = 0; i<SLOT_COUNT; i++) {
            //VAN-e olyan slotom szabadon, ami előtt az ellenfél támad!
            if(enemy.slots[@(i)]){
                if (!player.slots[@(i)]) {
                    //Az ellenfélnek VAN slotja, és nekem NINCS -> VÉDEKEZÉS
                    defenderPosition = i;
                }
                else{
                    ;//Az ellenfélnek VAN slotja, és nekem IS VAN -> KIRÁLY
                }
            }
            else{
                //Az ellenfélnek nincsen itt ellensége, ha nekem viszont lehetne itt szörnyem, hogy támadjam!
                if (!player.slots[@(i)]) {
                    //Az ellenfélnek nincs slotja, ÉS nekem sincs -> TÁMADÁS
                    attackPosition = i;
                }
                else{
                    ;//Az ellenfélnek nincs slotja, de nekem van -> KIRÁLY
                }
            }
        }
        
        //Megvan, hogy hová tehetek támadni vagy védekezni
        if (defenderPosition == NOT_DEFINED) {
            creaturePlace = attackPosition;
        }
        else{
            creaturePlace = defenderPosition;
        }
    }
    else{
        //Nincs szabad slotom!
        //Most csak skippelek!
        res.skipTurn = TRUE;
        res.card = nil;
    }
    return res;
}

@end
