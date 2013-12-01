//
//  NewCardTable.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/28/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "NewCardTable.h"
#import "NewCardTable+Layout.h"
#import "Button.h"
#import "Player.h"

#define DEALSPEED (0.2)
#define FASTSPEED (0.02)
#define DELAYSPEED (0.75)
#define CARDSCALE (0.3)

//#define DECKSIZE (NSUITS * NCARDS)
#define DECKSIZE 4

#define kDEAL @"Deal"
#define kPLAYAGAIN @"Play Again"
#define kFINISH_HAND @"Finish Hand"
#define kP1BUTTON @"P1"
#define kP2BUTTON @"P2"
#define kP1CARDS @"P1 Cards"
#define kP2CARDS @"P2 Cards"
#define kP1WINS @"P1 Wins"
#define kP2WINS @"P2 Wins"
#define kP1SHUFFLE @"P1 Shuffle"
#define kP2SHUFFLE @"P2 Shuffle"

typedef enum {
    NotStarted,
    Dealing,
    Dealt,
    P1CardPlayed,
    P2CardPlayed,
    BothCardsPlayed,
    CheckingWinner,
    P1Wins,
    P2Wins,
    Draw,
    ClearingWinningCards,
    Resetting
} GameState;

@interface NewCardTable() {
    SKTexture *backTexture;
    Button *p1Button, *p2Button, *reset, *msg, *p1score, *p2score, *p1shuffle, *p2shuffle, *p1wins, *p2wins, *dealButton;
//    NSInteger p1gameswon, p2gameswon;
}

@property (unsafe_unretained, nonatomic) GameState gameState;
@property (strong, atomic) Player *dealer, *p1field, *p2field, *p1, *p2;

@end

@implementation NewCardTable

-(id)initWithSize:(CGSize)size {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (self = [super initWithSize:size]) {
        self.gameState = NotStarted;
        self.p1 = [Player initPlayer];
        self.p2 = [Player initPlayer];
        self.dealer = [Player initPlayer];
        [self.dealer initCards];
        if (self.dealer.cards.count > DECKSIZE) {
            [self.dealer.cards removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(DECKSIZE, self.dealer.cards.count - DECKSIZE)]];
        }
        self.p1field = [Player initPlayer];
        self.p2field = [Player initPlayer];
        UIImage *back = [UIImage imageNamed:@"back"];
        self.fontsize = [UIFont systemFontSize] * 1.25;
        CGSize cs = CGSizeMake(back.size.width * CARDSCALE, back.size.height * CARDSCALE);
        [self initMetricsWithSize:cs];
    }
    return self;
}

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
    [self displayCards:self.dealer at:[self deckloc] withScale:CARDSCALE];
}

- (void)autoPlay {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (self.p1.cards.count > 1 || self.p2.cards.count > 1) {
        if (self.gameState != ClearingWinningCards) {
            [self playCard:self.p1 num:P1 at:[self playedcardloc:P1]];
            [self playCard:self.p2 num:P2 at:[self playedcardloc:P2]];
        }
        [self performSelector:@selector(autoPlay) withObject:nil afterDelay:DEALSPEED * 3];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    NSLog(@"node: %@", node.name);
    if (self.gameState == NotStarted && [self.dealer isTopCard:node.name]) {
        [self dealCards];
    } else if ((self.gameState == Dealt || self.gameState == P2CardPlayed) && [self.p1 isTopCard:node.name]) {
        [self playCard:self.p1 num:P1 at:[self playedcardloc:P1]];
    } else if ((self.gameState == Dealt || self.gameState == P1CardPlayed) && [self.p2 isTopCard:node.name]) {
        [self playCard:self.p2 num:P2 at:[self playedcardloc:P2]];
    } else if ([node.name isEqualToString:kPLAYAGAIN]) {
        [self clearField];
    } else if ([node.name isEqualToString:kP1SHUFFLE]) {
        [self autoPlay];
    } else {
        //abort();
        [self dumpCards];
        printf("ignored\n");
    }
}

- (void)dumpCards {
    SKSpriteNode *sprite;
    printf("p1:");
    for (CardClass *card in self.p1.cards) {
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        printf("\n%s@z:%f, %f, %f", [card.cardName UTF8String], sprite.zPosition, sprite.position.x, sprite.position.y);
    }
    printf("\np2:");
    for (CardClass *card in self.p2.cards) {
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        printf("\n%s@z:%f, %f, %f", [card.cardName UTF8String], sprite.zPosition, sprite.position.x, sprite.position.y);
    }
    printf("\np1field:");
    for (CardClass *card in self.p1field.cards) {
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        printf("\n%s@z:%f, %f, %f", [card.cardName UTF8String], sprite.zPosition, sprite.position.x, sprite.position.y);
    }
    printf("\np2field:");
    for (CardClass *card in self.p2field.cards) {
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        printf("\n%s@z:%f, %f, %f", [card.cardName UTF8String], sprite.zPosition, sprite.position.x, sprite.position.y);
    }
    printf("\ndealer:");
    for (CardClass *card in self.dealer.cards) {
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        printf("\n%s@z:%f, %f, %f", [card.cardName UTF8String], sprite.zPosition, sprite.position.x, sprite.position.y);
    }
    printf("\n");
}

- (void)displayCards:(CardsClass *)c at:(CGPoint)p withScale:(CGFloat)sc {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    assert(self.gameState == NotStarted);
    CGPoint cp = p;
    for (CardClass *card in c.cards) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:card.imageName];
        sprite.position = cp;
        sprite.name = [card cardKey];
        [sprite setScale:sc];
        [self addChild:sprite];
    }
    [self updateScore];
}

