//
//  ColoursDemo_Tests.m
//  ColoursDemo Tests
//
//  Created by Craig Walton on 02/11/2013.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIColor+Colours.h"

@interface UIColor_ColoursTests : XCTestCase

@end

@implementation UIColor_ColoursTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRGBAArrayContructor {
    NSArray *arrayForRed = @[@(1),@(0),@(0),@(1)];
    NSArray *arrayForGreen = @[@(0),@(1),@(0),@(1)];
    NSArray *arrayForBlue = @[@(0),@(0),@(1),@(1)];
    
    XCTAssertEqualObjects([UIColor redColor], [UIColor colorFromRGBAArray:arrayForRed], @"Color from RGBA Array [255,0,0,255] does not give red.");
    XCTAssertEqualObjects([UIColor greenColor], [UIColor colorFromRGBAArray:arrayForGreen], @"Color from RGBA Array [0,255,0,255] does not give green.");
    XCTAssertEqualObjects([UIColor blueColor], [UIColor colorFromRGBAArray:arrayForBlue], @"Color from RGBA Array [0,0,255,255] does not give blue.");
}

- (void)testRGBADictContructor {
    NSDictionary *dictForRed = @{@"r": [NSNumber numberWithInt:255], @"g":@(0), @"b": [NSNumber numberWithInt:0],@"a": [NSNumber numberWithInt:255]};
    NSDictionary *dictForGreen =@{@"r": [NSNumber numberWithInt:0],@"g": [NSNumber numberWithInt:255],@"b": [NSNumber numberWithInt:0],@"a": [NSNumber numberWithInt:255]};
    NSDictionary *dictForBlue = @{@"r": [NSNumber numberWithInt:0],@"g": [NSNumber numberWithInt:0],@"b": [NSNumber numberWithInt:255],@"a": [NSNumber numberWithInt:255]};
    
    XCTAssertEqualObjects([UIColor redColor], [UIColor colorFromRGBADictionary:dictForRed], @"Color from RGBA Dictionary [255,0,0,255] does not give red.");
    XCTAssertEqualObjects([UIColor greenColor], [UIColor colorFromRGBADictionary:dictForGreen], @"Color from RGBA Dictionary [0,255,0,255] does not give green.");
    XCTAssertEqualObjects([UIColor blueColor], [UIColor colorFromRGBADictionary:dictForBlue], @"Color from RGBA Dictionary [0,0,255,255] does not give blue.");
}


- (void)testColorFromHex {
    XCTAssertEqualObjects([UIColor colorFromHexString:@"#ff0000"], [UIColor redColor], @"Color from #ff0000 does not give red");
    XCTAssertEqualObjects([UIColor colorFromHexString:@"#00ff00"], [UIColor greenColor], @"Color from #00ff00 does not give green");
    XCTAssertEqualObjects([UIColor colorFromHexString:@"#0000ff"], [UIColor blueColor], @"Color from #0000ff does not give blue");
}

- (void)testHexString {
    XCTAssertEqualObjects(@"#ff0000", [[UIColor redColor] hexString], @"Hex string from [UIColor redColor] does not equal #ff0000");
    XCTAssertEqualObjects(@"#00ff00", [[UIColor greenColor] hexString], @"Hex string from [UIColor greenColor] does not equal #00ff00");
    XCTAssertEqualObjects(@"#0000ff", [[UIColor blueColor] hexString], @"Hex string from [UIColor blueColor] does not equal #0000ff");
}

- (void)testToAndFromRGBAArray {
    NSArray *testArray = [[UIColor seafoamColor] rgbaArray];
    UIColor *testColor = [UIColor colorFromRGBAArray:testArray];
    
    XCTAssertEqualObjects(testColor, [UIColor seafoamColor], @"Serializing to and from RGBA Array does not yield the same color.");
}

- (void)testToAndFromRGBADictionary {
    NSDictionary *testDictionary = [[UIColor seafoamColor] rgbaDictionary];
    UIColor *testColor = [UIColor colorFromRGBADictionary:testDictionary];
    
    XCTAssertEqualObjects(testColor, [UIColor seafoamColor], @"Serializing to and from RGBA Dictionary does not yield the same color.");
}


- (void)testToAndFromHSBAArray {
    NSArray *testArray = [[UIColor redColor] hsbaArray];
    UIColor *testColor = [UIColor colorFromHSBAArray:testArray];
    
    XCTAssertEqualObjects(testColor, [UIColor redColor], @"Serializing to and from HSBA Array does not yield the same color.");
}

- (void)testToAndFromHSBADictionary {
    NSDictionary *testDictionary = [[UIColor redColor] hsbaDictionary];
    UIColor *testColor = [UIColor colorFromHSBADictionary:testDictionary];
    
    XCTAssertEqualObjects(testColor, [UIColor redColor], @"Serializing to and from HSBA Dictionary does not yield the same color.");
}

- (void)testContrastingColors {
    XCTAssertEqualObjects([[UIColor eggplantColor] blackOrWhiteContrastingColor], [UIColor whiteColor], @"Contrasting color over dark does not yield white.");
    XCTAssertEqualObjects([[UIColor antiqueWhiteColor] blackOrWhiteContrastingColor], [UIColor blackColor], @"Contrasting color over light does not yield black.");
}






@end
