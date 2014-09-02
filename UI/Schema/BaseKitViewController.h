//
//  BaseKitViewController.h
//  ObjcKit
//
//  Created by Wei Mao on 9/2/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseKitViewController : UIViewController

//初始参数
@property(strong,nonatomic) NSMutableDictionary *params;

//初始化界面和初始数据（只执行一次的操作）
- (void)initUIAndData;
//初始化默认导航栏
- (void)initNavigationBar;
//初始化注册通知
- (void)initNotification;
//加载数据（可能会反复调用）
- (void)loadData;
@end
