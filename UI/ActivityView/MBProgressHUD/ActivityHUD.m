//
//  PopupHelper.m
//  GalarxyUIKitLib
//
//  Created by Wei Mao on 12/24/12.
//  Copyright (c) 2012 WandaKtvInc.. All rights reserved.
//

#import "ActivityHUD.h"
#import "MBProgressHUD.h"

__weak UIView *_displayedLoadingActivityHUDView;
__weak UIView *_displayedTipActivityHUDView;
__weak UIView *_displayedProgressActivityHUDView;

@interface ActivityHUD()

@end

@implementation ActivityHUD

BOOL dimBackground = YES;

+ (void)setBackgroundDim:(BOOL)dim{
    dimBackground = dim;
}


+ (void)loadingInView:(UIView *)view{
    [self loadingInView:view text:nil];
}
+ (void)loadingInView:(UIView *)view text:(NSString *)text{
    [self loadingInView:view text:text description:nil];
}
+ (void)loadingInView:(UIView *)view text:(NSString *)text description:(NSString *)description{
    [self loadingInView:view text:text description:description customView:nil];
}
+ (void)loadingInView:(UIView *)view text:(NSString *)text description:(NSString *)description customView:(UIImageView *)customView{
    _displayedLoadingActivityHUDView = view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text) {
        hud.labelText = text;
    }
    if (description) {
        hud.detailsLabelText = description;
    }
    hud.dimBackground = dimBackground;
}
+ (void)removeLoadingInView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}
+ (void)removeLoading{
    [self removeLoadingInView:_displayedLoadingActivityHUDView];
}

+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text complete:(void (^)())complete{
    [self tipInView:view keep:second text:text description:nil complete:complete];
}
+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text description:(NSString *)description complete:(void (^)())complete{
    [self tipInView:view keep:second text:text description:description customView:nil complete:complete];
}
+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text description:(NSString *)description customView:(UIImageView *)customView complete:(void (^)())complete{
    _displayedTipActivityHUDView = view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text) {
        hud.labelText = text;
    }
    if (description) {
        hud.detailsLabelText = description;
    }
    hud.customView = customView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.dimBackground = dimBackground;
    if (complete) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:view animated:YES];
            complete();
        });
    }else{
        [hud hide:YES afterDelay:second];
    }
}


+ (void)progressInView:(UIView *)view{
    [self progressInView:view text:nil];
}
+ (void)progressInView:(UIView *)view text:(NSString *)text{
    [self progressInView:view text:text description:nil];
}
+ (void)progressInView:(UIView *)view text:(NSString *)text description:(NSString *)description{
    _displayedProgressActivityHUDView = view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text) {
        hud.labelText = text;
    }
    if (description) {
        hud.detailsLabelText = description;
    }
    hud.mode = MBProgressHUDModeDeterminate;
    hud.dimBackground = dimBackground;
}
+ (void)progressInView:(UIView *)view setProgress:(CGFloat)progress{
    [MBProgressHUD HUDForView:view].progress = progress;
    if (progress == 1) {
        [MBProgressHUD hideHUDForView:view animated:YES];
    }
}

@end

