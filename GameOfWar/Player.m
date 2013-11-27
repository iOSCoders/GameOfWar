//
//  Player.m
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)init {
    if (self = [super init]) {
        self.score = 0;
    }
    return self;
}

+ (Player *)initPlayer {
    Player *p = [[Player alloc] init];
    p.cards = [NSMutableArray array];
    return p;
}

- (void)display {
    for (CardClass *c in self.cards) {
        NSLog(@"%@", c.suitString);
    }
}
@end
