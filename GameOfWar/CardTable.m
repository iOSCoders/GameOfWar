//
//  CardTable.m
//  CardsApp
//
//  Created by Joe Bologna on 10/30/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "CardTable.h"
#import "CardTable+Layout.h"
#import "CardsClass.h"
#import "Button.h"

#define DEALSPEED (0.2)
#define FASTSPEED (0.02)
#define DELAYSPEED (0.75)
#define CARDSCALE (0.3)
#define P1 0
#define P2 1

#define kDEAL @"Deal"
#define kPLAYAGAIN @"Play Again"
#define kFINISH_HAND @"Finish Hand"
#define kP1BUTTON @"P1"
#define kP2BUTTON @"P2"
#define kP1CARDS @"P1 Cards"
#define kP2CARDS @"P2 Cards"
#define kP1WINS @"P1 Wins"
#define kP2WINS @"P2 Wins"
#define kCARDPREFIX @"CARD:"
#define kP1SHUFFLE @"P1 Shuffle"
#define kP2SHUFFLE @"P2 Shuffle"

@interface CardTable() {
    SKTexture *backTexture;
    Button *p1Button, *p2Button, *reset, *msg, *p1score, *p2score, *p1shuffle, *p2shuffle, *p1wins, *p2wins, *dealButton;
    GamePlay *gamePlay;
    Player *dealer, *p1field, *p2field;
}
@end

@implementation CardTable

- (NSString *)showState {
    return [NSString stringWithFormat:@"%@, %@", gamePlay.gameStateToString, gamePlay.outcomeToString];
}

-(id)initWithSize:(CGSize)size {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (self = [super initWithSize:size]) {
        Player *p1 = [Player initPlayer];
        Player *p2 = [Player initPlayer];
        dealer = [Player initPlayer];
        [dealer initCards];
        p1field = [Player initPlayer];
        p2field = [Player initPlayer];
        gamePlay = [GamePlay initWithP1:p1 and:p2 delegate:self];
        self.fontsize = [UIFont systemFontSize] * 1.25;
        UIImage *back = [UIImage imageNamed:@"back"];
        CGSize cs = CGSizeMake(back.size.width * CARDSCALE, back.size.height * CARDSCALE);
        backTexture = [SKTexture textureWithImage:back];
        [self initMetricsWithSize:cs];
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    }
    return self;
}

-(void)outcomeMsg:(NSString *)m {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    NSLog(@"and the winner is! %@", m);
    msg.text = m;
}

-(NSString *)cardKey:(CardClass *)c {
    return [kCARDPREFIX stringByAppendingString:c.cardName];
}

- (BOOL)itsACard:(NSString *)nodeName {
    return [nodeName rangeOfString:kCARDPREFIX].location == 0;
}

#pragma mark SKScene delegate
- (void)didMoveToView:(SKView *)view {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    // create the playing field
    SKTexture *felt = [SKTexture textureWithImageNamed:@"felt"];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:felt];
    sprite.position = self.middle;
    sprite.userInteractionEnabled = YES;
    sprite.name = @"felt";
    [sprite setScale:.5];
    [self addChild:sprite];

    // add the buttons
    ADDBUTTON(dealButton, kDEAL, SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeLeft, [self deckbuttonloc]);
    ADDBUTTON(p1Button, kP1BUTTON, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeCenter, [self handbuttonloc:P1]);
    ADDBUTTON(reset, kPLAYAGAIN, SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeRight, [self resetloc]);
    ADDBUTTON(reset, kP2BUTTON, SKLabelVerticalAlignmentModeBottom, SKLabelHorizontalAlignmentModeCenter, [self handbuttonloc:P2]);
    ADDBUTTON(msg, kFINISH_HAND, SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeCenter, [self msgloc]);
    ADDBUTTON(p1score, kP1CARDS, SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeCenter, [self scoreloc:P1]);
    ADDBUTTON(p2score, kP2CARDS, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeCenter, [self scoreloc:P2]);
    ADDBUTTON2(p1shuffle, kP1SHUFFLE, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeLeft, [self shuffleloc:P1], @"Shuffle");
    ADDBUTTON2(p2shuffle, kP2SHUFFLE, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeLeft, [self shuffleloc:P2], @"Shuffle");
    ADDBUTTON(p1wins, kP1WINS, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeRight, [self winsloc:P1]);
    ADDBUTTON(p2wins, kP2WINS, SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeRight, [self winsloc:P2]);
    
    // put the deck of cards on the table, face down
    [self displayCards:dealer at:[self deckloc] withSpacing:0 withScale:CARDSCALE];

