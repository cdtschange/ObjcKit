//
//  WaterRefreshLoadMoreView.m
//  shiyanforwaterfresh
//
//  Created by 俊涵 on 13-9-19.
//  Copyright (c) 2013年 俊涵. All rights reserved.
//

#import "WaterRefreshLoadMoreView.h"
#import "SRSlimeView.h"
#import <QuartzCore/QuartzCore.h>

#define KEYPATH_CONTENTOFFSET       @"contentOffset"
#define KEYPATH_CONTENTSIZE         @"contentSize"

#define STRING_LOADMORE             @"加载更多"
#define STRING_NOMORE               @"没有更多内容"

#define HEIGHT_DEFAULT              40.0f
#define DURIATION_ANIMATE           0.2f
#define DURIATION_SHOWNOMORE        1.5f
#define TAG_LOADMORE_INDICATOR      200
#define kRefreshImageWidth          20.0f
#define kDistanceFromRemind         10.0f

static int scrollViewObservanceContext;
static int scrollViewContentSizeContext;

typedef enum {
    FooterViewStateNormal,
    FooterViewStateNormalPullling,
    FooterViewStateLoadingMore
}FooterViewState;

@interface WaterRefreshLoadMoreView()
{
    UIImageView     *_refleshView;
    SRSlimeView     *_slime;
}

@property (nonatomic, assign) FooterViewState footerState;

@property (nonatomic, strong) SRSlimeView *slime;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;

@property (nonatomic, assign) BOOL closeLoadMore;
@property (nonatomic, assign) BOOL endAnimation;
@property (nonatomic, assign) BOOL endRefreshWithRemind;
@property (nonatomic, assign) BOOL broken;
@property (nonatomic, assign) BOOL slimeMissWhenGoingBack;
@property (nonatomic, assign) BOOL lastDragScroll;
@property (nonatomic, assign) BOOL isHasMoreContent;

@property (nonatomic, assign) CGFloat upInset;
@property (nonatomic, strong) NSString *refreshRemindWord;
@property (nonatomic, strong) NSString *loadMoreRemindWord;

@property (nonatomic, strong) UITapGestureRecognizer *gesture;

@end

@implementation WaterRefreshLoadMoreView {
    UIActivityIndicatorView *_activityIndicatorView;
    CGFloat     _oldLength;
    BOOL        _unmissSlime;
    CGFloat     _dragingHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithHeight:HEIGHT_DEFAULT];
    return self;
}

- (id)initWithWithType:(WaterViewType)type
{
    self = [self initWithHeight:HEIGHT_DEFAULT];
    self.type = type;
    return self;
}

- (id)initWithHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
    self = [super initWithFrame:frame];
    if (self) {
        // slime
        _slime = [[SRSlimeView alloc] initWithFrame:self.bounds];
        _slime.startPoint = CGPointMake(frame.size.width / 2, height / 2);
        [self addSubview:_slime];
        [_slime setPullApartTarget:self
                            action:@selector(pullApart:)];
        // 刷新图样
        _refleshView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waterRefreshLoadMore_refresh"]];
        _refleshView.center = _slime.startPoint;
        _refleshView.bounds = CGRectMake(0.0f, 0.0f, kRefreshImageWidth, kRefreshImageWidth);
        [self addSubview:_refleshView];
        // indicator
        _activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = _slime.startPoint;
        [self addSubview:_activityIndicatorView];
        // refreshRemind
        self.refreshRemind = [[UILabel alloc] initWithFrame:_slime.frame];
        [self addSubview:self.refreshRemind];
        self.refreshRemind.backgroundColor = [UIColor clearColor];
        self.refreshRemind.textAlignment = NSTextAlignmentCenter;
        self.refreshRemind.textColor = [UIColor grayColor];
        self.refreshRemind.font = [UIFont systemFontOfSize:13.0f];
        self.refreshRemind.hidden = YES;
        // refreshRemindPicView
        self.refreshRemindPicView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kRefreshImageWidth, kRefreshImageWidth)];
        [self addSubview:self.refreshRemindPicView];
        self.refreshRemindPicView.hidden = YES;
        // 设置拖拽临界点的高度
        _dragingHeight = height;
        self.slimeMissWhenGoingBack = NO;
        self.waterRefreshView = self;
    }
    return self;
}

