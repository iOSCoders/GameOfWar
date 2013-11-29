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
}
@end

@implementation NewCardTable

-(id)initWithSize:(CGSize)size {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    if (self = [super initWithSize:size]) {
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
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    NSLog(@"node: %@", node.name);
    if ([node.name isEqualToString:kDEAL]) {
        [fsm deal];
    } else if ([node.name isEqualToString:@"P1 Cards"]) {
        [fsm playcard:[NSNumber numberWithInteger:P1]];
    } else if ([node.name isEqualToString:@"P2 Cards"]) {
        [fsm playcard:[NSNumber numberWithInteger:P2]];
    }
}

- (void)gameDidEnd {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
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

- (void)fieldDidClear {
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
