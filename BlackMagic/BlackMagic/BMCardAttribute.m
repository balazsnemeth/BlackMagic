//
//  BMCardAttribute.m
//  BlackMagic
//
//  Created by Jozsef Vesza on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMCardAttribute.h"
#import "BMCardEffect.h"

@implementation BMCardAttribute

- (id)initWithDictionary:(NSDictionary*) aDictionary withCardType:(NSString*)aCardType
{
    self = [super init];
    if (self)
    {
        _attack = aDictionary[@"attack"] ? [aDictionary[@"attack"] integerValue] : -1;
        _health = aDictionary[@"health"] ? [aDictionary[@"health"] integerValue] : -1;
        
        NSArray* effects = aDictionary[@"onSummon"];
        
        if ([aCardType isEqualToString:@"creature"])
        {
            if (!effects)
            {
                effects = aDictionary[@"onSummonOVT"];
            }
        }
        else if([aCardType isEqualToString:@"spell"])
        {
            effects = aDictionary[@"modifiers"];
        }
        //parse effect to object
        NSMutableArray* effs = [NSMutableArray new];
        for (NSDictionary* effect in effects)
        {
            [effs addObject: [[BMCardEffect alloc] initWithDictionary: effect]];
        }
        _effects = effs;
    }
    return self;
}

@end
