//
//  BMMyScene.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMStartScene.h"
#import "BMSceneFight.h"

@implementation StartScene{
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.name = @"buttonStart";
        myLabel.text = @"Start Game";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
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
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
