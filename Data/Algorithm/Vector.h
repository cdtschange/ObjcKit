//
//  Vector.h
//  SourceKitDemo
//
//  Created by Wei Mao on 12/19/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <Foundation/Foundation.h>

struct Vector{
    CGFloat x;
    CGFloat y;
};
typedef struct Vector Vector;

Vector VectorMake(CGFloat x,CGFloat y);
BOOL VectorEqual(Vector v1,Vector v2);

@interface VectorUtils : NSObject
//获得法向量
+(Vector)normalVector:(Vector)v;
//获得投影向量
+(Vector)projectionVector:(Vector)v1 toVector:(Vector)v2;

@end
