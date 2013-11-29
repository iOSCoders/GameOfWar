//
//  GameOfWarTests.m
//  GameOfWarTests
//
//  Created by Joe Bologna on 11/25/13.
//  Copyright (c) 2013 Joe Bologna. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSM.h"

@interface GameOfWarTests : XCTestCase <FSMDelegate>

@end

@implementation GameOfWarTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#ifdef NOTCOMMENTEDOUT
- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __func__);
}
#endif

- (void)testFSM {
    FSM *fsm = [[FSM alloc] init];
    fsm.delegate = self;
    do {
        [fsm dealTest];
    } while (fsm.game == GameReset);
    XCTAssertTrue(YES, @"...");
}

- (void)gameDidEnd {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)p1PlayedCard {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)p2PlayedCard {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)fieldDidClear {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (void)pleaseWait {
#ifdef DEBUG
    NSLog(@"%s", __func__);
#endif
}

@end
