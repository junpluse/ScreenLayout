//
//  SCLLayoutTests.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLLayoutTests : XCTestCase

@end


#pragma mark -
@implementation SCLLayoutTests

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
    
    [SCLLayout activateConstraints:self.constraints];
}

- (void)tearDown
{
    [super tearDown];
    
    [SCLLayout deactivateConstraints:self.constraints];
}

- (void)testPointConversion
{
    NSArray *screens = self.screens;
    
    SCLScreen *screen1 = [screens firstObject];
    SCLScreen *screen2 = [screens lastObject];
    
    CGPoint original = CGPointZero;
    CGPoint point = original;
    
    point = [screen1 convertPoint:point toScreen:screen2];
    XCTAssertFalse(CGPointEqualToPoint(point, original));
    
    if (CGFLOAT_IS_DOUBLE) {
        point = [screen1 convertPoint:point fromScreen:screen2];
        XCTAssertTrue(CGPointEqualToPoint(point, original));
    }
}

- (void)testRectConversion
{
    NSArray *screens = self.screens;
    
    SCLScreen *screen1 = [screens firstObject];
    SCLScreen *screen2 = [screens lastObject];
    
    CGRect original = CGRectMake(0, 0, 10, 20);
    CGRect rect = original;
    
    rect = [screen1 convertRect:rect toScreen:screen2];
    XCTAssertFalse(CGRectEqualToRect(rect, original));

    if (CGFLOAT_IS_DOUBLE) {
        rect = [screen1 convertRect:rect fromScreen:screen2];
        XCTAssertTrue(CGRectEqualToRect(rect, original));
    }
}

- (void)testVectorConversion
{
    NSArray *screens = self.screens;
    
    SCLScreen *screen1 = [screens firstObject];
    SCLScreen *screen2 = [screens lastObject];
    
    CGVector original = CGVectorMake(10, 20);
    CGVector vector = original;
    
    vector = [screen1 convertVector:vector toScreen:screen2];
    XCTAssertFalse(SCLVectorEqualToVector(vector, original));

    vector = [screen1 convertVector:vector fromScreen:screen2];
    XCTAssertTrue(SCLVectorEqualToVector(vector, original));
}

- (void)testAngleConversion
{
    NSArray *screens = self.screens;
    
    SCLScreen *screen1 = [screens firstObject];
    SCLScreen *screen2 = [screens lastObject];
    
    CGFloat original = M_PI_2;
    CGFloat angle = original;
    
    angle = [screen1 convertAngle:angle toScreen:screen2];
    XCTAssertNotEqual(angle, original);
    
    if (CGFLOAT_IS_DOUBLE) {
        angle = [screen1 convertAngle:angle fromScreen:screen2];
        XCTAssertEqual(angle, original);
    }
}

@end
