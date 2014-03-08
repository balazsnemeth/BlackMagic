//
//  BMPlayer.h
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPlayer : NSObject

@property (nonatomic, strong) NSArray* fireCards;
@property (nonatomic, strong) NSArray* airCards;
@property (nonatomic, strong) NSArray* earthCards;
@property (nonatomic, strong) NSArray* illusionCards;
@property (nonatomic, strong) NSArray* waterCards;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, assign) int waterMana;
@property (nonatomic, assign) int airMana;
@property (nonatomic, assign) int fireMana;
@property (nonatomic, assign) int earthMana;
@property (nonatomic, assign) int illusionMana;
@property (nonatomic, assign) int health;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
