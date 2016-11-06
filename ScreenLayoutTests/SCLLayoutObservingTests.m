//
//  SCLLayoutObservingTests.m
//  ScreenLayout
//
//  Created by Jun on 12/10/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLLayoutObservingTests : XCTestCase

@end


#pragma mark -
@implementation SCLLayoutObservingTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testObserverRegistration
{
    SCLScreen *screenA = [[SCLScreen alloc] initWithName:@"Test Screen #1" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
    SCLScreen *screenB = [[SCLScreen alloc] initWithName:@"Test Screen #2" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
    
    SCLLayoutConstraintItem *itemA = [[SCLLayoutConstraintItem alloc] initWithScreen:screenA anchor:CGPointMake(0.0, CGRectGetHeight(screenA.bounds) - CGRectGetWidth(screenA.bounds) / 2) rotation:M_PI_2];
    SCLLayoutConstraintItem *itemB = [[SCLLayoutConstraintItem alloc] initWithScreen:screenB anchor:CGPointMake(CGRectGetWidth(screenB.bounds) / 2, 0.0) rotation:M_PI];
    
    SCLLayoutConstraint *constraint = [[SCLLayoutConstraint alloc] initWithItems:@[itemA, itemB]];
    
    __block NSUInteger observeCount = 0;
    
    id observer = [SCLLayout addLayoutObserverWithBlock:^(NSArray *affectedScreens) {
        XCTAssertEqual(affectedScreens.count, 2);
        for (SCLScreen *screen in constraint.screens) {
            XCTAssertTrue([affectedScreens containsObject:screen]);
        }
        observeCount++;
    }];
    
    constraint.active = YES;
    XCTAssertEqual(observeCount, 1);

    constraint.active = NO;
    XCTAssertEqual(observeCount, 2);
    
    [SCLLayout removeLayoutObserver:observer];
    
    constraint.active = YES;
    XCTAssertEqual(observeCount, 2);
    
    constraint.active = NO;
    XCTAssertEqual(observeCount, 2);
}

@end
