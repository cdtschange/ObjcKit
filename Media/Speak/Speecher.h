//
//  Speecher.h
//  Yumi
//
//  Created by Mao on 15/2/7.
//  Copyright (c) 2015年 Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Speecher : NSObject

@property(nonatomic) double rate;             // [0-1] Default = 0.1
@property(nonatomic) double pitchMultiplier;  // [0.5 - 2] Default = 1
@property(nonatomic) double volume;           // [0-1] Default = 1

+ (Speecher *)shared;

- (void)speakWithText:(NSString *)text;
- (void)stopSpeak;
@end
