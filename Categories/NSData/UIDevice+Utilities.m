//
//  UIDevice+Utilities.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/17/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import "UIDevice+Utilities.h"
#import <objc/runtime.h>
#include <sys/sysctl.h>
#include <mach/mach.h>

const void *UIDeviceVersionStringKey = "UIDeviceVersionStringKey";
const void *UIDevicePlatformStringKey = "UIDevicePlatformStringKey";

@implementation UIDevice (Utilities)

- (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}

	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

- (NSString *)systemVersionString{
    NSString *version = objc_getAssociatedObject(self, UIDeviceVersionStringKey);
    if (version.length == 0) {
        version = [[UIDevice currentDevice] systemVersion];
        objc_setAssociatedObject(self, UIDeviceVersionStringKey, version, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return version;
}
+ (BOOL)isSystemiOS5orGreater{
    return [[[UIDevice currentDevice] systemVersionString] doubleValue]>=5.0;
}
+ (BOOL)isSystemiOS6orGreater{
    return [[[UIDevice currentDevice] systemVersionString] doubleValue]>=6.0;
}
+ (BOOL)isSystemiOS7orGreater{
    return [[[UIDevice currentDevice] systemVersionString] doubleValue]>=7.0;
}

- (NSString *) platform{
    NSString *platform = objc_getAssociatedObject(self, UIDevicePlatformStringKey);
    if (!platform) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        objc_setAssociatedObject(self, UIDevicePlatformStringKey, platform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return platform;
}

- (NSString *) platformString{
    NSString *deviceString = self.platform;
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5(AT&T)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5(GSM/CDMA)";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    //iPod Touch
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (CDMA)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    //Simulator
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    return nil;
}
+ (BOOL)isHardwareiPhone{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}
+ (BOOL)isHardwareiPad{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
+ (BOOL)isHardwareiPod{
    return [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"];
}

- (UIDeviceScreenSize)screenSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIDeviceScreenSizePad;
    }
    UIDeviceScreenSize screen = UIDeviceScreenSize35Inch;
    if ([[UIScreen mainScreen] bounds].size.height == 568.f) {
        screen = UIDeviceScreenSize4Inch;
    }

    return screen;
}
+ (BOOL)isScreenSize35Inch{
    return [UIDevice currentDevice].screenSize == UIDeviceScreenSize35Inch;
}
+ (BOOL)isScreenSize4Inch{
    return [UIDevice currentDevice].screenSize == UIDeviceScreenSize4Inch;
}
+ (BOOL)isScreenSizePad{
    return [UIDevice currentDevice].screenSize == UIDeviceScreenSizePad;
}


@end
