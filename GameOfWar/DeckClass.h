//
//  DeckClass.h
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "Player.h"

@interface DeckClass : CardsClass

@property NSMutableArray *players;

+ (DeckClass *)initDeck;
- (void)addPlayer:(Player *)player;
- (void)dealTo:(Player *)player;

@end
