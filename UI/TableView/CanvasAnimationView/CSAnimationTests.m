//
//  CSAnimationTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/16/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSAnimationView.h"

@interface CSAnimationTests : XCTestCase

@end

@implementation CSAnimationTests

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

- (void)testExampleWithAnimateView:(UIView *)view
{
    CSAnimationView *csview = (CSAnimationView *)view;
    if (csview) {
        csview.duration = 0.5;
        csview.delay = 0;
        csview.type = CSAnimationTypeMorph;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell startCanvasAnimation];
    cell.backgroundColor = [UIColor clearColor];
}

@end
