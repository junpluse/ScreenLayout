//
//  SCLGeometry.m
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLGeometry.h"


static const CGFloat SCL_2PI = M_PI * 2;


CGVector SCLVectorFromAngle(CGFloat angle)
{
    return SCLVectorFromAngleWithDistance(angle, 10);
}

CGVector SCLVectorFromAngleWithDistance(CGFloat angle, CGFloat distance)
{
    return CGVectorMake(distance * cos(angle), distance * sin(angle));
}

CGFloat SCLAngleFromVector(CGVector vector)
{
    return SCLAngleNormalize(atan2(vector.dy, vector.dx));
}

CGFloat SCLAngleNormalize(CGFloat angle)
{
    while (angle < -M_PI) {
        angle += SCL_2PI;
    }
    while (angle > M_PI) {
        angle -= SCL_2PI;
    }
    
    return angle;
}

CGFloat SCLAngleRoundQuartery(CGFloat angle)
{
    angle = SCLAngleNormalize(angle);
    
    if (angle >= 0) {
        angle = floor((angle + M_PI_4) / M_PI_2) * M_PI_2;
    }
    else {
        angle = ceil((angle - M_PI_4) / M_PI_2) * M_PI_2;
    }
    
    return angle;
}

CGFloat SCLAngleDifference(CGFloat angle1, CGFloat angle2)
{
    angle1 = SCLAngleNormalize(angle1);
    angle2 = SCLAngleNormalize(angle2);
    
    double diff = fabs(angle1 - angle2);
    
    return fmin(diff, SCL_2PI - diff);
}
