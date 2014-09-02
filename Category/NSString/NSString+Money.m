//
//  NSString+Money.m
//  ObjcKit
//
//  Created by Wei Mao on 9/2/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "NSString+Money.h"

@implementation NSString (Money)

+(NSString *)stringFromMoney:(int)money{
    if (money == 0)
    {
        return @"0";
    }
    else
    {
        NSMutableString *volumeStr = [NSMutableString string];

        int common = money;
        int tail = money % 1000;

        while (common > 0)
        {
            if(tail == common)
            {
                [volumeStr insertString:[NSString stringWithFormat:@"%d", tail] atIndex:0];
                break;
            }
            if (tail == 0) {
                [volumeStr insertString:@"000" atIndex:0];
            }
            else if(tail < 10)
            {
                [volumeStr insertString:[NSString stringWithFormat:@"00%d", tail] atIndex:0];
            }
            else if(tail < 100)
            {
                [volumeStr insertString:[NSString stringWithFormat:@"0%d", tail] atIndex:0];
            }
            else
            {
                [volumeStr insertString:[NSString stringWithFormat:@"%d", tail] atIndex:0];
            }

            common = common / 1000;
            tail = common % 1000;
            if (common > 0) {
                [volumeStr insertString:@"," atIndex:0];
            }
        }
        return volumeStr;
    }
}

@end