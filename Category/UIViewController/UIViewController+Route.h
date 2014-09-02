//
//  WandaUtils+UIViewController.h
//  WandaKTV
//
//  Created by Wei Mao on 10/17/13.
//  Copyright (c) 2013 Wanda Inc. All rights reserved.
//

@interface UIViewController (Route)

//获取Xib中的ViewController新实例
+ (id)instanceByName:(NSString *)name;
//返回上一个页面
- (void)routeBack;
//获取Navigation队列里上一个ViewController
- (UIViewController *)previousViewControllerInNavigation;
//跳转到下一个页面
- (void)routeToName:(NSString *)name params:(NSDictionary *)params;
- (void)routeToName:(NSString *)name params:(NSDictionary *)params pop:(BOOL)pop;
@end
