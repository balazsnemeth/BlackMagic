//
//  BMCreauterSlot.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMCreauterSlot.h"

@implementation BMCreauterSlot


-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    
    if (self = [super init]) {
        
        if (dictionary[@"attack"]){
            _attack = [dictionary[@"attack"] integerValue];
        }
        
        if (dictionary[@"health"]){
            _health = [dictionary[@"health"] integerValue];
        }
        
        _isEmpty = [dictionary[@"empty"] boolValue];
    }
    return self;
}

@end
