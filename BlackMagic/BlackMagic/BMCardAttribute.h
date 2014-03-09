//
//  BMCardAttribute.h
//  BlackMagic
//
//  Created by Jozsef Vesza on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMCardAttribute : NSObject

@property (nonatomic) NSInteger attack;
@property (nonatomic) NSInteger health;

/**item types: BMCardEffect */
@property (nonatomic,copy) NSArray* effects;
@property (nonatomic,copy) NSArray* immunities;

- (id)initWithDictionary:(NSDictionary*) aDictionary withCardType:(NSString*)cardType;

@end
