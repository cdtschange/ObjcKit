//
//  PgyManager.h
//  PgySDK
//
//  Created by Scott Lei on 2015-1-7.
//  Copyright (c) 2015年 蒲公英. All rights reserved.
//  Version: 1.0

#import <Foundation/Foundation.h>

/**
 *  激活反馈功能的方式
 */
typedef NS_ENUM(NSInteger, KPGYFeedbackActiveType){
    /**
     *  摇晃手机激活用户反馈界面
     */
    kPGYFeedbackActiveTypeShake = 0,
    /**
     *  在界面上三指下滑或者上滑激活用户反馈界面
     */
    kPGYFeedbackActiveTypeThreeFingersPan = 1,
};

@interface PgyManager : NSObject

/**
 *  激活用户反馈的方式，如果不设置的话，则默认为摇一摇激活用户反馈界面。
 *  设置激活用户反馈方式需在调用 - (void)startManagerWithAppId:(NSString *)appId 之前。
 */
@property (nonatomic, assign) KPGYFeedbackActiveType feedbackActiveType;

/**
 *  是否开启用户反馈功能，默认为自动开启用户反馈功能
 *  如果不需要开启用户反馈功能，则需要在调用 - (void)startManagerWithAppId:(NSString *)appId 之前将其设置为NO。
 */
@property (nonatomic, assign, getter=isFeedbackEnabled) BOOL enableFeedback;

/**
 *  初始化蒲公英SDK
 *
 *  @return PgyManger的单例对象
 */
+ (PgyManager *)sharedPgyManager;

/**
 *  启动蒲公英SDK
 *  如果需要取消用户反馈功能或者自定义用户反馈激活模式，则需要在调用此方法之前设置
 *  @param appId 应用程序ID，从蒲公英网站上获取。
 */
- (void)startManagerWithAppId:(NSString *)appId;

/**
 *  检查是否有版本更新。
 *  如果开发者在蒲公英上提交了新版本，则调用此方法后会弹出更新提示界面。
 */
- (void)checkUpdate;

@end
