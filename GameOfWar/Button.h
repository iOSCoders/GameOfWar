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

#define ADDBUTTON(tmp, name, v, h, p) tmp = [[Button alloc] init]; [tmp addButtonWithName:name andV:v andH:h andPosition:p toScene:self];
#define ADDBUTTON2(tmp, name, v, h, p, t) tmp = [[Button alloc] init]; [tmp addButtonWithName:name andV:v andH:h andPosition:p toScene:self]; tmp.text = t;

- (void)addButtonWithName:(NSString *)name andV:(SKLabelVerticalAlignmentMode)vm andH:(SKLabelHorizontalAlignmentMode)hm andPosition:(CGPoint)p toScene:(SKScene *)scene;

@end
