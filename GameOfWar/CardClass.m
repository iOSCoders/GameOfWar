//
//  CardClass.m
//  CardsApp
//
//  Created by Joe Bologna on 11/2/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "CardClass.h"

@implementation CardClass

@dynamic cardName;
- (NSString *)cardName {
    return [NSString stringWithFormat:@"%@%.2ld", self.suitString, (long)self.value];
}

@dynamic imageName;
- (NSString *)imageName {
    return self.faceUpDown == FACE_UP ? self.cardName : @"back";
}

@dynamic ordinalValue;
- (NSInteger)ordinalValue {
    return (_suit * NSUITS) + _value;
}

- (id)init {
    if (self = [super init]) {
        self.faceUpDown = FACE_UP;
    }
    return self;
}

+ (CardClass *)cardWithSuit:(Suit)s value:(NSInteger)v faceUpDown:(FaceUpDown)faceUpDown {
    CardClass *cc = [[self alloc] init];
    cc.faceUpDown = faceUpDown;
    cc.suit = s;
    cc.value = v;
    return cc;
}

@dynamic suitString;
- (NSString *)suitString {
    return [[SuitClass suitWithSuit:_suit] toString];
}
@end
