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

@interface BMCardEffect : NSObject

@property (nonatomic) NSInteger power;
@property (nonatomic) CardEffectType cardEffect;
@property (nonatomic,copy) NSString *targetOwner;
@property (nonatomic,copy) NSString *targetType;

@end
