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
    BOOL ready;
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
        ready = YES;
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
        backTexture = [SKTexture textureWithImage:back];
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

- (void)didEvaluateActions {
#ifdef DEBUG
    if ([self hasActions]) NSLog(@"%s, hasActions to complete.", __func__);
#endif
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (!ready) { printf("not ready\n"); return; }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    NSLog(@"node: %@", node.name);
    if (self.gameState == NotStarted && [self.dealer isTopCard:node.name]) {
        ready = NO;
        [self dealCards:0];
    } else if ((self.gameState == Dealt || self.gameState == P2CardPlayed) && [self.p1 isTopCard:node.name]) {
        ready = NO;
        [self playCard:self.p1];
    } else if ((self.gameState == Dealt || self.gameState == P1CardPlayed) && [self.p2 isTopCard:node.name]) {
        ready = NO;
        [self playCard:self.p2];
    } else if ([node.name isEqualToString:kPLAYAGAIN]) {
        ready = NO;
        [self clearField:0 player:self.p1field];
    } else if ([node.name isEqualToString:kP1SHUFFLE]) {
        ready = NO;
        [self moveInACircle];
    } else {
        //abort();
        [self dumpCards];
        printf("ignored\n");
    }
}

- (void)moveInACircle {
    if (self.dealer.cards.count > 0) {
        CardClass *card = [self.dealer.cards lastObject];
        SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        [sprite runAction:[SKAction moveTo:[self handloc:P1] duration:DEALSPEED] completion:^(void) {
            printf("movement to P1 complete\n");
            [sprite runAction:[SKAction moveTo:[self handloc:P2] duration:DEALSPEED] completion:^(void) {
                printf("movement to P2 complete\n");
                [sprite runAction:[SKAction moveTo:[self deckloc] duration:DEALSPEED] completion:^(void) {
                    printf("movement to dealer complete\n");
                    [self.dealer.cards removeLastObject];
                    [sprite removeFromParent];
                    ready = YES;
                }];
            }];
        }];
    } else {
        printf("No cards left.\n");
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
    card.faceUpDown = faceUpDown;
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
    sprite.texture = (faceUpDown == FACE_DOWN) ? backTexture : [SKTexture textureWithImageNamed:card.cardName];
}

- (void)dealCards:(NSInteger)num {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CardClass *card = self.dealer.cards[num];
    [self flipCard:card toFace:FACE_DOWN];
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
    [sprite runAction:[SKAction moveTo:[self handloc:(num % 2) == 0 ? P1 : P2] duration:DEALSPEED] completion:^(void) {
        [(num % 2) == 0 ? self.p1.cards : self.p2.cards addObject:self.dealer.cards[num]];
        sprite.zPosition = (num % 2) == 0 ? self.p1.cards.count : self.p2.cards.count;
        if (num < self.dealer.cards.count - 1) {
            [self dealCards:num + 1];
        } else {
            [self.dealer.cards removeAllObjects];
            self.gameState = Dealt;
            [self updateScore];
            ready = YES;
        }
    }];
}

- (void)playCard:(Player *)p {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CardClass *card = p.cards.lastObject;
    [self flipCard:card toFace:FACE_UP];
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
    [sprite runAction:[SKAction moveTo:[p isEqual:self.p1] ? [self playedcardloc:P1] : [self playedcardloc:P2] duration:DEALSPEED] completion:^(void) {
        sprite.zPosition = p.cards.count;
        [[p isEqual:self.p1] ? self.p1field.cards : self.p2field.cards addObject:p.cards.lastObject];
        [p.cards removeLastObject];
        if ([p isEqual:self.p1]) {
            self.gameState = self.gameState == P2CardPlayed ? BothCardsPlayed : P1CardPlayed;
        } else {
            self.gameState = self.gameState == P1CardPlayed ? BothCardsPlayed : P2CardPlayed;
        }
        if (self.gameState == BothCardsPlayed) {
            printf("check winner here\n");
            CardClass *card1 = self.p1field.cards.lastObject;
            CardClass *card2 = self.p2field.cards.lastObject;
            if (card1.value > card2.value) {
                self.gameState = P1Wins;
            } else if (card1.value < card2.value) {
                self.gameState = P2Wins;
            } else {
                self.gameState = Draw;
            }
            if (self.gameState != Draw) {
//                printf("move cards to %s\n", self.gameState == P1Wins ? "P1 Hand" : "P2 Hand");
                [self sendFieldFrom:self.p1field To:self.gameState == P1Wins ? self.p1 : self.p2 num:0];
            }
        }
        [self updateScore];
        ready = YES;
    }];
}

- (void)dumpNodes {
    for(SKNode *node in self.children) (void)NSLog(@"%@", node);
}

- (void)sendFieldFrom:(Player *)src To:(Player *)dest num:(NSInteger)num {
#ifdef DEBUG
    NSLog(@"%s, %@", __func__, [self gs:self.gameState]);
#endif
    if (src.cards.count == 0 || num == src.cards.count) {
        if ([src isEqual:self.p1field]) {
            [self sendFieldFrom:self.p2field To:dest num:0];
        } else {
            [self.p1field.cards removeAllObjects];
            [self.p2field.cards removeAllObjects];
            self.gameState = Dealt;
            [self updateScore];
            if (dest.cards.count == DECKSIZE) {
                [self clearField:0 player:self.p1field];
            } else {
                ready = YES;
            }
        }
    } else {
        CardClass *card = src.cards[num];
        [self flipCard:card toFace:FACE_DOWN];
        SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        [sprite runAction:[SKAction moveTo:[dest isEqual:self.p1] ? [self handloc:P1] : [self handloc:P2] duration:DEALSPEED] completion:^(void) {
            printf("put cards in the hand in the right order.\n");
            [dest.cards addObject:src.cards[num]];
            sprite.zPosition = dest.cards.count;
            [self sendFieldFrom:src To:dest num:num + 1];
        }];
    }
}

// move card from p1field, p2field, p1, p2 in order.
- (void)clearField:(NSInteger)num player:(Player *)p {
#ifdef DEBUG
    NSLog(@"%s, %@", __func__, [self gs:self.gameState]);
#endif
    if (p.cards.count == 0 || num == p.cards.count) {
        if ([p isEqual:self.p1field]) {
            [self clearField:0 player:self.p2field];
        } else if ([p isEqual:self.p2field]) {
            [self clearField:0 player:self.p1];
        } else if ([p isEqual:self.p1]) {
            [self clearField:0 player:self.p2];
        } else {
            [self.p1field.cards removeAllObjects];
            [self.p2field.cards removeAllObjects];
            [self.p1.cards removeAllObjects];
            [self.p2.cards removeAllObjects];
            self.gameState = NotStarted;
            [self updateScore];
            ready = YES;
        }
    } else {
        CardClass *card = p.cards[num];
        [self flipCard:card toFace:FACE_DOWN];
        SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
        [sprite runAction:[SKAction moveTo:[self deckloc] duration:DEALSPEED] completion:^(void) {
            [self.dealer.cards addObject:p.cards[num]];
            sprite.zPosition = self.dealer.cards.count;
            [self clearField:num + 1 player:p];
        }];
    }
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
