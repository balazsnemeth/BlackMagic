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
#import "UIAlertView+Blocks.h"

#define widthGap 10
#define heightGap 20
#define cardWidth 120
#define cardHeight 120
#define cardDeckWidth 400
#define cardDeckHeight 400

@implementation BMSceneFight{
    SKLabelNode *playerHealth;
    SKLabelNode *opponentHealth;
    SKSpriteNode *playerMana;
    SKSpriteNode* whiteBackground;
    

    
    
    NSMutableArray* playerCardSprites;
    NSMutableArray* opponenetCardSprites;
    NSArray* playerCardPositions;
    NSArray* opponenetCardPositions;
    
    //SKSpriteNode *opponentMana;
    
    BOOL _touchingCard;
    CGPoint _touchPoint;
    SKSpriteNode* movedCard;
    
    int prevFightPos;
    int fightPosition;
    
    BMPlayer* player;
    BMPlayer* enemy;
    
    BOOL isMyTurn;
    
    // experimental
    BOOL cardDeckIsPresent;
    UIView *cardDeckView;
    UIView *newView;
    BOOL gameOver;
}


NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(void)addBackground{
    
    whiteBackground = [SKSpriteNode spriteNodeWithImageNamed:@"FieldW"];
    whiteBackground.size = CGSizeMake(self.frame.size.width, self.frame.size.height / 2 +60);
    //card00.anchorPoint = CGPointZero;
    whiteBackground.position = CGPointMake(380, 800);
    //card00.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:card00.size];
    [self addChild:whiteBackground];
    
}

- (void) registerUserWithName:(NSString*)name{
    [[BMNetworkManager sharedManager] registerPlayer:name onCompletion:^(NSDictionary *result) {
        
        //NSLog(@"res:%@",result);
        player = [[BMPlayer alloc] initWithDictionary:result];
        enemy = [[BMPlayer alloc] initWithDictionary:result];
        player.name = name;
        isMyTurn = YES;
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIAlertView showWithTitle:@"Hiba a regisztrációnál" message:@"Újraindítottad a szervert?" cancelButtonTitle:@"Mégsem" otherButtonTitles:@[@"Újraindítom most"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    [[BMNetworkManager sharedManager] resetServerOnCompletion:^{
                        NSLog(@"Reset successfull!");
                        [self registerUserWithName:name];
                    } failure:^(NSError *error) {
                        NSLog(@"Reset unsuccessfull! Error: %@",error);
                    }];
                }
            }];
        });
        return;
    }];
}

- (void)positionFight {
    playerCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 200, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 275, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 350, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 425, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 500, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 575, fightPosition - 50}]];
    
    opponenetCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 200, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 275, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 350, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 425, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 500, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 575, fightPosition }]];
    
    if ([playerCardSprites count] != 6){
        return;
    }
    

    for (int i = 0; i<6; i++) {
        SKSpriteNode* node = (SKSpriteNode*)[playerCardSprites objectAtIndex:i];
        NSValue* playerPos = playerCardPositions[i];
        SKAction *fadeIn = [SKAction moveTo:playerPos.CGPointValue duration:0.5];
        [node runAction:fadeIn];
        
        node = (SKSpriteNode*)[opponenetCardSprites objectAtIndex:i];
        playerPos = opponenetCardPositions[i];
        fadeIn = [SKAction moveTo:playerPos.CGPointValue duration:0.5];
        [node runAction:fadeIn];
    }
    
    SKAction *fadeIn = [SKAction moveTo:CGPointMake(whiteBackground.position.x, fightPosition + 285) duration:0.5];
    [whiteBackground runAction:fadeIn];
    //whiteBackground.position = CGPointMake(whiteBackground.position.x, fightPosition + 285);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        isMyTurn = NO;
        gameOver = NO;
        //reset the server
        
        [self addBackground];
        
        playerCardSprites = [NSMutableArray array];
        opponenetCardSprites = [NSMutableArray array];
        
        NSString* name = [self genRandStringLength:6];
        [self registerUserWithName:name];
        //reg test A
        
        fightPosition = self.frame.size.height / 2;
        
        [self positionFight];
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        
        
