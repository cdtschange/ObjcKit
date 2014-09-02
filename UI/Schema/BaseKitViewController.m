//
//  BaseKitViewController.m
//  ObjcKit
//
//  Created by Wei Mao on 9/2/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "BaseKitViewController.h"

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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
