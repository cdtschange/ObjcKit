//
//  NSString+Type.m
//  G2R
//
//  Created by Mao on 10/13/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "NSString+Type.h"

@implementation NSString (Type)

//判断是否为整形：

- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
