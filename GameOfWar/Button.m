//
//  Button.m
//  CardsApp
//
//  Created by Joe Bologna on 11/22/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import "Button.h"

@interface Button() {
}

@end

@implementation Button

- (id)init {
    if (self = [super init]) {
        self.fontName = @"Baskerville";
        self.userInteractionEnabled = NO;
        self.scale = 1;
        self.fontSize = [UIFont systemFontSize];
        self.verticalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.shadow = [[SKShapeNode alloc] init];
        self.shadow.strokeColor = [UIColor colorWithRed:0.5 green:1 blue:0.5 alpha:.3];
        self.shadow.fillColor = [UIColor colorWithRed:0.5 green:1 blue:0.5 alpha:.3];
        self.zPosition = 0.5;
    }
    return self;
}

- (void)addButtonWithName:(NSString *)name andV:(SKLabelVerticalAlignmentMode)vm andH:(SKLabelHorizontalAlignmentMode)hm andPosition:(CGPoint)p toScene:(SKScene *)scene withShadow:(BOOL)withShadow {
    self.name = name;
    self.text = name;
    self.verticalAlignmentMode = vm;
    self.horizontalAlignmentMode = hm;
    self.position = p;
    [scene addChild:self];
    if (withShadow) {
        [scene addChild:self.shadow];
        self.shadow.path = CGPathCreateWithRect([self calculateAccumulatedFrame], NULL);
    }
}
@end
