//
//  FSM.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/26/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM.h"

static int iteration = 0;

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
    } else {
        printf("%17.17s\t%17.17s\t%17.17s\t%17.17s\t%17.17s\n", [self gameStr], [self dealerStr], [self p1Str], [self p2Str], [self handStr]);
    }
}

- (void)hey {
    printf("hey.\n");
}

- (void)deal:(NSNumber *)done {
// tap deal
    [self showState:NO];
    if (![done boolValue]) {
        game = GameInProgress;
        dealer = Dealing;
        [self deal:[NSNumber numberWithBool:YES]];
        printf("\n");
    } else {
        dealer = Dealt;
        p1 = p2 = WaitingToPlayCard;
        [self showState:NO];
        [self playcards:[NSNumber numberWithInteger:1]];
    }
}

- (void)playcards:(NSNumber *)p {
    if ([p integerValue] == 1) {
        if (p2 == WaitingForOtherPlayer) {
            p1 = WaitingForOtherPlayer;
        }
        [self showState:NO];
        [self playcards:[NSNumber numberWithInteger:2]];
    } else if ([p integerValue] == 2) {
        if (p1 == WaitingForOtherPlayer) {
            p1 = p2 = BothCardsPlayed;
        }
        switch (iteration) {
            case 0:
                hand = P1Wins;
                break;
                
            case 1:
                hand = P2Wins;
                break;
                
            case 2:
                hand = Draw;
                break;
                
            default:
                break;
        }
        [self showState:NO];
        printf("%d\n", iteration);
        if (++iteration < 3) {
            hand = NoWinnerYet;
            p1 = p2 = WaitingToPlayCard;
            [self deal:[NSNumber numberWithBool:NO]];
        }
    } else {
        abort();
    }
}

- (void)dealloc {
    printf("\n");
}

@end