//        [self addSpritesWithName:@"playerCard" FromArray:playerCardPositions withSize:CGSizeMake(50, 50)];
        
        int num = 0;
        for (NSValue* value in playerCardPositions) {
            
            SKSpriteNode* card00 = [SKSpriteNode spriteNodeWithImageNamed:@"FieldW"];
            card00.name = [NSString stringWithFormat:@"%@%d", @"playerCard", num];
            card00.size = CGSizeMake(50, 50);
            card00.anchorPoint = CGPointZero;
            card00.position = value.CGPointValue;
            //card00.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:card00.size];
            [self addChild:card00];
            [playerCardSprites addObject:card00];
            num++;
        }
        
        //[self addSpritesWithName:@"opponenetCard"FromArray:opponenetCardPositions withSize:CGSizeMake(50, 50)];
        
        num = 0;
        for (NSValue* value in opponenetCardPositions) {
            
            SKSpriteNode* card00 = [SKSpriteNode spriteNodeWithImageNamed:@"FieldB"];
            card00.name = [NSString stringWithFormat:@"%@%d", @"opponenetCard", num];
            card00.size = CGSizeMake(50, 50);
            card00.anchorPoint = CGPointZero;
            card00.position = value.CGPointValue;
            //card00.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:card00.size];
            [self addChild:card00];
            [opponenetCardSprites addObject:card00];
            num++;
        }
        
        
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
        myLabel.position = CGPointMake(CGRectGetMaxX(self.frame),
                                       CGRectGetMinY(self.frame));
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
        opponentHealth.fontColor = [UIColor blackColor];
        opponentHealth.position = CGPointMake(self.frame.size.width / 2 - 10, 995);
        //opponentHealth.zRotation = -M_PI/2;
        [self addChild:opponentHealth];
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    cardDeckView = [[[NSBundle mainBundle] loadNibNamed:@"CardDeckView" owner:self options:nil] lastObject];
    
    
}

- (void)addCardsToDeck
{
    for (int column = 0; column < 5; column++)
    {
        for (int row = 0; row < 4; row++)
        {
            CGFloat centerY = row * (cardHeight + heightGap) + cardHeight/2;
            CGFloat centerX = column * (cardWidth + widthGap) + cardWidth/2;
            
            CGRect frame = CGRectMake(centerX, centerY, cardWidth, cardHeight);
            UIView* currentCardView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] lastObject];
            currentCardView.frame = frame;
            currentCardView.backgroundColor = [UIColor redColor];
            [cardDeckView addSubview:currentCardView];
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
                [self.view.window.rootViewController.view addSubview:cardDeckView];
                cardDeckView.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), self.view.bounds.size.width, CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame));
                UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
                swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
                [cardDeckView addGestureRecognizer:swipeRecognizer];
                [UIView animateWithDuration:0.5 animations:^
                 {
                     cardDeckView.frame = CGRectMake(CGRectGetMinX(self.frame), self.view.bounds.size.height/2 - cardDeckHeight/2, self.view.bounds.size.width, CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame));
                 }];
                [self addCardsToDeck];
                cardDeckIsPresent = YES;
                
                prevFightPos = fightPosition;
                fightPosition = 900;
                [self positionFight];
            }
            else
            {
                NSLog(@"VOOM");
                [UIView animateWithDuration:0.5 animations:^
                {
                    cardDeckView.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), self.view.bounds.size.width, CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame));
                }];
                cardDeckIsPresent = NO;
            }
        }
        
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
         cardDeckView.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), self.view.bounds.size.width, CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame));
     }];
    cardDeckIsPresent = NO;
    
    fightPosition = prevFightPos;
    [self positionFight];
    
}

#pragma mark -
#pragma mark Game Loop

