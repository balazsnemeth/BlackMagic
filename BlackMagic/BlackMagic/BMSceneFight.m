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
#import "BMStartScene.h"
#import "SettingsHandler.h"

#define widthGap 20
#define heightGap 20
#define cardWidth 115
#define cardHeight 115
#define cardDeckWidth 400
#define cardDeckHeight 400


@implementation BMSceneFight{
    SKLabelNode *playerHealth;
    SKLabelNode *opponentHealth;
    SKLabelNode *air;
    SKLabelNode *water;
    SKLabelNode *illusion;
    SKLabelNode *earth;
    SKLabelNode *fire;
    SKSpriteNode *playerMana;
    SKSpriteNode* whiteBackground;
    SKSpriteNode* closestNode;
    
    int cardHighlighted;

    
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
    UITextView* cardDescriptionTextView;
    BOOL gameOver;
    UIImageView *dragAndDropImgView;
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
    whiteBackground.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    //card00.anchorPoint = CGPointZero;
    whiteBackground.position = CGPointMake(380, 1025);
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
    playerCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 175, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 250, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 325, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 400, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 475, fightPosition - 50}],
                            [NSValue valueWithCGPoint:(CGPoint){ 550, fightPosition - 50}]];
    
    opponenetCardPositions = @[[NSValue valueWithCGPoint:(CGPoint){ 175, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 250, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 325, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 400, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 475, fightPosition }],
                               [NSValue valueWithCGPoint:(CGPoint){ 550, fightPosition }]];
    
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
    
    SKAction *fadeIn = [SKAction moveTo:CGPointMake(whiteBackground.position.x, fightPosition + 512) duration:0.5];
    [whiteBackground runAction:fadeIn];
    //whiteBackground.position = CGPointMake(whiteBackground.position.x, fightPosition + 510);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        cardHighlighted = -1;
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
        
        SKSpriteNode *cardButton = [SKSpriteNode spriteNodeWithImageNamed:@"CardButton"];
        cardButton.size = CGSizeMake(50, 50);
        cardButton.name = @"buttonStart";
        cardButton.position = CGPointMake(730,30);
        [self addChild:cardButton];
        
        SKSpriteNode *hamburgerButton = [SKSpriteNode spriteNodeWithImageNamed:@"MenuButton"];
        hamburgerButton.size = CGSizeMake(54.78515625, 50);
        hamburgerButton.name = @"hamburger";
        hamburgerButton.position = CGPointMake(CGRectGetMinX(self.frame) + hamburgerButton.size.width, 30);
        [self addChild:hamburgerButton];
        
        SKSpriteNode *airButton = [SKSpriteNode spriteNodeWithImageNamed:@"air"];
        airButton.size = CGSizeMake(70, 70);
        airButton.position = CGPointMake(200, 80);
        [self addChild:airButton];
        
        air = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        air.text = [NSString stringWithFormat:@"%i", 0];
        air.fontSize = 20;
        air.position = CGPointMake(200, 60);
        air.fontColor = [UIColor whiteColor];
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:air];
        
        SKSpriteNode *waterButton = [SKSpriteNode spriteNodeWithImageNamed:@"water"];
        waterButton.size = CGSizeMake(70, 70);
        waterButton.position = CGPointMake(300, 80);
        [self addChild:waterButton];
        
        water = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        water.text = [NSString stringWithFormat:@"%i", 0];
        water.fontSize = 20;
        water.position = CGPointMake(300, 60);
        water.fontColor = [UIColor whiteColor];
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:water];
        
        SKSpriteNode *fireButton = [SKSpriteNode spriteNodeWithImageNamed:@"fire"];
        fireButton.size = CGSizeMake(70, 70);
        fireButton.position = CGPointMake(400, 80);
        [self addChild:fireButton];
        
        fire = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        fire.text = [NSString stringWithFormat:@"%i", 0];
        fire.fontSize = 20;
        fire.position = CGPointMake(403, 60);
        fire.fontColor = [UIColor whiteColor];
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:fire];
        
        SKSpriteNode *earthButton = [SKSpriteNode spriteNodeWithImageNamed:@"earth"];
        earthButton.size = CGSizeMake(70, 70);
        earthButton.position = CGPointMake(500, 80);
        [self addChild:earthButton];
        
        earth = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        earth.text = [NSString stringWithFormat:@"%i", 0];
        earth.fontSize = 20;
        earth.position = CGPointMake(500, 60);
        earth.fontColor = [UIColor whiteColor];
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:earth];
        
        SKSpriteNode *illusionButton = [SKSpriteNode spriteNodeWithImageNamed:@"illusion"];
        illusionButton.size = CGSizeMake(70, 70);
        illusionButton.position = CGPointMake(600, 80);
        [self addChild:illusionButton];
        
        illusion = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
        illusion.text = [NSString stringWithFormat:@"%i", 0];
        illusion.fontSize = 20;
        illusion.position = CGPointMake(600, 60);
        illusion.fontColor = [UIColor whiteColor];
        //playerHealth.zRotation = -M_PI/2;
        [self addChild:illusion];
        
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

