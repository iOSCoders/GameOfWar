//
//  NewCardTable+Layout.h
//  CardsApp
//
//  Created by Joe Bologna on 11/9/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "NewCardTable.h"

#define P1 1
#define P2 2

typedef struct {
    CGPoint ul;
    CGPoint ur;
    CGPoint middle;
    CGPoint lr;
    CGPoint ll;
    CGPoint mt;
    CGPoint mr;
    CGPoint mb;
    CGPoint ml;
} FrameWork;

@interface NewCardTable(Layout)

- (void)initMetricsWithSize:(CGSize)cs;

- (CGPoint)ul;
- (CGPoint)ur;
- (CGPoint)middle;
- (CGPoint)ll;
- (CGPoint)lr;
- (CGPoint)mt;
- (CGPoint)mr;
- (CGPoint)mb;
- (CGPoint)ml;
- (CGPoint)deckloc;
- (CGPoint)deckbuttonloc;
- (CGPoint)handloc:(NSInteger)player;
- (CGPoint)handbuttonloc:(NSInteger)player;
- (CGPoint)scoreloc:(NSInteger)player;
- (CGPoint)playedcardloc:(NSInteger)player;
- (CGPoint)msgloc;
- (CGPoint)resetloc;
- (CGPoint)shuffleloc:(NSInteger)player;
- (CGPoint)winsloc:(NSInteger)player;

@end
