//
//  AuthCodeButton.h
//  G2R
//
//  Created by Mao on 1/29/15.
//  Copyright (c) 2015 cdts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthCodeButton : UIButton

-(void)beginCountDownWithSeconds:(int)seconds;
- (void)stopTimer;

@end