- (UIImage*) cardImageForIndex:(NSInteger)index{
    switch (index)
    {
        case 0:
            return [UIImage imageNamed:@"WalloffireB1"];
            break;
        case 1:
            return [UIImage imageNamed:@"SeaSprite-01"];
            break;
        case 2:
            return [UIImage imageNamed:@"Faerie Sage-01"];
            break;
        case 3:
            return [UIImage imageNamed:@"ElevenHealer-05"];
            break;
        case 4:
            return [UIImage imageNamed:@"DreamofPlenty-01"];
            break;
        case 5:
            return [UIImage imageNamed:@"FirePriestB_01"];
            break;
        case 6:
            return [UIImage imageNamed:@"MerfolkApostate-01"];
            break;
        case 7:
            return [UIImage imageNamed:@"PhoenixB_1"];
            break;
        case 8:
            return [UIImage imageNamed:@"Rejuvenation+StoneRain-01"];
            break;
        case 9:
            return [UIImage imageNamed:@"Rejuvenation+StoneRain-01"];
            break;
        case 10:
            return [UIImage imageNamed:@"BurgulB1"];
            break;
        case 11:
            return [UIImage imageNamed:@"MindMasterB_1"];
            break;
        case 12:
            return [UIImage imageNamed:@"Chain Lighting+Tornado-01"];
            break;
        case 13:
            return [UIImage imageNamed:@"Rejuvenation+StoneRain-01"];
            break;
        case 14:
            return [UIImage imageNamed:@"IllB_01"];
            break;
        case 15:
            return [UIImage imageNamed:@"InfernoB"];
            break;
        case 16:
            return [UIImage imageNamed:@"MindMasterB_1"];
            break;
        case 17:
            return [UIImage imageNamed:@"Rejuvenation+StoneRain-01"];
            break;
        case 18:
            return [UIImage imageNamed:@"HydraB_1"];
            break;
        case 19:
            return [UIImage imageNamed:@"InfiniteWall-01"];
            break;
        default:
            return nil;
            break;
    }
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
            currentCardView.tag = row*5+column;
            currentCardView.backgroundColor = [UIColor whiteColor];
            UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cardWidth, cardHeight)];
            UIImage* img = [self cardImageForIndex:currentCardView.tag];
            UIImage* smalImg = [self imageWithImage:img scaledToSize:CGSizeMake(img.size.width/2.0,img.size.height/2.0)];
            cardImageView.image = smalImg;
            [currentCardView addSubview:cardImageView];
            [cardDeckView addSubview:currentCardView];
            UITapGestureRecognizer* cardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardDeckCardTapped:)];
            [currentCardView addGestureRecognizer:cardTapRecognizer];
            
            UILongPressGestureRecognizer* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longDeckCard:)];
            longRecognizer.minimumPressDuration = 0.2;
            [currentCardView addGestureRecognizer:longRecognizer];
            
        }
    }
    
    cardDescriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(cardWidth/2,4*(cardHeight + heightGap) + cardHeight/2, 5*cardWidth+4*widthGap,60)];
    cardDescriptionTextView.editable = FALSE;
    cardDescriptionTextView.font = [UIFont fontWithName:@"Arial" size:24];
    [cardDescriptionTextView setTextColor:[UIColor whiteColor]];
    cardDescriptionTextView.backgroundColor = [UIColor clearColor];
