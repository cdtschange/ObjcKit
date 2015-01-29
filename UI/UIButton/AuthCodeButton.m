//
//  AuthCodeButton.m
//  G2R
//
//  Created by Mao on 1/29/15.
//  Copyright (c) 2015 cdts. All rights reserved.
//

#import "AuthCodeButton.h"

@interface AuthCodeButton()

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int stopTime;
@property (nonatomic, copy) NSString *normalTitle;

@end

@implementation AuthCodeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)beginCountDownWithSeconds:(int)seconds{
    self.stopTime = [[NSDate date] timeIntervalSince1970];
    self.stopTime += seconds;
    self.enabled = NO;
    self.normalTitle = [self titleForState:UIControlStateNormal];
    [self showCurrentRemainSecond];
    [self stopTimer];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];

}
- (void)showCurrentRemainSecond
{
    int nowSince = [[NSDate date] timeIntervalSince1970];
    NSString *str = [NSString stringWithFormat:@"%d秒后重发",self.stopTime - nowSince];
    [self setTitle:str forState:UIControlStateDisabled];
}
- (void)countDownAction
{
    if ([[NSDate date] timeIntervalSince1970] > self.stopTime) {
        [self stopTimer];
        [self setTitle:self.normalTitle forState:UIControlStateNormal];
    } else {
        [self showCurrentRemainSecond];
    }
}
- (void)stopTimer
{
    if (self.countDownTimer != nil) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    self.enabled = YES;
}


@end