- (void)setWaterRefreshColor:(UIColor*)color
{
    [_activityIndicatorView setColor:color];
    self.refreshRemind.textColor = color;
 //   _slime.bodyColor = color;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (id)[self superview];
        if (self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyLoadMore) {
            [self addLoadMoreView];
        }
        self.isHasMoreContent = YES;
        // config frame
        CGRect rect = self.frame;
        rect.origin.y = rect.size.height ? -rect.size.height : -_dragingHeight;
        rect.size.width = _scrollView.frame.size.width;
        self.frame = rect;
        // inset
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = _upInset;
        self.scrollView.contentInset = inset;
        [self.scrollView addObserver:self forKeyPath:KEYPATH_CONTENTOFFSET options:0 context:&scrollViewObservanceContext];
        [self.scrollView addObserver:self forKeyPath:KEYPATH_CONTENTSIZE options:0 context:&scrollViewContentSizeContext];
        // configLoadMoreHide
        [self configLoadMoreHide];
    }else if (!self.superview) {
        self.scrollView = nil;
    }
}

- (void)addLoadMoreView
{
    // add loadmore
    CGFloat maxTop = self.scrollView.frame.size.height > self.scrollView.contentSize.height ? self.scrollView.frame.size.height : self.scrollView.contentSize.height;
    self.loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, maxTop, [UIScreen mainScreen].bounds.size.width, HEIGHT_DEFAULT)];
    [self.scrollView addSubview:self.loadMoreView];
    self.loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadMoreActivityView.tag = TAG_LOADMORE_INDICATOR;
    [self.loadMoreView addSubview:self.loadMoreActivityView];
    self.loadMoreActivityView.center = CGPointMake(self.loadMoreView.frame.size.width / 2, self.loadMoreView.frame.size.height / 2);
    [self showLoadMoreRemind:STRING_LOADMORE];
    // config loadMoreRemind
    self.loadMoreRemind = [[UILabel alloc] initWithFrame:self.loadMoreView.bounds];
    self.loadMoreRemind.backgroundColor = [UIColor clearColor];
    self.loadMoreRemind.font = [UIFont systemFontOfSize:12.0f];
    self.loadMoreRemind.textColor = [UIColor grayColor];
    self.loadMoreRemind.textAlignment = NSTextAlignmentCenter;
    [self.loadMoreView addSubview:self.loadMoreRemind];
    //self.loadMoreRemind.hidden = NO;
    [self showLoadMoreRemind:STRING_LOADMORE];
    // gesture
    self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMoreActionByClick)];
    [self.loadMoreView addGestureRecognizer:self.gesture];
    self.footerState = FooterViewStateNormal;
    [self configLoadMoreHide];
}

- (void)loadMoreActionByClick
{
    [self scrollViewDataSourceDidStartLoadingMore:self.scrollView];
}

- (void)dealloc
{
    [self clearObservance];
}

- (void)deallocWithCloseConnect  // TODO :换成更好的办法
{
    [self clearObservance];
}

- (void)clearObservance
{
    [self.scrollView removeObserver:self forKeyPath:KEYPATH_CONTENTOFFSET context:&scrollViewObservanceContext];
    [self.scrollView removeObserver:self forKeyPath:KEYPATH_CONTENTSIZE context:&scrollViewContentSizeContext];
    self.scrollView = nil;
}

- (void)removeFromSuperview
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super removeFromSuperview];
}

#pragma mark - setters And getter

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (_scrollView != scrollView) {
        _scrollView = scrollView;
        if (self.superview) {
            [self.loadMoreView removeFromSuperview];
            self.loadMoreView = nil;
            [self removeFromSuperview];
        }
        [self.scrollView addSubview:self];
    }
}

