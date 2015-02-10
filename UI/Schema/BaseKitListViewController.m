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
    self.separatorTableViewInset = 15;
    self.dataArray = [NSMutableArray new];
    self.refreshLoadMoreView = [[WaterRefreshLoadMoreView alloc] initWithWithType:self.listType];
    self.refreshLoadMoreView.refreshDelegate = self;
    self.refreshLoadMoreView.loadMoreDelegate = self;
    self.refreshLoadMoreView.scrollView = self.listView;
    self.refreshLoadMoreView.loadMoreIndicatorWord = BASEKIT_TXT_LOADING;
    self.refreshLoadMoreView.txtNoMore = self.txtNoMore;

    __weak BaseKitListViewController *weakself = self;
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
-(void)setTxtNoMore:(NSString *)txtNoMore{
    _txtNoMore = txtNoMore;
    self.refreshLoadMoreView.txtNoMore = txtNoMore;
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
            [self.refreshLoadMoreView banFunctionOfStartLoadMore:YES remind:self.txtNoMore];
        }else{
            if (!self.isRefresh) {
                if ([self listLoadNumber]>0&&(self.dataArray.count>0 && array.count==0)) {
                    [self.refreshLoadMoreView banFunctionOfStartLoadMore:YES remind:self.txtNoMore];
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


- (void)setListNetworkStateOfTask:(NSURLSessionTask *)task{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:AFNetworkingTaskDidCompleteNotification object:nil];
    
    if (task) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [notificationCenter addObserver:self selector:@selector(task_list_resume:) name:AFNetworkingTaskDidResumeNotification object:task];
            [notificationCenter addObserver:self selector:@selector(task_list_end:) name:AFNetworkingTaskDidCompleteNotification object:task];
            [notificationCenter addObserver:self selector:@selector(task_list_suspend:) name:AFNetworkingTaskDidSuspendNotification object:task];
        } else {
            NSNotification *notify = [[NSNotification alloc] initWithName:@"" object:task userInfo:nil];
            [self task_list_end:notify];
        }
    }
}
- (void)task_list_resume:(NSNotification *)notify{
    NSURLSessionTask *task = notify.object;
    [self.networkTasks addObject:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isRefresh) {
            [self.refreshLoadMoreView startRefreshWithExpansionWithoutDelegate];
        }
    });
}
- (void)task_list_end:(NSNotification *)notify{
    NSURLSessionTask *task = notify.object;
    [self.networkTasks removeObject:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isRefresh) {
            [self.refreshLoadMoreView endRefreshWithRemindsWords:BASEKIT_TXT_REFRESH_SUCCESS remindImage:nil];
        }else{
            [self.refreshLoadMoreView endLoadingMoreWithRemind:nil];
        }
    });
}
- (void)task_list_suspend:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isRefresh) {
            [self.refreshLoadMoreView endRefreshWithRemindsWords:BASEKIT_TXT_REFRESH_SUCCESS remindImage:nil];
        }else{
            [self.refreshLoadMoreView endLoadingMoreWithRemind:nil];
        }
    });
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,self.separatorTableViewInset,0,0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,self.separatorTableViewInset,0,0)];
    }
//    [cell startCanvasAnimation];
}

-(void)viewDidLayoutSubviews
{
    UITableView *tableView = (UITableView *)self.listView;
    if (tableView) {
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsMake(0,self.separatorTableViewInset,0,0)];
        }
        
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsMake(0,self.separatorTableViewInset,0,0)];
        }
    }
}

@end