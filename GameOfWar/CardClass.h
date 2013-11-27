//
//  CardClass.h
//  CardsApp
//
//  Created by Joe Bologna on 11/2/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

typedef enum {FACE_UP,FACE_DOWN} FaceUpDown;

#import <Foundation/Foundation.h>
#import "SuitClass.h"

#define NCARDS 13

@interface CardClass : NSObject

@property (unsafe_unretained, nonatomic) Suit suit;
@property (unsafe_unretained, nonatomic) FaceUpDown faceUpDown;
@property (strong, nonatomic) NSString  *suitString, *imageName, *cardName;
@property (unsafe_unretained, nonatomic) NSInteger value;
@property (unsafe_unretained, nonatomic) NSInteger ordinalValue;

+ (CardClass *)cardWithSuit:(Suit)s value:(NSInteger)v faceUpDown:(FaceUpDown)faceUpDown;

@end
