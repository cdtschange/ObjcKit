//
//  PulsingHaloTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/12/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PulsingHaloLayer.h"

@interface PulsingHaloTests : XCTestCase

@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (nonatomic, weak) IBOutlet UIImageView *beaconView;
@end

@implementation PulsingHaloTests

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
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = self.beaconView.center;
    [hostView.layer insertSublayer:self.halo below:self.beaconView.layer];
    self.halo.backgroundColor = [UIColor blueColor].CGColor;
    self.halo.radius = 100;
}

@end
