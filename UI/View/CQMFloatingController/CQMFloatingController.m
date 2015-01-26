//
// CQMFloatingController.m
// Created by cocopon on 2011/05/19.
//
// Copyright (c) 2012 cocopon <cocopon@me.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "CQMFloatingController.h"
#import "CQMFloatingContentOverlayView.h"
#import "CQMFloatingFrameView.h"
#import "CQMFloatingNavigationBar.h"
#import "CQMPathUtilities.h"


#define kDefaultMaskColor  [UIColor colorWithWhite:0 alpha:0.5]
#define kDefaultFrameColor [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:0.00f]
#define kDefaultFrameSize  CGSizeMake(320 - 66, 460 - 66)
#define kFramePadding      5.0f
#define kRootKey           @"root"
#define kShadowColor       [UIColor clearColor]
#define kShadowOffset      CGSizeMake(0, 2.0f)
#define kShadowOpacity     0.70f
#define kShadowRadius      10.0f
#define kAnimationDuration .6f


@interface CQMFloatingController()

@property (nonatomic, readonly, retain) UIControl *maskControl;
@property (nonatomic, readonly, retain) CQMFloatingFrameView *frameView;
@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, readonly, retain) CQMFloatingContentOverlayView *contentOverlayView;
@property (nonatomic, readonly, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIImageView *shadowView;
@property (nonatomic, retain) NSMutableArray *presentQueue;// 弹出队列
@property (nonatomic, retain) NSMutableArray *viewControllers;// 已弹出VC队列
- (void)layoutFrameView;
// Actions
- (void)maskControlDidTouchUpInside:(id)sender;

@end


@implementation CQMFloatingController {
@private
	BOOL presented_;
    BOOL presenting_;
	// View
	UIControl *maskControl_;
	CQMFloatingFrameView *frameView_;
	UIView *contentView_;
	CQMFloatingContentOverlayView *contentOverlayView_;
	UINavigationController *navController_;
	UIViewController *contentViewController_;
}


- (id)init {
	if (self = [super init]) {
        [self setPresentMode:UIPresentFrameMode];
		[self setFrameSize:kDefaultFrameSize];
		[self setFrameColor:kDefaultFrameColor];
	}
	return self;
}


- (void)dealloc {
	[contentViewController_ release];
	[maskControl_ release];
	[frameView_ release];
	[contentView_ release];
	[contentOverlayView_ release];
	[navController_ release];
	[self setShadowView:nil];
    self.presentQueue = nil;
    self.viewControllers = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Property
@synthesize presentMode;

- (CGSize)frameSize {
	return [self.frameView frame].size;
}
- (void)setFrameSize:(CGSize)frameSize {
	CGRect frame = [self.frameView frame];
	frame.size = frameSize;
	[self.frameView setFrame:frame];
}


- (UIColor*)frameColor {
	return [self.frameView baseColor];
}
- (void)setFrameColor:(UIColor*)frameColor {
	[self.frameView setBaseColor:frameColor];
	[self.contentOverlayView setEdgeColor:frameColor];
	[self.navigationController.navigationBar setTintColor:frameColor];
}


- (UIControl*)maskControl {
	if (maskControl_ == nil) {
		maskControl_ = [[UIControl alloc] init];
		[maskControl_ setBackgroundColor:kDefaultMaskColor];
		[maskControl_ addTarget:self
						 action:@selector(maskControlDidTouchUpInside:)
			   forControlEvents:UIControlEventTouchUpInside];
	}
	return maskControl_;
}


- (UIView*)frameView {
	if (frameView_ == nil) {
		frameView_ = [[CQMFloatingFrameView alloc] init];
		[frameView_.layer setShadowColor:[kShadowColor CGColor]];
		[frameView_.layer setShadowOffset:kShadowOffset];
		[frameView_.layer setShadowOpacity:kShadowOpacity];
		[frameView_.layer setShadowRadius:kShadowRadius];
	}
	return frameView_;
}


- (UIView*)contentView {
	if (contentView_ == nil) {
		contentView_ = [[UIView alloc] init];
		[contentView_ setClipsToBounds:YES];
	}
	return contentView_;
}


- (CQMFloatingContentOverlayView*)contentOverlayView {
	if (contentOverlayView_ == nil) {
		contentOverlayView_ = [[CQMFloatingContentOverlayView alloc] init];
		[contentOverlayView_ setUserInteractionEnabled:NO];
        [contentOverlayView_ setHidden:YES];
	}
	return contentOverlayView_;
}


- (UINavigationController*)navigationController {
	if (navController_ == nil) {
		UIViewController *dummy = [[UIViewController alloc] init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dummy];
		[dummy release];
		
		// Archive navigation controller for changing navigationbar class
		[navController navigationBar];
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:navController forKey:kRootKey];
		[archiver finishEncoding];
		[archiver release];
		[navController release];
		
		// Unarchive it with changing navigationbar class
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[unarchiver setClass:[CQMFloatingNavigationBar class]
				forClassName:NSStringFromClass([UINavigationBar class])];
		navController_ = [[unarchiver decodeObjectForKey:kRootKey] retain];
		[unarchiver release];
		
		[data release];
	}
	return navController_;
}


@synthesize shadowView = shadowView_;


#pragma mark -
#pragma mark Singleton


+ (CQMFloatingController*)sharedFloatingController {
	static CQMFloatingController *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^ {
		instance = [[CQMFloatingController alloc] init];
	});
	return instance;
}


