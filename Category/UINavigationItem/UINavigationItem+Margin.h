//
//  UINavigationItem+Margin.h
//  WandaKTV
//
//  Created by Wei Mao on 12/2/13.
//  Copyright (c) 2013 Wanda Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (Margin)

// 如果要使用ios6,7 我们自定义的Margin适配，应该配置为 YES，默认是NO
@property (nonatomic, assign) BOOL useMarginLayout;

@end
