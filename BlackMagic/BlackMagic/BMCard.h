//
//  BMCard.h
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCardAttribute.h"

#define CREATURE_TYPE @"creature"
#define SPELL_TYPE @"spell"

#define CARD_TYPE_AIR @"air"
#define CARD_TYPE_EARTH @"earth"
#define CARD_TYPE_FIRE @"fire"
#define CARD_TYPE_WATER @"water"
#define CARD_TYPE_ILLUSION @"illusion"


@interface BMCard : NSObject

@property (nonatomic,copy) BMCardAttribute* attribute;
@property (nonatomic,copy) NSDictionary* cost;
@property (nonatomic,copy) NSString* description;
@property (nonatomic) NSInteger identifier;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* type;
@property (nonatomic) BOOL hasEffectInEveryRound;

- (id)initWithDictionary:(NSDictionary*) aDictionary;

@end
