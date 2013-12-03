//
//  NSArray-UtilitiesTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/3/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray-Utilities.h"

@interface NSArray_UtilitiesTests : XCTestCase

@end

@implementation NSArray_UtilitiesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testStringExtensions
{
    NSArray *a = @[@"b",@"a",@"f",@"d",@"e",@"c"];
    NSArray *b = a.sortedStrings;
    NSString *result = [b stringValue];
    XCTAssertTrue([result isEqualToString: @"a b c d e f"], @"StringExtensions Fail");
    
}

- (void)testUtilityExtensions
{
    NSArray *a = @[@"b",@"a",@"f",@"a"];
    NSString *result = [[a uniqueMembers] stringValue];
    XCTAssertTrue([result isEqualToString: @"b f a"], @"UtilityExtensions Fail");
    NSArray *b = @[@"f",@"c",@"b"];
    result = [[a unionWithArray:b] stringValue];
    XCTAssertTrue([result isEqualToString: @"a f c b"], @"UtilityExtensions Fail");
    b = @[@"a",@"c",@"k"];
    result = [[a intersectionWithArray:b] stringValue];
    XCTAssertTrue([result isEqualToString: @"a"], @"UtilityExtensions Fail");
    NSSet *set = [NSSet setWithObjects:@"a",@"c",@"k", nil];
    result = [[a intersectionWithSet:set] stringValue];
    XCTAssertTrue([result isEqualToString: @"a"], @"UtilityExtensions Fail");
    result = [[a complementWithArray:b] stringValue];
    XCTAssertTrue([result isEqualToString: @"b f"], @"UtilityExtensions Fail");
    set = [NSSet setWithObjects:@"a",@"c",@"k", nil];
    result = [[a complementWithSet:set] stringValue];
    XCTAssertTrue([result isEqualToString: @"b f"], @"UtilityExtensions Fail");
    
    NSArray *c = @[@"b",@"a",@"f",@"c"];
    NSMutableArray *cc = [NSMutableArray arrayWithArray:c];
    [cc reverse];
    result = [cc stringValue];
    XCTAssertTrue([result isEqualToString: @"c f a b"], @"UtilityExtensions Fail");
    [cc removeFirstObject];
    result = [cc stringValue];
    XCTAssertTrue([result isEqualToString: @"f a b"], @"UtilityExtensions Fail");
    [cc reverse];
    result = [cc stringValue];
    XCTAssertTrue([result isEqualToString: @"b a f"], @"UtilityExtensions Fail");
    srandom([[NSDate date] timeIntervalSince1970]);
    [cc shuffle];
    result = [cc stringValue];
    XCTAssertTrue(cc.count==3, @"UtilityExtensions Fail");
    [cc removeAllObjects];
    [cc removeFirstObject];
    result = [cc stringValue];
    XCTAssertTrue([result isEqualToString: @""], @"UtilityExtensions Fail");
}

- (void)testStackAndQueueExtensions{
    NSArray *a = @[@"a",@"b",@"c",@"d"];
    //Stack
    NSMutableArray *aa = [NSMutableArray arrayWithArray:a];
    [aa push:@"e"];
    NSString *result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"a b c d e"], @"UtilityExtensions Fail");
    [aa pushObjects:@"f",@"g",@"h",nil];
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"a b c d e f g h"], @"UtilityExtensions Fail");
    result = [aa peek];
    XCTAssertTrue([result isEqualToString: @"h"], @"UtilityExtensions Fail");
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"a b c d e f g h"], @"UtilityExtensions Fail");
    result = [aa pop];
    XCTAssertTrue([result isEqualToString: @"h"], @"UtilityExtensions Fail");
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"a b c d e f g"], @"UtilityExtensions Fail");
    result = [aa firstObject];
    XCTAssertTrue([result isEqualToString: @"a"], @"UtilityExtensions Fail");
    XCTAssertTrue(![aa isEmpty], @"UtilityExtensions Fail");
    [aa removeAllObjects];
    XCTAssertTrue([aa isEmpty], @"UtilityExtensions Fail");
    //Queue
    [aa removeAllObjects];
    [aa enqueue:@"a"];
    [aa enqueue:@"b"];
    [aa enqueue:@"c"];
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"c b a"], @"UtilityExtensions Fail");
    result = [aa dequeue];
    XCTAssertTrue([result isEqualToString: @"a"], @"UtilityExtensions Fail");
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"c b"], @"UtilityExtensions Fail");
    [aa enqueueObjects:@"d",@"e",nil];
    result = [aa stringValue];
    XCTAssertTrue([result isEqualToString: @"e d c b"], @"UtilityExtensions Fail");
}

- (void)testPSLib{
    NSString *match = @"a";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", match];
    NSArray *a = @[@"a",@"b",@"c",@"d",@"aac"];
    NSString *result = [a objectUsingPredicate:predicate];
    XCTAssertTrue([result isEqualToString: @"a"], @"UtilityExtensions Fail");
    predicate = [NSPredicate predicateWithFormat:@"SELF != %@", match];
    result = [a objectUsingPredicate:predicate];
    XCTAssertTrue([result isEqualToString: @"b"], @"UtilityExtensions Fail");
    match = @"*ac";
    predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    result = [a objectUsingPredicate:predicate];
    XCTAssertTrue([result isEqualToString: @"aac"], @"UtilityExtensions Fail");
}

- (void)testSafeMethod{
    NSArray *a = @[@"a",@"b",@"c",@"d"];
    NSString *result = [a safeObjectAtIndex:2];
    XCTAssertTrue([result isEqualToString: @"c"], @"UtilityExtensions Fail");
    result = [a safeObjectAtIndex:20];
    XCTAssertNil(result, @"UtilityExtensions Fail");
    result = [a safeObjectAtIndex:-1];
    XCTAssertNil(result, @"UtilityExtensions Fail");
}
@end