- (void)setType:(WaterViewType)type
{
    if (self.type == type) {
        return;
    }
    if (self.type != WaterRefreshTypeNone) {
        [self.scrollView removeObserver:self forKeyPath:KEYPATH_CONTENTOFFSET context:&scrollViewObservanceContext];
        [self.scrollView removeObserver:self forKeyPath:KEYPATH_CONTENTSIZE context:&scrollViewContentSizeContext];
    }
    _type = type;
    _isLoadingMore = NO;
    [self setFooterState:FooterViewStateNormal];
    self.closeLoadMore = NO;
    // 如果切换类型之前动画还未结束
    if (self.endAnimation == NO) {
        self.endAnimation = YES;
    }
    self.endRefreshWithRemind = NO;
    [self endRefreshWithRemindsWords:@"" remindImage:nil];
    [self endLoadingMoreWithRemind:@""];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(collapse) object:nil];
    [self backStateOfScrollView];
    if (type == WaterRefreshTypeRefreshAndLoadMore || type == WaterRefreshTypeOnlyRefresh) {
        self.hidden = NO;
        self.loadMoreView.hidden = NO;
        UIScrollView *scrollView = self.scrollView;
        self.scrollView = nil; //clear
        self.scrollView = scrollView;
    } else if (type == WaterRefreshTypeOnlyLoadMore) {
        self.loadMoreView.hidden = NO;
        self.hidden = YES;
        UIScrollView *scrollView = self.scrollView;
        self.scrollView = nil; //clear
        self.scrollView = scrollView;
    } else if(type == WaterRefreshTypeNone) {
        self.hidden = YES;
        self.loadMoreView.hidden = YES;
    }
}

- (void)backStateOfScrollView
{
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = _upInset;
    inset.bottom = 0.0f;
    self.scrollView.contentInset = inset;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_slime.state == SRSlimeStateNormal) {
        _slime.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        _slime.startPoint = CGPointMake(frame.size.width / 2, _dragingHeight / 2);
    }
    _refleshView.center = _slime.startPoint;
    _activityIndicatorView.center = _slime.startPoint;
}

- (void)setUpInset:(CGFloat)upInset
{
    _upInset = upInset;
    UIEdgeInsets inset = _scrollView.contentInset;
    inset.top = _upInset;
    _scrollView.contentInset = inset;
}

- (void)setSlimeMissWhenGoingBack:(BOOL)slimeMissWhenGoingBack
{
    _slimeMissWhenGoingBack = slimeMissWhenGoingBack;
    if (!slimeMissWhenGoingBack) {
        _slime.alpha = 1;
    }else {
        CGPoint p = _scrollView.contentOffset;
        self.alpha = -(p.y + _upInset) / _dragingHeight;
    }
}

#pragma mark - Scroll handle

- (void)scrollViewDidScroll
{
    CGPoint offset = _scrollView.contentOffset;
    CGRect rect = self.frame;
    // 下拉刷新
    if (self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyRefresh) {
        if (offset.y <= - _dragingHeight - _upInset) {
            // 处于拉伸变形的状态
            rect.origin.y = offset.y + _upInset;
            rect.size.height = -offset.y;
            rect.size.height = ceilf(rect.size.height);
            self.frame = rect; //special setFrame
            if (!self.isRefreshing) {
                [_slime setNeedsDisplay];
            }
            if (!_broken) {
                float l = -(offset.y + _dragingHeight + _upInset);
                if (l <= _oldLength) {
                    // 往回的时候
                    l = MIN(distansBetween(_slime.startPoint, _slime.toPoint), l);
                    CGPoint ssp = _slime.startPoint;
                    _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                    CGFloat pf = (1.0f - l / _slime.viscous) * (1.0f - kStartTo) + kStartTo;
                    _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
                }else if (self.scrollView.isDragging) {
                    // 手拽着往下拉伸的时候
                    CGPoint ssp = _slime.startPoint;
                    _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                    CGFloat pf = (1.0f - l / _slime.viscous) * (1.0f - kStartTo) + kStartTo;
                    _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
                }
                _oldLength = l;
            }
            if (self.alpha != 1.0f) self.alpha = 1.0f; //拉出来显示的时候可能 alpha不为1
        }else if (offset.y < -_upInset) {
            rect.origin.y = -_dragingHeight;
            rect.size.height = _dragingHeight;
            self.frame = rect;
            [_slime setNeedsDisplay];
            _slime.toPoint = _slime.startPoint;
            if (_slimeMissWhenGoingBack)
                self.alpha = -(offset.y + _upInset) / _dragingHeight;
        }
        if (self.isRefreshing && self.broken == NO) {
            // 配合适应inset避免 使用 tableview的话 section位置浮动错误
            UIEdgeInsets inset = _scrollView.contentInset;
            CGFloat offsetmath = MAX(_scrollView.contentOffset.y * -1, 0);
            offsetmath = MIN(offsetmath, HEIGHT_DEFAULT);
            inset.top = offsetmath;
            _scrollView.contentInset = inset;
        }
    }
    if ((self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyLoadMore) && self.closeLoadMore == NO) {
        // 上拉
        if (self.footerState == FooterViewStateNormal) {
            if (self.scrollView.isDragging && [self offsetFromBottom:self.scrollView] > self.loadMoreView.frame.size.height + 5) {
                [self setFooterState:FooterViewStateNormalPullling];
                if (self.isHasMoreContent == NO) {
                } else {
                    [self scrollViewDataSourceDidStartLoadingMore:self.scrollView];
                }
            }
        } else if (self.footerState == FooterViewStateNormalPullling) {
            if (self.scrollView.isDragging && [self offsetFromBottom:self.scrollView] < self.frame.size.height + 5) {
                [self setFooterState:FooterViewStateNormal];
            }
        } else if (self.footerState == FooterViewStateLoadingMore) {
        }
    }
}

