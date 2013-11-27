//
//  Suit.m
//  CardsApp
//
//  Created by Joe Bologna on 11/2/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "SuitClass.h"

@implementation SuitClass

- (id)init {
    if (self = [super init]) {
        _suits = [NSArray arrayWithObjects:@"C", @"D", @"H", @"S", nil];
    }
    return self;
}

+ (SuitClass *)suitWithSuit:(Suit)s {
    SuitClass *sc = [[self alloc] init];
    sc.suit = s;
    return sc;
}

- (NSString *)toString {
    return _suits[_suit];
}

@end
