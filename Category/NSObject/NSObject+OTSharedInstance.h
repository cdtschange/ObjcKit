//
//  NSObject+OTSharedInstance.h
//  G2R
//
//  Created by Mao on 2/4/15.
//  Copyright (c) 2015 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (OTSharedInstance)
+ (id)sharedInstance;
+ (void)freeSharedInstance;
@end
