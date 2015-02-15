//
//  UIViewController+TextFieldDelegate.m
//  Yumi
//
//  Created by Mao on 1/29/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "UIViewController+TextFieldDelegate.h"

@implementation UIViewController (TextFieldDelegate)

-(BOOL)mobileValidWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *text = [textField text];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *newString = @"";
    int i=3;
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, i)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == i) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, i)];
        if (i==3) {
            i++;
        }
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    
    if (newString.length > 13) {
        return NO;
    }
    
    [textField setText:newString];
    
    return NO;
}
-(BOOL)bankcardValidWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *text = [textField text];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *newString = @"";
    int i=4;
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, i)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == i) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, i)];
        //            if (i==3) {
        //                i++;
        //            }
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    
    
    [textField setText:newString];
    
    return NO;
}
-(BOOL)isTextEmptyWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *newValue = [textField.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    return newValue.length==0;
}

@end
