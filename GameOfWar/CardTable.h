//
//  CardTable.h
//  CardsApp
//

//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GamePlay.h"

@interface CardTable : SKScene <GamePlayDelegate>

//- (void)rotate;

@property (unsafe_unretained, nonatomic) BOOL portrait;
@property (unsafe_unretained, nonatomic) CGSize cardSize;
@property (unsafe_unretained, nonatomic) CGFloat fontsize;


@end
