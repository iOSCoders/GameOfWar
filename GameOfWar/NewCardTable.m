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

@interface NewCardTable() {
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
    [self displayCards:dealer at:[self deckloc] withScale:CARDSCALE];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    NSLog(@"node: %@", node.name);
    if ([dealer isTopCard:node.name]) {
        [self dealCards];
    } else if ([p1 isTopCard:node.name]) {
        [self playCard:p1 num:P1 at:[self playedcardloc:P1]];
    } else if ([p2 isTopCard:node.name]) {
        [self playCard:p2 num:P2 at:[self playedcardloc:P2]];
    } else if ([node.name isEqualToString:kPLAYAGAIN]) {
        [self reset];
    } else {
        abort();
    }
}

- (void)displayCards:(CardsClass *)c at:(CGPoint)p withScale:(CGFloat)sc {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CGPoint cp = p;
    for (CardClass *card in c.cards) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:card.imageName];
        sprite.position = cp;
        sprite.name = [card cardKey];
        [sprite setScale:sc];
        [self addChild:sprite];
    }
}

- (void)flipCard:(CardClass *)card toFace:(FaceUpDown)faceUpDown {
#ifdef DEBUG
    NSLog(@"%s", __func__);
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
    __block BOOL done = NO;
    int p = P1;
    int i = 0;
    NSMutableIndexSet *is1 = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *is2 = [NSMutableIndexSet indexSet];
    SKSpriteNode *sprite = nil;
    [dealer shuffle];
    for (CardClass *card in dealer.cards) {
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
            sprite.zPosition = i;
            done = YES;
        }], nil]]];
    }
    [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
        if (!done) printf("warning, previous action not complete.\n");
        [p1.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is1]];
        [p2.cards addObjectsFromArray:[dealer.cards objectsAtIndexes:is2]];
        [dealer.cards removeAllObjects];
    }];
}

- (void)playCard:(Player *)p num:(NSInteger)num at:(CGPoint)loc {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CardClass *card = [p.cards lastObject];
    SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
    [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
        [self flipCard:p.cards.lastObject];
        if (num == P1) {
            [p1field.cards addObject:p.cards.lastObject];
            sprite.zPosition = p1field.cards.count + 1;
        } else {
            [p2field.cards addObject:p.cards.lastObject];
            sprite.zPosition = p2field.cards.count + 1;
        }
        [p.cards removeLastObject];
    }], nil]]];
}

- (void)reset {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    // send field cards and player cards to dealer then shuffle them
    [self clearField];
}

- (void)clearField {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    CGPoint loc = [self deckloc];
    for (Player *p in [NSArray arrayWithObjects:p1field, p2field, p1, p2, nil]) {
        __block BOOL done = NO;
        NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
        int i = 0;
        for (CardClass *card in p.cards) {
            [is addIndex:i++];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            [sprite runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction moveTo:loc duration:DEALSPEED], [SKAction runBlock:^(void){
            }], nil]]];
        }
        [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
            if (!done) printf("warning, previous action not complete.\n");
            if (is.count > 0) {
                [dealer.cards addObjectsFromArray:[p.cards objectsAtIndexes:is]];
                [p.cards removeObjectsAtIndexes:is];
            }
        }];
    }
    [self runAction:[SKAction waitForDuration:DEALSPEED*2] completion:^(void){
        [dealer shuffle];
        for (int i = 0; i < dealer.cards.count; i++) {
            CardClass *card = dealer.cards[i];
            SKSpriteNode *sprite = (SKSpriteNode *)[self childNodeWithName:card.cardKey];
            sprite.zPosition = i + 1;
        }
    }];
}

@end
