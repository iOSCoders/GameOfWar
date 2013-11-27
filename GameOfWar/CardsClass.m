//
//  CardsClass.m
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "CardsClass.h"

@implementation CardsClass

- (id)init {
    if (self = [super init]) {
        _cards = [NSMutableArray array];
    }
    return self;
}

+ (CardsClass *)theCards {
    CardsClass *cc = [[self alloc] init];
    [cc initCards];
    return cc;
}

- (void)initCards {
    _cards = [NSMutableArray array];
    for (int s = 0; s < NSUITS; s++) {
        for (int cv = 1; cv <= NCARDS; cv++) {
            CardClass *c = [CardClass cardWithSuit:(Suit)s value:cv faceUpDown:FACE_DOWN];
            [_cards addObject:c];
        }
    }
}

- (void)printDeck {
    for (int i = 0; i < self.cards.count; i++) {
        printf("%s\n", [((CardClass *)self.cards[i]).cardName UTF8String]);
    }
}

- (void)shuffle {
    assert(_cards != nil && _cards.count > 0);
    NSMutableArray *a = [NSMutableArray array];
    unsigned int t = (unsigned int)time(NULL);
    srandom(t);
    do {
        long r = random() % self.cards.count;
        [a addObject:self.cards[r]];
        [self.cards removeObjectAtIndex:r];
    } while (self.cards.count > 0);
    self.cards = a;
}

@end
