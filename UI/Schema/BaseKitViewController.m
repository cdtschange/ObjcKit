//
//  BaseKitViewController.m
//  ObjcKit
//
//  Created by Wei Mao on 9/2/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "BaseKitViewController.h"
#import "ActivityHUD.h"

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
    __weak BaseKitViewController *weakself = self;
    self.statusBlock = ^(NetworkProviderStatus status, NSError *error) {
        switch (status) {
            case NetworkProviderStatusBegin:
                [ActivityHUD loadingInView:[weakself getDisplayView] text:BASEKIT_TXT_LOADING];
                break;
            case NetworkProviderStatusEnd:
                [ActivityHUD removeLoading];
                break;
            case NetworkProviderStatusFailed:
                [ActivityHUD removeLoading];
                [weakself showErrorTip:error];
                break;
            default:
                break;
        }
    };
    self.failureBlock = ^(NSError *error) {
        [weakself showErrorTip:error];
    };
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
    if (self.view.window) {
        [ActivityHUD tipInView:self.view.window keep:BASEKIT_TIP_KEEP_SECOND text:tip complete:complete];
    }else{
        [ActivityHUD tipInView:self.view keep:BASEKIT_TIP_KEEP_SECOND text:tip complete:complete];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
