//
//  NSArray_LINQ_Quantifier_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 23/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Quantifier_Tests : XCTestCase

@property (nonatomic, strong) NSArray *input_numbers;
@property (nonatomic, strong) NSArray *input_words;

@end

@implementation NSArray_LINQ_Quantifier_Tests

- (void)setUp {
    self.input_numbers = @[@1, @2, @3, @4, @5];
    self.input_words = @[@"A", @"AB", @"ABC", @"ABCD", @"ABCDE"];
}

- (void)tearDown {
    self.input_numbers = nil;
    self.input_words = nil;
}

- (void)test_all {
    BOOL result = [self.input_words linq_all:^BOOL(id item) {
        return ([item length] > 0);
    }];
    
    XCTAssertEqual(result, YES);
}

- (void)test_all_returns_true_when_empty {
    BOOL result = [[NSArray array] linq_all:^BOOL(id item) {
        return YES;
    }];
    
    XCTAssertEqual(result, YES);
}

- (void)test_all_returns_true_when_no_condition {
    BOOL result = [self.input_numbers linq_all:nil];
    XCTAssertEqual(result, YES);
}

- (void)test_any {
    BOOL result = [self.input_words linq_any:^BOOL(id item) {
        return ([item length] > 3);
    }];
    
    XCTAssertEqual(result, YES);
}

- (void)test_any_returns_false_when_empty {
    BOOL result = [[NSArray array] linq_any:^BOOL(id item) {
        return YES;
    }];
    
    XCTAssertEqual(result, NO);
}

- (void)test_any_returns_false_when_no_condition {
    BOOL result = [self.input_numbers linq_any:nil];
    XCTAssertEqual(result, NO);
}


@end

