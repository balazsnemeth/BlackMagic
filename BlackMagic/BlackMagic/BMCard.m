//
//  BMCard.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMCard.h"
#import "BMCardAttribute.h"

@implementation BMCard

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    if (self)
    {
        _cost = aDictionary[@"cost"];
        _description = aDictionary[@"description"];
        _identifier = [aDictionary[@"id"] integerValue];
        _name = aDictionary[@"name"];
        NSDictionary* attr = aDictionary[@"attributes"];
        _type = aDictionary[@"type"];
        _attribute = [[BMCardAttribute alloc] initWithDictionary:attr withCardType:_type];
    }
    
    return self;
}

@end
