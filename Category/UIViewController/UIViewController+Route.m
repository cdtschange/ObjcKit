//
//  WandaUtils+UIViewController.m
//  WandaKTV
//
//  Created by Wei Mao on 10/17/13.
//  Copyright (c) 2013 Wanda Inc. All rights reserved.
//

#import "UIViewController+Route.h"

@implementation UIViewController (Route)

//返回上一个页面
- (void)routeBack{
    //如果是弹到Nav的根页面，则dismiss
    if (!self.navigationController||self.navigationController.viewControllers.count==1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//获取Navigation队列里上一个ViewController
- (UIViewController *)previousViewControllerInNavigation{
    if (self.navigationController.viewControllers.count>1) {
        return self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    }
    return nil;
}



@end
