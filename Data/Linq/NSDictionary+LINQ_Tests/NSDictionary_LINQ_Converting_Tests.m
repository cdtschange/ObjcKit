//
//  NSDictionary_LINQ_Converting_Tests.m
//  LINQ4Obj-C
//
//  Created by Michal Konturek on 12/10/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LINQ.h"

@interface NSDictionary_LINQ_Converting_Tests : XCTestCase

@property (nonatomic, strong) NSDictionary *input;

@end

@implementation NSDictionary_LINQ_Converting_Tests

- (void)setUp {
    self.input = @{@1: @"A", @2: @"B", @3: @"C", @4: @"D", @5: @"E",};
}

- (void)tearDown {
    self.input = nil;
}

- (void)test_toArray {
    id result = [self.input linq_toArray];
    
    XCTAssertEqual((int)[result count], (int)[self.input count]);
    XCTAssertEqual((int)[result count], 5);//containsInAnyOrder(@"A", @"B", @"C", @"D", @"E", nil)
}

- (void)test_toArrayWhereKey {
    id result = [self.input linq_toArrayWhereKey:^BOOL(id item) {
        return ([item integerValue] > 3);
    }];
    
    XCTAssertEqual((int)[result count], 2);
    XCTAssertEqual(result[0], @"D");
    XCTAssertEqual(result[1], @"E");
}

- (void)test_toArrayWhereValue {
    id result = [self.input linq_toArrayWhereValue:^BOOL(id item) {
        return ([item isEqualToString:@"A"] || [item isEqualToString:@"B"]);
    }];

    XCTAssertEqual((int)[result count], 2);//containsInAnyOrder(@"A", @"B", nil)
}

- (void)test_toArrayWhereKeyValue {
    id result = [self.input linq_toArrayWhereKeyValue:^BOOL(id key, id value) {
        return (([key integerValue] == 1) && ([value isEqualToString:@"A"]));
    }];
    
    XCTAssertEqual((int)[result count], 1);//containsInAnyOrder(@"A", nil)
}

@end