#ifdef SHOWGUIDES
    // layout guides
    [self showGuides];
#endif
    
    [self updateScores];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    // this is needed for debugging because this method makes the CardsApp context inaccessible
    //[self showGuides];
    
    NSLog(@"node: %@", node.name);
    if ([node.name isEqualToString:kDEAL] && dealer.cards.count == 52) {
        NSLog(@"Dealing hands to p1 & p2");
        [self dealHands];
    } else if ([node.name isEqualToString:kPLAYAGAIN]) {
        [self sendToDealer];
    } else if ([node.name isEqualToString:kP1SHUFFLE]) {
        [gamePlay.p1 shuffle];
    } else if ([node.name isEqualToString:kP2SHUFFLE]) {
        [gamePlay.p2 shuffle];
    } else if ([self itsACard:node.name]) {
        NSLog(@"its a card: %@", node.name);
        NSLog(@"%@", [self showState]);
        if (dealer.cards.count > 0 && [node.name isEqualToString:[self cardKey:dealer.cards.lastObject]]) {
            [self dealHands];
        } else {
            [self playCard:(SKLabelNode *)node];
        }
        NSLog(@"%@", [self showState]);
    } else {
        NSLog(@"nope, its: %@", node.name);
    }
}

#pragma mark card methods

- (void)displayCards:(CardsClass *)c at:(CGPoint)p withSpacing:(CGFloat)sp withScale:(CGFloat)sc {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CGPoint cp = p;
    for (CardClass *card in c.cards) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:card.imageName];
        sprite.position = cp;
        sprite.name = [self cardKey:card];
        [sprite setScale:sc];
        [self addChild:sprite];
        cp.y -= sp;
    }
}

- (void)flipFaceOf:(CardClass *)card to:(FaceUpDown)faceUpDown {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (card.faceUpDown == faceUpDown) {
        return;
    }
    [self flip:card];
}

- (void)flip:(CardClass *)card {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    card.faceUpDown = card.faceUpDown == FACE_DOWN ? FACE_UP : FACE_DOWN;
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:card]];
    sprite.texture = card.faceUpDown == FACE_DOWN ? backTexture : [SKTexture textureWithImage:[UIImage imageNamed:card.imageName]];
}

- (void)removeCards:(CardsClass *)c {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    for (CardClass *card in c.cards) {
        SKNode *cardNode = (SKSpriteNode *)[self childNodeWithName:[self cardKey:card]];
        if (cardNode) [cardNode removeFromParent];
    }
}

- (void)updateScores {
    [((Button *)[self childNodeWithName:kP1CARDS]) setText:[NSString stringWithFormat:@"(%lu)", (unsigned long)gamePlay.p1.cards.count]];
    [((Button *)[self childNodeWithName:kP2CARDS]) setText:[NSString stringWithFormat:@"(%lu)", (unsigned long)gamePlay.p2.cards.count]];
    [((Button *)[self childNodeWithName:kP1WINS]) setText:[NSString stringWithFormat:@"Wins: %lu", (unsigned long)gamePlay.p1.score]];
    [((Button *)[self childNodeWithName:kP2WINS]) setText:[NSString stringWithFormat:@"Wins: %lu", (unsigned long)gamePlay.p2.score]];
}

