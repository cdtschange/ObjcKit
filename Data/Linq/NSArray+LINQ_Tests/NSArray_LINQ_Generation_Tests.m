//
//  NSArray_LINQ_Generation_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Generation_Tests : XCTestCase

@end

@implementation NSArray_LINQ_Generation_Tests

- (void)test_empty {
    NSArray *result = [NSArray linq_empty];
    XCTAssertEqual((int)result.count, 0);
}

- (void)test_from_to_returns_empty_when_equal_parameters {
    NSArray *result = [NSArray linq_from:5 to:5];
    XCTAssertEqual((int)result.count, 0);
}

- (void)test_from_to_returns_when_ascending_both {
    NSInteger from = -1;
    NSInteger to = 5;
    [self aux_test_from_to_from:from to:to];
}

- (void)test_from_to_returns_when_ascending_negative {
    NSInteger from = -5;
    NSInteger to = -1;
    [self aux_test_from_to_from:from to:to];
}

- (void)test_from_to_returns_when_ascending_positive {
    NSInteger from = 1;
    NSInteger to = 5;
    [self aux_test_from_to_from:from to:to];
}

- (void)test_from_to_returns_when_descending_both {
    NSInteger from = 5;
    NSInteger to = -1;
    [self aux_test_from_to_from:from to:to];
}

- (void)test_from_to_returns_when_descending_negative {
    NSInteger from = -1;
    NSInteger to = -5;
    [self aux_test_from_to_from:from to:to];
}

- (void)test_from_to_returns_when_descending_positive {
    NSInteger from = 5;
    NSInteger to = 1;
    [self aux_test_from_to_from:from to:to];
}

- (void)aux_test_from_to_from:(NSInteger)from to:(NSInteger)to {
    NSArray *result = [NSArray linq_from:from to:to];
    
    NSInteger range = abs(from - to) + 1;
    XCTAssertEqual((int)result.count, range);
    XCTAssertEqual([[result objectAtIndex:0] intValue], from);
    XCTAssertEqual([[result objectAtIndex:(range - 1)] intValue], to);
}

- (void)test_repeat_count_returns_empty_when_no_element {
    NSArray *result = [NSArray linq_repeat:nil count:1];
    XCTAssertEqual((int)result.count, 0);
}

- (void)test_repeat_count_returns_empty_when_count_below_one {
    NSArray *result = [NSArray linq_repeat:@"Element" count:0];
    XCTAssertEqual((int)result.count, 0);
}

- (void)test_repeat {
    NSString *element = @"Element";
    NSArray *result = [NSArray linq_repeat:element count:5];
    XCTAssertEqual((int)result.count, 5);
    XCTAssertEqual(result[0], element);
    XCTAssertEqual(result[1], element);
    XCTAssertEqual(result[2], element);
    XCTAssertEqual(result[3], element);
    XCTAssertEqual(result[4], element);
}

@end

