//
//  NSDictionary_LINQ_Filtering_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 12/10/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSDictionary_LINQ_Filtering_Tests : XCTestCase

@end

@implementation NSDictionary_LINQ_Filtering_Tests

- (void)test_ofTypeKey {
    id input = @{@1: @1, @"2": @2, @3: @3, @"4": @4};
    id result = [input linq_ofTypeKey:[NSString class]];
    
    XCTAssertEqual((int)[result count], 2);
    XCTAssertEqual((int)[[result allKeys] count], 2);//containsInAnyOrder(@"2", @"4", nil)
    XCTAssertEqual((int)[[result allValues] count], 2);//containsInAnyOrder(@2, @4, nil)
}

- (void)test_ofTypeValue {
    id input = @{@1: @"A", @2: @"B", @3: @3, @4: @"C"};
    id result = [input linq_ofTypeValue:[NSString class]];

    XCTAssertEqual((int)[result count], 3);
    XCTAssertEqual((int)[[result allKeys] count], 3);//containsInAnyOrder(@1, @2, @4, nil));
    XCTAssertEqual((int)[[result allValues] count], 3);//containsInAnyOrder(@"A", @"B", @"C", nil));
}

- (void)test_where {
    NSDictionary *input = [NSDictionary linq_from:1 to:10];
    id result = [input linq_where:^BOOL(id key, id value) {
        return (([key integerValue] > 5) && ([value integerValue] > 5));
    }];
 
    XCTAssertEqual((int)[result count], 4);
    XCTAssertEqual((int)[[result allKeys] count], 4);//containsInAnyOrder(@6, @7, @8, @9, nil));
    XCTAssertEqual((int)[[result allValues] count], 4);//containsInAnyOrder(@7, @8, @9, @10, nil));
}

- (void)test_whereKey {
    id input = @{@1: @"A", @2: @"B", @3: @3, @4: @"C"};
    id result = [input linq_whereKey:^BOOL(id item) {
        return ([item integerValue] > 2);
    }];
    
    XCTAssertEqual((int)[result count], 2);
    XCTAssertEqual((int)[[result allKeys] count], 2);//containsInAnyOrder(@3, @4, nil));
    XCTAssertEqual((int)[[result allValues] count], 2);//containsInAnyOrder(@3, @"C", nil));
}

- (void)test_whereValue {
    id input = @{@1: @"A", @2: @"B", @3: @3, @4: @"C"};
    id result = [input linq_whereValue:^BOOL(id item) {
        return ([item isKindOfClass:[NSNumber class]]);
    }];
    
    XCTAssertEqual((int)[result count], 1);
    XCTAssertEqual((int)[[result allKeys] count], 1);//contains(@3, nil));
    XCTAssertEqual((int)[[result allValues] count], 1);//contains(@3, nil));
}

@end
