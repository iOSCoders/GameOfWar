//
//  GamePlay.h
//  CardsApp
//
//  Created by Joe Bologna on 11/13/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"

typedef enum {UnknownOutcome, Draw, P1Wins, P2Wins} Outcome;
typedef enum {NotStarted, Dealing, WaitingForHandsToBePlayed, P1Played, P2Played, BothHandsPlayed, WinnerFound, WarInProgress, GameComplete} GameState;

@protocol GamePlayDelegate;

@interface GamePlay : NSObject

@property (unsafe_unretained, nonatomic) id <GamePlayDelegate> delegate;
@property (strong, nonatomic) Player *p1, *p2;
@property (strong, nonatomic) CardsClass *p1field, *p2field;
@property (unsafe_unretained, nonatomic) Outcome outcome;
@property (unsafe_unretained, nonatomic) GameState gameState;
@property (strong, nonatomic) NSString *outcomeToString;

- (Outcome)checkWinnerWith:(CardClass *)p1 and:(CardClass *)p2;
- (NSString *)outcomeToString;
- (NSString *)gameStateToString;
+ (GamePlay *)initWithP1:(Player *)p1 and:(Player *)p2 delegate:(id <GamePlayDelegate>)d;

- (void)startPlay;
- (void)dealCards;
- (GameState)playHands;
- (void)clearField;

@end

@protocol GamePlayDelegate <NSObject>

- (void)outcomeMsg:(NSString *)msg;

@end
