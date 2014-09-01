//
//  NSDictionary_LINQ_Aggregation_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 12/10/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSDictionary_LINQ_Aggregation_Tests : XCTestCase

@property (nonatomic, strong) NSDictionary *input_numbers;
@property (nonatomic, strong) NSDictionary *input_words;

@end

@implementation NSDictionary_LINQ_Aggregation_Tests

- (void)setUp {
    self.input_numbers = [NSDictionary linq_from:1 to:10];
    self.input_words = @{@1: @"A", @2: @"AB", @3: @"ABC", @4: @"ABCD", @5: @"ABCDE"};
}

- (void)tearDown {
    self.input_numbers = nil;
    self.input_words = nil;
}

- (void)test_aggregate {
    NSNumber *result = [self.input_numbers linq_aggregate:^id(id item, id aggregate) {
        NSDecimalNumber *acc = [NSDecimalNumber decimalNumberWithDecimal:[aggregate decimalValue]];
        return [acc decimalNumberByMultiplyingBy:
                [NSDecimalNumber decimalNumberWithDecimal:[item decimalValue]]];
    }];
    
    XCTAssertEqual(result.intValue, 3628800);
}

- (void)test_aggregate_returns_nil_when_empty {
    NSString *result = [[NSDictionary linq_empty] linq_aggregate:^id(id item, id aggregate) {
        return [NSString stringWithFormat:@"%@, %@", aggregate, item];
    }];
    
    XCTAssertNil(result);
}

- (void)test_aggregate_returns_self_when_no_accumulator {
    NSDictionary *input = self.input_words;
    id result = [input linq_aggregate:nil];
    XCTAssertEqual(result, input);
}

- (void)test_avg {
    NSNumber *result = [self.input_numbers linq_avg];
    XCTAssertEqualWithAccuracy(result.floatValue, 5.5, 0.01);
}

- (void)test_avg_returns_zero_when_empty {
    NSNumber *result = [[NSDictionary linq_empty] linq_avg];
    XCTAssertEqual([result intValue], 0);
}

- (void)test_avgForKey {
    NSNumber *result = [self.input_words linq_avgForKey:@"length"];
    XCTAssertEqual(result.intValue, 3);
}

- (void)test_count_returns_when_condition {
    NSInteger result = [self.input_numbers linq_count:^BOOL(id item) {
        return ([item compare:@8] != NSOrderedAscending);
    }];
    
    XCTAssertEqual(result, 3);
}

- (void)test_count_returns_when_no_condition {
    NSInteger result = [self.input_numbers linq_count:nil];
    XCTAssertEqual((int)result, (int)[self.input_numbers count]);
}

- (void)test_max {
    NSNumber *result = [self.input_numbers linq_max];
    XCTAssertEqual(result.intValue, 10);
}

- (void)test_max_returns_zero_when_empty {
    NSNumber *result = [[NSDictionary linq_empty] linq_max];
    XCTAssertEqual(result.intValue, 0);
}

- (void)test_maxForKey {
    NSNumber *result = [self.input_words linq_maxForKey:@"length"];
    XCTAssertEqual(result.intValue, 5);
}

- (void)test_min {
    NSNumber *result = [self.input_numbers linq_min];
    XCTAssertEqual(result.intValue, 1);
}

- (void)test_min_returns_zero_when_empty {
    NSNumber *result = [[NSDictionary linq_empty] linq_min];
    XCTAssertEqual(result.intValue, 0);
}

- (void)test_minForKey {
    NSNumber *result = [self.input_words linq_minForKey:@"length"];
    XCTAssertEqual(result.intValue, 1);
}

- (void)test_sum_integers {
    NSNumber *result = [self.input_numbers linq_sum];
    XCTAssertEqual(result.intValue, 55);
}

- (void)test_sum_double {
    NSNumber *result = [@[@1.25, @1.25, @3.3, @4.11] linq_sum];
    XCTAssertEqualWithAccuracy(result.floatValue, 9.91, 0.01);
}

- (void)test_sum_returns_zero_when_empty {
    NSNumber *result = [[NSDictionary linq_empty] linq_sum];
    XCTAssertEqual(result.intValue, 0);
}

- (void)test_sumForKey {
    NSNumber *result = [self.input_words linq_sumForKey:@"length"];
    XCTAssertEqual(result.intValue, 15);
}

- (void)test_sumForKey_returns_zero_when_empty {
    NSNumber *result = [[NSDictionary linq_empty] linq_sumForKey:@"someKey"];
    XCTAssertEqual(result.intValue, 0);
}

@end