//    txtview.backgroundColor = [UIColor redColor];
    [cardDeckView addSubview:cardDescriptionTextView];
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
        if ([node.name isEqualToString:@"buttonStart"] && player)
        {
            if (!cardDeckIsPresent)
            {
                NSLog(@"BOOM");
                cardDescriptionTextView.text = @"";
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
        
        if ([node.name isEqualToString:@"hamburger"])
        {
            NSLog(@"BAM");
            StartScene *startScene = [[StartScene alloc] initWithSize:self.size];
            SKTransition *sceneTransition = [SKTransition fadeWithColor:[UIColor darkGrayColor] duration:0.5];
            [self.view presentScene:startScene transition:sceneTransition];
            
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
    NSLog(@"touchesEnded");

    
    
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

- (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    // [view.layer renderInContext:UIGraphicsGetCurrentContext()]; // <- same result...
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) updateMySlots{
    if (dragAndDropImgView) {
        CGFloat minDist = 10000;
        SKSpriteNode* closestSlot = playerCardSprites[0];
        int minIndex = -1;
        int i = 0;
        for (SKSpriteNode* slotNode in playerCardSprites) {
            CGPoint p1 = dragAndDropImgView.center;
            CGPoint p2 = slotNode.position;
            if (p2.y == 840) {
                p2.y = 850;
            }
            CGFloat xDist = (p2.x - p1.x);
            CGFloat yDist = (p2.y - p1.y);
            CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
            NSLog(@"dist:(%f,%f)",p2.x,p2.y);
            if (minDist > distance) {
                closestSlot = slotNode;
                minDist = distance;
                minIndex = i;
                //legközelebbi (rátenni az effectet)
            }
            //összes többi (eltüntetni az effectet)
            i++;
        }
        NSLog(@"minIndex:%d",minIndex);
        if (closestSlot == closestNode){
            return;
        }
        else{
            closestNode.position = CGPointMake(closestNode.position.x, closestNode.position.y + 10);
            closestSlot.position = CGPointMake(closestSlot.position.x, closestSlot.position.y - 10);
            closestNode = closestSlot;
        }
        
    }
}

- (void)longDeckCard:(UITapGestureRecognizer*)gestureRec
{
    if(gestureRec.state == UIGestureRecognizerStateBegan){
        if (!dragAndDropImgView) {
            NSLog(@"long and create");
            UIImage* img = [self imageFromView:gestureRec.view];
            UIImage* smalImg = [self imageWithImage:img scaledToSize:CGSizeMake(gestureRec.view.frame.size.width/2.0,gestureRec.view.frame.size.height/2.0)];
            CGRect f = gestureRec.view.frame;
            f.size = smalImg.size;
            f.origin.x = f.origin.x+ smalImg.size.width/2.0;
            f.origin.y = f.origin.y+ smalImg.size.height/2.0;
            dragAndDropImgView = [[UIImageView alloc] initWithFrame:f];
            dragAndDropImgView.image = smalImg;
            [cardDeckView addSubview:dragAndDropImgView];
            CGPoint location = [gestureRec locationInView:cardDeckView];
            [UIView animateWithDuration:0.2 animations:^{
                dragAndDropImgView.center = location;
            }];
        }
        else{
            NSLog(@"long");
        }
    }
    else if(gestureRec.state == UIGestureRecognizerStateChanged){
        if (dragAndDropImgView) {
            CGPoint location = [gestureRec locationInView:cardDeckView];
            dragAndDropImgView.center = location;
            [self updateMySlots];
        }
    }
    else if(gestureRec.state == UIGestureRecognizerStateEnded || gestureRec.state == UIGestureRecognizerStateCancelled){
        if (dragAndDropImgView) {
            CGPoint location = [gestureRec locationInView:cardDeckView];
            dragAndDropImgView.center = location;
            //ide letesszük
            [dragAndDropImgView removeFromSuperview];
            dragAndDropImgView = nil;
            int row = (int)gestureRec.view.tag/5;
            int col = gestureRec.view.tag - row*5;
            BMCard* card = [self cardAtCol:col atRow:row];
            //Az ehhez tartozó sprite-ot aktiválni!
            
            return;
        }
    }
    
}

- (BMCard*) cardAtCol:(int) col atRow:(int)row{
    switch (col) {
        case 0:
            return [player.fireCards objectAtIndex:row];
            break;
        case 1:
            return [player.waterCards objectAtIndex:row];
            break;
        case 2:
            return [player.airCards objectAtIndex:row];
            break;
        case 3:
            return [player.earthCards objectAtIndex:row];
            break;
        case 4:
            return [player.illusionCards objectAtIndex:row];
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

- (void)cardDeckCardTapped:(UITapGestureRecognizer*)gestureRec
{
    
//    CGPoint p = [gestureRec locationInView:cardDeckView];
    int row = (int)gestureRec.view.tag/5;
    int col = gestureRec.view.tag - row*5;
    NSLog(@"%ld",(long)gestureRec.view.tag);
    BMCard* card = [self cardAtCol:col atRow:row];
    cardDescriptionTextView.text = card.description;
    NSLog(@"POW - (%d,%d)",row,col);
    UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetHeight(self.frame) - 30, self.view.bounds.size.width, 21)];
    detailsLabel.text = @"dwawdafwfwafwafwa";
    detailsLabel.textColor = [UIColor redColor];
    [cardDeckView addSubview:detailsLabel];
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
    air.text = [NSString stringWithFormat:@"%i", player.airMana];
    water.text = [NSString stringWithFormat:@"%i", player.waterMana];
    earth.text = [NSString stringWithFormat:@"%i", player.earthMana];
    illusion.text = [NSString stringWithFormat:@"%i", player.illusionMana];
    fire.text = [NSString stringWithFormat:@"%i", player.fireMana];
    
    if (gameState.isGameOver) {
        gameOver = TRUE;
    }
}


- (void)performNextStep:(BMMIResult *)miRes
{
    SKSpriteNode* node = playerCardSprites[miRes.slotIndex];
    NSString* cardType = @"";
    int cardIndex = NSNotFound;
    
    [self cardIndexAndCardTypeOfCard:miRes.card cardIndex_p:&cardIndex cardType_p:&cardType];
    NSString* imageName = [NSString stringWithFormat:@"%@%dW", cardType, cardIndex];
    NSLog(@"imageName: %@", imageName);
    node.texture = [SKTexture textureWithImageNamed:imageName];
    
    float x = player.health - enemy.health;
    
    x = x*10;
    
    fightPosition += x;
    NSLog(@"player: %d enemy: %d x : %d", player.health, enemy.health, fightPosition);
    
    if (fightPosition > -1200 && fightPosition < 900){
        [self positionFight];
    }
    
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
            
            
            BMCard* enemyCard = [player cardForID:gameState.enemyCardID];
            NSString* cardType = @"";
            int cardIndex = NSNotFound;
            [self cardIndexAndCardTypeOfCard:enemyCard cardIndex_p:&cardIndex cardType_p:&cardType];
            NSString* imageName = [NSString stringWithFormat:@"%@%dB", cardType, cardIndex];
            NSLog(@"imageName: %@", imageName);
            SKSpriteNode* node = nil;
            NSLog(@"enemm slot index: %d", gameState.enemySlotIndex);
            if (gameState.enemySlotIndex < 7){
                node = opponenetCardSprites[gameState.enemySlotIndex];
            }
            
            node.texture = [SKTexture textureWithImageNamed:imageName];
            
            if ([SettingsHandler sharedSettings].autoPlayByAI) {
                BMMIResult* miRes = [[BMMIManager sharedManager] suggestedCardForPlayer:player withEnemy:enemy inTurn:gameState.turnCount];
                [self performNextStep:miRes];
            }
            
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

- (void)cardIndexAndCardTypeOfCard:(BMCard *)card cardIndex_p:(int *)cardIndex_p cardType_p:(NSString **)cardType_p {
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
        [self cardIndexAndCardTypeOfCard:card cardIndex_p:&cardIndex cardType_p:&cardType];
        
        card.index = cardIndex;
        
        [myNewDictionary setObject:cardType forKey:@"resourceType"];
        [myNewDictionary setObject:@(cardIndex) forKey:@"cardIndex"];
        [myNewDictionary setObject:@(miResult.slotIndex) forKey:@"slotIndex"];
    }
    return myNewDictionary;
}


@end
