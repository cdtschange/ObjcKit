//
//  UIDeviceUtilitiesTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/17/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIDevice+Utilities.h"

@interface UIDeviceUtilitiesTests : XCTestCase

@end

@implementation UIDeviceUtilitiesTests

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

- (void)testExample
{
    //iOS7 4Inch iPhone
    XCTAssertTrue(iOS_7_OR_LATER(), @"Device Utilities Fail");
    XCTAssertTrue(iOS_6_OR_LATER(), @"Device Utilities Fail");
    XCTAssertTrue(iOS_5_OR_LATER(), @"Device Utilities Fail");
    XCTAssertFalse(Screen_3_5_Inch(), @"Device Utilities Fail");
    XCTAssertTrue(Screen_4_Inch(), @"Device Utilities Fail");
    XCTAssertTrue(iPhone(), @"Device Utilities Fail");
    XCTAssertFalse(iPad(), @"Device Utilities Fail");
}

@end
