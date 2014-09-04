//
//  UIImageView+Rounded.m
//  Demo
//
//  Created by Tozy on 13-7-22.
//  Copyright (c) 2013年 TozyZuo. All rights reserved.
//

#import "UIView+Rounded.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define BorderRatio 0.044                   // Border与半径的比率
#define BorderColor [UIColor whiteColor]     // 默认Border颜色

static const void *IsRoundedKey = "IsRoundedKey";

@implementation UIView (Rounded)
@dynamic isRounded;

- (BOOL)isRounded
{
    return [objc_getAssociatedObject(self, IsRoundedKey) boolValue];
}

- (void)setIsRounded:(BOOL)isRounded
{
    objc_setAssociatedObject(self, IsRoundedKey, @(isRounded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (isRounded) {
        CALayer* roundCornerLayer = [CALayer layer];
        roundCornerLayer.frame = self.bounds;
        roundCornerLayer.contents = (id)[[UIImage imageNamed:@"uiview_rounded_mask"] CGImage];
        [[self layer] setMask:roundCornerLayer];
    }else{
        [[self layer] setMask:nil];
    }
    
//    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width*0.5, self.height*0.5) radius:MIN(self.width, self.height)*0.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
//    CAShapeLayer* shape = [CAShapeLayer layer];
//    shape.path = path.CGPath;
//    self.layer.mask = shape;
//    if (isRounded) {
//        self.clipsToBounds = YES;
//        self.layer.cornerRadius = MIN(self.frame.size.width, self.frame.size.height) * .5;
//        self.layer.borderWidth = BorderRatio * MIN(self.frame.size.width, self.frame.size.height);
//        self.layer.borderColor = BorderColor.CGColor;
//    } else {
//        self.layer.cornerRadius = 0;
//        self.layer.borderWidth = 0;
//    }
}

-(void)setRoundBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color
{
    self.isRounded = YES;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
    if (borderWidth>0) {
        self.layer.cornerRadius = MIN(self.frame.size.width, self.frame.size.height) * .5;
        self.layer.borderWidth = BorderRatio * MIN(self.frame.size.width, self.frame.size.height);
        self.layer.borderColor = BorderColor.CGColor;
    }
}
@end
