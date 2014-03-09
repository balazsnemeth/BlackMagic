//
//  BMGameState.h
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMGameState : NSObject

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;


@property (nonatomic, strong) NSString* enemyAction;
@property (nonatomic, assign) NSInteger enemyCardID;
@property (nonatomic, assign) int enemySlotIndex;

@property (nonatomic, assign) int currentPlayerIndex;
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, assign) int turnCount;

@property (nonatomic, strong) NSArray* players;

@end
