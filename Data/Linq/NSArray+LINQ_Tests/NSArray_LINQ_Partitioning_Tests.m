//
//  NSArray_LINQ_Partitioning_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Partitioning_Tests : XCTestCase

@end

@implementation NSArray_LINQ_Partitioning_Tests

- (void)test_skip {
    NSArray *result = [[NSArray linq_from:1 to:10] linq_skip:5];
    XCTAssertEqual((int)result.count, 5);//contains(@6, @7, @8, @9, @10, nil)
}

- (void)test_take {
    NSArray *result = [[NSArray linq_from:1 to:10] linq_take:5];
    XCTAssertEqual((int)result.count, 5);//contains(@1, @2, @3, @4, @5, nil)
}

@end
