//
//  NewCardTableLayout.m
//  CardsApp
//
//  Created by Joe Bologna on 11/9/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "NewCardTable+Layout.h"

#define STATUSLINEOFFSET 10

static CGSize spacing;
static CGSize inset;

static FrameWork framework;

@implementation NewCardTable(Layout)

- (void)initMetricsWithSize:(CGSize)cs {
    self.portrait = YES;
    inset = CGSizeMake([super frame].size.width * 0.075, [super frame].size.height * 0.075);
    self.cardSize = cs;
    spacing = CGSizeMake(self.fontsize/2, self.fontsize/2);

    CGRect f = self.frame;
    
    framework.ul = CGPointMake(inset.width, f.size.height - inset.height - STATUSLINEOFFSET);
    framework.ur = CGPointMake(f.size.width - inset.width, f.size.height - inset.height - STATUSLINEOFFSET);
    framework.middle = CGPointMake(f.size.width/2, f.size.height/2);
    framework.lr = CGPointMake(f.size.width - inset.width, inset.height);
    framework.ll = CGPointMake(inset.width, inset.height);
    framework.mt = CGPointMake(framework.middle.x, framework.ul.y);
    framework.mr = CGPointMake(framework.lr.x, framework.middle.y);
    framework.mb = CGPointMake(framework.middle.x, framework.ll.y);
    framework.ml = CGPointMake(framework.ll.x, framework.middle.y);
}

- (CGPoint)ul {
    return framework.ul;
}

- (CGPoint)ur {
    return framework.ur;
}

- (CGPoint)middle {
    return framework.middle;
}

- (CGPoint)ll {
    return framework.ll;
}

- (CGPoint)lr {
    return framework.lr;
}

- (CGPoint)mt {
    return framework.mt;
}

- (CGPoint)mr {
    return framework.mr;
}

- (CGPoint)mb {
    return framework.mb;
}

- (CGPoint)ml {
    return framework.ml;
}

- (CGPoint)deckloc {
    CGPoint p = [self deckbuttonloc];
    return CGPointMake(p.x + @"Deck".length * self.fontsize + self.fontsize, p.y);
}

- (CGPoint)deckbuttonloc {
    return self.ml;
}

- (CGPoint)handloc:(NSInteger)player {
    CGPoint p = [self handbuttonloc:player];
    if (player == P1) {
        return CGPointMake(p.x, p.y - self.cardSize.height);
    }
    if (player == P2) {
        return CGPointMake(p.x, p.y + self.cardSize.height);
    }
    abort();
}

- (CGPoint)handbuttonloc:(NSInteger)player {
    if (player == P1) {
        return self.mt;
    }
    if (player == P2) {
        return self.mb;
    }
    abort();
}

- (CGPoint)scoreloc:(NSInteger)player {
    if (player == P1) {
        return CGPointMake(framework.mt.x, framework.mt.y + self.fontsize);
    }
    if (player == P2) {
        return CGPointMake(framework.mb.x, framework.mb.y - self.fontsize/2);
    }
    abort();
}

- (CGPoint)playedcardloc:(NSInteger)player {
    if (player == P1) {
        return CGPointMake([self middle].x - self.cardSize.width/2 * 1.1, [self middle].y);
    }
    if (player == P2) {
        return CGPointMake([self middle].x + self.cardSize.width/2 * 1.1, [self middle].y);
    }
    abort();
}

- (CGPoint)msgloc {
    return CGPointMake([self handloc:P1].x, [self handloc:P1].y + self.fontsize*3.75);
//    return CGPointMake([self middle].x, [self middle].y + self.cardSize.height);
}

- (CGPoint)resetloc {
    return CGPointMake(framework.mr.x + self.fontsize, framework.mr.y);
}

- (CGPoint)shuffleloc:(NSInteger)player {
    if (player == P1) {
        return [self ul];
    }
    if (player == P2) {
        return [self ll];
    }
    abort();
}

- (CGPoint)winsloc:(NSInteger)player {
    if (player == P1) {
        return [self ur];
    }
    if (player == P2) {
        return [self lr];
    }
    abort();
}
@end
