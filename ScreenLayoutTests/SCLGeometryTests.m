//
//  SCLGeometryTests.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLGeometryTests : XCTestCase

@end


#pragma mark -
@implementation SCLGeometryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testVectorFromAngle
{
    CGVector vector = SCLVectorFromAngleWithDistance(M_PI_2, 10);
    
    XCTAssertTrue(fabs(vector.dx) < 0.000001 && vector.dy == 10);
}

- (void)testAngleFromVector
{
    CGFloat angle = SCLAngleFromVector(CGVectorMake(0, 10));
    
    XCTAssertEqual(angle, (CGFloat)M_PI_2);
}

- (void)testAngleNormalize
{
    CGFloat angle;
    
    if (CGFLOAT_IS_DOUBLE) {
        angle = SCLAngleNormalize(M_PI + M_PI_2);
        XCTAssertEqual(angle, (CGFloat)-M_PI_2);
        
        angle = SCLAngleNormalize(M_PI_2 * 7);
        XCTAssertEqual(angle, (CGFloat)-M_PI_2);
    }
    else {
        angle = SCLAngleNormalize(M_PI + M_PI_2);
        XCTAssertTrue(fabsf(angle - -M_PI_2) < 0.000001);
        
        angle = SCLAngleNormalize(M_PI_2 * 7);
        XCTAssertTrue(fabsf(angle - -M_PI_2) < 0.000001);
    }
}

- (void)testRoundQuartery
{
    CGFloat angle;
    
    angle = SCLAngleRoundQuartery(3.0);
    XCTAssertEqual(angle, (CGFloat)M_PI);
    
    angle = SCLAngleRoundQuartery(-3.0);
    XCTAssertEqual(angle, (CGFloat)-M_PI);
}

- (void)testAngleDifference
{
    CGFloat angle;
    
    if (CGFLOAT_IS_DOUBLE) {
        angle = SCLAngleDifference(M_PI, M_PI_2);
        XCTAssertEqual(angle, M_PI_2);
        
        angle = SCLAngleDifference(-M_PI, M_PI_2);
        XCTAssertEqual(angle, M_PI_2);
    }
    else {
        angle = SCLAngleDifference(M_PI, M_PI_2);
        XCTAssertTrue(fabsf(angle - M_PI_2) < 0.000001);
        
        angle = SCLAngleDifference(-M_PI, M_PI_2);
        XCTAssertTrue(fabsf(angle - M_PI_2) < 0.000001);
    }
}

@end
