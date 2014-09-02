//
//  BaseListViewController.m
//  G2R
//
//  Created by Wei Mao on 7/15/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "BaseKitListViewController.h"

#define BASEKIT_TXT_LOADING                 @"正在加载..."
#define BASEKIT_TXT_REFRESH_SUCCESS         @"刷新成功"
#define BASEKIT_TXT_REFRESH_FAILED          @"刷新失败"

@interface BaseKitListViewController()

@property (assign, nonatomic) BOOL isRefresh;

@end

@implementation BaseKitListViewController

-(void)dealloc{
    self.dataArray = nil;
    [self.refreshLoadMoreView deallocWithCloseConnect];
    self.refreshLoadMoreView = nil;
}
-(void)initUIAndData{
    [super initUIAndData];
    self.isRefresh = YES;
    self.dataArray = [NSMutableArray new];
    self.refreshLoadMoreView = [[WaterRefreshLoadMoreView alloc] initWithWithType:self.listType];
    self.refreshLoadMoreView.refreshDelegate = self;
    self.refreshLoadMoreView.loadMoreDelegate = self;
    self.refreshLoadMoreView.scrollView = self.listView;
    self.refreshLoadMoreView.loadMoreIndicatorWord = BASEKIT_TXT_LOADING;

    __weak BaseKitListViewController *weakself = self;
    self.listStatusBlock = ^(NetworkProviderStatus status, NSError *error) {
        switch (status) {
            case NetworkProviderStatusBegin:
                if (weakself.isRefresh) {
                    [weakself.refreshLoadMoreView startRefreshWithExpansionWithoutDelegate];
                }
                break;
            case NetworkProviderStatusEnd:
                if (weakself.isRefresh) {
                    [weakself.refreshLoadMoreView endRefreshWithRemindsWords:BASEKIT_TXT_REFRESH_SUCCESS remindImage:nil];
                }else{
                    [weakself.refreshLoadMoreView endLoadingMoreWithRemind:nil];
                }
                break;
            case NetworkProviderStatusFailed:
                if (weakself.isRefresh) {
                    [weakself.refreshLoadMoreView endRefreshWithRemindsWords:BASEKIT_TXT_REFRESH_FAILED remindImage:nil];
                }else{
                    [weakself.refreshLoadMoreView endLoadingMoreWithRemind:nil];
                }
                [weakself showErrorTip:error];
                break;
            default:
                break;
        }
    };
    self.listFailureBlock = ^(NSError *error) {
        if (weakself.isRefresh) {
            [weakself.refreshLoadMoreView endRefreshWithRemindsWords:BASEKIT_TXT_REFRESH_FAILED remindImage:nil];
        }else{
            [weakself.refreshLoadMoreView endLoadingMoreWithRemind:nil];
        }
        [weakself showErrorTip:error];
    };
}
-(void)setTipTextColor:(UIColor *)tipTextColor{
    _tipTextColor = tipTextColor;
    self.refreshLoadMoreView.loadMoreRemind.textColor = _tipTextColor;
    self.refreshLoadMoreView.refreshRemind.textColor = _tipTextColor;
}
-(UIScrollView *)listView{
    return nil;//需要子类重写
}
-(int)listLoadNumber{
    return 0;
}
-(int)listMaxNumber{
    return 0;
}
-(void)scrollViewPulling:(BOOL)isRefresh{
    self.isRefresh = isRefresh;
    [self.refreshLoadMoreView banFunctionOfStartLoadMore:NO remind:nil];
}
-(void)dataArrayChanged:(NSArray *)array{
    if (self.isRefresh||self.dataIndex == 0) {
        self.dataIndex = 0;
        [self.dataArray removeAllObjects];
    }
    for (id item in array) {
        [self.dataArray addObject:item];
        self.dataIndex ++;
    }
    if ([self listLoadNumber]>0&&
        (self.dataArray.count%[self listLoadNumber]>0||
         self.dataArray.count>[self listMaxNumber])) {
            [self.refreshLoadMoreView banFunctionOfStartLoadMore:YES remind:nil];
        }else{
            if (!self.isRefresh) {
                if ([self listLoadNumber]>0&&(self.dataArray.count>0 && array.count==0)) {
                    [self.refreshLoadMoreView banFunctionOfStartLoadMore:YES remind:nil];
                }
            }
        }
    if (self.listType == WaterRefreshTypeNone) {
        self.listView.bounces = self.dataArray.count>0;
    }
}

#pragma mark - WaterView Refresh delegate and loadMore delegate

- (void)slimeRefreshStartRefresh:(WaterRefreshLoadMoreView *)refreshView
{
    self.dataIndex = 0;
    [self scrollViewPulling:YES];
}

- (void)slimeRefreshEndRefresh:(WaterRefreshLoadMoreView *)refreshView
{
}

- (void)loadMoreViewStartLoad:(WaterRefreshLoadMoreView *)refreshView
{
    [self scrollViewPulling:NO];
}

- (void)loadMoreViewEndLoad:(WaterRefreshLoadMoreView *)refreshView
{
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [cell startCanvasAnimation];
}

@end