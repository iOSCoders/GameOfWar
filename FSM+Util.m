//
//  FSM+Util.m
//  GameOfWar
//
//  Created by Joe Bologna on 11/28/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM+Util.h"

@implementation FSM (Util)

- (const char *)gameStr {
    switch (self.game) {
        case GameNotStarted:
            return [@"GameNotStarted" UTF8String];
        case GameInProgress:
            return [@"GameInProgress" UTF8String];
        case GameOver:
            return [@"GameOver" UTF8String];
        case GameReset:
            return [@"GameReset" UTF8String];
    }
}

- (const char *)dealerStr {
    switch (self.dealer) {
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
        case CardNotPlayed:
            return [@"CardNotPlayed" UTF8String];
        case CardPlayed:
            return [@"CardPlayed" UTF8String];
    }
}

- (const char *)p1Str {
    return [self playerStr:self.p1];
}

- (const char *)p2Str {
    return [self playerStr:self.p2];
}

- (const char *)handStr {
    switch (self.hand) {
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

@end
