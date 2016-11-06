//
//  SCLSessionMessageTests.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ScreenLayout.h"


#pragma mark -
@interface SCLSessionMessageTests : XCTestCase

@property (nonatomic, strong) SCLSessionMessage *object;

@end


#pragma mark -
@implementation SCLSessionMessageTests

- (void)setUp
{
    [super setUp];
    
    self.object = [[SCLSessionMessage alloc] initWithName:@"Test Message" object:@[[SCLScreen mainScreen]] ofClasses:@[[NSArray class], [SCLScreen class]]];
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
    XCTAssertEqualObjects(self.object.object, clone.object);
}

- (void)testCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.object];
    clone = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.name, clone.name);
    XCTAssertEqualObjects(self.object.object, clone.object);
}

- (void)testSecureCoding
{
    typeof(self.object) clone;
    
    NSData *archiveData = [NSKeyedArchiver scl_archivedDataWithRootObject:self.object requiresSecureCoding:YES];
    clone = [NSKeyedUnarchiver scl_unarchiveObjectOfClass:[self.object class] data:archiveData requiresSecureCoding:YES];
    
    XCTAssertEqualObjects(self.object, clone);
    XCTAssertEqualObjects(self.object.name, clone.name);
    XCTAssertEqualObjects(self.object.object, clone.object);
}

@end
