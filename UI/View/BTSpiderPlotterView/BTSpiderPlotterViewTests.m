//
//  BTSpiderPlotterViewTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/6/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BTSpiderPlotterView.h"

@interface BTSpiderPlotterViewTests : XCTestCase
@property(strong, nonatomic) BTSpiderPlotterView *spiderView;

@end

@implementation BTSpiderPlotterViewTests

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

- (void)testExampleWithHostView:(UIView *)hostView
{
    NSDictionary *valueDictionary = @{@"Design": @"6",
                                      @"Display Life": @"8",
                                      @"Camera" : @"5",
                                      @"Reception": @"3",
                                      @"Performance" : @"7",
                                      @"Software": @"6",
                                      @"Battery Life" : @"2",
                                      @"Ecosystem": @"4"};
    
    self.spiderView = [[BTSpiderPlotterView alloc] initWithFrame:hostView.frame valueDictionary:valueDictionary];
    //spiderView.plotColor = [UIColor colorWithRed:.8 green:.4 blue:.3 alpha:.7];
    [hostView addSubview:self.spiderView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(click_Data:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(10, 10, 100, 50);
    btn.backgroundColor = [UIColor greenColor];
    [hostView addSubview:btn];
}

- (void)click_Data:(id)sender{
    [self.spiderView animateWithDuration:0.5 valueDictionary:@{@"Design": @"2",
                                                          @"Display Life": @"4",
                                                          @"Camera" : @"5",
                                                          @"Reception": @"1",
                                                          @"Performance" : @"9",
                                                          @"Software": @"2",
                                                          @"Battery Life" : @"7",
                                                          @"Ecosystem": @"3"}];
}

@end
