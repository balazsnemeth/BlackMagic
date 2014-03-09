//
//  BMMIManager.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMMIManager.h"
#import "BMCreauterSlot.h"
#import "BMCardEffect.h"

@interface BMMIManager()

@property (nonatomic) NSInteger lastHealthIllusionTurnIndex;

@end

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
        _lastHealthIllusionTurnIndex = NOT_DEFINED;
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
        if (n.integerValue <= player.fireMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.waterCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue <= player.waterMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.airCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue <= player.airMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.illusionCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue <= player.illusionMana) {
            [buyableCards addObject:card];
        }
    }
    for (BMCard* card in player.earthCards) {
        NSNumber* n = card.cost[@"amount"];
        if (n.integerValue <= player.earthMana) {
            [buyableCards addObject:card];
        }
    }
    return buyableCards;
}



- (id) randomObjectFromArray:(NSArray*)array
{
    if ([array count] == 0) {
        return nil;
    }
    return [array objectAtIndex: arc4random() % [array count]];
}


- (int) numberOfDamageIllusionOfPlayer:(BMPlayer*)player{
    NSInteger damageCard = 0;
    for (BMCard* card in player.fireCards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        damageCard++;
                    }
                }
            }
        }
    }
    for (BMCard* card in player.waterCards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        damageCard++;
                    }
                }
            }
        }
    }
    for (BMCard* card in player.airCards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        damageCard++;
                    }
                }
            }
        }
    }
    for (BMCard* card in player.illusionCards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        damageCard++;
                    }
                }
            }
        }
    }
    for (BMCard* card in player.earthCards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        damageCard++;
                    }
                }
            }
        }
    }
    return damageCard;
}

/**Kiválogatom a dombolókat, és random választok közülük!*/
- (BMCard*) strongestDamageOfCards:(NSArray*)cards minimumRankCount:(NSInteger)rankCount{
    
    if (rankCount > 4) {
        rankCount = 4;
    }
    if (rankCount <= 0) {
        rankCount = 1;
    }
    NSMutableArray* damageCards = [NSMutableArray array];
    for (BMCard* card in cards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
            //            NSNumber* n = card.cost[@"amount"];
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == damageAllCreature) {
                        [damageCards addObject: card];
                    }
                }
            }
        }
    }
    /**Ha nagy a rankcount, akkor várhatok a sorsolással*/
    if (damageCards.count <= rankCount) {
        return nil;
    }
    else{
        return [self randomObjectFromArray:damageCards];
    }
}



- (BMCard*) getHealthIncreaseIllusion:(NSArray*)cards{
    BMCard* strongestCard = nil;
    for (BMCard* card in cards) {
        if ([card.type isEqualToString:SPELL_TYPE]) {
//            NSNumber* n = card.cost[@"amount"];
            if (card.attribute) {
                for (BMCardEffect* effect in card.attribute.effects) {
                    if (effect.cardEffect == heal) {
                        return card;
                    }
                }
            }
        }
    }
    return strongestCard;
}

- (BMCard*) strongestOfCards:(NSArray*)cards inType:(NSString*)type{
    BMCard* strongestCard = nil;
    NSInteger strongestValue = -1;
    for (BMCard* card in cards) {
        if ([card.type isEqualToString:type]) {
            NSNumber* n = card.cost[@"amount"];
            NSInteger cost = n.integerValue;
            if (cost > strongestValue-3) {
                strongestValue = cost;
                strongestCard = card;
            }
        }
    }
    return strongestCard;
}

- (BOOL) hasFreeSlotOfPlayer:(BMPlayer*)player{
    BOOL outR = FALSE;
    for (BMCreauterSlot* slot in player.slots) {
        if (slot.isEmpty) {
            outR = TRUE;
            break;
        }
    }
    return outR;
}

- (BMMIResult*) suggestedCardForPlayer:(BMPlayer*)player withEnemy:(BMPlayer*)enemy inTurn:(NSInteger)turnCount{
    
    BMMIResult* res = [BMMIResult new];
    res.skipTurn = FALSE;
    NSArray* buyableCards = [self bayableCardsOfPlayer:player];
    BMCard* strongestCreature = [self strongestOfCards:buyableCards inType:CREATURE_TYPE];
    res.card = strongestCreature;
    //hová tegyem?
    //1. Van-e szabad helyem -> ott tudok vagy védekezni, vagy támadni!
    int creaturePlace = NOT_DEFINED;
    if ([self hasFreeSlotOfPlayer:player]) {
        NSLog(@"%d - add slot",turnCount);
        //Van szabad slotom!
        int defenderPosition = NOT_DEFINED;
        int attackPosition = NOT_DEFINED;
        for (int i = 0; i<SLOT_COUNT; i++) {
            BMCreauterSlot* currEnemySlot = enemy.slots[i];
            BMCreauterSlot* currPlayerSlot = player.slots[i];
            
            //VAN-e olyan slotom szabadon, ami előtt az ellenfél támad!
            if(!currEnemySlot.isEmpty){
                if (currPlayerSlot.isEmpty) {
                    //Az ellenfélnek VAN slotja, és nekem NINCS -> VÉDEKEZÉS
                    defenderPosition = i;
                }
                else{
                    ;//Az ellenfélnek VAN slotja, és nekem IS VAN -> KIRÁLY
                }
            }
            else{
                //Az ellenfélnek nincsen itt ellensége, ha nekem viszont lehetne itt szörnyem, hogy támadjam!
                if (currPlayerSlot.isEmpty) {
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
        res.slotIndex = creaturePlace;
    }
    else{
        //Nincs szabad slotom!
        BMCard* illusion = nil;
        if (player.health < enemy.health) {
            //meg kell próbálnom gyógyító varázslatot
            illusion = [self getHealthIncreaseIllusion:buyableCards];
        }
        else{
            //meg kell néznem, tudom-e őt rombolni
                //megnézem, hogy mennyivel vezetek, és ettől függően várhatok erősebb rombolásra!
           
                int lifeDiff = (player.health - enemy.health);
                int unit = 1;
                if (lifeDiff < 10) {
                    unit = 1;
                }
                else if(lifeDiff < 16){
                    unit = 2;
                }
                else if(lifeDiff < 24){
                    unit = 3;
                }
                else if(lifeDiff < 30){
                    unit = 4;
                }
                int maxDamageCard = [self numberOfDamageIllusionOfPlayer:player];
                if (maxDamageCard < unit && unit != 1) {
                    unit = maxDamageCard;
                }
                illusion = [self strongestDamageOfCards:buyableCards minimumRankCount:unit];
                //ha tudok, akkor varázsolhatok is
        }
        if (illusion) {
            res.card = illusion;
            //be kell állítani!
            res.slotIndex = 0;
        }
        else{
            //Ha nem tudok varázsolni, akkor skippelek, hogy növeljem a pontjaimat!
            res.skipTurn = TRUE;
            res.card = nil;
        }
    }
    return res;
}

@end
