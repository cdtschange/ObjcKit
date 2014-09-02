//
//  WandaUtils+UIViewController.m
//  WandaKTV
//
//  Created by Wei Mao on 10/17/13.
//  Copyright (c) 2013 Wanda Inc. All rights reserved.
//

#import "UIViewController+Route.h"

@implementation UIViewController (Route)

//获取Xib中的ViewController新实例
+ (id)instanceByName:(NSString *)name{
    return [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
}
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
//跳转到下一个页面
- (void)routeToName:(NSString *)name params:(NSDictionary *)params{
    [self routeToName:name params:params pop:NO];
}
- (void)routeToName:(NSString *)name params:(NSDictionary *)params pop:(BOOL)pop{
    UIViewController *vc = [UIViewController instanceByName:name];
    if (params) {
        [vc setValue:[NSMutableDictionary dictionaryWithDictionary:params] forKey:@"params"];
    }
    if (pop) {
        UINavigationController *nav = [[[self.navigationController class] alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [self.navigationController pushViewController:vc animated:YES];
    }

}



@end
