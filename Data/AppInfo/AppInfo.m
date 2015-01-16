//
//  AppInfoUtilities.m
//  SourceKitDemo
//
//  Created by Wei Mao on 1/14/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import "AppInfo.h"

@interface AppInfo()

@property (nonatomic, copy) NSString *imeiPrivate;

@end

@implementation AppInfo

AppInfo * _sharedAppInfo = nil;

+(AppInfo *)shared
{
    @synchronized(self) {
        if(_sharedAppInfo == nil) {
            _sharedAppInfo = [[self alloc] init];
        }
    }
    return _sharedAppInfo;
}

//app bundle identifier
+(NSString *)appBundleIdentifier{
    NSDictionary *appInfoDict = [[NSBundle mainBundle] infoDictionary];
    return appInfoDict[(NSString *)kCFBundleIdentifierKey];
}
//App最低目标版本 etc.6.0 7.0
+ (NSString *)minTargetedVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleInfoDictionaryVersion"];
}
//App iOS SDK版本
+ (NSString *)iOSSDKVersion{
#if defined(__IPHONE_7_0)
    //#warning "SDK7"
    return @"SDK7.0 (Xcode5)";
#elif defined(__IPHONE_6_1)
    //#warning "SDK6.1"
    return @"SDK6.1 (Xcode4)";
#elif defined(__IPHONE_5_1)
    //#warning "SDK5.1"
    return @"SDK5.1 (Xcode4)";
#else
    //#warning "SDK<5"
    return @"SDK<6 (Xcode?)";
#endif
}
//App Bundle Version
+ (NSString *)bundleVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
//App Bundle Short Version String
+ (NSString *)bundleShortVersionString{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//App Bundle Short Version Number
+ (int)bundleShortVersionNumber{
    NSString *str = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    int num = [[str stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
    num*=10;
    return num;
}

- (NSString *)IMEI
{
    if (self.imeiPrivate.length == 0) {
        self.imeiPrivate = [OpenUDID value];
    }
    return self.imeiPrivate;
}
@end
