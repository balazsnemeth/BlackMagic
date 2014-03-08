//
//  BMCreauterSlot.h
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMCreauterSlot : NSObject

@property (nonatomic, assign) BOOL isEmpty;
@property (nonatomic, assign) int attack;
@property (nonatomic, assign) int health;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
