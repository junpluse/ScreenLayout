//
//  SCLScreenTests.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLScreenTests : XCTestCase

@property (readwrite, nonatomic, strong) SCLScreen *object;

@end


#pragma mark -
@implementation SCLScreenTests

- (void)setUp
{
    [super setUp];
    
    self.object = [[SCLScreen alloc] initWithName:@"Test Screen" bounds:CGRectMake(0, 0, 320, 480) scale:1.0 ppi:163.0 margins:SCLEdgeInsetsMake(10, 10, 10, 10)];
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
    XCTAssertEqualObjects(self.object.name, clone.name);
    XCTAssertTrue(CGRectEqualToRect(self.object.bounds, clone.bounds));
    XCTAssertEqual(self.object.scale, clone.scale);
    XCTAssertEqual(self.object.ppi, clone.ppi);
    XCTAssertTrue(SCLEdgeInsetsEqualToEdgeInsets(self.object.margins, clone.margins));
    XCTAssertEqualObjects(self.object.peerID, clone.peerID);
}

- (void)testCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    clone = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.name, clone.name);
    XCTAssertTrue(CGRectEqualToRect(self.object.bounds, clone.bounds));
    XCTAssertEqual(self.object.scale, clone.scale);
    XCTAssertEqual(self.object.ppi, clone.ppi);
    XCTAssertTrue(SCLEdgeInsetsEqualToEdgeInsets(self.object.margins, clone.margins));
    XCTAssertEqualObjects(self.object.peerID, clone.peerID);
}

- (void)testSecureCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver scl_archivedDataWithRootObject:self.object requiresSecureCoding:YES];
    clone = [NSKeyedUnarchiver scl_unarchiveObjectOfClass:[self.object class] data:archiveData requiresSecureCoding:YES];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.name, clone.name);
    XCTAssertTrue(CGRectEqualToRect(self.object.bounds, clone.bounds));
    XCTAssertEqual(self.object.scale, clone.scale);
    XCTAssertEqual(self.object.ppi, clone.ppi);
    XCTAssertTrue(SCLEdgeInsetsEqualToEdgeInsets(self.object.margins, clone.margins));
    XCTAssertEqualObjects(self.object.peerID, clone.peerID);
}

@end
