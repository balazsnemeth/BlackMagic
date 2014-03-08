//
//  BMPlayer.h
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPlayer : NSObject

@property (nonatomic, strong) NSDictionary* fireCards;
@property (nonatomic, strong) NSDictionary* airCards;
@property (nonatomic, strong) NSDictionary* earthCards;
@property (nonatomic, strong) NSDictionary* illusionCards;
@property (nonatomic, strong) NSDictionary* waterCards;

@end
