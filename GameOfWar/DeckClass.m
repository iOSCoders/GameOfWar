//
//  DeckClass.m
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "DeckClass.h"

@implementation DeckClass

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

+ (DeckClass *)initDeck {
    DeckClass *d = [[DeckClass alloc] init];
    [d initCards];
    return d;
}

- (void)addPlayer:(Player *)player {
    [self.players addObject:player];
}

- (void)dealTo:(Player *)player {
    [player.cards addObject:[self.cards lastObject]];
    [self.cards removeLastObject];
}

@end
