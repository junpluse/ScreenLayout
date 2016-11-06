//
//  SCLGeometry.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"

/**
 @abstract Returns a vector converted from an angle.
 @param angle A CGFloat representing angle.
 @return A vector converted from angle.
 @discussion This function internally calls SCLVectorFromAngleWithDistance() with distance 10.0.
 */
extern CGVector SCLVectorFromAngle(CGFloat angle);

/**
 @abstract Returns a vector converted from an angle with a distance.
 @param angle A CGFloat value representing an angle.
 @param distance A CGFloat value representing a distance.
 @return A vector converted from angle with distance.
 */
extern CGVector SCLVectorFromAngleWithDistance(CGFloat angle, CGFloat distance);

/**
 @abstract Returns an angle converted from a vector.
 @param vector A CGVector structure representing a vector.
 @return A angle converted from vector.
 */
extern CGFloat SCLAngleFromVector(CGVector vector);

/**
 @abstract Returns an angle normarized to the range from -PI to +PI.
 @param angle A CGFloat value representing an angle.
 @return A normarized angle.
 */
extern CGFloat SCLAngleNormalize(CGFloat angle);

/**
 @abstract Returns an angle rounded to 0, PI/2, PI, -PI/2 or -PI.
 @param angle A CGFloat value representing an angle.
 @return A rounded angle.
 */
extern CGFloat SCLAngleRoundQuartery(CGFloat angle);

/**
 @abstract Returns an absolute difference between two angles.
 @param angle1 A CGFloat value representing an angle.
 @param angle2 A CGFloat value representing an angle.
 @return A difference between angle1 and angle2.
 */
extern CGFloat SCLAngleDifference(CGFloat angle1, CGFloat angle2);
