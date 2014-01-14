//
//  RSBarcodesTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 1/14/14.
//  Copyright (c) 2014 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSCodeView.h"
#import "RSCodeGen.h"
#import "RSScannerViewController.h"

@interface RSBarcodesTests : XCTestCase
@property (nonatomic, weak) UILabel *codeLabel;

@end

@implementation RSBarcodesTests

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

- (void)testRSBarcodesGenerator
{
    RSCodeView *view = [[RSCodeView alloc] init];
    view.code = [CodeGen genCodeWithContents:@"HelloWorld2014010906" machineReadableCodeObjectType:AVMetadataObjectTypeQRCode];
}

- (void)testRSBarcodesScanner{
    RSScannerViewController *vc = [[RSScannerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.barcodesHandler = ^(NSArray *barcodeObjects) {
        if (barcodeObjects.count > 0) {
            NSMutableString *text = [[NSMutableString alloc] init];
            [barcodeObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [text appendString:[NSString stringWithFormat:@"%@: %@", [(AVMetadataObject *)obj type], [obj stringValue]]];
                if (idx != (barcodeObjects.count - 1)) {
                    [text appendString:@"\n"];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.codeLabel.numberOfLines = [barcodeObjects count];
                weakSelf.codeLabel.text = text;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.codeLabel.text = @"";
            });
        }
    };

    vc.tapGestureHandler = ^(CGPoint tapPoint) {
    };
}

@end
