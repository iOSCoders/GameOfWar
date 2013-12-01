//
//  Player.h
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "CardsClass.h"

@interface Player : CardsClass

@property (unsafe_unretained, atomic) NSInteger score;

+ (Player *)initPlayer;
- (void)display;

@end
