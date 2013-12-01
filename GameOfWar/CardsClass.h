//
//  CardsClass.h
//  CardsApp
//
//  Created by Joe Bologna on 11/3/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardClass.h"

@interface CardsClass : NSObject

@property (strong, nonatomic) NSMutableArray *cards;

+ (CardsClass *)theCards;
- (void)initCards;
- (void)shuffle;
- (BOOL)isTopCard:(NSString *)name;

@end
