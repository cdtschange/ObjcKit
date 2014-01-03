//
//  NSDictionary_LINQ_Partitioning_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 13/10/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSDictionary_LINQ_Partitioning_Tests : XCTestCase

@end

@implementation NSDictionary_LINQ_Partitioning_Tests

- (void)test_skip {
    NSDictionary *result = [[NSDictionary linq_from:1 to:10] linq_skip:5];
    XCTAssertEqual((int)[result count], 5);
}

- (void)test_take {
    NSDictionary *result = [[NSDictionary linq_from:1 to:10] linq_take:5];
    XCTAssertEqual((int)[result count], 5);
}

@end
