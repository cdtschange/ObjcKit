//
//  UIViewController+Photo.h
//  ObjcKit
//
//  Created by Wei Mao on 9/4/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Photo)

//选择照片
- (void)choosePhotoWithTitle:(NSString *)title compelete:(void(^)(BOOL success, NSString *errorMessage, UIImage *image))block;

@end
