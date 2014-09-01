//
//  AppInfoUtilities.h
//  SourceKitDemo
//
//  Created by Wei Mao on 1/14/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenUDID.h"

@interface AppInfo : NSObject

+ (AppInfo *)shared;
//app bundle identifier
+(NSString *)appBundleIdentifier;
//App最低目标版本
+ (NSString *)minTargetedVersion;
//App iOS SDK版本
+ (NSString *)iOSSDKVersion;
//App Bundle Version
+ (NSString *)bundleVersion;
//App Bundle Short Version String
+ (NSString *)bundleShortVersionString;
//OpenUDID
- (NSString *)IMEI;
@end