- (void)playCard:(SKLabelNode *)node {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    NSLog(@"gamePlay: %@, %ld, %ld", [self showState], (unsigned long)gamePlay.p1.cards.count, (unsigned long)gamePlay.p2.cards.count);
    __block CardClass *c = nil;
    CGPoint loc;
    int z = 0;
    if (gamePlay.p1.cards.count > 0 && gamePlay.gameState != P1Played) {
        if ([node.name isEqualToString:[self cardKey:((CardClass *)gamePlay.p1.cards.lastObject)]]) {
            c = (CardClass *)gamePlay.p1.cards.lastObject;
            [p1field.cards addObject:c];
            NSLog(@"%s, add to p1: %lu", __func__, (unsigned long)p1field.cards.count);
            [gamePlay.p1.cards removeLastObject];
            loc = [self playedcardloc:P1];
            if (gamePlay.gameState == P2Played) gamePlay.gameState = BothHandsPlayed;
            else gamePlay.gameState = P1Played;
            z = p1field.cards.count;
        }
    }
    if (gamePlay.p2.cards.count > 0 && gamePlay.gameState != P2Played) {
        if ([node.name isEqualToString:[self cardKey:((CardClass *)gamePlay.p2.cards.lastObject)]]) {
            c = (CardClass *)gamePlay.p2.cards.lastObject;
            [p2field.cards addObject:c];
            NSLog(@"%s, add to p2: %lu", __func__, (unsigned long)p2field.cards.count);
            [gamePlay.p2.cards removeLastObject];
            loc = [self playedcardloc:P2];
            if (gamePlay.gameState == P1Played) gamePlay.gameState = BothHandsPlayed;
            else gamePlay.gameState = P2Played;
            z = p2field.cards.count;
        }
    }
    if (c != nil && (gamePlay.gameState == P1Played || gamePlay.gameState == P2Played || gamePlay.gameState == BothHandsPlayed)) {
        SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:node.name];
        [self flip:c];
        [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
            sprite.zPosition = z;
            [self updateScores];
            if (gamePlay.gameState == BothHandsPlayed) {
                [gamePlay checkWinnerWith:p1field.cards.lastObject and:p2field.cards.lastObject];
                NSLog(@"%@", [self showState]);
                if ((gamePlay.gameState == BothHandsPlayed) && (gamePlay.outcome != Draw)) {
                    [self clearField];
                }
                if (gamePlay.outcome == Draw) {
                    c = (CardClass *)p1field.cards.lastObject;
                    [self flip:c];
                    c = (CardClass *)p2field.cards.lastObject;
                    [self flip:c];
                }
            }
        }], nil]]];
    } else {
        NSLog(@"fell through");
    }
}

- (void)clearField {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    SKSpriteNode *sprite;
    CardClass *c;
    NSUInteger n;
    NSLog(@"%ld, %ld", (unsigned long)gamePlay.p1field.cards.count, (unsigned long)gamePlay.p2field.cards.count);
    for (int playsToClear = 0; playsToClear < MAX(gamePlay.p1field.cards.count, gamePlay.p2field.cards.count); playsToClear++) {
        if (gamePlay.outcome == P1Wins) {
            n = p1field.cards.count;
            for (NSUInteger i = 0; i < n; i++) {
                c = [p1field.cards lastObject];
                sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:c]];
                [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:DELAYSPEED], [SKAction moveTo:[self handloc:P1] duration:DEALSPEED], [SKAction runBlock:^(void){
                    sprite.zPosition = 0;
                    [self flip:c];
                    [gamePlay.p1.cards insertObject:c atIndex:0];
                    [p1field.cards removeLastObject];
                    NSLog(@"%s, %lu!!", __func__, (unsigned long)p1field.cards.count);
                }], nil]]];
            }
            n = p2field.cards.count;
            for (NSUInteger i = 0; i < n; i++) {
                c = [p2field.cards lastObject];
                sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:c]];
                [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:DELAYSPEED], [SKAction moveTo:[self handloc:P1] duration:DEALSPEED], [SKAction runBlock:^(void){
                    sprite.zPosition = 0;
                    [self flip:c];
                    [gamePlay.p1.cards insertObject:c atIndex:0];
                    [p2field.cards removeLastObject];
                    NSLog(@"%s, %lu!!", __func__, (unsigned long)p2field.cards.count);
                }], nil]]];
            }
        } else if (gamePlay.outcome == P2Wins) {
            n = p1field.cards.count;
            for (NSInteger i = 0; i < n; i++) {
                c = [p1field.cards lastObject];
                sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:c]];
                [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:DELAYSPEED], [SKAction moveTo:[self handloc:P2] duration:DEALSPEED], [SKAction runBlock:^(void){
                    sprite.zPosition = 0;
                    [self flip:c];
                    [gamePlay.p2.cards insertObject:c atIndex:0];
                    [p1field.cards removeLastObject];
                    NSLog(@"%s, %lu!!", __func__, (unsigned long)p1field.cards.count);
                }], nil]]];
            }
            n = p2field.cards.count;
            for (NSInteger i = 0; i < n; i++) {
                c = [p2field.cards lastObject];
                sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:c]];
                [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:DELAYSPEED], [SKAction moveTo:[self handloc:P2] duration:DEALSPEED], [SKAction runBlock:^(void){
                    sprite.zPosition = 0;
                    [self flip:c];
                    [gamePlay.p2.cards insertObject:c atIndex:0];
                    [p2field.cards removeLastObject];
                    NSLog(@"%s, %lu!!", __func__, (unsigned long)p2field.cards.count);
                }], nil]]];
            }
        }
    }
    [self updateScores];
    gamePlay.gameState = WaitingForHandsToBePlayed;
    NSLog(@"%@", [self showState]);
}