- (void)statusUpdate:(NSDictionary *)result
{
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
    playerHealth.text = [NSString stringWithFormat:@"%i", player.health];
    opponentHealth.text = [NSString stringWithFormat:@"%i", enemy.health];
    if (gameState.isGameOver) {
        gameOver = TRUE;
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    if (gameOver) {
        //TODO: gameOver screen!
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"Game over");
            NSString* message = [NSString stringWithFormat:@"Winner: %@", enemy.health < player.health ? @"You" : @"Enemy"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        return;
    }
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
            [self statusUpdate:result];
            
//            NSLog(@"számolok");
            BMMIResult* miRes = [[BMMIManager sharedManager] suggestedCardForPlayer:player withEnemy:enemy inTurn:gameState.turnCount];
            
            SKSpriteNode* node = playerCardSprites[miRes.slotIndex];
            NSString* cardType = @"";
            int cardIndex = NSNotFound;
            
            [self extracted_method:miRes.card cardIndex_p:&cardIndex cardType_p:&cardType];
            NSString* imageName = [NSString stringWithFormat:@"%@%dW", cardType, cardIndex];
            NSLog(@"imageName: %@", imageName);
            node.texture = [SKTexture textureWithImageNamed:imageName];
            
            float x = player.health - enemy.health;
            
            x = x*10;
            
            NSLog(@"player: %d enemy: %d x : %f", player.health, enemy.health, x);
            
            fightPosition += x;
            [self positionFight];
            
//            int num = 0;
//            for (SKSpriteNode* value in playerCardSprites) {
//                
//                NSValue* val = playerCardPositions[num];
//                value.position = val.CGPointValue;
//                num++;
//            }
//            
//            num = 0;
//            for (SKSpriteNode* value in opponenetCardSprites) {
//                
//                NSValue* val = opponenetCardPositions[num];
//                value.position = val.CGPointValue;
//                num++;
//            }
            
//            whiteBackground.position =

            NSDictionary* nextStep = [self stepInputTypeOfMIResult:miRes];
        
            [[BMNetworkManager sharedManager] proceedPlayer:player.name withInput:nextStep onCompletion:^(NSDictionary *result) {
                
                [self statusUpdate:result];
                isMyTurn = YES;
                
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

#pragma mark -
#pragma mark Helper

- (void)extracted_method:(BMCard *)card cardIndex_p:(int *)cardIndex_p cardType_p:(NSString **)cardType_p {
    *cardIndex_p = [player.fireCards indexOfObject:card];
    if (*cardIndex_p != NSNotFound) {
        *cardType_p = CARD_TYPE_FIRE;
    }
    if (*cardIndex_p == NSNotFound) {
        *cardIndex_p = [player.earthCards indexOfObject:card];
        if (*cardIndex_p != NSNotFound) {
            *cardType_p = CARD_TYPE_EARTH;
        }
    }
    if (*cardIndex_p == NSNotFound) {
        *cardIndex_p = [player.illusionCards indexOfObject:card];
        if (*cardIndex_p != NSNotFound) {
            *cardType_p = CARD_TYPE_ILLUSION;
        }
    }
    if (*cardIndex_p == NSNotFound) {
        *cardIndex_p = [player.airCards indexOfObject:card];
        if (*cardIndex_p != NSNotFound) {
            *cardType_p = CARD_TYPE_AIR;
        }
    }
    if (*cardIndex_p == NSNotFound) {
        *cardIndex_p = [player.waterCards indexOfObject:card];
        if (*cardIndex_p != NSNotFound) {
            *cardType_p = CARD_TYPE_WATER;
        }
    }
}

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
        [self extracted_method:card cardIndex_p:&cardIndex cardType_p:&cardType];
        
        card.index = cardIndex;
        
        [myNewDictionary setObject:cardType forKey:@"resourceType"];
        [myNewDictionary setObject:@(cardIndex) forKey:@"cardIndex"];
        [myNewDictionary setObject:@(miResult.slotIndex) forKey:@"slotIndex"];
    }
    return myNewDictionary;
}


@end
