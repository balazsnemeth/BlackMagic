//
//  BMCardEffect.h
//  BlackMagic
//
//  Created by Jozsef Vesza on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    directDamage,
    damageAllCreature,
    heal,
    healAllCreature,
    resourceAdd
}CardEffectType;

typedef enum
{
    fire,
    water,
    air,
    earth,
    illusion
}EffectResourceType;

@interface BMCardEffect : NSObject

@property (nonatomic) NSInteger power;
@property (nonatomic) EffectResourceType resourceType;
@property (nonatomic) CardEffectType cardEffect;
@property (nonatomic,copy) NSString *targetOwner;
@property (nonatomic,copy) NSString *targetType;

- (id)initWithDictionary:(NSDictionary*) aDictionary;

@end
