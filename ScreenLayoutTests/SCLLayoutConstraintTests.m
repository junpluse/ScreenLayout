//
//  SCLLayoutConstraintTests.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLLayoutConstraintTests : XCTestCase

@property (readwrite, nonatomic, strong) SCLLayoutConstraint *object;

@end


#pragma mark -
@implementation SCLLayoutConstraintTests

- (void)setUp
{
    [super setUp];
    
    SCLScreen *screenA = [[SCLScreen alloc] initWithName:@"Test Screen #1" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
    SCLScreen *screenB = [[SCLScreen alloc] initWithName:@"Test Screen #2" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
    
    SCLLayoutConstraintItem *itemA = [[SCLLayoutConstraintItem alloc] initWithScreen:screenA anchor:CGPointMake(0.0, CGRectGetHeight(screenA.bounds) - CGRectGetWidth(screenA.bounds) / 2) rotation:M_PI_2];
    SCLLayoutConstraintItem *itemB = [[SCLLayoutConstraintItem alloc] initWithScreen:screenB anchor:CGPointMake(CGRectGetWidth(screenB.bounds) / 2, 0.0) rotation:M_PI];
    
    SCLLayoutConstraint *constraint = [[SCLLayoutConstraint alloc] initWithItems:@[itemA, itemB]];
    
    self.object = constraint;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCopying
{
    typeof(self.object) clone;
    
    clone = [self.object copy];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.items, clone.items);
}

- (void)testCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    clone = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.items, clone.items);
}

- (void)testSecureCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver scl_archivedDataWithRootObject:self.object requiresSecureCoding:YES];
    clone = [NSKeyedUnarchiver scl_unarchiveObjectOfClass:[self.object class] data:archiveData requiresSecureCoding:YES];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.items, clone.items);
}

@end


#pragma mark -
@interface SCLLayoutConstraintItemTests : XCTestCase

@property (readwrite, nonatomic, strong) SCLLayoutConstraintItem *object;

@end


#pragma mark -
@implementation SCLLayoutConstraintItemTests

- (void)setUp
{
    [super setUp];
    
    SCLScreen *screen = [[SCLScreen alloc] initWithName:@"Test Screen #1" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsZero];
    
    SCLLayoutConstraintItem *item = [[SCLLayoutConstraintItem alloc] initWithScreen:screen anchor:CGPointMake(0.0, CGRectGetHeight(screen.bounds) - CGRectGetWidth(screen.bounds) / 2) rotation:M_PI_2];
    
    self.object = item;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCopying
{
    typeof(self.object) clone;
    
    clone = [self.object copy];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.screen, clone.screen);
    XCTAssertTrue(CGPointEqualToPoint(self.object.anchor, clone.anchor));
    XCTAssertEqual(self.object.rotation, clone.rotation);
}

- (void)testCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    clone = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.screen, clone.screen);
    XCTAssertTrue(CGPointEqualToPoint(self.object.anchor, clone.anchor));
    XCTAssertEqual(self.object.rotation, clone.rotation);
}

- (void)testSecureCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver scl_archivedDataWithRootObject:self.object requiresSecureCoding:YES];
    clone = [NSKeyedUnarchiver scl_unarchiveObjectOfClass:[self.object class] data:archiveData requiresSecureCoding:YES];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.screen, clone.screen);
    XCTAssertTrue(CGPointEqualToPoint(self.object.anchor, clone.anchor));
    XCTAssertEqual(self.object.rotation, clone.rotation);
}

@end