- (void)scrollViewDidEndDraging
{
    // 下拉刷新
    if (self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyRefresh) {
        if (_broken) {
            self.broken = NO;
            if (self.isRefreshing) {
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:DURIATION_ANIMATE animations:^{
                    UIEdgeInsets inset = _scrollView.contentInset;
                    inset.top = _upInset + _dragingHeight;
                    _scrollView.contentInset = inset;
                } completion:^(BOOL finished) {
                }];
            }
        }
    }
    // 上拉
    if ((self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyLoadMore) && self.closeLoadMore == NO) {
        if (self.footerState == FooterViewStateNormalPullling) {
            if (self.isHasMoreContent == NO) {
            } else {
                [self scrollViewDataSourceDidStartLoadingMore:self.scrollView];
            }
        }
    }
}

#pragma mark - loadMore

- (void)relayoutLoadMoreViewAndInset
{
    if (self.closeLoadMore == YES) {
        return;
    }
    CGFloat max = self.scrollView.contentSize.height < self.scrollView.frame.size.height ? self.scrollView.frame.size.height - self.scrollView.contentSize.height : 0;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom = max + self.loadMoreView.frame.size.height;
    self.scrollView.contentInset = inset;
    CGFloat footerViewTop = MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
    self.loadMoreView.frame = CGRectMake(0, footerViewTop, self.loadMoreView.frame.size.width, self.loadMoreView.frame.size.height);
}

- (void)configLoadMoreHide
{
    if (self.type == WaterRefreshTypeRefreshAndLoadMore || self.type == WaterRefreshTypeOnlyLoadMore) {
        if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
            self.loadMoreView.hidden = YES;
            self.closeLoadMore = YES;
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.bottom = 0.0f;
            self.scrollView.contentInset = inset;
        } else {
            self.loadMoreView.hidden = YES;
            self.closeLoadMore = YES;
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.bottom = self.loadMoreView.frame.size.height;
            self.scrollView.contentInset = inset;
            self.loadMoreView.hidden = NO;
            self.closeLoadMore = NO;
        }
    }
}

- (void)startLoadingMoreExpansion
{
    [self scrollViewDataSourceDidStartLoadingMore:self.scrollView];
}

- (void)startLoadingMoreExpansionWithOutDelegate
{
    [self scrollViewDataSourceDidStartLoadingMoreWithOutDelegate:self.scrollView];
}

- (void)endLoadingMoreWithRemind:(NSString *)remind
{
    if (self.type == WaterRefreshTypeNone || self.type == WaterRefreshTypeOnlyRefresh) {
        return;
    }
    if (_isLoadingMore) {
        self.loadMoreRemindWord = remind;
        [self safeStopLoadingMore:self.scrollView];
    }
}

