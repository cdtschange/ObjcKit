//
//  BaseKitViewController.m
//  ObjcKit
//
//  Created by Wei Mao on 9/2/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "BaseKitViewController.h"
#import "ActivityHUD.h"
#import "AFNetworking.h"

#define BASEKIT_TXT_LOADING                 @"正在加载..."
#define BASEKIT_TXT_TITLE                   @"提示"
#define BASEKIT_TIP_KEEP_SECOND             2
#define BASEKIT_TIP_MAXLENGTH               10

@interface BaseKitViewController ()

@end

@implementation BaseKitViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initUIAndData];
}

//初始化界面和初始数据（只执行一次的操作）
-(void)initUIAndData{
    [self initNavigationBar];
    [self initNotification];
    if (!self.params) {
        self.params = [NSMutableDictionary new];
    }
    self.networkTasks = [NSMutableArray new];
    __weak BaseKitViewController *weakself = self;
    self.failureBlock = ^(NSError *error) {
        [weakself showErrorTip:error];
    };
}


- (void)setNetworkStateOfTask:(NSURLSessionTask *)task{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidCompleteNotification object:nil];
    
    if (task) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [notificationCenter addObserver:self selector:@selector(task_resume:) name:AFNetworkingTaskDidResumeNotification object:task];
            [notificationCenter addObserver:self selector:@selector(task_end:) name:AFNetworkingTaskDidCompleteNotification object:task];
            [notificationCenter addObserver:self selector:@selector(task_suspend:) name:AFNetworkingTaskDidSuspendNotification object:task];
        } else {
            NSNotification *notify = [[NSNotification alloc] initWithName:@"" object:task userInfo:nil];
            [self task_end:notify];
        }
    }
}
- (void)task_resume:(NSNotification *)notify{
    NSURLSessionTask *task = notify.object;
    [self.networkTasks addObject:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ActivityHUD loadingInView:[self getDisplayView] text:BASEKIT_TXT_LOADING];
    });
}
- (void)task_end:(NSNotification *)notify{
    NSURLSessionTask *task = notify.object;
    [self.networkTasks removeObject:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ActivityHUD removeLoading];
    });
}
- (void)task_suspend:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ActivityHUD removeLoading];
    });
}

- (void)cancelAllTasks{
    for (NSURLSessionDataTask *task in self.networkTasks) {
        [task cancel];
    }
}


//弹窗显示信息，过一段时间自动消失
- (void)showInfoTip:(NSString *)tip{
    [self showInfoTip:tip complete:nil];
}
- (void)showInfoTip:(NSString *)tip complete:(void (^)())complete{
    UIView *view = self.view.window;
    if (!view) {
        view = self.view;
    }
    if (tip.length>BASEKIT_TIP_MAXLENGTH) {
        [ActivityHUD tipInView:view keep:BASEKIT_TIP_KEEP_SECOND text:BASEKIT_TXT_TITLE description:tip complete:complete];
        return;
    }
    [ActivityHUD tipInView:view keep:BASEKIT_TIP_KEEP_SECOND text:tip complete:complete];
}
- (void)showErrorTip:(NSError *)error{
    [self showInfoTip:error.description complete:nil];
}
//显示遮罩加载
- (void)showLoading{
    [ActivityHUD loadingInView:self.view text:BASEKIT_TXT_LOADING];
}
- (void)showLoadingWithText:(NSString *)text{
    [ActivityHUD loadingInView:self.view text:text];
}
//移除遮罩加载
- (void)hideLoading{
    [ActivityHUD removeLoading];
}

//初始化默认导航栏
- (void)initNavigationBar{}
//初始化注册通知
- (void)initNotification{}
//加载数据（可能会反复调用）
-(void)loadData{
    for (NSString* key in self.params) {
        [self setValue:[self.params objectForKey:key] forKey:key];
    }
}

- (UIView *)getDisplayView
{
    UIWindow *window = self.view.window;
    if (!window) {
        return self.view;
    }
    id rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = nil;
        nc = rootViewController;
        return nc.visibleViewController.view;
    }
    return window;
}


- (void)dealloc{
    [self cancelAllTasks];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
