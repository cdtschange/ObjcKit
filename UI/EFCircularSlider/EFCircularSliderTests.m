//
//  EFCircularSliderTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/13/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EFCircularSlider.h"

@interface EFCircularSliderTests : XCTestCase
@property (weak, nonatomic) UILabel *timeLabel;

@end

@implementation EFCircularSliderTests

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
//  @0 Base
    CGRect sliderFrame = CGRectMake(60, 150, 200, 200);
    EFCircularSlider* circularSlider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [circularSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [hostView addSubview:circularSlider];
//  @1  BigCircle
//    circularSlider.handleType = EFBigCircle;
//    circularSlider.handleColor = [UIColor blueColor];
    
//  @2  DoubleCircle
//    circularSlider.handleType = EFDoubleCircleWithOpenCenter;
    
//  @3  WithLabels
//    NSArray* labels = @[@"B", @"C", @"D", @"E", @"A"];
//    [circularSlider setInnerMarkingLabels:labels];

//  @4  SnapToLabels
//    NSArray* labels = @[@"B", @"C", @"D", @"E", @"A"];
//    [circularSlider setInnerMarkingLabels:labels];
//    circularSlider.snapToLabels = YES;
    
//  @5  TimePicker
//    self.view.backgroundColor = [UIColor colorWithRed:31/255.0f green:61/255.0f blue:91/255.0f alpha:1.0f];
//    CGRect minuteSliderFrame = CGRectMake(5, 170, 310, 310);
//    minuteSlider = [[EFCircularSlider alloc] initWithFrame:minuteSliderFrame];
//    minuteSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
//    minuteSlider.filledColor = [UIColor colorWithRed:155/255.0f green:211/255.0f blue:156/255.0f alpha:1.0f];
//    [minuteSlider setInnerMarkingLabels:@[@"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", @"60"]];
//    minuteSlider.labelFont = [UIFont systemFontOfSize:14.0f];
//    minuteSlider.lineWidth = 8;
//    minuteSlider.minimumValue = 0;
//    minuteSlider.maximumValue = 60;
//    minuteSlider.labelColor = [UIColor colorWithRed:76/255.0f green:111/255.0f blue:137/255.0f alpha:1.0f];
//    minuteSlider.handleType = EFDoubleCircleWithOpenCenter;
//    minuteSlider.handleColor = minuteSlider.filledColor;
//    [hostView addSubview:minuteSlider];
//    [minuteSlider addTarget:self action:@selector(minuteDidChange:) forControlEvents:UIControlEventValueChanged];
//    
//    CGRect hourSliderFrame = CGRectMake(55, 220, 210, 210);
//    hourSlider = [[EFCircularSlider alloc] initWithFrame:hourSliderFrame];
//    hourSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
//    hourSlider.filledColor = [UIColor colorWithRed:98/255.0f green:243/255.0f blue:252/255.0f alpha:1.0f];
//    [hourSlider setInnerMarkingLabels:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"]];
//    hourSlider.labelFont = [UIFont systemFontOfSize:14.0f];
//    hourSlider.lineWidth = 12;
//    hourSlider.snapToLabels = NO;
//    hourSlider.minimumValue = 0;
//    hourSlider.maximumValue = 12;
//    hourSlider.labelColor = [UIColor colorWithRed:127/255.0f green:229/255.0f blue:255/255.0f alpha:1.0f];
//    hourSlider.handleType = EFBigCircle;
//    hourSlider.handleColor = hourSlider.filledColor;
//    [hostView addSubview:hourSlider];
//    [hourSlider addTarget:self action:@selector(hourDidChange:) forControlEvents:UIControlEventValueChanged];

}

-(void)valueChanged:(EFCircularSlider*)slider {
    NSLog(@"%.02f", slider.currentValue);
}
-(void)hourDidChange:(EFCircularSlider*)slider {
    int newVal = (int)slider.currentValue ? (int)slider.currentValue : 12;
    NSString* oldTime = _timeLabel.text;
    NSRange colonRange = [oldTime rangeOfString:@":"];
    _timeLabel.text = [NSString stringWithFormat:@"%d:%@", newVal, [oldTime substringFromIndex:colonRange.location + 1]];
}

-(void)minuteDidChange:(EFCircularSlider*)slider {
    int newVal = (int)slider.currentValue < 60 ? (int)slider.currentValue : 0;
    NSString* oldTime = _timeLabel.text;
    NSRange colonRange = [oldTime rangeOfString:@":"];
    _timeLabel.text = [NSString stringWithFormat:@"%@:%02d", [oldTime substringToIndex:colonRange.location], newVal];
}
@end