- (void)safeStartLoadingMore:(UIScrollView *)scrollView
{
    if (!_isLoadingMore) {
        _isLoadingMore = YES;
    } else {
        return;
    }
    [self endRefreshWithRemindsWords:nil remindImage:nil];
    [self setFooterState:FooterViewStateLoadingMore];
    self.gesture.enabled = NO;
    self.loadMoreView.hidden = NO;
    [self showLoadMoreRemind:@""]; //清空
    [self.loadMoreActivityView startAnimating];
    // config 转动时提示
    [self configIndicatorPositionWithWord:self.loadMoreIndicatorWord];
    self.loadMoreRemind.alpha = 0.45f;
    // cofig animate with indicatorword
    NSTimeInterval animateDuration = 0.7f;
    [UIView animateWithDuration:animateDuration animations:^{
        self.loadMoreRemind.alpha = 1.0f;
    }];
    CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    aniamtion.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCATransform3D:
                         CATransform3DRotate(CATransform3DMakeScale(0.01, 0.01, 0.1),
                                             -M_PI, 0, 0, 1)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)],
                        [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
    aniamtion.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:1], nil];
    aniamtion.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:
                                  kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:
                                  kCAMediaTimingFunctionEaseInEaseOut],
                                 nil];
    aniamtion.duration = animateDuration;
    self.loadMoreActivityView.layer.transform = CATransform3DIdentity;
    [self.loadMoreActivityView.layer addAnimation:aniamtion forKey:@""];
    
}

- (void)safeStopLoadingMore:(UIScrollView *)scrollView
{
    if (!_isLoadingMore) {
        return;
    }
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.2f animations:^{
        self.loadMoreActivityView.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.01f, 0.01f, 0.1f), -M_PI, 0, 0, 1);
        self.loadMoreRemind.alpha = 0.2f;
    } completion:^(BOOL finished) {
        [self.loadMoreActivityView stopAnimating];
        self.loadMoreActivityView.layer.transform = CATransform3DRotate(CATransform3DMakeScale(1.0f, 1.0f, 1.0f), M_PI, 0, 0, 1);
        self.loadMoreRemind.alpha = 1.0f;
        [self relayoutLoadMoreViewAndInset];
        if (self.isHasMoreContent) {
            if (self.loadMoreRemindWord) {
                //错误提示语
                [self showLoadMoreRemind:self.loadMoreRemindWord];
                [self performSelector:@selector(backToLoadMoreRemind) withObject:nil afterDelay:1.0f];
            } else {
                [self showLoadMoreRemind:STRING_LOADMORE];
                _isLoadingMore = NO;
                [self setFooterState:FooterViewStateNormal];
                self.gesture.enabled = YES;
                if ([self.loadMoreDelegate respondsToSelector:@selector(loadMoreViewEndLoad:)]) {
                    [self.loadMoreDelegate loadMoreViewEndLoad:self];
                }
            }
        } else {
            if (self.loadMoreRemindWord) {
                if ([self.loadMoreRemindWord isEqualToString:@""]) {
                    self.loadMoreRemindWord = STRING_NOMORE;
                }
                [self showLoadMoreRemind:self.loadMoreRemindWord];
            } else {
                [self showNoContentRemind];
            }
            [self performSelector:@selector(setInsetBottomAnimateToZeroAndCallDelegate:) withObject:[NSNumber numberWithBool:YES] afterDelay:DURIATION_SHOWNOMORE];
        }
    }];
}

- (void)setInsetBottomAnimateToZeroAndCallDelegate:(NSNumber *)callDelegate
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:DURIATION_ANIMATE animations:^{
        [self setInsetBottomToZero];
    } completion:^(BOOL finished) {
        _isLoadingMore = NO;
        [self setFooterState:FooterViewStateNormal];
        if (self.isHasMoreContent) {
            self.gesture.enabled = YES;
        }
        if (callDelegate.boolValue) {
            if ([self.loadMoreDelegate respondsToSelector:@selector(loadMoreViewEndLoad:)]) {
                [self.loadMoreDelegate loadMoreViewEndLoad:self];
            }
        };
    }];
    [UIView commitAnimations];
}

- (void)setInsetBottomToZero
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = 0;
    self.scrollView.contentInset = currentInsets;
}

- (void)scrollViewDataSourceDidStartLoadingMore:(UIScrollView *)scrollView
{
    if (!_isLoadingMore) {
        [self safeStartLoadingMore:scrollView];
        if ([self.loadMoreDelegate respondsToSelector:@selector(loadMoreViewStartLoad:)]) {
            [self.loadMoreDelegate loadMoreViewStartLoad:self];
        }
    }
}

