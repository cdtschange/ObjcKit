//
//  NSDictionary_LINQ_Sets_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 13/10/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSDictionary_LINQ_Sets_Tests : XCTestCase

@end

@implementation NSDictionary_LINQ_Sets_Tests

- (void)test_distinct {
    NSDictionary *result = [@{@1: @1, @2: @2, @3: @3, @4: @2} linq_distinct];

    XCTAssertEqual((int)[result count], 3);
    XCTAssertEqual((int)[[result allValues] count], 3);//containsInAnyOrder(@1, @2, @3, nil)
}

- (void)test_distinct_returns_self_when_empty {
    NSDictionary *input = [NSDictionary linq_empty];
    NSDictionary *result = [input linq_distinct];
    
    XCTAssertEqual((int)[result count], 0);
    XCTAssertEqual(result, input);
}

- (void)test_except {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = [NSDictionary linq_from:3 to:10];
    NSDictionary *result = [input linq_except:other];
    
    XCTAssertEqual((int)[result count], 2);
    XCTAssertEqual((int)[[result allValues] count], 2);//containsInAnyOrder(@1, @2, nil)
}

- (void)test_except_returns_self_when_empty {
    NSDictionary *input = [NSDictionary linq_empty];
    NSDictionary *other = [NSDictionary linq_from:3 to:10];
    NSDictionary *result = [input linq_except:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_except_returns_self_when_other_empty {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = [NSDictionary linq_empty];
    NSDictionary *result = [input linq_except:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_except_returns_self_when_other_nil {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = nil;
    NSDictionary *result = [input linq_except:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_intersect {
    NSDictionary *input = [NSDictionary linq_from:1 to:8];
    NSDictionary *other = [NSDictionary linq_from:6 to:10];
    NSDictionary *result = [input linq_intersect:other];
    
    XCTAssertEqual((int)[result count], 3);
    XCTAssertEqual((int)[[result allValues] count], 3);//containsInAnyOrder(@6, @7, @8, nil)
}

- (void)test_intersect_returns_self_when_empty {
    NSDictionary *input = [NSDictionary linq_empty];
    NSDictionary *other = [NSDictionary linq_from:3 to:10];
    NSDictionary *result = [input linq_intersect:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_intersect_returns_self_when_other_empty {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = [NSDictionary linq_empty];
    NSDictionary *result = [input linq_intersect:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_intersect_returns_self_when_other_nil {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = nil;
    NSDictionary *result = [input linq_intersect:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_merge {
    NSDictionary *input = [NSDictionary linq_from:1 to:8];
    NSDictionary *other = [NSDictionary linq_from:1 to:10];
    NSDictionary *result = [input linq_merge:other];
    
    XCTAssertEqual((int)[result count], 10);
    XCTAssertEqual((int)[[result allValues] count], 10);//containsInAnyOrder(@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, nil)
}

- (void)test_merge_returns_other_when_empty {
    NSDictionary *input = [NSDictionary linq_empty];
    NSDictionary *other = [NSDictionary linq_from:1 to:5];
    NSDictionary *result = [input linq_merge:other];
    
    XCTAssertEqual(result, other);
}

- (void)test_merge_returns_self_when_other_empty {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = [NSDictionary linq_empty];
    NSDictionary *result = [input linq_merge:other];
    
    XCTAssertEqual(result, input);
}

- (void)test_merge_returns_self_when_other_nil {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    NSDictionary *other = nil;
    NSDictionary *result = [input linq_merge:other];
    
    XCTAssertEqual(result, input);
}

@end
