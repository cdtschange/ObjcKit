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
@property(strong,nonatomic)     NSMutableDictionary         *params;
@property(nonatomic, strong)    NSMutableArray              *networkTasks;
@property (nonatomic, copy)     void (^failureBlock)(NSError *);

//初始化界面和初始数据（只执行一次的操作）
- (void)initUIAndData;
//初始化默认导航栏
- (void)initNavigationBar;
//初始化注册通知
- (void)initNotification;
//加载数据（可能会反复调用）
- (void)loadData;
//网络请求Task变化的通知
- (void)setNetworkStateOfTask:(NSURLSessionTask *)task;

//弹窗显示信息，过一段时间自动消失
- (void)showInfoTip:(NSString *)tip;
- (void)showInfoTip:(NSString *)tip complete:(void (^)())complete;
- (void)showErrorTip:(NSError *)error;
//显示遮罩加载
- (void)showLoading;
- (void)showLoadingWithText:(NSString *)text;
//移除遮罩加载
- (void)hideLoading;
@end
