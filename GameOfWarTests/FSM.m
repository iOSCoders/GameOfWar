//
//  FSM.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/26/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM.h"

@interface FSM() {
    GameFSM game;
    DealerFSM dealer;
    PlayerFSM p1, p2;
    HandFSM hand;
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
        case WaitingForOtherPlayer:
            return [@"WaitingForOtherPlayer" UTF8String];
        case BothCardsPlayed:
            return [@"BothCardsPlayed" UTF8String];
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
        game = GameNotStarted;
        dealer = WaitingToDeal;
        p1 = WaitingToPlayCard;
        p2 = WaitingToPlayCard;
        hand = NoWinnerYet;
        [self showState:YES];
    }
    return self;
}

- (void)showState:(BOOL)withHeader {
    if (withHeader) {
        printf("\n             game\t           dealer\t               p1\t               p2\t             hand\n");
        printf(  "_________________\t_________________\t_________________\t_________________\t_________________\n");
    }
    printf("%17.17s\t%17.17s\t%17.17s\t%17.17s\t%17.17s\n", [self gameStr], [self dealerStr], [self p1Str], [self p2Str], [self handStr]);
}

- (void)deal:(NSNumber *)done {
// tap deal
    game = GameInProgress;
    dealer = Dealing;
    [self showState:NO];
    if (![done boolValue]) {
        [self performSelector:@selector(deal:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
        printf("\n");
    }
}

- (void)dealloc {
    printf("\n");
}

@end
