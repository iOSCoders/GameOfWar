//
//  Suit.h
//  CardsApp
//
//  Created by Joe Bologna on 11/2/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSUITS 4

typedef enum {
    Clubs,
    Diamonds,
    Hearts,
    Spades
} Suit;

@interface SuitClass : NSObject

@property (strong, nonatomic) NSArray *suits;
@property (unsafe_unretained, nonatomic) Suit suit;

+ (SuitClass *)suitWithSuit:(Suit)s;
- (NSString *)toString;

@end
