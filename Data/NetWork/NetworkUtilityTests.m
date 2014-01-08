//
//  NetworkUtilityTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 1/8/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NetworkUtility.h"

@interface NetworkUtilityTests : XCTestCase

@end

@implementation NetworkUtilityTests

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

- (void)testNetworkUtility
{
    XCTAssertTrue([NetworkUtility isNetworkReachable]);
}

@end
