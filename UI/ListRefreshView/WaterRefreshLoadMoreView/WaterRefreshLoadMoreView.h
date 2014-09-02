/**
 *  WaterRefreshLoadMoreView.h
 *  A refresh view looks like UIRefreshControl and have loadMore function
 *  (水滴下拉刷新，上拉加载)
 *
 *  使用方法：（可设置type类型，默认是下拉上拉都有）
 *      1.  直接initWithType创建,然后将它的scrollView赋值,别忘了在使用它的ScrollView 或者 VC的dealloc
 *          中调用这个 deallocWithCloseConnect 方法
 *
 *  Created by 覃俊涵 on 13-9-18. All rights reserved.
 **/

#import <UIKit/UIKit.h>
#import "SRSlimeView.h"

typedef enum{
    WaterRefreshTypeRefreshAndLoadMore,//含下拉上拉(default)
    WaterRefreshTypeOnlyRefresh,       //仅下拉刷新
    WaterRefreshTypeOnlyLoadMore,      //仅加载更多
    WaterRefreshTypeNone
}WaterViewType;

@protocol WaterRefreshDelegate;
@protocol WaterLoadMoreDelegate;

@interface WaterRefreshLoadMoreView : UIView

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) WaterViewType type;

// 水下拉的view
@property (nonatomic, weak) UIView *waterRefreshView;
// 上拉的view
@property (nonatomic, strong) UIView *loadMoreView;

// 水滴中央的图片样式
@property (nonatomic, strong) UIImageView *refleshView;
// 刷新提示字时 前方显示的 图片样式
@property (nonatomic, strong) UIImageView *refreshRemindPicView;

// refresh上的提示label
@property (nonatomic, strong) UILabel *refreshRemind;
// loadMore上的提示label
@property (nonatomic, strong) UILabel *loadMoreRemind;

// loadMore转圈时显示的文字，比如 "加载中.."，没有设置则转动图样居中显示
@property (nonatomic, strong) NSString *loadMoreIndicatorWord;

@property (nonatomic, weak) id <WaterRefreshDelegate>   refreshDelegate;
@property (nonatomic, weak) id <WaterLoadMoreDelegate>  loadMoreDelegate;
@property (nonatomic, assign, readonly) BOOL isRefreshing;
@property (nonatomic, assign, readonly) BOOL isLoadingMore;

// initial method
- (id)initWithWithType:(WaterViewType)type;

// !你需要在使用它的ScrollView 或者 VC的dealloc中调用这个方法
- (void)deallocWithCloseConnect;
/*w
 start: 自动开始水滴下拉刷新自动开始，另一种是靠你手去拖动触发
 end  : 结束水滴下拉刷新并显示提示动画，请传入提示语，你可能会想提示："刷新成功",
 可指定提示图片
 */
- (void)startRefreshWithExpansion;
- (void)startRefreshWithExpansionWithoutDelegate;
- (void)endRefreshWithRemindsWords:(NSString *)remind remindImage:(UIImage *)remindImage;

/*
 start: 自动开始上拉加载,另一种是靠手去上拉
 end  : 停止上拉加载，可给予提示
 */
- (void)startLoadingMoreExpansion;
- (void)startLoadingMoreExpansionWithOutDelegate;
- (void)endLoadingMoreWithRemind:(NSString *)remind;

// 禁掉loadMore的上拉加载功能，ban为YES时提示语默认为“没有更多内容”
- (void)banFunctionOfStartLoadMore:(BOOL)ban remind:(NSString *)remind;

- (void)setWaterRefreshColor:(UIColor*)color;
@end

@protocol WaterRefreshDelegate <NSObject>
// 水滴下拉刷新的代理方法
- (void)slimeRefreshStartRefresh:(WaterRefreshLoadMoreView*)refreshView;
- (void)slimeRefreshEndRefresh:(WaterRefreshLoadMoreView *)refreshView;
@end

@protocol WaterLoadMoreDelegate <NSObject>

@optional
// 加载更多的代理方法
- (void)loadMoreViewStartLoad:(WaterRefreshLoadMoreView*)refreshView;
- (void)loadMoreViewEndLoad:(WaterRefreshLoadMoreView *)refreshView;
@end

