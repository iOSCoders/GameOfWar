//
//  FSM.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/26/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM+Util.h"

@interface FSM() {
    NSInteger iteration;
    NSInteger decksize;
    NSInteger handsize;
    HandFSM testcase;
    BOOL resetTested;
}

@end

@implementation FSM

- (void)showState:(BOOL)withHeader {
    if (withHeader) {
        printf("\n");
        printf("p1score\tp2score\tp1cards\tp2cards\t  field\t             game\t           dealer\t               p1\t               p2\t             hand\n");
        printf("_______\t_______\t_______\t_______\t_______\t_________________\t_________________\t_________________\t_________________\t_________________\n");
    } else {
        printf("%7d\t%7d\t%7d\t%7d\t%7d\t%17.17s\t%17.17s\t%17.17s\t%17.17s\t%17.17s\n", self.p1score, self.p2score, self.p1cards, self.p2cards, self.fieldcards, self.gameStr, self.dealerStr, self.p1Str, self.p2Str, self.handStr);
    }
}

- (id)init {
    if (self = [super init]) {
        [self showState:YES];
        iteration = 0;
        decksize = 10;
        handsize = decksize / 2;
        self.p1score = self.p2score = 0;
        testcase = P1Wins;
        self.game = GameNotStarted;
        resetTested = NO;
    }
    return self;
}

- (void)setGame:(GameFSM)game {
    printf("game: %s -> ", self.gameStr);
    _game = game;
    printf("%s\n", self.gameStr);
    if (_game == GameOver) {
        if ([self.delegate respondsToSelector:@selector(gameDidEnd)]) {
            [self.delegate gameDidEnd];
        }
    }
}

- (void)setDealer:(DealerFSM)dealer {
    printf("\tdealer: %s -> ", self.dealerStr);
    _dealer = dealer;
    printf("%s\n", self.dealerStr);
}

- (void)setP1:(PlayerFSM)p1 {
    BOOL ignored = p1 == _p1 == CardPlayed;
    printf("\t\tp1: %s -> ", self.p1Str);
    _p1 = p1;
    printf("%s%s\n", self.p1Str, ignored ? " (ignored)" : "");
    if (ignored && [self.delegate respondsToSelector:@selector(pleaseWait)]) {
        [self.delegate pleaseWait];
    }
}

- (void)setP2:(PlayerFSM)p2 {
    BOOL ignored = p2 == _p2 == CardPlayed;
    printf("\t\tp2: %s -> ", self.p2Str);
    _p2 = p2;
    printf("%s%s\n", self.p2Str, ignored ? " (ignored)" : "");
    if (ignored && [self.delegate respondsToSelector:@selector(pleaseWait)]) {
        [self.delegate pleaseWait];
    }
}

- (void)setHand:(HandFSM)hand {
    BOOL clearfield = hand != Draw;
    printf("\t\t\thand: %s -> ", self.handStr);
    _hand = hand;
    printf("%s%s\n", self.handStr, clearfield ? " [clearfield]" : "");
    // cards have been played, reset
    self.p1 = self.p2 = CardNotPlayed;
    if (clearfield) {
        if (_hand == P1Wins) {
            _p1cards += _fieldcards;
            self.fieldcards = 0;
        } else if (_hand == P2Wins) {
            _p2cards += _fieldcards;
            self.fieldcards = 0;
        } else {
            abort();
        }
        if ([self.delegate respondsToSelector:@selector(fieldDidClear)]) {
            [self.delegate fieldDidClear];
        }
    }
}

- (void)setFieldcards:(NSInteger)fieldcards {
    _fieldcards = fieldcards;
    printf(">>> p1cards\tp2cards\tf_cards\n");
    printf("    %7d\t%7d\t%7d\n", _p1cards, _p2cards, _fieldcards);
}

- (void)deal {
    self.dealer = Dealing;
    self.game = GameInProgress;
    self.p1cards = self.p2cards = handsize;
    self.fieldcards = 0;
    self.dealer = Dealt;
    // this simulates waiting for a touch.
    while (self.game == GameInProgress) {
        [self playcard:[NSNumber numberWithInteger:1]];
        [self playcard:[NSNumber numberWithInteger:1]];
        [self playcard:[NSNumber numberWithInteger:2]];
        // simulate user tapping deal button
        self.dealer = Dealing;
    }
}

- (void)playcard:(NSNumber *)p {
    if (_game == GameOver) return;
    if ([p integerValue] == 1) {
        self.p1 = CardPlayed;
        self.p1cards--;
        self.fieldcards++;
        if ([self.delegate respondsToSelector:@selector(p1PlayedCard)]) {
            [self.delegate p1PlayedCard];
        }
    } else if ([p integerValue] == 2) {
        self.p2 = CardPlayed;
        self.p2cards--;
        self.fieldcards++;
        if ([self.delegate respondsToSelector:@selector(p2PlayedCard)]) {
            [self.delegate p2PlayedCard];
        }
    } else {
        abort();
    }
    
    if (self.p1 == CardPlayed && self.p2 == CardPlayed) {
        switch (iteration++) {
            case 0:
                self.hand = P1Wins;
                break;
            case 1:
                self.hand = P2Wins;
                break;
            case 2:
                self.hand = Draw;
                break;
            default:
                self.hand = P1Wins;
                if (self.p1cards == decksize || self.p2cards == decksize) {
                    if (!resetTested) {
                        resetTested = YES;
                        self.game = GameReset;
                    } else {
                        self.game = GameOver;
                    }
                }
                break;
        }
    }
}

- (void)dealloc {
    printf("\n");
}

@end
