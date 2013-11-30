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
    GameOver,
    GameReset
} GameFSM;

// DealerFSM
typedef enum {
    WaitingToDeal,
    Dealing,
    Dealt
} DealerFSM;

// PlayerFSM
typedef enum {
    CardNotPlayed,
    CardPlayed
} PlayerFSM;

// HandFSM
typedef enum {
    NoWinnerYet,
    P1Wins,
    P2Wins,
    Draw
} HandFSM;

@interface FSM : NSObject

@property (nonatomic, strong) id delegate;
@property (nonatomic, unsafe_unretained) GameFSM game;
@property (nonatomic, unsafe_unretained) DealerFSM dealer;
@property (nonatomic, unsafe_unretained) PlayerFSM p1, p2;
@property (nonatomic, unsafe_unretained) HandFSM hand;
@property (nonatomic, unsafe_unretained) NSInteger p1cards, p2cards;
@property (nonatomic, unsafe_unretained) NSInteger p1score, p2score;
@property (nonatomic, unsafe_unretained) NSInteger fieldcards;

- (void)deal;
- (void)dealTest;
- (void)playcard:(NSNumber *)p;
@end

@protocol FSMDelegate <NSObject>

@optional
- (void)gameDidEnd;
- (void)p1PlayedCard;
- (void)p2PlayedCard;
- (void)fieldShouldClear;
- (void)fieldDidClear;
- (void)pleaseWait;
- (void)dealingDidEnd;
@end
