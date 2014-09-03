//
//  Tenpay.h
//  TenpayiOS
//
//  Created by Darius Wang on 10-12-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
/*
 Changes:
    2011-09-08, fix autologin
    2012-03-29, 添加html5支付方式

 */

#import <Foundation/Foundation.h>

//以下Key值用来设置payWithDictionary:error:所需的参数
extern NSString *const PayInfoTokenIDKey; // 财付通token_id，必填
extern NSString *const PayInfoNotifyURLKey; // 回调商户支付结果的URL，必填
extern NSString *const PayInfoBargainorIDKey; // 商户id, 即bargainor_id，必填
extern NSString *const PayInfoSessionIDKey; // 商户共享的session，仅在需要共享登录时提供
extern NSString *const PayInfoSessionTypeKey; // 商户session类型，仅在需要共享登录时提供

extern NSString *const PayInfoPerferredMethodKey; // 商户首选的支付形式, 值可为PayInfoPerferredMethodDefault, PayInfoPerferredMethodClient，PayInfoPerferredMethodHTML5。 不填按PayInfoPerferredMethodDefault处理。 非必填

//以下为PayInfoPerferredMethodKey可选的值
extern NSString *const PayInfoPerferredMethodDefault; // 商户首选使用SDK默认的方式，现阶段等同PayInfoPerferredMethodClient
extern NSString *const PayInfoPerferredMethodClient; // 商户首选客户端支付
extern NSString *const PayInfoPerferredMethodHTML5; // 商户首选使用内嵌HTML5支付

extern NSString *const PayInfoDelegateKey; //设置调用结果回调。不设置视为[[UIApplication sharedApplication] delegate]
extern NSString *const PayInfoDidFinishSelectorKey; //设置支付结果回调。不设置视为  - (void)tenpayDidFinish:(TenpayResult)result details:(NSDictionary *)details

extern NSString *const TenpaySDKVersion; // SDK版本信息

typedef enum {
	TenpayResultNoError = 0,

	TenpayResultNotInstalled = 400,
	TenpayResultInvalidParameters,
	TenpayResultNotifySchemeNotSet,

	TenpayResultInvalidTokenID = 500,
	TenpayResultServiceNotAvailable,

	TenpayResultCancelledByUser = 300,
	TenpayResultInterruptted, // pressed Home button for example

	TenpayResultUnknown = 9999

} TenpayResult;

@interface Tenpay : NSObject {

}

/*
 检查是否可以使用财付通安全支付服务。

 参数：
 无

 返回值：
 YES, 表示可以使用；
 NO, 表示不能使用。

 随着HTML5的引入，这个方法将一直返回YES。
 */
+ (BOOL) isTenpayAvailable;

/*
 检查是否可以使用财付通客户端支付。

 参数：
 无

 返回值：
 YES, 表示可以使用；
 NO, 表示财付通客户端未安装或安装的版本不支持安全支付服务。
 */
+ (BOOL) isTenpayClientAvailable;

/*
 开始支付。

 参数：
 payInfo, 包含支付信息的dictionary，所有值均为NSString类型。
        payInfo至少要包括PayInfoTokenIDKey，PayInfoNotifyURLKey和PayInfoBargainorIDKey；
         PayInfoNotifyURLKey对应的回调URI详情请参看文档《财付通iPhone客户端支付商户开发协议》
 error, 错误发生时返回的错误对象，传入NULL表示不需要返回错误对象。

 返回值：
 YES, 表示开始支付。
 NO, 表示由于错误未能开始支付, 具体错误原因请查询error对象的code属性。
 */
+ (BOOL) payWithDictionary:(NSDictionary *) payInfo error:(NSError **)error;



/*
 处理财付通客户端的回调。
 请务必在程序Delegate类的application：handleOpenURL:方法中调用此方法。

 参数：
 url, handleOpenURL中的url。

 返回值：
 无。

 请在 delegate的- (void)tenpayDidFinish:(TenpayResult *)result details:(NSDictionary *)details中处理支付结果

 */
+ (void) handlePayCallBack:(NSURL *) url;


/*
 解析财付通客户端的回调。此方法把返回的查询串变成方便使用的NSDictionary对象。
 请在程序Delegate类的application：handleOpenURL:方法中调用此方法。

 请不要再使用此方法，请使用handlePayCallBack以及对应的Delegate机制

 参数：
 url, handleOpenURL中的url。

 返回值：
 NSDictionary对象或nil。

 返回nil表示这不是一个有效的回调；

 返回的NSDictionary对象根据回调URI的设置可能包含下面几个key,
 result, 客户端返回的支付结果码， 请对照TenpayResult查看各返回值的意义；
 retcode, 服务端返回的支付结果。0表示成功，其它表示失败；
 retmsg, 支付结果说明；
 sp_data, 支付数据dictionary，具体意义见文档。仅在支付成功时有意义；
 其它回调URI中带的参数。

 */
+ (NSDictionary *) parsePayCallBack:(NSURL *) url;


/*
 前往财付通页面，用户在可此页面下载安装财付通客户端。

 参数：
 无

 返回值：
 无
 */
+ (void) gotoTenpayOnAppStore;
@end
