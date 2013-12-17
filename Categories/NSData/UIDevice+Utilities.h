//
//  UIDevice+Utilities.h
//  SourceKitDemo
//
//  Created by Wei Mao on 12/17/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Utilities)
//可用的内存
@property (readonly) double availableMemory;

//系统软件版本 iOS5,6,7...
- (NSString *) systemVersionString;
//系统设备型号 iPhone,iPad,Simulator...
- (NSString *) platform;
- (NSString *) platformString;

BOOL iOS_5_OR_LATER();
BOOL iOS_6_OR_LATER();
BOOL iOS_7_OR_LATER();
BOOL Screen_3_5_Inch();
BOOL Screen_4_Inch();
BOOL iPhone();
BOOL iPad();
BOOL iPod();

@end
