//
//  FSM+Util.h
//  GameOfWar
//
//  Created by Joe Bologna on 11/28/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "FSM.h"

@interface FSM (Util)

- (const char *)gameStr;
- (const char *)dealerStr;
- (const char *)playerStr:(PlayerFSM)player;
- (const char *)p1Str;
- (const char *)p2Str;
- (const char *)handStr;

@end
