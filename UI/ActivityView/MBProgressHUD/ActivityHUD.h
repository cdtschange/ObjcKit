//
//  PopupHelper.h
//  GalarxyUIKitLib
//
//  Created by Wei Mao on 12/24/12.
//  Copyright (c) 2012 WandaKtvInc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityHUD : NSObject

typedef void (^void_action_block)(void);
//背景是否蒙上阴影
+ (void)setBackgroundDim:(BOOL)dim;
//加载遮罩
+ (void)loadingInView:(UIView *)view;
+ (void)loadingInView:(UIView *)view text:(NSString *)text;
+ (void)loadingInView:(UIView *)view text:(NSString *)text description:(NSString *)description;
+ (void)loadingInView:(UIView *)view text:(NSString *)text description:(NSString *)description customView:(UIImageView *)customView;
+ (void)removeLoadingInView:(UIView *)view;
//提示遮罩
+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text complete:(void (^)())complete;
+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text description:(NSString *)description complete:(void (^)())complete;
+ (void)tipInView:(UIView *)view keep:(int)second text:(NSString *)text description:(NSString *)description customView:(UIImageView *)customView complete:(void (^)())complete;
//进度遮罩
+ (void)progressInView:(UIView *)view;
+ (void)progressInView:(UIView *)view text:(NSString *)text;
+ (void)progressInView:(UIView *)view text:(NSString *)text description:(NSString *)description;
+ (void)progressInView:(UIView *)view setProgress:(CGFloat)progress;
@end
