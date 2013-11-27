//
//  GamePlay.m
//  CardsApp
//
//  Created by Joe Bologna on 11/13/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "GamePlay.h"

@implementation GamePlay

- (id)init {
    if (self = [super init]) {
        self.outcome = UnknownOutcome;
        self.gameState = NotStarted;
        self.delegate = nil;
    }
    return self;
}

+ (GamePlay *)initWithP1:(Player *)p1 and:(Player *)p2 delegate:(id <GamePlayDelegate>)d {
    GamePlay *g = [[GamePlay alloc] init];
    g.p1 = p1;
    g.p2 = p2;
    g.p1field = [[CardsClass alloc] init];
    g.p2field = [[CardsClass alloc] init];
    g.delegate = d;
    return g;
}

- (Outcome)checkWinnerWith:(CardClass *)p1 and:(CardClass *)p2 {
#define FACECARDSARE10
#ifdef FACECARDSARE10
    long p1value = MIN(10, p1.value);
    long p2value = MIN(10, p2.value);
#else
    long p1value = p1.value;
    long p2value = p2.value;
#endif
    printf("p1value: %ld, p2value: %ld\n", p1value, p2value);
    if (p1value == p2value) {
        self.outcome = Draw;
    } else if (p1value > p2value) {
        self.outcome = P1Wins;
    } else if (p1value < p2value) {
        self.outcome = P2Wins;
    } else {
        self.outcome = UnknownOutcome;
    }
    [self.delegate outcomeMsg:[self outcomeToString]];
    return self.outcome;
}

- (NSString *)outcomeToString {
    switch(self.outcome) {
        case UnknownOutcome: return @"UnknownOutcome";
        case Draw: return @"Draw";
        case P1Wins: return @"P1Wins";
        case P2Wins: return @"P2Wins";
    }
}

- (NSString *)gameStateToString {
    switch(self.gameState) {
        case NotStarted: return @"NotStarted";
        case Dealing: return @"Dealing";
        case WaitingForHandsToBePlayed: return @"WaitingForHandsToBePlayed";
        case BothHandsPlayed: return @"BothHandsPlayed";
        case P1Played: return @"P1Played";
        case P2Played: return @"P2Played";
        case WinnerFound: return @"WinnerFound";
        case WarInProgress: return @"WarInProgress";
        case GameComplete: return @"GameComplete";
    }
}

- (void)startPlay {
    self.gameState = Dealing;
    // deal cards
#define SHUFFLEAFTER 10
    NSInteger timeToShuffle = SHUFFLEAFTER;
    NSInteger handsPlayed = 0;
    [self dealCards];
    while (self.gameState != GameComplete) {
        do {
            handsPlayed++;
            NSString *before = [self gameStateToString];
            self.gameState = [self playHands];
            NSString *after = [[self gameStateToString] stringByAppendingFormat:@" %@", [self outcomeToString]];
            printf("%s -> %s (%lu, %lu, %lu, %lu)\n", [before UTF8String], [after UTF8String], (unsigned long)self.p1.cards.count, (unsigned long)self.p2.cards.count, (unsigned long)self.p1field.cards.count, (unsigned long)self.p2field.cards.count);
            if (self.gameState == WinnerFound) [self clearField];
            if (--timeToShuffle == 0 && self.p1.cards.count > 0 && self.p2.cards.count > 0) {
                printf("shuffling...\n");
                timeToShuffle = SHUFFLEAFTER;
                [self.p1 shuffle];
                [self.p2 shuffle];
            }
        } while (self.gameState == WinnerFound);
        printf("%s (%lu, %lu, %lu, %lu)\n", [[self gameStateToString] UTF8String], (unsigned long)self.p1.cards.count, (unsigned long)self.p2.cards.count, (unsigned long)self.p1field.cards.count, (unsigned long)self.p2field.cards.count);
        printf("%s, handsPlayed: %ld\n", [[self outcomeToString] UTF8String], (long)handsPlayed);
    }
}

// give each player 1/2 the deck.
- (void)dealCards {
    assert(self.p1 != nil);
    assert(self.p2 != nil);
    assert(self.p1.cards.count == 0);
    assert(self.p2.cards.count == 0);
    assert(self.p1field.cards.count == 0);
    assert(self.p2field.cards.count == 0);
    self.gameState = Dealing;
    CardsClass *deck = [CardsClass theCards];
    [deck shuffle];
    self.p1.cards = [NSMutableArray arrayWithArray:[deck.cards subarrayWithRange:NSMakeRange(0, 26)]];
    self.p2.cards = [NSMutableArray arrayWithArray:[deck.cards subarrayWithRange:NSMakeRange(26, 26)]];
    self.gameState = WaitingForHandsToBePlayed;
}

- (GameState)playHands {
    [self.p1field.cards addObject:[self.p1.cards lastObject]];
    NSLog(@"%s, add to p1: %lu", __func__, (unsigned long)self.p1field.cards.count);
    [self.p2field.cards addObject:[self.p2.cards lastObject]];
    NSLog(@"%s, add to p2: %lu", __func__, (unsigned long)self.p2field.cards.count);
    [self.p1.cards removeLastObject];
    [self.p2.cards removeLastObject];
    self.outcome = [self checkWinnerWith:self.p1field.cards.lastObject and:self.p2field.cards.lastObject];
    if (self.p1.cards.count == 0 || self.p2.cards.count == 0) {
        self.gameState = GameComplete;
    } else if (self.outcome == P1Wins || self.outcome == P2Wins) {
        self.gameState = WinnerFound;
    } else  if (self.outcome == Draw) {
        self.gameState = WarInProgress;
//        [self.p1 shuffle];
//        [self.p2 shuffle];
    } else {
        NSLog(@"%s, something strange happened", __func__);
        abort();
    }
    return self.gameState;
}

- (void)clearField {
    if (self.outcome == P1Wins) {
        [self.p1.cards addObjectsFromArray:self.p1field.cards];
        [self.p1.cards addObjectsFromArray:self.p2field.cards];
        [self.p1field.cards removeAllObjects];
        NSLog(@"%s, %lu!!", __func__, (unsigned long)self.p1field.cards.count);
        [self.p2field.cards removeAllObjects];
        NSLog(@"%s, %lu!!", __func__, (unsigned long)self.p2field.cards.count);
        self.gameState = WinnerFound;
    } else if (self.outcome == P2Wins) {
        [self.p2.cards addObjectsFromArray:self.p1field.cards];
        [self.p2.cards addObjectsFromArray:self.p2field.cards];
        [self.p1field.cards removeAllObjects];
        NSLog(@"%s, %lu!!", __func__, (unsigned long)self.p1field.cards.count);
        [self.p2field.cards removeAllObjects];
        NSLog(@"%s, %lu!!", __func__, (unsigned long)self.p2field.cards.count);
        self.gameState = WinnerFound;
    } else if (self.outcome == Draw) {
        // do nothing.
    } else {
        NSLog(@"outcome = %s, something strange happened", [[self outcomeToString] UTF8String]);
        abort();
    }
}

@end
