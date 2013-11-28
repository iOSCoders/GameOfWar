//
//  FSM.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/26/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM.h"

@interface FSM() {
    NSInteger iteration;
    GameFSM game;
    DealerFSM dealer;
    PlayerFSM p1, p2;
    HandFSM hand;
    NSInteger p1cards, p2cards;
    NSInteger p1score, p2score;
    NSInteger fieldcards;
    NSInteger decksize;
    NSInteger handsize;
    HandFSM testcase;
}

@end

@implementation FSM

- (const char *)gameStr {
    switch (game) {
        case GameNotStarted:
            return [@"GameNotStarted" UTF8String];
        case GameInProgress:
            return [@"GameInProgress" UTF8String];
        case GameOver:
            return [@"GameOver" UTF8String];
    }
}

- (const char *)dealerStr {
    switch (dealer) {
        case WaitingToDeal:
            return [@"WaitingToDeal" UTF8String];
        case Dealing:
            return [@"Dealing" UTF8String];
        case Dealt:
            return [@"Dealt" UTF8String];
    }
}

- (const char *)playerStr:(PlayerFSM)player {
    switch (player) {
        case WaitingToPlayCard:
            return [@"WaitingToPlayCard" UTF8String];
        case CardPlayed:
            return [@"CardPlayed" UTF8String];
    }
}

- (const char *)p1Str {
    return [self playerStr:p1];
}

- (const char *)p2Str {
    return [self playerStr:p2];
}

- (const char *)handStr {
    switch (hand) {
        case NoWinnerYet:
            return [@"NoWinnerYet" UTF8String];
        case P1Wins:
            return [@"P1Wins" UTF8String];
        case P2Wins:
            return [@"P2Wins" UTF8String];
        case Draw:
            return [@"Draw" UTF8String];
    }
}

- (id)init {
    if (self = [super init]) {
        iteration = 0;
        decksize = 10;
        handsize = decksize / 2;
        p1score = p2score = 0;
        testcase = P1Wins;
        [self reset];
        [self showState:YES];
    }
    return self;
}

- (void)reset {
    game = GameNotStarted;
    dealer = WaitingToDeal;
    hand = NoWinnerYet;
    p1 = p2 = WaitingToPlayCard;
    p1cards = p2cards = handsize;
    fieldcards = 0;
}

- (void)showState:(BOOL)withHeader {
    if (withHeader) {
        printf("\n");
        printf("p1score\tp2score\tp1cards\tp2cards\t  field\t             game\t           dealer\t               p1\t               p2\t             hand\n");
        printf("_______\t_______\t_______\t_______\t_______\t_________________\t_________________\t_________________\t_________________\t_________________\n");
    } else {
        printf("%7d\t%7d\t%7d\t%7d\t%7d\t%17.17s\t%17.17s\t%17.17s\t%17.17s\t%17.17s\n", p1score, p2score, p1cards, p2cards, fieldcards, [self gameStr], [self dealerStr], [self p1Str], [self p2Str], [self handStr]);
    }
}

- (void)deal {
// tap deal
    [self showState:NO];
    game = GameInProgress;
    dealer = Dealing;
    [self showState:NO];
    [self playcard:[NSNumber numberWithInteger:1]];
}

- (void)playcard:(NSNumber *)p {
    if ([p integerValue] == 1) {
        p1 = CardPlayed;
        fieldcards++;
        p1cards--;
        [self showState:NO];
    } else if ([p integerValue] == 2) {
        p2 = CardPlayed;
        fieldcards++;
        p2cards--;
        [self showState:NO];
    }
    if (p1 == CardPlayed && p2 == CardPlayed) {
        switch (iteration) {
            case 0:
                hand = P1Wins;
                p1 = p2 = WaitingToPlayCard;
                p1cards += fieldcards;
                fieldcards = 0;
                break;
                
            case 1:
                hand = P2Wins;
                p1 = p2 = WaitingToPlayCard;
                p2cards += fieldcards;
                fieldcards = 0;
                break;
                
            case 2:
                hand = Draw;
                p1 = p2 = WaitingToPlayCard;
                break;
                
            default:
                break;
        }
        [self showState:NO];
    }
    if (p1cards < decksize && p2cards < decksize) {
        if (p1 == CardPlayed) {
            [self playcard:[NSNumber numberWithInteger:2]];
        } else if (p2 == CardPlayed) {
            [self playcard:[NSNumber numberWithInteger:1]];
        } else {
            if (p1cards > 0) {
                [self playcard:[NSNumber numberWithInteger:1]];
            } else if (p2cards > 0) {
                [self playcard:[NSNumber numberWithInteger:2]];
            } else {
                abort();
            }
        }
    } else {
        game = GameOver;
        if (p1cards == decksize) {
            p1score++;
        } else if (p2cards == decksize) {
            p2score++;
        } else {
            abort();
        }
        [self showState:NO];
    }
    if (game == GameOver) {
        iteration++;
        switch (iteration) {
            case 1:
                testcase = P2Wins;
                [self deal];
                break;
                
            case 2:
                testcase = Draw;
                [self deal];
                break;
                
            default:
                // all done
                printf("All done.\n");
                break;
        }
    }
}

- (void)dealloc {
    printf("\n");
}

@end
