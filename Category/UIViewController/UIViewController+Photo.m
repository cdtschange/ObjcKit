//
//  UIViewController+Photo.m
//  ObjcKit
//
//  Created by Wei Mao on 9/4/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "UIViewController+Photo.h"

static int const TAG_CHOOSEPHOTOSHEET = 10001;

@interface UIViewController()<UIImagePickerControllerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate>

@property (copy, nonatomic) void(^choosePhotoBlock)(BOOL success, NSString *errorMessage, UIImage *image);

@end

@implementation UIViewController (Photo)

//选择照片
-(void)choosePhotoWithTitle:(NSString *)title compelete:(void (^)(BOOL, NSString *, UIImage *))block{
    self.choosePhotoBlock = block;
    UIActionSheet *choosePhotoActionSheet = nil;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", @"拍照", nil];
    } else {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择", nil];
    }
    choosePhotoActionSheet.tag = TAG_CHOOSEPHOTOSHEET;
    [choosePhotoActionSheet showInView:self.view.window];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (actionSheet.tag) {
        case TAG_CHOOSEPHOTOSHEET:{
            NSUInteger sourceType = 0;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                switch (buttonIndex) {
                    case 0:
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    case 1:
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        break;
                    case 2:
                        return;
                }
            } else {
                if (buttonIndex == 1) {
                    return;
                } else {
                    sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
            }
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}
#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (selectImage) {
        if (self.choosePhotoBlock) {
            self.choosePhotoBlock(YES,nil,selectImage);
            self.choosePhotoBlock = nil;
        }
    }else{
        if (self.choosePhotoBlock) {
            self.choosePhotoBlock(NO,nil,nil);
            self.choosePhotoBlock = nil;
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
