//
//  FSM.h
//  GameOfWar
//
//  Created by Joe Bologna on 11/26/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <Foundation/Foundation.h>

// GameFSM
typedef enum {
    GameNotStarted,
    GameInProgress,
    GameOver
} GameFSM;

// DealerFSM
typedef enum {
    WaitingToDeal,
    Dealing,
    Dealt
} DealerFSM;

// PlayerFSM
typedef enum {
    WaitingToPlayCard,
    WaitingForOtherPlayer,
    BothCardsPlayed
} PlayerFSM;

// HandFSM
typedef enum {
    NoWinnerYet,
    P1Wins,
    P2Wins,
    Draw
} HandFSM;

@interface FSM : NSObject

- (void)deal:(NSNumber *)done;

@end
