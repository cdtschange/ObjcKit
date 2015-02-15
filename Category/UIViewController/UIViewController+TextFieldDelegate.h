//
//  UIViewController+TextFieldDelegate.h
//  Yumi
//
//  Created by Mao on 1/29/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TextFieldDelegate)

-(BOOL)mobileValidWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
-(BOOL)bankcardValidWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
-(BOOL)isTextEmptyWithTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end
