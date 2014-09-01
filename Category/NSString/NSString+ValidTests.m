//
//  NSStringUtilitiesTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 1/8/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Valid.h"

@interface NSString_ValidTests : XCTestCase

@end

@implementation NSString_ValidTests

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

- (void)testNSStringValid
{
    XCTAssertTrue([@"18612345678" validFormatChinaMobile]);
    XCTAssertFalse([@"12345678900" validFormatChinaMobile]);
    XCTAssertTrue([@"123@123.com" validFormatEmail]);
    XCTAssertFalse([@"1234@com" validFormatEmail]);
    XCTAssertTrue([@"123" validFormatNumber]);
    XCTAssertTrue([@".123" validFormatNumber]);
    XCTAssertTrue([@"0.123" validFormatNumber]);
    XCTAssertTrue([@"12.23" validFormatNumber]);
    XCTAssertTrue([@"-12.23" validFormatNumber]);
    XCTAssertTrue([@"-.23" validFormatNumber]);
    XCTAssertFalse([@"- .23" validFormatNumber]);
    XCTAssertFalse([@"a123" validFormatNumber]);
    XCTAssertFalse([@".1a3" validFormatNumber]);
}

@end
