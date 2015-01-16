//
//  MLNavigationController.h
//  iplaza
//
//  Created by Rush.D.Xzj on 13-7-11.
//  Copyright (c) 2013年 Wanda Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLNavigationController : UINavigationController
{
@protected
    BOOL _canDragBack;
}
// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign) BOOL canDragBack;
@property (nonatomic,retain) UIPanGestureRecognizer *panGestureRecognizer;
@end
