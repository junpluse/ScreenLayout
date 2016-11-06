//
//  SCLLayoutPoolTests.m
//  ScreenLayout
//
//  Created by Jun on 12/5/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"
#import "SCLLayoutPool.h"


#pragma mark -
@interface SCLLayoutPoolTests : XCTestCase

@property (readwrite, nonatomic, strong) SCLLayoutPool *object;

@end


#pragma mark -
@implementation SCLLayoutPoolTests

- (NSArray *)screens
{
    static NSArray *screens = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < 4; i++) {
            NSString *name = [NSString stringWithFormat:@"Test Screen #%lu", (unsigned long)i];
            SCLScreen *screen = [[SCLScreen alloc] initWithName:name bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
            [array addObject:screen];
        }
        screens = [array copy];
    });
    
    return screens;
}

- (NSArray *)constraints
{
    static NSArray *constraints = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *screens = self.screens;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:screens.count - 1];
        
        for (NSUInteger i = 1; i < screens.count; i++) {
            SCLScreen *screenA = screens[i - 1];
            SCLScreen *screenB = screens[i];
            
            SCLLayoutConstraintItem *itemA = [[SCLLayoutConstraintItem alloc] initWithScreen:screenA anchor:CGPointMake(0.0, CGRectGetHeight(screenA.bounds) - CGRectGetWidth(screenA.bounds) / 2) rotation:M_PI_2];
            SCLLayoutConstraintItem *itemB = [[SCLLayoutConstraintItem alloc] initWithScreen:screenB anchor:CGPointMake(CGRectGetWidth(screenB.bounds) / 2, 0.0) rotation:M_PI];
            
            SCLLayoutConstraint *constraint = [[SCLLayoutConstraint alloc] initWithItems:@[itemA, itemB]];
            [array addObject:constraint];
        }
        
        constraints = [array copy];
    });
    
    return constraints;
}

- (void)setUp
{
    [super setUp];
    
    self.object = [[SCLLayoutPool alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAddConstraints
{
    NSArray *constraints = self.constraints;
    
    [self.object addConstraints:@[constraints.firstObject]];
    
    XCTAssertEqual(self.object.layouts.count, 1);
    XCTAssertEqual(self.object.screens.count, 2);
    XCTAssertEqual(self.object.constraints.count, 1);
    XCTAssertEqual([self.object.layouts.anyObject screens].count, 2);
    
    [self.object addConstraints:@[constraints.lastObject]];
    
    XCTAssertEqual(self.object.layouts.count, 2);
    XCTAssertEqual(self.object.screens.count, 4);
    XCTAssertEqual(self.object.constraints.count, 2);
    XCTAssertEqual([self.object.layouts.anyObject screens].count, 2);
    
    [self.object addConstraints:constraints];
    
    XCTAssertEqual(self.object.layouts.count, 1);
    XCTAssertEqual(self.object.screens.count, 4);
    XCTAssertEqual(self.object.constraints.count, 3);
    XCTAssertEqual([self.object.layouts.anyObject screens].count, 4);
}

- (void)testRemoveConstraints
{
    NSArray *constraints = self.constraints;
    
    [self.object addConstraints:constraints];
    
    XCTAssertEqual(self.object.layouts.count, 1);
    XCTAssertEqual(self.object.screens.count, 4);
    XCTAssertEqual(self.object.constraints.count, 3);
    
    [self.object removeConstraints:@[constraints[1]]];
    
    XCTAssertEqual(self.object.layouts.count, 2);
    XCTAssertEqual(self.object.screens.count, 4);
    XCTAssertEqual(self.object.constraints.count, 2);
    
    [self.object removeConstraints:@[constraints.lastObject]];
    
    XCTAssertEqual(self.object.layouts.count, 1);
    XCTAssertEqual(self.object.screens.count, 2);
    XCTAssertEqual(self.object.constraints.count, 1);
    
    [self.object removeConstraints:@[constraints.firstObject]];
    
    XCTAssertEqual(self.object.layouts.count, 0);
    XCTAssertEqual(self.object.screens.count, 0);
    XCTAssertEqual(self.object.constraints.count, 0);
}

@end
