//
//  NSArray_LINQ_Filtering_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Filtering_Tests : XCTestCase

@end

@implementation NSArray_LINQ_Filtering_Tests

- (void)test_ofType {
    NSArray *input = @[@"A", @1, @"B", @2];
    NSArray *result = [input linq_ofType:[NSString class]];
    
    XCTAssertEqual((int)result.count, 2);
}

- (void)test_where {
    
    NSArray *result = [[NSArray linq_from:1 to:10] linq_where:^BOOL(id item) {
        return (([item integerValue] % 2) == 0);
    }];
    
    XCTAssertEqual((int)result.count, 5);//contains(@2, @4, @6, @8, @10, nil)
}

- (void)test_where_returns_when_no_condition {
    NSArray *result = [[NSArray linq_from:1 to:5] linq_where:nil];
    XCTAssertEqual((int)[result count], 5);
}


@end