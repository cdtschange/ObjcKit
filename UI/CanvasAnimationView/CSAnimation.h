/*
 * This file is part of the Canvas package.
 * (c) Canvas <usecanvas@gmail.com>
 *
 * For the full copyright and license information,please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

typedef enum CSAnimationType{
    CSAnimationTypeBounceLeft   ,
    CSAnimationTypeBounceRight  ,
    CSAnimationTypeBounceDown   ,
    CSAnimationTypeBounceUp     ,
    CSAnimationTypeFadeIn       ,
    CSAnimationTypeFadeOut      ,
    CSAnimationTypeFadeInLeft   ,
    CSAnimationTypeFadeInRight  ,
    CSAnimationTypeFadeInDown   ,
    CSAnimationTypeFadeInUp     ,
    CSAnimationTypeSlideLeft    ,
    CSAnimationTypeSlideRight   ,
    CSAnimationTypeSlideDown    ,
    CSAnimationTypeSlideUp      ,
    CSAnimationTypePop          ,
    CSAnimationTypeMorph        ,
    CSAnimationTypeFlash        ,
    CSAnimationTypeShake        ,
    CSAnimationTypeZoomIn       ,
    CSAnimationTypeZoomOut
}CSAnimationType;

extern NSString *const CSAnimationExceptionMethodNotImplemented;

@protocol CSAnimation <NSObject>

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;

+ (void)performAnimationOnView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

@end


@interface CSAnimation : NSObject <CSAnimation>

+ (void)registerClass:(Class)theClass forAnimationType:(CSAnimationType)animationType;
+ (Class)classForAnimationType:(CSAnimationType)animationType;

@end
