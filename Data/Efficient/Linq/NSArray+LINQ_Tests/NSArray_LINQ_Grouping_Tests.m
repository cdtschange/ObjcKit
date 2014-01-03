//
//  NSArray_LINQ_Grouping_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 22/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Grouping_Tests : XCTestCase

@property (nonatomic, strong) NSArray *input_numbers;
@property (nonatomic, strong) NSArray *input_words;

@end

@implementation NSArray_LINQ_Grouping_Tests

- (void)setUp {
    self.input_numbers = [NSArray linq_from:1 to:10];
    self.input_words = @[@"Adam", @"Anthony",
                         @"Ben", @"Bob",
                         @"Michael", @"Max", @"Matt",
                         @"Simon"];
}

- (void)tearDown {
    self.input_numbers = nil;
    self.input_words = nil;
}

- (void)test_groupBy {
    NSDictionary *results = [self.input_words linq_groupBy:^id(id item) {
        return [item substringToIndex:1];
    }];
    
    XCTAssertEqual((int)results.count, 4);
    XCTAssertEqual((int)[results allKeys].count, 4);//containsInAnyOrder(@"A", @"B", @"M", @"S", nil)
    XCTAssertEqual((int)[[results objectForKey:@"A"] count], 2);//containsInAnyOrder(@"Adam", @"Anthony", nil)
    XCTAssertEqual((int)[[results objectForKey:@"B"] count], 2);//containsInAnyOrder(@"Ben", @"Bob", nil)
    XCTAssertEqual((int)[[results objectForKey:@"M"] count], 3);//containsInAnyOrder(@"Michael", @"Max", @"Matt", nil)
    XCTAssertEqual((int)[[results objectForKey:@"S"] count], 1);//containsInAnyOrder(@"Simon", nil)
}

- (void)test_toLookup {
    NSArray *results = [self.input_words linq_toLookup:^id(id item) {
        return [item substringToIndex:1];
    }];
    
    XCTAssertEqual((int)results.count, 8);
    XCTAssertEqual((int)[[results linq_lookup:@"A"] count], 2);
    XCTAssertEqual((int)[[results linq_lookup:@"B"] count], 2);
    XCTAssertEqual((int)[[results linq_lookup:@"M"] count], 3);
    XCTAssertEqual((int)[[results linq_lookup:@"S"] count], 1);
    
    XCTAssertTrue([[[results linq_lookup:@"S"][0] valueForKey:@"S"] isEqualToString: @"Simon"]);
}


@end
