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
#import "BMGameState.h"

#define widthGap 10
#define heightGap 20
#define cardWidth 50
#define cardHeight 50
#define cardDeckWidth 400
#define cardDeckHeight 400

@implementation BMSceneFight{
    SKLabelNode *playerHealth;
    SKLabelNode *opponentHealth;
    SKSpriteNode *playerMana;
    
    
    
    NSArray* playerMinions;
    NSArray* opponenetMinions;
    NSArray* playerCardPositions;
    NSArray* opponenetCardPositions;
    
    //NSArray* playerAvailableCardPositions;
    //SKSpriteNode *opponentMana;
    
    BOOL _touchingCard;
    CGPoint _touchPoint;
    SKSpriteNode* movedCard;
    
    int fightPosition;
    
    BMPlayer* player;
    BMPlayer* enemy;
    
    BOOL isMyTurn;
    
    // experimental
    BOOL cardDeckIsPresent;
    UIView *newView;
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
                enemy = [[BMPlayer alloc] initWithDictionary:result];
                player.name = name;
                isMyTurn = YES;
            } failure:^(NSError *error) {
                NSLog(@"error:%@",error);
            }];
        
        
        
        fightPosition = self.frame.size.height / 2;
        
        playerCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 200, fightPosition - 50}],
                                [NSValue valueWithCGPoint:(CGPoint){ 250, fightPosition - 50}],
                                [NSValue valueWithCGPoint:(CGPoint){ 300, fightPosition - 50}],
                                [NSValue valueWithCGPoint:(CGPoint){ 350, fightPosition - 50}],
                                [NSValue valueWithCGPoint:(CGPoint){ 400, fightPosition - 50}],
                                [NSValue valueWithCGPoint:(CGPoint){ 450, fightPosition - 50}]];
        
        opponenetCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 200, fightPosition }],
                                [NSValue valueWithCGPoint:(CGPoint){ 250, fightPosition }],
                                [NSValue valueWithCGPoint:(CGPoint){ 300, fightPosition }],
                                [NSValue valueWithCGPoint:(CGPoint){ 350, fightPosition }],
                                [NSValue valueWithCGPoint:(CGPoint){ 400, fightPosition }],
                                [NSValue valueWithCGPoint:(CGPoint){ 450, fightPosition }]];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        [self addSpritesWithName:@"playerCard" FromArray:playerCardPositions withSize:CGSizeMake(50, 50)];
        [self addSpritesWithName:@"opponenetCard"FromArray:opponenetCardPositions withSize:CGSizeMake(50, 50)];
        //[self addSpritesWithName:@"playerAvailableCard" FromArray:playerAvailableCardPositions withSize:CGSizeMake(50, 50)];
        
        
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
        
        SKSpriteNode *myLabel = [SKSpriteNode spriteNodeWithImageNamed:@"images"];
        myLabel.size = CGSizeMake(50, 50);
        myLabel.name = @"buttonStart";
//        myLabel.text = @"pick";
//        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMinX(self.frame),
                                       CGRectGetMidY(self.frame));
        [self addChild:myLabel];
        
        playerHealth = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        playerHealth.text = [NSString stringWithFormat:@"%i", 60];
        playerHealth.fontSize = 30;
        playerHealth.position = CGPointMake(self.frame.size.width / 2 - 10, 10);
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:playerHealth];
        
        opponentHealth = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        opponentHealth.text = [NSString stringWithFormat:@"%i", 60];
        opponentHealth.fontSize = 30;
        opponentHealth.position = CGPointMake(self.frame.size.width / 2 - 10, 1000);
        //opponentHealth.zRotation = -M_PI/2;
        [self addChild:opponentHealth];
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    newView = [[[NSBundle mainBundle] loadNibNamed:@"CardDeckView" owner:self options:nil] lastObject];
    
    for (int row = 0; row < 5; row++)
    {
        for (int column = 0; column < 4; column++)
        {
            CGFloat centerY = row * (cardHeight + heightGap);
            CGFloat centerX = column * (cardWidth + widthGap);
            
            CGRect frame = CGRectMake(centerX, centerY, cardWidth, cardHeight);
            UIView* currentCardView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] lastObject];
            currentCardView.frame = frame;
            [newView addSubview:currentCardView];
            UITapGestureRecognizer* cardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardDeckCardTapped)];
            [currentCardView addGestureRecognizer:cardTapRecognizer];
        }
    }
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
        SKNode* node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"buttonStart"])
        {
            if (!cardDeckIsPresent)
            {
                NSLog(@"BOOM");
                [self.view.window.rootViewController.view addSubview:newView];
                newView.frame = CGRectMake(CGRectGetMinX(self.frame) - cardDeckWidth, self.view.bounds.size.height/2 - cardDeckHeight/2, cardDeckWidth, cardDeckHeight);
                UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
                swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
                [newView addGestureRecognizer:swipeRecognizer];
                [UIView animateWithDuration:0.5 animations:^
                {
                    newView.frame = CGRectMake(CGRectGetMinX(self.frame), self.view.bounds.size.height/2 - cardDeckHeight/2, cardDeckWidth, cardDeckHeight);
                }];
                cardDeckIsPresent = YES;
            }
        }
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

