//
//  ViewController.m
//  BTLibrary
//
//  Created by Byte on 5/29/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTSpiderPlotterView.h"

@interface BTSpiderPlotterView()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSMutableDictionary *animationStepValueDictionary;
@property (strong, nonatomic) NSMutableDictionary *targetValueDictionary;

@end

@implementation BTSpiderPlotterView{
    //Value and key
    NSMutableDictionary *_valueDictionary;
    
    CGFloat _centerX;
    CGFloat _centerY;

    //Plotting and UI Array
    NSMutableArray *_pointsLengthArrayArray;
    NSMutableArray *_pointsToPlotArray;
}

- (id)initWithFrame:(CGRect)frame valueDictionary:(NSDictionary *)valueDictionary
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        //Private iVar
        _valueDictionary = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
        _pointsLengthArrayArray = [NSMutableArray array];
        _pointsToPlotArray = [NSMutableArray array];
        
        
        //Public iVar
        _circleNumber = 5;
        _drawboardColor = [UIColor blackColor];
        _plotColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.9];
        
        [self calculateAllPoints];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // circles
    for (NSArray *pointArray in _pointsLengthArrayArray) {
        //plot background
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGPoint beginPoint = [[pointArray objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
        for (NSValue* pointValue in pointArray){
            CGPoint point = [pointValue CGPointValue];
            CGContextAddLineToPoint(graphContext, point.x, point.y);
        }
        CGContextAddLineToPoint(graphContext, beginPoint.x, beginPoint.y);
        CGContextSetStrokeColorWithColor(graphContext, _drawboardColor.CGColor);
        CGContextStrokePath(graphContext);
    }
    
    // cuts
    NSArray *largestPointArray = [_pointsLengthArrayArray lastObject];
    for (NSValue* pointValue in largestPointArray){
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGContextMoveToPoint(graphContext, _centerX, _centerY);
        CGPoint point = [pointValue CGPointValue];
        CGContextAddLineToPoint(graphContext, point.x, point.y);
        CGContextSetStrokeColorWithColor(graphContext, _drawboardColor.CGColor);
        CGContextStrokePath(graphContext);
    }
    
    // plot 
    if (YES) {
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGPoint beginPoint = [[_pointsToPlotArray objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
        for (NSValue* pointValue in _pointsToPlotArray){
            CGPoint point = [pointValue CGPointValue];
            CGContextAddLineToPoint(graphContext, point.x, point.y);
        }
        CGContextSetFillColorWithColor(graphContext, _plotColor.CGColor);
        CGContextFillPath(graphContext);
    }
     
}


#pragma mark - Main Function
- (void)calculateAllPoints
{
    [_pointsLengthArrayArray removeAllObjects];
    [_pointsToPlotArray removeAllObjects];
    
    //init Angle, Key and Value
    NSArray *keyArray = [_valueDictionary allKeys];
    NSArray *valueArray = [self getValueArrayFromDictionary:_valueDictionary keyArray:keyArray];
//    _maxValue = [self getMaxValueFromValueArray:valueArray];
    NSArray *angleArray = [self getAngleArrayFromNumberOfSection:(int)[keyArray count]];
    
    //Calculate all the lengths
    CGFloat boundWidth = self.bounds.size.width;
    CGFloat boundHeight =  self.bounds.size.height;
    _centerX = boundWidth/2;
    _centerY = boundHeight/2;
    CGFloat maxLength = MIN(boundWidth, boundHeight) * 17/40;
    int plotCircles = _circleNumber;
    CGFloat lengthUnit = maxLength/plotCircles;
    NSArray *lengthArray = [self getLengthArrayWithLengthUnit:lengthUnit maxLength:maxLength];
    
    //get all the points and plot
    for (NSNumber *lengthNumber in lengthArray) {
        CGFloat length = [lengthNumber floatValue];
        [_pointsLengthArrayArray addObject:[self getPlotPointWithLength:length angleArray:angleArray]];
    }
    
    int section = 0;
    for (id value in valueArray) {
        CGFloat valueFloat = [value floatValue];
        if (valueFloat > _circleNumber) {
            NSLog(@"ERROR - Value number is higher than max value - value: %f - maxValue: %f", valueFloat, _circleNumber);
            return;
        }
        CGFloat length = valueFloat/_circleNumber * maxLength;
        CGFloat angle = [[angleArray objectAtIndex:section] floatValue];
        CGFloat x = _centerX + length*cos(angle);
        CGFloat y = _centerY + length*sin(angle);
        [_pointsToPlotArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        section++;
    }
    
    //label
    [self drawLabelWithMaxLength:maxLength labelArray:keyArray angleArray:angleArray];
    
}

#pragma mark - Helper Function
- (NSArray *)getAngleArrayFromNumberOfSection:(int)numberOfSection
{
    NSMutableArray *angleArray = [NSMutableArray array];
    for (int section = 0; section < numberOfSection; section++) {
        [angleArray addObject:[NSNumber numberWithFloat:(float)section/(float)[_valueDictionary count] * 2*M_PI]];
    }
    return angleArray;
}

- (NSArray *)getValueArrayFromDictionary:(NSDictionary *)dictionary keyArray:(NSArray *) keyArray
{
    NSMutableArray *valueArray = [NSMutableArray array];
    float max = 0;
    for (NSString *key in keyArray) {
        CGFloat value = [[dictionary objectForKey:key] floatValue];
        max = fmax(value, max);
        [valueArray addObject:[NSNumber numberWithFloat:value]];
    }
    max /= _circleNumber;
    NSMutableArray *result = [NSMutableArray array];
    for (NSNumber *number in valueArray) {
        CGFloat value = number.floatValue;
        value /= max;
        [result addObject:[NSNumber numberWithFloat:value]];
    }
    return result;
}

- (CGFloat)getMaxValueFromValueArray:(NSArray *)valueArray
{
    CGFloat maxValue = _circleNumber;
    for (NSNumber *valueNumber in valueArray) {
        CGFloat valueFloat = [valueNumber floatValue];
        maxValue = valueFloat>maxValue?valueFloat:maxValue;
    }
    return ceilf(maxValue);
}

- (NSArray *)getLengthArrayWithLengthUnit:(CGFloat)lengthUnit maxLength:(CGFloat)maxLength
{
    NSMutableArray *lengthArray = [NSMutableArray array];
    for (CGFloat length = lengthUnit; length <= maxLength; length += lengthUnit) {
        [lengthArray addObject:[NSNumber numberWithFloat:length]];
    }
    return lengthArray;
}

- (NSArray *)getPlotPointWithLength:(CGFloat)length angleArray:(NSArray *)angleArray
{
    NSMutableArray *pointArray = [NSMutableArray array];
    //each length find the point
    for (NSNumber *angleNumber in angleArray) {
        CGFloat angle = [angleNumber floatValue];
        CGFloat x = _centerX + length*cos(angle);
        CGFloat y = _centerY + length*sin(angle);
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    //store
    return pointArray;
}

- (void)drawLabelWithMaxLength:(CGFloat)maxLength labelArray:(NSArray *)labelArray angleArray:(NSArray *)angleArray
{
    int labelTag = 921;
    while (true) {
        UIView *label = [self viewWithTag:labelTag];
        if (!label) break;
        [label removeFromSuperview];
    }
    
    int section = 0;
    CGFloat fontSize = (maxLength/10)*5/4;
    CGFloat labelLength = maxLength + maxLength/10;
    for (NSString *labelString in labelArray) {
        CGFloat angle = [[angleArray objectAtIndex:section] floatValue];
        CGFloat x = _centerX + labelLength*cos(angle);
        CGFloat y = _centerY + labelLength*sin(angle);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x - 5*fontSize/2, y - fontSize/2, 5*fontSize, fontSize)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.transform = CGAffineTransformMakeRotation(((float)section/[labelArray count]) *
                                                        (2*M_PI) + M_PI_2);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = labelString;
        label.tag = labelTag;
        [label sizeToFit];
        [self addSubview: label];
        
        section++;
    }
}

-(void)animateWithDuration:(NSTimeInterval)duration valueDictionary:(NSDictionary *)valueDictionary{
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reportProgress:)];
        self.displayLink.frameInterval = 1/20.0;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    self.targetValueDictionary = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
    long long times = duration*40;
    self.displayLink.paused = YES;
    self.animationStepValueDictionary = [NSMutableDictionary new];
    NSArray *keyArray1 = [_valueDictionary allKeys];
    NSArray *valueArray1 = [self getValueArrayFromDictionary:_valueDictionary keyArray:keyArray1];
    NSArray *keyArray2 = [valueDictionary allKeys];
    NSArray *valueArray2 = [self getValueArrayFromDictionary:valueDictionary keyArray:keyArray2];
    if (keyArray1.count!=keyArray2.count) {
        return;
    }
    for (int i = 0; i<keyArray2.count; i++) {
        self.animationStepValueDictionary[keyArray2[i]] = [NSString stringWithFormat:@"%f",([valueArray2[i] floatValue]-[valueArray1[i] floatValue])/times];
    }
    self.displayLink.paused = NO;
}
- (void)reportProgress:(CADisplayLink *)dl
{
    NSArray *keyArray = [_valueDictionary allKeys];
    for (NSString *key in keyArray) {
        double delta = [self.targetValueDictionary[key] floatValue] - [_valueDictionary[key] floatValue];
        double minusDelta =  [self.animationStepValueDictionary[key] floatValue];
        if ((delta>=0&&minusDelta<=0) || (delta<=0&&minusDelta>=0)) {
            if ([self checkIsToTarget]) {
                [self.displayLink invalidate];
                self.displayLink = nil;
                _valueDictionary = self.targetValueDictionary;
                [self calculateAllPoints];
                [self setNeedsDisplay];
                return;
            }else{
                continue;
            }
        }
        float value = [_valueDictionary[key] floatValue]+[self.animationStepValueDictionary[key] floatValue];
        _valueDictionary[key] = [NSString stringWithFormat:@"%f",value];
    }
    [self calculateAllPoints];
    [self setNeedsDisplay];
}
- (BOOL)checkIsToTarget{
    NSArray *keyArray = [_valueDictionary allKeys];
    for (NSString *key in keyArray) {
        double delta = [self.targetValueDictionary[key] floatValue] - [_valueDictionary[key] floatValue];
        double minusDelta =  [self.animationStepValueDictionary[key] floatValue];
        if ((delta>=0&&minusDelta>=0) || (delta<=0&&minusDelta<=0)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - setters

- (void)setCircleNumber:(CGFloat)maxValue
{
    _circleNumber = maxValue;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setDrawboardColor:(UIColor *)drawboardColor
{
    _drawboardColor = drawboardColor;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setPlotColor:(UIColor *)plotColor
{
    _plotColor = plotColor;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_valueDictionary) {
        [self calculateAllPoints];
        [self setNeedsDisplay];
    }
   
}
@end