- (void)scrollViewDataSourceDidStartLoadingMoreWithOutDelegate:(UIScrollView *)scrollView
{
    [self safeStartLoadingMore:scrollView];
}

- (void)scrollViewDataSourceDidFinishLoadingMore:(UIScrollView *)scrollView
{
    [self safeStopLoadingMore:scrollView];
}

- (CGFloat)offsetFromBottom:(UIScrollView *)scrollView
{
    CGFloat change = scrollView.contentSize.height < scrollView.frame.size.height ? 0 :  scrollView.contentSize.height - scrollView.frame.size.height;
    return  scrollView.contentOffset.y - change;
}

- (void)showNoContentRemind
{
    self.loadMoreRemind.hidden = NO;
    [self showLoadMoreRemind:STRING_NOMORE];
}

- (void)showLoadMoreRemind:(NSString *)remindword
{
    self.loadMoreActivityView.hidden = YES;
    self.loadMoreRemind.hidden = NO;
    self.loadMoreRemind.text = remindword;
    self.loadMoreRemind.center = CGPointMake(self.loadMoreView.frame.size.width / 2, self.loadMoreView.frame.size.height / 2);
    self.loadMoreRemindWord = nil; //clear
}

- (void)backToLoadMoreRemind
{
    UILabel *label = self.loadMoreRemind;
    [UIView animateWithDuration:0.3f animations:^{
        label.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self showLoadMoreRemind:STRING_LOADMORE];
        [UIView animateWithDuration:0.3f animations:^{
            label.alpha = 1.0f;
            self.gesture.enabled = YES;
            _isLoadingMore = NO;
            [self setFooterState:FooterViewStateNormal];
            if ([self.loadMoreDelegate respondsToSelector:@selector(loadMoreViewEndLoad:)]) {
                [self.loadMoreDelegate loadMoreViewEndLoad:self];
            }
        }];
    }];
}

- (void)banFunctionOfStartLoadMore:(BOOL)ban remind:(NSString *)remind
{
    if (ban) {
        self.gesture.enabled = NO;
        self.isHasMoreContent = NO;
        if (remind) {
            self.loadMoreRemind.text = remind;
            [self endLoadingMoreWithRemind:remind];
        } else {
            self.loadMoreRemind.text = STRING_NOMORE;
            [self endLoadingMoreWithRemind:STRING_NOMORE];
        }
        [self performSelector:@selector(setInsetBottomAnimateToZeroAndCallDelegate:) withObject:[NSNumber numberWithBool:NO] afterDelay:DURIATION_SHOWNOMORE];
    } else {
        self.gesture.enabled = YES;
        self.isHasMoreContent = YES;
        if (!_isLoadingMore) {
            [self showLoadMoreRemind:STRING_LOADMORE];
        }
    }
}

