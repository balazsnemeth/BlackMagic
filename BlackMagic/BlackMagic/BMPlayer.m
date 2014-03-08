//
//  BMPlayer.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMPlayer.h"
#import "BMCard.h"

@implementation BMPlayer

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    
    if (self = [super init]) {
     
        NSLog(@"dic: %@", dictionary[@"cards"][@"air"]);
        
        for (NSDictionary* dict in dictionary[@"cards"]) {
        
            NSLog(@"dic: %@", dictionary[@"cards"][@"air"]);
            
//            
//            for (NSArray* cardDict in dict) {
//                
//                BMCard* card = [[BMCard alloc] initWithDictionary:dict];
//                
//                NSLog(@"card: %@", card);
//
//            }
        }
        
        _airCards = dictionary[@"cards"][@"air"];
        _fireCards = dictionary[@"cards"][@"fire"];
        _earthCards = dictionary[@"cards"][@"earth"];
        _illusionCards = dictionary[@"cards"][@"illusion"];
        _waterCards = dictionary[@"cards"][@"water"];
        
    }
    return self;
    
}

@end
