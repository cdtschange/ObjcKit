//
//  BaseListViewController.h
//  G2R
//
//  Created by Wei Mao on 7/15/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKitViewController.h"
#import "WaterRefreshLoadMoreView.h"

typedef enum{
    ListViewArrowStyleGray
}ListViewArrowStyle;

@interface BaseKitListViewController : BaseKitViewController<WaterRefreshDelegate,WaterLoadMoreDelegate>

@property (nonatomic, copy)     void (^listStatusBlock)(NetworkProviderStatus status, NSError *error);
@property (nonatomic, copy)     void (^listFailureBlock)(NSError *);
@property(assign, nonatomic) WaterViewType listType; // 列表类型：刷新、加载更多
@property(assign, nonatomic) int listLoadNumber;
@property(assign, nonatomic) int listMaxNumber;
@property(strong, nonatomic) UIColor *tipTextColor;
@property(assign, nonatomic) NSInteger dataIndex;
@property(strong, nonatomic) NSMutableArray *dataArray;
@property(strong, nonatomic) WaterRefreshLoadMoreView *refreshLoadMoreView;

- (UIScrollView *)listView;
- (void)scrollViewPulling:(BOOL)isRefresh;
- (void)dataArrayChanged:(NSArray *)array;

@end