- (void)configIndicatorPositionWithWord:(NSString *)word
{
    if (word && ![word isEqualToString:@""]) {
        // 如果有提供的文字就做左偏移
        self.loadMoreRemind.hidden = NO;
        self.loadMoreRemind.alpha = 1.0f;
        self.loadMoreRemind.text = word;
        CGSize size = [word sizeWithFont:self.loadMoreRemind.font constrainedToSize:CGSizeMake(self.loadMoreView.bounds.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = self.loadMoreRemind.frame;
        rect.size.width = size.width;
        rect.size.height = size.height;
        self.loadMoreRemind.frame = rect;
        self.loadMoreRemind.center = CGPointMake(self.loadMoreView.frame.size.width / 2, self.loadMoreView.frame.size.height / 2);
        self.loadMoreActivityView.center = CGPointMake(self.loadMoreRemind.frame.origin.x - kDistanceFromRemind, self.loadMoreActivityView.center.y);
        [self alignmentWithView:self.loadMoreActivityView lable:self.loadMoreRemind distance:kDistanceFromRemind totalWidth:self.scrollView.frame.size.width];
    } else {
        //还原
        self.loadMoreRemind.hidden = YES;
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.loadMoreView viewWithTag:TAG_LOADMORE_INDICATOR];
        indicator.center = CGPointMake(self.loadMoreView.frame.size.width / 2, self.loadMoreView.frame.size.height / 2);
        self.loadMoreRemind.center = indicator.center;
    }
}

- (void)alignmentWithView:(UIView *)view lable:(UILabel *)label distance:(CGFloat)distance totalWidth:(CGFloat)totalWidth
{
    CGFloat viewWidths = view.frame.size.width + distance + label.frame.size.width;
    CGFloat left = (totalWidth - viewWidths) / 2;
    view.center = CGPointMake(left + view.frame.size.width / 2 , view.center.y);
    label.center = CGPointMake(view.center.x + view.frame.size.width /2 + distance + label.frame.size.width / 2, label.center.y);
}

#pragma mark - refresh

- (void)setIsRefreshing:(BOOL)isRefreshing
{
    if (_isRefreshing == isRefreshing) {
        return;
    }
    _isRefreshing = isRefreshing;
    if (_isRefreshing) {
        [self endLoadingMoreWithRemind:nil];
        [_activityIndicatorView.layer removeAllAnimations];
        [_activityIndicatorView startAnimating];
        CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        aniamtion.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:
                             CATransform3DRotate(CATransform3DMakeScale(0.01, 0.01, 0.1),
                                                 -M_PI, 0, 0, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
        aniamtion.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.6],
                              [NSNumber numberWithFloat:1], nil];
        aniamtion.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                     nil];
        aniamtion.duration = 0.7;
        aniamtion.delegate = self;
        _activityIndicatorView.layer.transform = CATransform3DIdentity;
        [_activityIndicatorView.layer addAnimation:aniamtion
                                            forKey:@""];
        _refleshView.hidden = YES;
        if (!_unmissSlime){
            _slime.state = SRSlimeStateMiss;
        }else {
            _unmissSlime = NO;
        }
    }else {
        // 刷新结束
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView.layer removeAllAnimations];
        _refleshView.layer.transform = CATransform3DIdentity;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.35f animations:^{
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = _upInset;
            _scrollView.contentInset = inset;
            if (_scrollView.contentOffset.y == -_upInset &&
                _slimeMissWhenGoingBack) {
                self.alpha = 0.0f;
            }
        } completion:^(BOOL finished) {
            _broken = NO;
            _slime.hidden = NO;
            _refleshView.hidden = NO;
            self.refreshRemind.text = @"";
            self.refreshRemindPicView.hidden = YES;
        }];
    }
}

- (void)startRefreshWithExpansion
{
    if (self.type == WaterRefreshTypeOnlyLoadMore || self.type == WaterRefreshTypeNone) {
        return;
    }
    if (self.isRefreshing) {
        return;
    }
    [UIView animateWithDuration:DURIATION_ANIMATE animations:^() {
        UIEdgeInsets inset = _scrollView.contentInset;
        inset.top = _upInset + _dragingHeight;
        _scrollView.contentInset = inset;
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x,
                                                  -_scrollView.contentInset.top)
                             animated:NO];
    }];
    [self startRefresh];
}

-(void)startRefreshWithExpansionWithoutDelegate{
    if (self.type == WaterRefreshTypeOnlyLoadMore || self.type == WaterRefreshTypeNone) {
        return;
    }
    if (self.isRefreshing) {
        return;
    }
    [UIView animateWithDuration:DURIATION_ANIMATE animations:^() {
        UIEdgeInsets inset = _scrollView.contentInset;
        inset.top = _upInset + _dragingHeight;
        _scrollView.contentInset = inset;
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x,
                                                  -_scrollView.contentInset.top)
                             animated:NO];
    } completion:^(BOOL finished) {
    }];
    self.isRefreshing = YES;
}

- (void)startRefresh
{
    self.isRefreshing = YES;
    if ([self.refreshDelegate respondsToSelector:@selector(slimeRefreshStartRefresh:)]) {
        [self.refreshDelegate slimeRefreshStartRefresh:self];
    }
}

- (void)pullApart:(WaterRefreshLoadMoreView*)refreshView
{
    self.broken = YES;
    _unmissSlime = YES;
    [self startRefresh];
}