- (void)flipCard:(CardClass *)card toFace:(FaceUpDown)faceUpDown {
#ifdef DEBUG
//    NSLog(@"%s", __func__);
#endif
    if (card.faceUpDown == faceUpDown) {
        return;
    }
    [self flipCard:card];
}

- (void)flipCard:(CardClass *)card {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    card.faceUpDown = card.faceUpDown == FACE_DOWN ? FACE_UP : FACE_DOWN;
    SKSpriteNode *sprite = (SKSpriteNode *)[self.scene childNodeWithName:[card cardKey]];
    sprite.texture = card.faceUpDown == FACE_DOWN ? backTexture : [SKTexture textureWithImage:[UIImage imageNamed:card.imageName]];
}

- (void)dealCards {
#ifdef DEBUG
        NSLog(@"%s", __func__);
#endif
    [self dumpCards];
    assert(self.gameState == NotStarted);
    self.gameState = Dealing;
    __block BOOL done = NO;
    int p = P1;
    int i = 0;
    NSMutableIndexSet *is1 = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *is2 = [NSMutableIndexSet indexSet];
    SKSpriteNode *sprite = nil;
    [self.dealer shuffle];
    [self dumpCards];
    for (CardClass *card in self.dealer.cards) {
        [self flipCard:card toFace:FACE_DOWN];
        CGPoint loc = [self handloc:p];
        NSLog(@"%@, %.f, %.f", card.cardName, loc.x, loc.y);
        if (p == P1) {
            [is1 addIndex:i++];
            p = P2;
        } else {
            p = P1;
            [is2 addIndex:i++];
        }
        sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
            done = ![self hasActions];
        }], nil]]];
    }
    [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
        if (!done) printf("%s, warning, previous action not complete.\n", __func__);
        [self.p1.cards addObjectsFromArray:[self.dealer.cards objectsAtIndexes:is1]];
        [self.p2.cards addObjectsFromArray:[self.dealer.cards objectsAtIndexes:is2]];
        for (Player *p in [NSArray arrayWithObjects:self.p1, self.p2, nil]) {
            int j = 0;
            for (CardClass *card in p.cards) {
                SKSpriteNode *sprite2 = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
                sprite2.zPosition = j + 1;
                j++;
            }
        }
        [self.dealer.cards removeAllObjects];
        [self updateScore];
        self.gameState = Dealt;
        [self dumpCards];
    }];
}

- (void)playCard:(Player *)p num:(NSInteger)num at:(CGPoint)loc {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    assert(self.gameState == P1CardPlayed || self.gameState || P2CardPlayed || self.gameState == Dealt);
    __block BOOL done = NO;
    CardClass *card = [p.cards lastObject];
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
    [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
        [self flipCard:p.cards.lastObject toFace:FACE_UP];
        done = ![self hasActions];
    }], nil]]];
    [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
        if (!done) printf("%s, warning, previous action not complete.\n", __func__);
        if (num == P1) {
            [self.p1field.cards addObject:p.cards.lastObject];
            sprite.zPosition = self.p1field.cards.count + 1;
        } else {
            [self.p2field.cards addObject:p.cards.lastObject];
            sprite.zPosition = self.p2field.cards.count + 1;
        }
        [p.cards removeLastObject];
        [self updateScore];
        if (self.gameState == Dealt) {
            self.gameState = (num == P1) ? P1CardPlayed : P2CardPlayed;
        } else if (self.gameState == P1CardPlayed || self.gameState == P2CardPlayed) {
            self.gameState = BothCardsPlayed;
            [self actOnWinner];
        } else {
            abort();
        }
    }];
}

