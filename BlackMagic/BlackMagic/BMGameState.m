//
//  BMGameState.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMGameState.h"
#import "BMPlayer.h"

@implementation BMGameState

-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    
    if (self = [super init]) {
     
        
        NSDictionary* gameState = dictionary[@"gameState"];
        
        _isGameOver = [gameState[@"gameOver"] boolValue];
        
        _players = gameState[@"players"];
        _turnCount = [gameState[@"turnCount"] integerValue];
        
        NSDictionary* enemyInput = dictionary[@"enemyInput"];
        
        if (enemyInput){
            
            _enemyAction = enemyInput[@"playCard"];
            _enemyCardID = [enemyInput[@"cardID"] integerValue];
            _enemySlotIndex = [enemyInput[@"slotIndex"] integerValue];
        }
        
       // NSLog(@"players: %@", _players);
    }
    
    return self;
}

@end
