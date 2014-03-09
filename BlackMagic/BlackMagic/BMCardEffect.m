//
//  BMCardEffect.m
//  BlackMagic
//
//  Created by Jozsef Vesza on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMCardEffect.h"

@implementation BMCardEffect

- (id)initWithDictionary:(NSDictionary*) aDictionary
{
    self = [super init];
    if (self)
    {
        NSDictionary* details = aDictionary[@"effect"];
        _power = [details[@"power"] integerValue];
        _resourceType = [self parseResourceType:details[@"resourceType"]];
        _cardEffect = [self parseCardEffectType:details[@"type"]];
        _targetOwner = aDictionary[@"targetOwner"];
        _targetType = aDictionary[@"targetType"];
        
    }
    
    return self;
}

- (EffectResourceType) parseResourceType:(NSString*) aString
{
    if ([aString isEqualToString:@"fire"]) return fire;
    else if ([aString isEqualToString:@"water"]) return water;
    else if ([aString isEqualToString:@"air"]) return air;
    else if ([aString isEqualToString:@"earth"]) return earth;
    else return illusion;
}

- (CardEffectType) parseCardEffectType:(NSString*) aString
{
    if ([aString isEqualToString:@"directDamage"]) return directDamage;
    else if ([aString isEqualToString:@"damageAllCreature"]) return damageAllCreature;
    else if ([aString isEqualToString:@"heal"]) return heal;
    else if ([aString isEqualToString:@"healAllCreature"]) return healAllCreature;
    else return resourceAdd;
}

@end