#pragma mark -


- (void)presentWithContentViewController:(UIViewController*)viewController animated:(BOOL)animated {
	@synchronized(self) {
		if (presenting_) {
            if (!self.presentQueue) {
                self.presentQueue = [[NSMutableArray alloc] init];
            }
            if (![self.presentQueue containsObject:viewController]) {
                [self.presentQueue addObject:viewController];
            }
			return;
		}
		presented_ = YES;
	}

	[self.view setAlpha:0];

	if (contentViewController_ != viewController) {
		[[contentViewController_ view] removeFromSuperview];
		contentViewController_ = viewController;
        if (!self.viewControllers) {
            self.viewControllers = [[NSMutableArray alloc] init];
        }
        [self.viewControllers insertObject:contentViewController_ atIndex:0];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:contentViewController_]];
	}

//	if (contentViewController_ != viewController) {
//		[[contentViewController_ view] removeFromSuperview];
//		[contentViewController_ release];
//		contentViewController_ = [viewController retain];
//
//		NSArray *viewControllers = [NSArray arrayWithObject:contentViewController_];
//		[self.navigationController setViewControllers:viewControllers];
//	}
    int count = (int)[[UIApplication sharedApplication] windows].count;
	UIWindow *window = [[UIApplication sharedApplication] windows][count-1];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	[self.view setFrame:[window convertRect:appFrame fromView:nil]];
	[window addSubview:[self view]];

	[self layoutFrameView];

	__block CQMFloatingController *me = self;
    CGRect frame = self.frameView.frame;
    if (presentMode == UIPresentFrameMode||presentMode == UIPresentUpFrameMode) {
        self.frameView.frame = CGRectMake(frame.origin.x, frame.origin.y+appFrame.size.height, frame.size.width, frame.size.height);
    }
    // callBack
    if (_delegate && [_delegate respondsToSelector:@selector(willPresentViewController:)]) {
        [_delegate willPresentViewController:contentViewController_];
    }
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0)
					 animations:
	 ^(void) {
         presenting_ = YES;
         [self.frameView setFrame:frame];
		 [me.view setAlpha:1.0f];
	 } completion:^(BOOL finished) {
         if (finished) {
             // callBack
             if (_delegate && [_delegate respondsToSelector:@selector(didPresentViewController:)]) {
                 [_delegate didPresentViewController:contentViewController_];
             }
             presenting_ = NO;
             if ([self.presentQueue containsObject:viewController]) {
                 [self.presentQueue removeObject:viewController];
             }
             [self checkQueue];
         }
     }];
}


