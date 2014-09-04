//
//  UIImageView+Rounded.h
//  Demo
//
//  Created by Tozy on 13-7-22.
//  Copyright (c) 2013年 TozyZuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Rounded)

@property (nonatomic, assign) BOOL isRounded;

- (void)setRoundBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

@end
