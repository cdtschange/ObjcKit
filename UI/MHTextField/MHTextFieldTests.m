//
//  MHTextFieldTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/9/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHTextField.h"

@interface DemoTextField : MHTextField

@end
@implementation DemoTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBorderStyle:UITextBorderStyleNone];
    
    [self setFont: [UIFont systemFontOfSize:17]];
    [self setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 5);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 5);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    [layer setBorderWidth: 0.8];
    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
    
    [layer setCornerRadius:3.0];
    [layer setShadowOpacity:1.0];
    [layer setShadowColor:[UIColor redColor].CGColor];
    [layer setShadowOffset:CGSizeMake(1.0, 1.0)];
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : [UIColor colorWithRed:182/255. green:182/255. blue:183/255. alpha:1.0]};
    [self.placeholder drawInRect:CGRectInset(rect, 5, 5) withAttributes:attributes];
}

@end


@interface MHTextFieldTests : XCTestCase

@property (strong, nonatomic) IBOutlet DemoTextField *emailTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *phoneTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *ageTextField;
@property (strong, nonatomic) IBOutlet DemoTextField *zipTextField;
@end

@implementation MHTextFieldTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExampleWithHostView:(UIView *)hostView
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    //Firstly add fields to Xib or Storyboards
    [_emailTextField setRequired:YES];
    [_emailTextField setEmailField:YES];
    [_passwordTextField setRequired:YES];
    [_ageTextField setDateField:YES];
}


- (BOOL)validateInputInView:(UIView*)view
{
    for(UIView *subView in view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]])
            return [self validateInputInView:subView];
        
        if ([subView isKindOfClass:[DemoTextField class]]){
            if (![(MHTextField*)subView validate]){
                return NO;
            }
        }
    }
    
    return YES;
}
@end
