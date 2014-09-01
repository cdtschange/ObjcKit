//
//  UIViewUtilitiesTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/17/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIView+Frame.h"

@interface UIView_FrameTests : XCTestCase

@end

@implementation UIView_FrameTests

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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2, 3, 4, 5)];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(20, 30, 40, 50)];
    [containerView addSubview:view];
    XCTAssertEqual(2, (int)view.left, @"UIView Utilities Fail");
    XCTAssertEqual(3, (int)view.top, @"UIView Utilities Fail");
    XCTAssertEqual(4, (int)view.width, @"UIView Utilities Fail");
    XCTAssertEqual(5, (int)view.height, @"UIView Utilities Fail");
    XCTAssertEqual(2+4, (int)view.right, @"UIView Utilities Fail");
    XCTAssertEqual(3+5, (int)view.bottom, @"UIView Utilities Fail");
    view.left = 3;
    view.top = 4;
    XCTAssertEqual(3, (int)view.left, @"UIView Utilities Fail");
    XCTAssertEqual(4, (int)view.top, @"UIView Utilities Fail");
    XCTAssertEqual(3+4, (int)view.right, @"UIView Utilities Fail");
    XCTAssertEqual(4+5, (int)view.bottom, @"UIView Utilities Fail");
    view.right = 4+4;
    view.bottom = 5+5;
    XCTAssertEqual(4, (int)view.left, @"UIView Utilities Fail");
    XCTAssertEqual(5, (int)view.top, @"UIView Utilities Fail");
    XCTAssertEqual(4+4, (int)view.right, @"UIView Utilities Fail");
    XCTAssertEqual(5+5, (int)view.bottom, @"UIView Utilities Fail");
    XCTAssertEqual(4+4/2, (int)view.centerX, @"UIView Utilities Fail");
    XCTAssertEqual(5+5/2, (int)view.centerY, @"UIView Utilities Fail");
    XCTAssertNotNil([view superview], @"UIView Utilities Fail");
    [containerView removeAllSubviews];
    XCTAssertNil([view superview], @"UIView Utilities Fail");
}

@end