- (void)dismissAnimated:(BOOL)animated {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	__block CQMFloatingController *me = self;
    CGRect frame = self.frameView.frame;
    // callBack
    if (_delegate && [_delegate respondsToSelector:@selector(willDismissViewController:)]) {
        [_delegate willDismissViewController:contentViewController_];
    }
	[UIView animateWithDuration:(animated ? kAnimationDuration : 0)
					 animations:
	 ^(void) {
         presenting_ = YES;
         if (presentMode == UIPresentFrameMode||presentMode == UIPresentUpFrameMode) {
             self.frameView.frame = CGRectMake(frame.origin.x, frame.origin.y+appFrame.size.height, frame.size.width, frame.size.height);
         }
		[me.view setAlpha:0];
	 }
					 completion:
	 ^(BOOL finished) {
		 if (finished) {
             // callBack
             if (_delegate && [_delegate respondsToSelector:@selector(didDismissViewController:)]) {
                 [_delegate didDismissViewController:contentViewController_];
             }
			 [me.view removeFromSuperview];
			 presented_ = NO;
             presenting_ = NO;
             [self.viewControllers removeObject:contentViewController_];
             if (![self checkQueue]) {
                 [self checkViewControllers];
             }
		 }
	 }];
}

- (BOOL)checkQueue
{
    if (self.presentQueue.count) {
        [self presentWithContentViewController:self.presentQueue[0] animated:YES];
        return YES;
    }
    return NO;
}

- (void)checkViewControllers
{
    if (self.viewControllers.count) {
        [self presentWithContentViewController:self.viewControllers[0] animated:YES];
    }
}

- (void)layoutFrameView {
	// Frame
	UIView *frameView = [self frameView];
	CGSize viewSize = [self.view frame].size;
	CGSize frameSize = [frameView frame].size;
	[frameView setFrame:CGRectMake(ceil((viewSize.width - frameSize.width) / 2),
								   ceil((viewSize.height - frameSize.height) / 2),
								   frameSize.width,
								   frameSize.height)];
    if(presentMode == UIPresentUpFrameMode){
        [frameView setFrame:CGRectMake(ceil((viewSize.width - frameSize.width) / 2),
                                       50,
                                       frameSize.width,
                                       frameSize.height)];
    }
	// Content
	UIView *contentView = [self contentView];
//	CGRect contentFrame = CGRectMake(kFramePadding, 0,
//									 frameSize.width - kFramePadding * 2,
//									 frameSize.height - kFramePadding);
    CGRect contentFrame = frameView.bounds;
	CGSize contentSize = contentFrame.size;
	[contentView setFrame:contentFrame];
	
	// Navigation
	UIView *navView = [self.navigationController view];
	CGFloat navBarHeight = [self.navigationController.navigationBar frame].size.height;
	[navView setFrame:CGRectMake(0, 0,
								 contentSize.width, contentSize.height)];
//	[self.navigationController.navigationBar setFrame:CGRectMake(0, 0,
//																 contentSize.width, navBarHeight)];
    [self.navigationController.navigationBar setFrame:CGRectZero];
    
	// Content overlay
	UIView *contentOverlay = [self contentOverlayView];
	CGFloat contentFrameWidth = [CQMFloatingContentOverlayView frameWidth];
	[contentOverlay setFrame:CGRectMake(contentFrame.origin.x - contentFrameWidth,
										contentFrame.origin.y + navBarHeight - contentFrameWidth,
										contentSize.width  + contentFrameWidth * 2,
										contentSize.height - navBarHeight + contentFrameWidth * 2)];
	[contentOverlay.superview bringSubviewToFront:contentOverlay];
	
	// Shadow
	CGFloat radius = [self.frameView cornerRadius];
	CGPathRef shadowPath = CQMPathCreateRoundingRect(CGRectMake(0, 0,
																frameSize.width, frameSize.height),
													 radius, radius, radius, radius);
	[frameView.layer setShadowPath:shadowPath];
	CGPathRelease(shadowPath);
}


#pragma mark -
#pragma mark Actions


- (void)maskControlDidTouchUpInside:(id)sender {
//	[self dismissAnimated:YES];
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	UIView *maskControl = [self maskControl];
	CGSize viewSize = [self.view frame].size;
	[maskControl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	[maskControl setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
	[self.view addSubview:maskControl];
	
	[self.view addSubview:[self frameView]];
	[self.frameView addSubview:[self contentView]];
	[self.contentView addSubview:[self.navigationController view]];
	[self.frameView addSubview:[self contentOverlayView]];
}


@end
