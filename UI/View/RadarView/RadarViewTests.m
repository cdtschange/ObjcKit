//
//  RadarViewTests.m
//  CameraARTest
//
//  Created by Wei Mao on 12/3/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "Radar.h"
#import "RadarViewPortView.h"

@interface RadarViewTests : XCTestCase <CLLocationManagerDelegate,UIAccelerometerDelegate>
@property (nonatomic, strong) Radar *radarView;
@property (nonatomic, strong) RadarViewPortView *radarViewPort;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) PoiItem *centerCoordinate;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

#define ARC4RANDOM_MAX 0x100000000
static inline CGFloat RandomFloat(CGFloat x, CGFloat y)
{return x + arc4random()/(CGFloat)ARC4RANDOM_MAX*(y - x);};

#define kFilteringFactor        0.05
#define kFilteringFactorX       0.002
UIAccelerationValue rollingX, rollingZ;

@implementation RadarViewTests

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
    CGFloat width = hostView.frame.size.height;
    CGFloat height = hostView.frame.size.width;
    self.overlayView = [[UIView alloc] initWithFrame:hostView.bounds];
    [hostView addSubview:self.overlayView];
    self.radarView = [[Radar alloc] initWithFrame:CGRectMake(width - 65, height - 65, 60, 60)];
    int x = 1, y = 1;
    self.radarView.radius = sqrt(pow(x, 2) + pow(y, 2));
    self.radarViewPort = [[RadarViewPortView alloc] initWithFrame:CGRectMake(width - 65, height - 65, 60, 60)];
    self.radarViewPort.referenceAngle = -135;
    self.radarViewPort.newAngle = 90;
    UILabel *northLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.radarView.frame.origin.x+26, self.radarView.frame.origin.y - 5, 10, 10)];
    northLabel.backgroundColor = [UIColor blackColor];
    northLabel.textColor = [UIColor whiteColor];
    northLabel.font = [UIFont systemFontOfSize:8.0];
    northLabel.textAlignment = NSTextAlignmentCenter;
    northLabel.text = @"N";
    northLabel.alpha = 0.8;
    [self.overlayView addSubview:northLabel];
    [self.overlayView addSubview:self.radarView];
    [self.overlayView addSubview:self.radarViewPort];
    
    self.radarView.pois = [self radarTestData];
    self.centerCoordinate = [[PoiItem alloc] initCoordinateWithRadialDistance:0 inclination:0 azimuth:0];
    if (!self.motionManager) {
		self.motionManager = [[CMMotionManager alloc] init];
        if (!self.motionManager.accelerometerAvailable) {
            // fail code // 检查传感器到底在设备上是否可用
        }
        self.motionManager.accelerometerUpdateInterval = 0.01; // 告诉manager，更新频率是100Hz
        __weak RadarViewTests *weakself = self;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            CMAccelerometerData *newestAccel = weakself.motionManager.accelerometerData;
            if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
                rollingZ  = (newestAccel.acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
                rollingX = (newestAccel.acceleration.x * kFilteringFactorX) + (rollingX * (1.0 - kFilteringFactorX));
            } else {
                rollingZ  = (newestAccel.acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
                rollingX = (newestAccel.acceleration.y * kFilteringFactorX) + (rollingX * (1.0 - kFilteringFactorX));
            }
            if (rollingZ > 0.0) {
                self.centerCoordinate.inclination = atan(rollingX / rollingZ) + M_PI / 2.0;
            } else if (rollingZ < 0.0) {
                self.centerCoordinate.inclination = atan(rollingX / rollingZ) - M_PI / 2.0;// + M_PI;
            } else if (rollingX < 0) {
                self.centerCoordinate.inclination = M_PI / 2.0;
            } else if (rollingX >= 0) {
                self.centerCoordinate.inclination = 3 * M_PI / 2.0;
            }
            //    if (rollingZ < -.8 && self.ar_mapView.alpha < 1) {
            //        [self.ar_mapView setAlpha:1 duration:kAnimationDuration];
            //        [self.overlayView setAlpha:0 duration:kAnimationDuration];
            //        [[self.cameraController captureSession] stopRunning];
            //    }
            //    else if (rollingZ > -.6 && self.ar_overlayView.alpha < 1)
            //    {
            //        [self.ar_mapView setAlpha:0 duration:kAnimationDuration];
            //        [self.ar_overlayView setAlpha:1 duration:kAnimationDuration];
            //
            //        //[[self.cameraController captureSession] startRunning];
            //        [[self.cameraController captureSession] performSelector:@selector(startRunning) withObject:nil afterDelay:.1];
            //    }
        }]; // 开始更新，后台线程开始运行。这是pull方式。
	}
	if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        //we want every move.
		self.locationManager.headingFilter = kCLHeadingFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[self.locationManager startUpdatingHeading];
        [self.locationManager startUpdatingLocation];
	}
	//steal back the delegate.
	self.locationManager.delegate = self;
}

- (NSArray *)radarTestData
{
    NSMutableArray *allPOIs = [NSMutableArray new];
    for (int i = 0; i < 8; i++) {
        PoiItem *poi = [[PoiItem alloc] init];
        poi.azimuth = RandomFloat(0, 2 * M_PI);
        poi.radialDistance = RandomFloat(100, 1000);
        [allPOIs addObject:poi];
    }
    return allPOIs;
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    CLLocationDirection relativeHeading = newHeading.magneticHeading;
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft) {
        relativeHeading += 90;
        if (relativeHeading > 360) {
            relativeHeading -= 360;
        }
    }else if ( UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
        relativeHeading -= 90;
        if (relativeHeading < 0) {
            relativeHeading += 360;
        }
    }
	self.radarViewPort.referenceAngle = relativeHeading - self.radarViewPort.newAngle * .5 - 90;
    [self.radarViewPort setNeedsDisplay];
}

@end
