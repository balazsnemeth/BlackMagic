//
//  BMMIResult.h
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCard.h"

@interface BMMIResult : NSObject

@property (nonatomic,strong)BMCard* card;
@property (nonatomic)NSInteger slotIndex;
@property (nonatomic)BOOL skipTurn;

@end
