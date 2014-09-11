//
//  UINavigationItem+Margin.m
//  WandaKTV
//
//  Created by Wei Mao on 12/2/13.
//  Copyright (c) 2013 Wanda Inc. All rights reserved.
//

#import "UINavigationItem+Margin.h"
#import <objc/runtime.h>

static const void *keyUseMarginLayout = "keyUseMarginLayout";

@implementation UINavigationItem (Margin)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;

        if (_leftBarButtonItem)
        {
            if (self.useMarginLayout) {
                [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
            } else {
                [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
            }
        }
        else
        {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        if (_rightBarButtonItem)
        {
            if (self.useMarginLayout) {
                [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
            } else {
                [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
            }
        }
        else
        {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

- (void)setUseMarginLayout:(BOOL)useMarginLayout
{
    NSNumber *number = [NSNumber numberWithBool:useMarginLayout];
    objc_setAssociatedObject(self, keyUseMarginLayout, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)useMarginLayout
{
    NSNumber *number = objc_getAssociatedObject(self, keyUseMarginLayout);
    return [number boolValue];
}

#endif
@end
