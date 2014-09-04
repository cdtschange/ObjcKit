//
//  UIImage+Photo.h
//  ObjcKit
//
//  Created by Wei Mao on 9/4/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Photo)

//保存图片到手机
- (void)saveInPhoneWithCompletion:(void(^)(BOOL success, NSError *error))completion;
@end
