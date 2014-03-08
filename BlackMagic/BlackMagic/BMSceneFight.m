//
//  BMSceneFight.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMSceneFight.h"

@implementation BMSceneFight{
    SKSpriteNode *playerHealth;
    SKSpriteNode *opponentrHealth;
    SKSpriteNode *playerMana;
    NSArray* playerMinions;
    NSArray* opponenetMinions;
    NSArray* playerCardPositions;
    NSArray* opponenetCardPositions;
    //SKSpriteNode *opponentMana;
}


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        playerCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 100, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 210, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 320, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 430, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 540, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 650, 400 }]];
        
        opponenetCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 100, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 210, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 320, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 430, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 540, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ 650, 600 }]];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        for (NSValue* value in playerCardPositions) {

            SKSpriteNode* card00 = [SKSpriteNode spriteNodeWithImageNamed:@"images"];
            card00.size = CGSizeMake(100, 100);
            card00.anchorPoint = CGPointZero;
            card00.position = value.CGPointValue;
            
            [self addChild:card00];
        }
        
        for (NSValue* value in opponenetCardPositions) {
            
            SKSpriteNode* card00 = [SKSpriteNode spriteNodeWithImageNamed:@"images"];
            card00.size = CGSizeMake(100, 100);
            card00.anchorPoint = CGPointZero;
            card00.position = value.CGPointValue;
            
            [self addChild:card00];
        }
        
        
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.name = @"buttonStart";
        myLabel.text = @"Start Game";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        //[self addChild:myLabel];
    }
    return self;
}

@end
