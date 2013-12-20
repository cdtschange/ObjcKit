//
//  VectorTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/19/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Vector.h"

@interface VectorTests : XCTestCase

@end

@implementation VectorTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testVector
{
    Vector v1 = VectorMake(2, 1);
    Vector v1n = [VectorUtils normalVector:v1];
    XCTAssertTrue(VectorEqual(v1n, VectorMake(1, -2)), @"Vector test fail");

    Vector v3 = VectorMake(0, 2);
    Vector v3p = [VectorUtils projectionVector:v3 toVector:v1];
    XCTAssertTrue(VectorEqual(v3p, VectorMake(0.8, 0.4)), @"Vector test fail");
}

@end
