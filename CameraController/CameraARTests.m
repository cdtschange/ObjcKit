//
//  CameraARTestTests.m
//  CameraARTestTests
//
//  Created by Wei Mao on 12/2/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CameraController.h"

@interface CameraARTests : XCTestCase
@property (nonatomic, strong) CameraController *cameraController;
@end

@implementation CameraARTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExampleWithHostView:(UIView *)hostView
{
#if !TARGET_IPHONE_SIMULATOR
	// Do any additional setup after loading the view, typically from a nib.
    UIView *cameraView = [[UIView alloc] initWithFrame:hostView.bounds];
    [hostView addSubview:cameraView];
    self.cameraController = [[CameraController alloc] init];
    [self.cameraController addVideoInput];
    [self.cameraController addVideoPreviewLayer];
    [self.cameraController setLandscapeRight];
    [cameraView.layer addSublayer:[self.cameraController previewLayer]];
    [[self.cameraController captureSession] startRunning];
#endif

}

@end
