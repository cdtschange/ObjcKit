//
//  UIImage+Orientation.h
//  iplaza
//
//  Created by Tozy on 13-4-27.
//  Copyright (c) 2013年 Wanda Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Orientation)
//翻转UIImage
- (UIImage *)rotateWithimageOrientation:(UIImageOrientation)imageOrientation;
@end

@interface UIImage (UIColor)
//获取纯色UIImage
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
@end