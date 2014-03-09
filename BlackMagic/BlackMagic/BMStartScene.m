//
//  BMMyScene.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMStartScene.h"
#import "BMSceneFight.h"
#import "SettingsHandler.h"

@implementation StartScene{
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        
        SKLabelNode *startLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        startLabel.name = @"buttonStart";
        startLabel.text = @"Play Game";
        startLabel.fontSize = 30;
        startLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) + 60);
        [self addChild:startLabel];
        
        
        SKLabelNode *autoLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        autoLabel.name = @"buttonStartCPU";
        autoLabel.text = @"Simulation";
        autoLabel.fontSize = 30;
        autoLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) + 0);
        [self addChild:autoLabel];
        
        SKLabelNode *resetLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        resetLabel.name = @"buttonReset";
        resetLabel.text = @"Reset Server";
        resetLabel.fontSize = 30;
        resetLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) - 60);
        [self addChild:resetLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
        if ([node.name isEqualToString:@"buttonStart"]) {
            BMSceneFight *scene = [[BMSceneFight alloc] initWithSize:self.size];
            SKTransition *sceneTransition = [SKTransition fadeWithColor:[UIColor darkGrayColor] duration:0.5];
            [self.view presentScene:scene transition:sceneTransition];
        }
        
        else if ([node.name isEqualToString:@"buttonStartCPU"]) {
            [SettingsHandler sharedSettings].autoPlayByAI = TRUE;
            BMSceneFight *scene = [[BMSceneFight alloc] initWithSize:self.size];
            SKTransition *sceneTransition = [SKTransition fadeWithColor:[UIColor darkGrayColor] duration:0.5];
            [self.view presentScene:scene transition:sceneTransition];
        }
        else if ([node.name isEqualToString:@"buttonReset"]) {
            [SettingsHandler sharedSettings].autoPlayByAI = FALSE;
            BMSceneFight *scene = [[BMSceneFight alloc] initWithSize:self.size];
            SKTransition *sceneTransition = [SKTransition fadeWithColor:[UIColor darkGrayColor] duration:0.5];
            [self.view presentScene:scene transition:sceneTransition];
        }
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