- (void)notifyWinnerFound {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    msg.text = [gamePlay.outcomeToString stringByAppendingString:@", Play next card"];
    [self performSelector:@selector(clearField) withObject:nil afterDelay:1.5];
}

- (void)dealHands {
#ifdef DEBUG
        NSLog(@"%s", __func__);
#endif
    gamePlay.gameState = Dealing;
    [dealer shuffle];
    [self dealToPlayers];
    msg.text = @"Dealing...";
}

- (void)dealToPlayers {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    int p = P1;
    int z = 1;
    int loc = 0;
    NSMutableIndexSet *is1 = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *is2 = [NSMutableIndexSet indexSet];
    for (CardClass *card in dealer.cards) {
        CGPoint l = [self handloc:p];
        NSLog(@"%@, %.f, %.f", card.cardName, l.x, l.y);
        if (p == P1) {
            [is1 addIndex:loc++];
            p = P2;
        } else {
            p = P1;
            [is2 addIndex:loc++];
        }
        SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:card]];
        [sprite runAction:[SKAction moveTo:l duration:DEALSPEED]];
        sprite.zPosition = z;
        if (p == P1) z++;
    }
    [gamePlay.p1.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is1]];
    [gamePlay.p2.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is2]];
    [dealer.cards removeAllObjects];
    gamePlay.gameState = WaitingForHandsToBePlayed;
    [self updateScores];
}

- (void)sendToDealer {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CGPoint loc = [self deckloc];
    NSArray *fieldCards = [NSArray arrayWithObjects:p1field.cards, p2field.cards, gamePlay.p1.cards, gamePlay.p2.cards, nil];
    for (NSMutableArray *cards in fieldCards) {
        for (CardClass *card in cards) {
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:card]];
            [sprite runAction:[SKAction moveTo:loc duration:DEALSPEED]];
            [dealer.cards addObject:card];
        }
        [cards removeAllObjects];
    }
    gamePlay.gameState = NotStarted;
}

#pragma mark utilities

/*
 The logic for userInteractionEnabled appears to be inverted.
 Therefore interaction with the felt is disabled, but interaction
 with the labelnodes I'm using for buttons is not.
 */

- (Button *)addAButton:(NSString *)label {
    Button *button = [Button labelNodeWithFontNamed:@"Baskerville"];
    button.fontSize = self.fontsize;
    button.text = button.name = label;
    button.userInteractionEnabled = NO;
    [button setScale:1];
    //[self addChild:button.shadow];
    [self addChild:button];
    return button;
}

-(void)showGuides {
    Button *l;
    ADDBUTTON(l, @"ul", SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeLeft, [self ul]);
    ADDBUTTON(l, @"ur", SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeCenter, [self ur]);
    ADDBUTTON(l, @"middle", SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeCenter, [self middle]);
    ADDBUTTON(l, @"ll", SKLabelVerticalAlignmentModeBottom, SKLabelHorizontalAlignmentModeLeft, [self ll]);
    ADDBUTTON(l, @"lr", SKLabelVerticalAlignmentModeBottom, SKLabelHorizontalAlignmentModeRight, [self lr]);
    ADDBUTTON(l, @"mt", SKLabelVerticalAlignmentModeTop, SKLabelHorizontalAlignmentModeCenter, [self mt]);
    ADDBUTTON(l, @"mr", SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeRight, [self mr]);
    ADDBUTTON(l, @"mb", SKLabelVerticalAlignmentModeBottom, SKLabelHorizontalAlignmentModeCenter, [self mb]);
    ADDBUTTON(l, @"ml", SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeLeft, [self ml]);
}

@end
