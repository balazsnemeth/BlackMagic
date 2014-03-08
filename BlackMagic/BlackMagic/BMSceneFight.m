//
//  BMSceneFight.m
//  BlackMagic
//
//  Created by Istvan Balogh on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMSceneFight.h"
#import "SKTUtils.h"
#import "BMNetworkManager.h"
#import "BMPlayer.h"
#import "BMMIManager.h"

@implementation BMSceneFight{
    SKSpriteNode *playerHealth;
    SKSpriteNode *opponentrHealth;
    SKSpriteNode *playerMana;
    
    
    NSArray* playerMinions;
    NSArray* opponenetMinions;
    NSArray* playerCardPositions;
    NSArray* opponenetCardPositions;
    
    NSArray* playerAvailableCardPositions;
    //SKSpriteNode *opponentMana;
    
    BOOL _touchingCard;
    CGPoint _touchPoint;
    SKSpriteNode* movedCard;
    
    int fightPosition;
    
    BMPlayer* player;
    
    BOOL isMyTurn;
}


NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        isMyTurn = NO;
        //reset the server
        
        NSString* name = [self genRandStringLength:6];
        
            //reg test A
            [[BMNetworkManager sharedManager] registerPlayer:name onCompletion:^(NSDictionary *result) {
                
                //NSLog(@"res:%@",result);
                player = [[BMPlayer alloc] initWithDictionary:result];
                player.name = name;
                isMyTurn = YES;
            } failure:^(NSError *error) {
                NSLog(@"error:%@",error);
            }];
            
        
        
        fightPosition = self.frame.size.width / 2;
        
        playerCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 550 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 500 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 450 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition - 50, 350 }]];
        
        opponenetCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ fightPosition, 600 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition, 550 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition, 500 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition, 450 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition, 400 }],
                                [NSValue valueWithCGPoint:(CGPoint){ fightPosition, 350 }]];
        
        playerAvailableCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 400, 250 }],
                                   [NSValue valueWithCGPoint:(CGPoint){ 450, 250 }],
                                   [NSValue valueWithCGPoint:(CGPoint){ 500, 250 }],
                                   [NSValue valueWithCGPoint:(CGPoint){ 550, 250 }],
                                   [NSValue valueWithCGPoint:(CGPoint){ 600, 250 }],
                                   [NSValue valueWithCGPoint:(CGPoint){ 650, 250 }]];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        [self addSpritesWithName:@"playerCard" FromArray:playerCardPositions withSize:CGSizeMake(50, 50)];
        [self addSpritesWithName:@"opponenetCard"FromArray:opponenetCardPositions withSize:CGSizeMake(50, 50)];
        [self addSpritesWithName:@"playerAvailableCard" FromArray:playerAvailableCardPositions withSize:CGSizeMake(50, 50)];
        
        
        SKSpriteNode* healthBar = [SKSpriteNode spriteNodeWithImageNamed:@"Healthbar"];
        healthBar.size = CGSizeMake(100, 100);
        healthBar.anchorPoint = CGPointZero;
        healthBar.position = CGPointMake(10, 10);
        [self addChild:healthBar];
        
        SKSpriteNode* manaBar = [SKSpriteNode spriteNodeWithImageNamed:@"Healthbar"];
        manaBar.size = CGSizeMake(100, 100);
        manaBar.anchorPoint = CGPointZero;
        manaBar.position = CGPointMake(110, 10);
        [self addChild:manaBar];
        
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

-(void)addSpritesWithName:(NSString*)name FromArray:(NSArray*)array withSize:(CGSize)size{
    
    int num = 0;
    for (NSValue* value in array) {
        
        SKSpriteNode* card00 = [SKSpriteNode spriteNodeWithImageNamed:@"images"];
        card00.name = [NSString stringWithFormat:@"%@%d", name, num];
        card00.size = size;
        card00.anchorPoint = CGPointZero;
        card00.position = value.CGPointValue;
        //card00.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:card00.size];
        [self addChild:card00];
        num++;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        // NSLog(@"** TOUCH LOCATION ** \nx: %f / y: %f", location.x, location.y);
      
        SKNode* card = [self childNodeWithName:@"playerAvailableCard0"];
        
        if([card containsPoint:location])
        {
             NSLog(@"xxxxxxxxxxxxxxxxxxx touched hat");
            _touchingCard = YES;
            _touchPoint = location;
            movedCard = (SKSpriteNode*)card;
            
            /* change the physics or the hat is too 'heavy' */
            
            card.physicsBody.velocity = CGVectorMake(0, 0);
            card.physicsBody.angularVelocity = 0;
            card.physicsBody.affectedByGravity = NO;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchPoint = [[touches anyObject] locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchingCard)
    {
        CGPoint currentPoint = [[touches anyObject] locationInNode:self];
        
        if ( currentPoint.x >= 300 && currentPoint.x <= 550 &&
            currentPoint.y >= 250 && currentPoint.y <= 400 )
        {
             NSLog(@"Close Enough! Let me do it for you");
            
            currentPoint.x = 420;
            currentPoint.y = 330;
            
            movedCard.position = currentPoint;
            
            //SKAction *popSound = [SKAction playSoundFileNamed:@"thompsonman_pop.wav" waitForCompletion:NO];
            //[_hat runAction:popSound];
        }
        else
            movedCard.physicsBody.affectedByGravity = YES;
        
        _touchingCard = NO;
    }
}

#pragma mark -
#pragma mark Game Loop

-(void)update:(CFTimeInterval)currentTime
{
    if (_touchingCard)
    {
        _touchPoint.x = Clamp(_touchPoint.x, movedCard.size.width / 2, self.size.width - movedCard.size.width / 2);
        _touchPoint.y = Clamp(_touchPoint.y, movedCard.size.height / 2,
                              self.size.height - movedCard.size.height / 2);
        
        movedCard.position = _touchPoint;
    }
    
    if (isMyTurn){
        
        isMyTurn = NO;
        
        [[BMNetworkManager sharedManager] startRequestNextMove:player.name onCompletion:^(NSDictionary *result) {
            NSLog(@"res: %@", result);
            
/*            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL"
                                                            message:@"Dee dee doo doo."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];*/

            BMMIResult* step = [[BMMIManager sharedManager] suggestedCardForPlayer:self.player withEnemy:self.enemy inTurn:self.turnIndex];
            [[BMNetworkManager sharedManager] proceedPlayer:player.name withInput:BMMIResult onCompletion:^(NSDictionary *result) {
                //update-lni kell a dolgokat, és várni a következő körre!
                
                
            } failure:^(NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                message:error.domain
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"error %@", error);
            }];
            
        } failure:^(NSError *error) {
            NSLog(@"error %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:error.domain
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    //receive status
    // Choose card
    // send rest api
    // wailt for new turn
}

@end
