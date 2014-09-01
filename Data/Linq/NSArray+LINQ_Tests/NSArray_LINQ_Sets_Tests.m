//
//  NSArray_LINQ_Sets_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 23/06/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSArray_LINQ_Sets_Tests : XCTestCase

@end

@implementation NSArray_LINQ_Sets_Tests


- (void)test_distinct {
    NSArray *result = [@[@1, @1, @2, @2, @3, @4, @5] linq_distinct];
    XCTAssertEqual((int)result.count, 5);//contains(@1, @2, @3, @4, @5, nil)
}

- (void)test_distinct_returns_self_when_empty {
    NSArray *input = [NSArray array];
    NSArray *result = [input linq_distinct];
    XCTAssertEqual(result, input);
}

- (void)test_except {
    id result = [[NSArray linq_from:1 to:10] linq_except:[NSArray linq_from:6 to:10]];
    XCTAssertEqual((int)[result count], 5);//contains(@1, @2, @3, @4, @5, nil)
}

- (void)test_except_returns_self_when_empty {
    NSArray *input = [NSArray array];
    NSArray *other = [NSArray linq_from:6 to:10];
    NSArray *result = [input linq_except:other];
    XCTAssertEqual(result, input);
}

- (void)test_except_returns_self_when_other_empty {
    NSArray *input = [NSArray linq_from:1 to:5];
    NSArray *other = [NSArray array];
    NSArray *result = [input linq_except:other];
    XCTAssertEqual(result, input);
}

- (void)test_except_returns_self_when_other_nil {
    NSArray *input = [NSArray linq_from:1 to:5];
    NSArray *other = nil;
    NSArray *result = [input linq_except:other];
    XCTAssertEqual(result, input);
}

- (void)test_intersect {
    NSArray *input = [NSArray linq_from:1 to:8];
    NSArray *other = [NSArray linq_from:6 to:10];
    NSArray *result = [input linq_intersect:other];
    XCTAssertEqual((int)result.count, 3);//contains(@6, @7, @8, nil)
}

- (void)test_intersect_returns_self_when_empty {
    NSArray *input = [NSArray array];
    NSArray *other = [NSArray linq_from:6 to:10];
    NSArray *result = [input linq_intersect:other];
    XCTAssertEqual(result, input);
}

- (void)test_intersect_returns_self_when_other_empty {
    NSArray *input = [NSArray linq_from:6 to:10];
    NSArray *other =[NSArray array];
    NSArray *result = [input linq_intersect:other];
    XCTAssertEqual(result, input);
}

- (void)test_intersect_returns_self_when_other_nil {
    NSArray *input = [NSArray linq_from:6 to:10];
    NSArray *other =nil;
    NSArray *result = [input linq_intersect:other];
    XCTAssertEqual(result, input);
}

- (void)test_union {
    NSArray *input = [NSArray linq_from:1 to:8];
    NSArray *other = [NSArray linq_from:6 to:10];
    NSArray *result = [input linq_union:other];
    XCTAssertEqual((int)result.count, 10);//contains(@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, nil)
}

- (void)test_union_returns_other_when_empty {
    NSArray *input = [NSArray array];
    NSArray *other = [NSArray linq_from:6 to:10];
    NSArray *result = [input linq_union:other];
    XCTAssertEqual(result, other);
}

- (void)test_union_returns_self_when_other_empty {
    NSArray *input = [NSArray linq_from:1 to:8];
    NSArray *other = [NSArray array];
    NSArray *result = [input linq_union:other];
    XCTAssertEqual(result, input);
}

- (void)test_union_returns_self_when_other_nil {
    NSArray *input = [NSArray linq_from:1 to:8];
    NSArray *other = nil;
    NSArray *result = [input linq_union:other];
    XCTAssertEqual(result, input);
}


@end