- (void)cardDeckCardTapped
{
    NSLog(@"POW");
}

- (void)handleSwipe
{
    NSLog(@"VOOM");
    [UIView animateWithDuration:0.5 animations:^
    {
        newView.frame = CGRectMake(CGRectGetMinX(self.frame) - cardDeckWidth, self.view.bounds.size.height/2 - cardDeckHeight/2, cardDeckWidth, cardDeckHeight);
    }];
    cardDeckIsPresent = NO;
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
            //NSLog(@"res: %@", result);
            
            BMGameState* gameState = [[BMGameState alloc] initWithDictionary:result];
            
            if ([player.name isEqualToString:gameState.players[0][@"name"]]){
                [player updatePlayerFromDictionary:gameState.players[0]];
                [enemy updatePlayerFromDictionary:gameState.players[1]];
            }
            else{
                [player updatePlayerFromDictionary:gameState.players[1]];
                [enemy updatePlayerFromDictionary:gameState.players[0]];
            }
            
            playerHealth.text = [NSString stringWithFormat:@"%i", player.health];
            opponentHealth.text = [NSString stringWithFormat:@"%i", enemy.health];
            
            BMMIResult* miRes = [[BMMIManager sharedManager] suggestedCardForPlayer:player withEnemy:enemy inTurn:gameState.turnCount];
            
            NSLog(@"health: %d", player.health);
            
            NSString* cardName = [NSString stringWithFormat:@"playerAvailableCard%d", miRes.slotIndex];
            SKSpriteNode* card = (SKSpriteNode*)[self childNodeWithName:cardName];
            card.color = [UIColor blackColor];
            card.texture = nil;
            

            NSDictionary* nextStep = [self stepInputTypeOfMIResult:miRes];
        
            [[BMNetworkManager sharedManager] proceedPlayer:player.name withInput:nextStep onCompletion:^(NSDictionary *result) {
                    //update-lni kell a dolgokat, és várni a következő körre!
                    BMGameState* gameState = [[BMGameState alloc] initWithDictionary:result];
                    if ([player.name isEqualToString:gameState.players[0][@"name"]]){
                        [player updatePlayerFromDictionary:gameState.players[0]];
                        [enemy updatePlayerFromDictionary:gameState.players[1]];
                    }
                    else{
                        [player updatePlayerFromDictionary:gameState.players[1]];
                        [enemy updatePlayerFromDictionary:gameState.players[0]];
                    }
            } failure:^(NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                message:error.domain
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"error %@", error);
            }];

            
            
            //choose card
            
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

#pragma mark -
#pragma mark Helper

- (NSDictionary*) stepInputTypeOfMIResult:(BMMIResult*)miResult{
    NSMutableDictionary *myNewDictionary = [NSMutableDictionary new];
    
    if (miResult.skipTurn) {
        [myNewDictionary setObject:@"skipTurn" forKey:@"action"];
    }
    else{
        [myNewDictionary setObject:@"playCard" forKey:@"action"];
        BMCard* card = miResult.card;
        NSString* cardType = @"";
        int cardIndex = NSNotFound;
        cardIndex = [player.fireCards indexOfObject:card];
        if (cardIndex != NSNotFound) {
            cardType = CARD_TYPE_FIRE;
        }
        if (cardIndex == NSNotFound) {
            cardIndex = [player.earthCards indexOfObject:card];
            if (cardIndex != NSNotFound) {
                cardType = CARD_TYPE_EARTH;
            }
        }
        if (cardIndex == NSNotFound) {
            cardIndex = [player.illusionCards indexOfObject:card];
            if (cardIndex != NSNotFound) {
                cardType = CARD_TYPE_ILLUSION;
            }
        }
        if (cardIndex == NSNotFound) {
            cardIndex = [player.airCards indexOfObject:card];
            if (cardIndex != NSNotFound) {
                cardType = CARD_TYPE_AIR;
            }
        }
        if (cardIndex == NSNotFound) {
            cardIndex = [player.waterCards indexOfObject:card];
            if (cardIndex != NSNotFound) {
                cardType = CARD_TYPE_WATER;
            }
        }
        
        [myNewDictionary setObject:cardType forKey:@"resourceType"];
        [myNewDictionary setObject:@(cardIndex) forKey:@"cardIndex"];
        [myNewDictionary setObject:@(miResult.slotIndex) forKey:@"slotIndex"];
    }
    return myNewDictionary;
}


@end
