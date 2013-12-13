//
//  SphereViewTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/13/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZYQSphereView.h"

@interface SphereViewTests : XCTestCase{
    ZYQSphereView *sphereView;
    NSTimer *timer;
    BOOL isRotating;
}

@end

@implementation SphereViewTests

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
    hostView.backgroundColor = [UIColor blackColor];
    
	sphereView = [[ZYQSphereView alloc] initWithFrame:CGRectMake(10, 60, 300, 300)];
    sphereView.center=CGPointMake(hostView.center.x, hostView.center.y-30);
	NSMutableArray *views = [[NSMutableArray alloc] init];
	for (int i = 0; i < 50; i++) {
		UIButton *subV = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		subV.backgroundColor = [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
        [subV setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        subV.layer.masksToBounds=YES;
        subV.layer.cornerRadius=3;
        [subV addTarget:self action:@selector(subVClickDown:) forControlEvents:UIControlEventTouchDown];
        [subV addTarget:self action:@selector(subVClickUp:) forControlEvents:UIControlEventTouchUpInside];
        [views addObject:subV];
	}
    
	[sphereView setItems:views];
    
    sphereView.isPanTimerStart=YES;
    
	[hostView addSubview:sphereView];
    [sphereView timerStart];
    
	
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake((hostView.frame.size.width-120)/2, hostView.frame.size.height-60, 120, 30);
    [hostView addSubview:btn];
    btn.backgroundColor=[UIColor whiteColor];
    btn.layer.borderWidth=1;
    btn.layer.borderColor=[[UIColor orangeColor] CGColor];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn setTitle:@"start/stop" forState:UIControlStateNormal];
    btn.selected=NO;
    [btn addTarget:self action:@selector(changePF:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)subVClickDown:(UIButton*)sender{
    NSLog(@"%@",sender.titleLabel.text);
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform=CGAffineTransformMakeScale(2, 2);
    }];
    isRotating = [sphereView isTimerStart];
    [sphereView timerStop];
}
-(void)subVClickUp:(UIButton*)sender{
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform=CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            if (isRotating) {
                [sphereView timerStart];
            }
        }];
    }];
}



-(void)changePF:(UIButton*)sender{
    if ([sphereView isTimerStart]) {
        [sphereView timerStop];
    }
    else{
        [sphereView timerStart];
    }
}

@end
