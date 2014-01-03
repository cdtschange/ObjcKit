//
//  LINQ_NSArray_Aggregation_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Aggregation_Tests : XCTestCase

@property (nonatomic, strong) NSArray *input_numbers;
@property (nonatomic, strong) NSArray *input_words;

@end

@implementation NSArray_LINQ_Aggregation_Tests

- (void)setUp {
    self.input_numbers = [NSArray linq_from:1 to:10];
    self.input_words = @[@"A", @"AB", @"ABC", @"ABCD", @"ABCDE"];
}

- (void)tearDown {
    self.input_numbers = nil;
    self.input_words = nil;
}

- (void)test_aggregate {
    NSArray *input = @[@"M", @"A", @"R", @"K"];
    NSString *result = [input linq_aggregate:^id(id item, id aggregate) {
        return [NSString stringWithFormat:@"%@, %@", aggregate, item];
    }];
    
    XCTAssertTrue([result isEqualToString: @"M, A, R, K"],@"Linq test Failed");
}

- (void)test_aggregate_returns_nil_when_empty {
    NSString *result = [[NSArray linq_empty] linq_aggregate:^id(id item, id aggregate) {
        return [NSString stringWithFormat:@"%@, %@", aggregate, item];
    }];
    
    XCTAssertNil(result, @"Linq test Failed");
}

- (void)test_aggregate_returns_self_when_no_accumulator {
    NSArray *input = @[@"M", @"A", @"R", @"K"];
    id result = [input linq_aggregate:nil];
    XCTAssertEqual(result,input,@"Linq test Failed");
}

- (void)test_avg {
    NSNumber *result = [self.input_numbers linq_avg];
    XCTAssertEqualWithAccuracy(result.floatValue, 5.5, 0.01,@"Linq test Failed");
}

- (void)test_avg_returns_zero_when_empty {
    NSNumber *result = [[NSArray linq_empty] linq_avg];
    XCTAssertEqualWithAccuracy(result.floatValue, 0.0, 0.01,@"Linq test Failed");
}

- (void)test_avgForKey {
    NSNumber *result = [self.input_words linq_avgForKey:@"length"];
    XCTAssertEqualWithAccuracy(result.floatValue, 3, 0.01,@"Linq test Failed");
}

- (void)test_count_returns_when_condition {
    NSInteger result = [self.input_numbers linq_count:^BOOL(id item) {
        return ([item compare:@8] != NSOrderedAscending);
    }];
    
    XCTAssertEqual(result, 3, @"Linq test Failed");
}

- (void)test_count_returns_when_no_condition {
    NSInteger result = [self.input_numbers linq_count:nil];
    XCTAssertEqual((int)result, (int)[self.input_numbers count],@"Linq test Failed");
}

- (void)test_max {
    NSNumber *result = [self.input_numbers linq_max];
    XCTAssertEqualWithAccuracy(result.floatValue, 10, 0.01,@"Linq test Failed");
}

- (void)test_max_returns_zero_when_empty {
    NSNumber *result = [[NSArray linq_empty] linq_max];
    XCTAssertEqualWithAccuracy(result.floatValue, 0, 0.01,@"Linq test Failed");
}

- (void)test_maxForKey {
    NSNumber *result = [self.input_words linq_maxForKey:@"length"];
    XCTAssertEqualWithAccuracy(result.floatValue, 5, 0.01,@"Linq test Failed");
}

- (void)test_min {
    NSNumber *result = [self.input_numbers linq_min];
    XCTAssertEqualWithAccuracy(result.floatValue, 1, 0.01,@"Linq test Failed");
}

- (void)test_min_returns_zero_when_empty {
    NSNumber *result = [[NSArray linq_empty] linq_min];
    XCTAssertEqualWithAccuracy(result.floatValue, 0, 0.01,@"Linq test Failed");
}

- (void)test_minForKey {
    NSNumber *result = [self.input_words linq_minForKey:@"length"];
    XCTAssertEqualWithAccuracy(result.floatValue, 1, 0.01,@"Linq test Failed");
}

- (void)test_sum_integers {
    NSNumber *result = [self.input_numbers linq_sum];
    XCTAssertEqualWithAccuracy(result.floatValue, 55, 0.01,@"Linq test Failed");
}

- (void)test_sum_double {
    NSNumber *result = [@[@1.25, @1.25, @3.3, @4.11] linq_sum];
    XCTAssertEqualWithAccuracy(result.floatValue, 9.91, 0.01,@"Linq test Failed");
}

- (void)test_sum_returns_zero_when_empty {
    NSNumber *result = [[NSArray linq_empty] linq_sum];
    XCTAssertEqualWithAccuracy(result.floatValue, 0, 0.01,@"Linq test Failed");
}

- (void)test_sumForKey {
    NSNumber *result = [self.input_words linq_sumForKey:@"length"];
    XCTAssertEqualWithAccuracy(result.floatValue, 15, 0.01,@"Linq test Failed");
}

- (void)test_sumForKey_returns_zero_when_empty {
    NSNumber *result = [[NSArray linq_empty] linq_sumForKey:@"someKey"];
    XCTAssertEqualWithAccuracy(result.floatValue, 0, 0.01,@"Linq test Failed");
}

@end

