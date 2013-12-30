//
//  UIDevice+Utilities.h
//  SourceKitDemo
//
//  Created by Wei Mao on 12/17/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIDeviceScreenSize) {
    UIDeviceScreenSize35Inch = 0,
    UIDeviceScreenSize4Inch,
    UIDeviceScreenSizePad
};

@interface UIDevice (Utilities)
//可用的内存
@property (readonly) double availableMemory;

//系统软件版本 iOS5,6,7...
- (NSString *) systemVersionString;
+ (BOOL)isSystemiOS5orGreater;
+ (BOOL)isSystemiOS6orGreater;
+ (BOOL)isSystemiOS7orGreater;
//系统设备型号 iPhone,iPad,Simulator...
- (NSString *) platform;
- (NSString *) platformString;
+ (BOOL)isHardwareiPhone;
+ (BOOL)isHardwareiPad;
+ (BOOL)isHardwareiPod;
//系统屏幕大小
- (UIDeviceScreenSize)screenSize;
+ (BOOL)isScreenSize35Inch;
+ (BOOL)isScreenSize4Inch;
+ (BOOL)isScreenSizePad;

@end
