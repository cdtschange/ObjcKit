//
//  SRSlimeView
//  @author  SR
//  Modified by JunHan on 13-9-18.
//

#import <UIKit/UIKit.h>

#define kStartTo    0.7f
#define kEndTo      0.15f
#define kAnimationInterval  (1.0f / 50.0f)

NS_INLINE CGFloat distansBetween(CGPoint p1 , CGPoint p2) {
    return sqrtf((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
}

typedef enum {
    SRSlimeStateNormal,
    SRSlimeStateShortening,
    SRSlimeStateMiss
} SRSlimeState;

@class SRSlimeView;

@interface SRSlimeView : UIView

@property (nonatomic, assign)   CGPoint startPoint, toPoint;
@property (nonatomic, assign)   CGFloat viscous;    //default 55
@property (nonatomic, assign)   CGFloat radius;     //default 13
@property (nonatomic, assign)   CGFloat lineWith;
@property (nonatomic, assign)   CGFloat shadowBlur;

@property (nonatomic, strong)   UIColor *bodyColor, *skinColor;
@property (nonatomic, strong)   UIColor *shadowColor;

@property (nonatomic, assign)   SRSlimeState state;

- (void)setPullApartTarget:(id)target action:(SEL)action;

@end
