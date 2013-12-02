//
//  Button.h
//  CardsApp
//
//  Created by Joe Bologna on 11/22/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Button : SKLabelNode

@property (nonatomic, strong) SKShapeNode *shadow;

#define ADDBUTTON(tmp, name, v, h, p, w) tmp = [[Button alloc] init]; [tmp addButtonWithName:name andV:v andH:h andPosition:p toScene:self withShadow:w];
#define ADDBUTTON2(tmp, name, v, h, p, t, w) tmp = [[Button alloc] init]; [tmp addButtonWithName:name andV:v andH:h andPosition:p toScene:self withShadow:w]; tmp.text = t;

- (void)addButtonWithName:(NSString *)name andV:(SKLabelVerticalAlignmentMode)vm andH:(SKLabelHorizontalAlignmentMode)hm andPosition:(CGPoint)p toScene:(SKScene *)scene withShadow:(BOOL)withShadow;

@end
