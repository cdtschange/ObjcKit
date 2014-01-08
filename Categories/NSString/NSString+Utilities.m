//
//  NSString+Utilities.m
//  SourceKitDemo
//
//  Created by Wei Mao on 1/8/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Valid)
- (BOOL)validFormatChinaMobile{
    NSString *regex = @"(13[0-9]|15[012356789]|18[02356789]|14[57])[0-9]{8}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}
- (BOOL)validFormatEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
- (BOOL)validFormatNumber{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:self];
    return number != nil;
}
@end
