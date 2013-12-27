//
//  Vector.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/19/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import "Vector.h"

Vector VectorMake(CGFloat x,CGFloat y){
    return (Vector){x,y};
}
BOOL VectorEqual(Vector v1,Vector v2){
    return (fabs(v1.x - v2.x) < __FLT_EPSILON__) && (fabs(v1.y - v2.y) < __FLT_EPSILON__);
}

@implementation VectorUtils

//获得法向量
+(Vector)normalVector:(Vector)v{
    Vector v2 = VectorMake(v.y,-v.x);
    return v2;
}
//获得投影向量
+(Vector)projectionVector:(Vector)v1 toVector:(Vector)v2{
    Vector v3 = [VectorUtils normalVector:v2];
    CGFloat k = v3.y*v1.x-v3.x*v1.y;
    CGFloat x = k*v2.x/(v3.y*v2.x-v3.x*v2.y);
    CGFloat y = v2.y/v2.x*x;
    Vector v4 = VectorMake(x, y);
    return v4;
}
@end
