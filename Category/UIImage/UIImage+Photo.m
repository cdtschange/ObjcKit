//
//  UIImage+Photo.m
//  ObjcKit
//
//  Created by Wei Mao on 9/4/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "UIImage+Photo.h"

@interface UIImage()

@property (copy, nonatomic) void(^saveInPhoneBlock)(BOOL success, NSError *error);

@end

@implementation UIImage (Photo)

//保存图片到手机
-(void)saveInPhoneWithCompletion:(void (^)(BOOL, NSError *))completion{
    self.saveInPhoneBlock = completion;
    UIImageWriteToSavedPhotosAlbum(self, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (self.saveInPhoneBlock) {
        if (error) {
            self.saveInPhoneBlock(NO, error);
        }else{
            self.saveInPhoneBlock(YES, nil);
        }
    }
}

@end
