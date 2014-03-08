//
//  BMPlayer.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMPlayer.h"
#import "BMCard.h"
#import "BMCreauterSlot.h"

@implementation BMPlayer

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    
    if (self = [super init]) {
     
        //NSLog(@"dic: %@", dictionary[@"cards"][@"air"]);
        
        NSMutableArray* cards = [NSMutableArray array];
        for (NSDictionary* dict in dictionary[@"cards"][@"air"]) {
            
            BMCard* card = [[BMCard alloc] initWithDictionary:dict];
            [cards addObject:card];
        }
        _airCards = cards;
        
        cards = [NSMutableArray array];
        for (NSDictionary* dict in dictionary[@"cards"][@"water"]) {
            
            BMCard* card = [[BMCard alloc] initWithDictionary:dict];
            [cards addObject:card];
        }
        _waterCards = cards;
        
        cards = [NSMutableArray array];
        for (NSDictionary* dict in dictionary[@"cards"][@"illusion"]) {
            
            BMCard* card = [[BMCard alloc] initWithDictionary:dict];
            [cards addObject:card];
        }
        _illusionCards = cards;
        
        cards = [NSMutableArray array];
        for (NSDictionary* dict in dictionary[@"cards"][@"fire"]) {
            
            BMCard* card = [[BMCard alloc] initWithDictionary:dict];
            [cards addObject:card];
        }
        _fireCards = cards;
        
        cards = [NSMutableArray array];
        for (NSDictionary* dict in dictionary[@"cards"][@"earth"]) {
            
            BMCard* card = [[BMCard alloc] initWithDictionary:dict];
            [cards addObject:card];
        }
        _earthCards = cards;
        
        _health = 60;
        
        _waterMana = _airMana = _earthMana = _fireMana = _illusionMana = 15;
//        
//        NSLog(@"water cards %@", _waterCards);
//        NSLog(@"fire cards %@", _fireCards);
//        NSLog(@"_earth cards %@", _earthCards);
//        NSLog(@"illusion cards %@", _illusionCards);
//        NSLog(@"air cards %@", _airCards);
    }
    return self;
    
}

-(void)updatePlayerFromDictionary:(NSDictionary*)dictionary{
    
    //NSLog(@"player dict : %@", dictionary);
    NSDictionary* resources = dictionary[@"availableResources"];
    
    NSMutableArray* slots = [NSMutableArray array];
    for (NSDictionary* dict in dictionary[@"creatureSlots"]) {
        
        BMCreauterSlot* slot = [[BMCreauterSlot alloc] initWithDictionary:dict];
        [slots addObject:slot];
    }
    
    self.slots = slots;
    
    //NSLog(@"slots: %@", self.slots);
    
    self.waterMana = [resources[@"water"] integerValue];
    self.earthMana = [resources[@"earth"] integerValue];
    self.fireMana = [resources[@"fire"] integerValue];
    self.illusionMana = [resources[@"illusion"] integerValue];
    self.airMana = [resources[@"air"] integerValue];
    
    self.health =  [dictionary[@"health"] integerValue];
    
    
}

@end