// send field cards and player cards to dealer then shuffle them
- (void)clearField {
#ifdef DEBUG
    NSLog(@"%s, %@", __func__, [self gs:self.gameState]);
#endif
    self.gameState = Resetting;
    CGPoint loc = [self deckloc];
    for (Player *p in [NSArray arrayWithObjects:self.p1field, self.p2field, self.p1, self.p2, nil]) {
        NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
        int i = 0;
        __block BOOL done = NO;
        for (CardClass *card in p.cards) {
            [self flipCard:card toFace:FACE_DOWN];
            done = NO;
            [is addIndex:i++];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
                done = ![self hasActions];
            }], nil]]];
        }
        [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
            if (!done) printf("%s, warning, previous action not complete.\n", __func__);
            if (is.count > 0) {
                [self.dealer.cards addObjectsFromArray:[p.cards objectsAtIndexes:is]];
                [p.cards removeObjectsAtIndexes:is];
            }
        }];
    }
    [self runAction:[SKAction waitForDuration:DEALSPEED*3] completion:^(void){
        [self.dealer shuffle];
        for (int i = 0; i < self.dealer.cards.count; i++) {
            CardClass *card = self.dealer.cards[i];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            sprite.zPosition = i + 1;
        }
        self.gameState = NotStarted;
        [self updateScore];
    }];
}

- (void)actOnWinner {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    assert(self.p1field && self.p1field.cards && self.p1field.cards.count > 0);
    assert(self.p2field && self.p2field.cards && self.p2field.cards.count > 0);
    assert(self.gameState == BothCardsPlayed);
    self.gameState = CheckingWinner;
    CardClass *pf1 = self.p1field.cards.lastObject;
    CardClass *pf2 = self.p2field.cards.lastObject;
    if (pf1.value > pf2.value) {
        [self sendFieldTo:P1];
    } else if (pf1.value < pf2.value) {
        [self sendFieldTo:P2];
    } else {
        self.gameState = Dealt;
    }
}

- (void)sendFieldTo:(NSInteger)player {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    self.gameState = ClearingWinningCards;
    CGPoint loc = [self handloc:player];
    Player *destPlayer = (player == P1) ? self.p1 : self.p2;
    for (Player *p in [NSArray arrayWithObjects:self.p1field, self.p2field, nil]) {
        NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
        int i = 0;
        __block BOOL done = NO;
        for (CardClass *card in p.cards) {
            [self flipCard:card toFace:FACE_DOWN];
            done = NO;
            [is addIndex:i++];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
                done = ![self hasActions];
            }], nil]]];
        }
        [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
            if (!done) printf("%s, warning, previous action not complete.\n", __func__);
            if (is.count > 0) {
                [destPlayer.cards addObjectsFromArray:[p.cards objectsAtIndexes:is]];
                [p.cards removeObjectsAtIndexes:is];
            }
            [self updateScore];
        }];
    }
    [self runAction:[SKAction waitForDuration:DEALSPEED*3] completion:^(void){
        for (int i = 0; i < destPlayer.cards.count; i++) {
            CardClass *card = destPlayer.cards[i];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            sprite.zPosition = i + 1;
        }
        [self updateScore];
        if (destPlayer.cards.count == DECKSIZE) {
            if (player == P1) {
                self.p1.score++;
            } else {
                self.p2.score++;
            }
            [self clearField];
        } else {
            self.gameState = Dealt;
        }
        [self updateScore];
    }];
}

#pragma mark -

- (void)setGameState:(GameState)gameState {
    NSLog(@"%@ -> %@", [self gs:_gameState], [self gs:gameState]);
    _gameState = gameState;
}

- (NSString *)gs:(GameState)s {
    switch (s) {
        case NotStarted: return @"NotStarted";
        case Dealing: return @"Dealing";
        case Dealt: return @"Dealt";
        case P1CardPlayed: return @"P1CardPlayed";
        case P2CardPlayed: return @"P2CardPlayed";
        case BothCardsPlayed: return @"BothCardsPlayed";
        case CheckingWinner: return @"CheckingWinner";
        case P1Wins: return @"P1Wins";
        case P2Wins: return @"P2Wins";
        case Draw: return @"Draw";
        case ClearingWinningCards: return @"ClearingWinningCards";
        case Resetting: return @"Resetting";
    }
}

- (void)updateScore {
    p1score.text = [NSString stringWithFormat:@"(%d)", self.p1.cards.count];
    p2score.text = [NSString stringWithFormat:@"(%d)", self.p2.cards.count];
    p1wins.text = self.p1.score == 0 ? @"No Games Won" : [NSString stringWithFormat:@"%d Games Won", self.p1.score];
    p2wins.text = self.p2.score == 0 ? @"No Games Won" : [NSString stringWithFormat:@"%d Games Won", self.p2.score];
    [self dumpCards];
}


@end
