//
//  NewCardTable.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/28/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "NewCardTable.h"
#import "NewCardTable+Layout.h"
#import "FSM.h"
#import "Button.h"
#import "Player.h"

#define DEALSPEED (0.2)
#define FASTSPEED (0.02)
#define DELAYSPEED (0.75)
#define CARDSCALE (0.3)

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

@interface NewCardTable() <FSMDelegate> {
    FSM *fsm;
    SKTexture *backTexture;
    Button *p1Button, *p2Button, *reset, *msg, *p1score, *p2score, *p1shuffle, *p2shuffle, *p1wins, *p2wins, *dealButton;
    Player *dealer, *p1field, *p2field, *p1, *p2;
}
@end

@implementation NewCardTable

-(id)initWithSize:(CGSize)size {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (self = [super initWithSize:size]) {
        p1 = [Player initPlayer];
        p2 = [Player initPlayer];
        dealer = [Player initPlayer];
        [dealer initCards];
        p1field = [Player initPlayer];
        p2field = [Player initPlayer];
        fsm = [[FSM alloc] init];
        fsm.delegate = self;
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
//    ADDBUTTON(dealButton, kDEAL, SKLabelVerticalAlignmentModeCenter, SKLabelHorizontalAlignmentModeLeft, [self deckbuttonloc]);
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
    [self displayCards:dealer at:[self deckloc] withSpacing:0 withScale:CARDSCALE];
    fsm.game = GameNotStarted;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    NSLog(@"node: %@", node.name);
    if ([self card:node.name isOnTopOf:dealer] && fsm.dealer == WaitingToDeal) {
        [self dealHands];
        [fsm deal];
        fsm.p1cards = p1.cards.count;
        fsm.p2cards = p2.cards.count;
        fsm.fieldcards = 0;
    } else if ([self card:node.name isOnTopOf:p1] && fsm.dealer == Dealt && fsm.p1 == CardNotPlayed) {
        [self playCard:P1];
        [fsm playcard:[NSNumber numberWithInteger:P1]];
    } else if ([self card:node.name isOnTopOf:p2] && fsm.dealer == Dealt && fsm.p2 == CardNotPlayed) {
        [self playCard:P2];
        [fsm playcard:[NSNumber numberWithInteger:P2]];
    }
}

- (void)playCard:(NSInteger)player {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CGPoint loc;
    int z = 0;
    CardClass *c;
    if (player == P1) {
        c = ((CardClass *)p1.cards.lastObject);
        [p1field.cards addObject:c];
        [p1.cards removeLastObject];
        loc = [self playedcardloc:P1];
        z = p1field.cards.count + 1;
    } else {
        c = ((CardClass *)p2.cards.lastObject);
        [p2field.cards addObject:c];
        [p2.cards removeLastObject];
        loc = [self playedcardloc:P2];
        z = p2field.cards.count + 1;
    }
    
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:[self cardKey:c]];
    [self flip:c];

    [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
        sprite.zPosition = z;
        [self updateScores];
        if (player == P1) fsm.p1 = CardPlayed; else fsm.p2 = CardPlayed;
    }], nil]]];
}

- (void)dealHands {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
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
    [p1.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is1]];
    [p2.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is2]];
    [dealer.cards removeAllObjects];
    [self updateScores];
}

- (void)updateScores {
    [((Button *)[self childNodeWithName:kP1CARDS]) setText:[NSString stringWithFormat:@"(%lu)", (unsigned long)p1.cards.count]];
    [((Button *)[self childNodeWithName:kP2CARDS]) setText:[NSString stringWithFormat:@"(%lu)", (unsigned long)p2.cards.count]];
    [((Button *)[self childNodeWithName:kP1WINS]) setText:[NSString stringWithFormat:@"Wins: %lu", (unsigned long)p1.score]];
    [((Button *)[self childNodeWithName:kP2WINS]) setText:[NSString stringWithFormat:@"Wins: %lu", (unsigned long)p2.score]];
}

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

-(NSString *)cardKey:(CardClass *)c {
    return [kCARDPREFIX stringByAppendingString:c.cardName];
}

- (BOOL)itsACard:(NSString *)nodeName {
    return [nodeName rangeOfString:kCARDPREFIX].location == 0;
}

- (BOOL)card:(NSString *)name isOnTopOf:(Player *)p {
    if (p == nil) return NO;
    if (p.cards == nil || p.cards.count == 0) return NO;
    return [[self cardKey:[p.cards lastObject]] isEqualToString:name];
}

- (void)gameDidEnd {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)dealingDidEnd {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    msg.text = @"Play cards";
}

- (void)p1PlayedCard {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)p2PlayedCard {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)fieldShouldClear {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)pleaseWait {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}
@end