- (void)endRefreshWithRemindsWords:(NSString *)remind remindImage:(UIImage *)remindImage
{
    if (self.type == WaterRefreshTypeOnlyLoadMore || self.type == WaterRefreshTypeNone ) {
        return;
    }
    if (self.isRefreshing && self.endRefreshWithRemind == NO) {
        self.refreshRemindWord = remind;
        self.refreshRemindPicView.image = remindImage;
        self.endRefreshWithRemind = YES;
        if (self.endAnimation == YES) {
            [self restore];
        }
    }
}

- (void)showRemindWordAndClear;
{
    if (!self.refreshRemindWord || [self.refreshRemindWord isEqualToString:@""]) {
        [self collapse];
        return;
    }
    self.refreshRemind.hidden = NO;
    self.refreshRemind.text = self.refreshRemindWord;
    self.refreshRemindWord = nil;
    [self performSelector:@selector(collapse) withObject:nil afterDelay:0.5f];
    
}

- (void)configRefreshPicViewPositionWithWord:(NSString *)word
{
    if (word && ![word isEqualToString:@""]) {
        // 如果有提供的文字就做左偏移
        //self.refreshRemindPicView.hidden = NO;
        self.refreshRemindPicView.alpha = 1.0f;
        CGSize size = [word sizeWithFont:self.refreshRemind.font constrainedToSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = self.refreshRemind.frame;
        rect.size.width = size.width;
        rect.size.height = size.height;
        self.refreshRemind.frame = rect;
        self.refreshRemind.center = _slime.startPoint;
        self.refreshRemindPicView.center = CGPointMake(self.refreshRemind.frame.origin.x - kDistanceFromRemind, self.refreshRemind.center.y);
        [self alignmentWithView:self.refreshRemindPicView lable:self.refreshRemind distance:kDistanceFromRemind totalWidth:self.scrollView.frame.size.width];
    } else {
        //还原
        //self.refreshRemindPicView.hidden = NO;
        self.refreshRemindPicView.alpha = 1.0f;
        self.refreshRemindPicView.center = _slime.startPoint;
    }
}

- (void)restore
{
    _oldLength = 0.0f;
    _slime.toPoint = _slime.startPoint;
    [_activityIndicatorView.layer removeAllAnimations];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.3f animations:^{
        _activityIndicatorView.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.01f, 0.01f, 0.1f), -M_PI, 0, 0, 1);
    } completion:^(BOOL finished)
     {
         [self relayoutLoadMoreViewAndInset];
         if (self.refreshRemindPicView.image) {
             self.refreshRemindPicView.hidden = NO;
             [self configRefreshPicViewPositionWithWord:self.refreshRemindWord];
         } else {
             [self alignmentWithView:nil lable:self.refreshRemind distance:0.0f totalWidth:self.scrollView.frame.size.width];
         }
         if (self.refreshRemindWord) {
             self.refreshRemind.hidden = NO;
             [self showRemindWordAndClear];
         } else {
             [self collapse];
         }
     }];
}

- (void)collapse
{
    if (_isRefreshing == NO) {
        return;
    }
    [self setIsRefreshing:NO];
    self.endRefreshWithRemind = NO;
    _slime.state = SRSlimeStateNormal;
    if ([self.refreshDelegate respondsToSelector:@selector(slimeRefreshEndRefresh:)]) {
        [self.refreshDelegate slimeRefreshEndRefresh:self];
    }
}

#pragma mark - Observer handle

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &scrollViewObservanceContext) {
        // handle change
        if ([keyPath isEqualToString:KEYPATH_CONTENTOFFSET]) {
            [self scrollViewDidScroll];
            if (self.scrollView.dragging == YES && self.lastDragScroll == NO) {
                self.lastDragScroll = YES;
            } else if (self.scrollView.dragging == NO && self.lastDragScroll == YES) {
                self.lastDragScroll = NO;
                [self scrollViewDidEndDraging];
            }
        }
    }
    if (context == &scrollViewContentSizeContext) {
        if ([keyPath isEqualToString:KEYPATH_CONTENTSIZE]) {
            [self configLoadMoreHide];
            [self relayoutLoadMoreViewAndInset];
        }
    }
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.endAnimation = YES;
    if (self.endRefreshWithRemind == YES) {
        self.endRefreshWithRemind = NO;
        self.endAnimation = NO;
        [self restore];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    self.endAnimation = NO;
}

@end
