//
//  SCLCoordinateSpace.m
//  ScreenLayout
//
//  Created by Jun on 12/9/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLCoordinateSpace.h"
#import "SCLGeometry.h"


CGVector SCLConvertVectorBetweenCoordinateSpaces(CGVector vector, id<UICoordinateSpace> from, id<UICoordinateSpace> to)
{
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointMake(vector.dx, vector.dy);
    
    point1 = [from convertPoint:point1 toCoordinateSpace:to];
    point2 = [from convertPoint:point2 toCoordinateSpace:to];
    
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

CGFloat SCLConvertAngleBetweenCoordinateSpaces(CGFloat angle, id<UICoordinateSpace> from, id<UICoordinateSpace> to)
{
    CGVector vector = SCLVectorFromAngle(angle);
    
    vector = SCLConvertVectorBetweenCoordinateSpaces(vector, from, to);
    
    return SCLAngleFromVector(vector);
}


#pragma mark -
@implementation SCLScreen (SCLScreenCoordinateSpaceSupports)

#pragma mark UICoordinateSpace

- (CGPoint)convertPoint:(CGPoint)point toCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    if ([coordinateSpace isKindOfClass:[SCLScreen class]]) {
        point = [self convertPoint:point toScreen:(SCLScreen *)coordinateSpace];
    }
    else {
        point = [[SCLScreen mainScreen] convertPoint:point fromScreen:self];
        point = [coordinateSpace convertPoint:point fromCoordinateSpace:[UIScreen mainScreen].fixedCoordinateSpace];
    }
    
    return point;
}

- (CGPoint)convertPoint:(CGPoint)point fromCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    if ([coordinateSpace isKindOfClass:[SCLScreen class]]) {
        point = [self convertPoint:point fromScreen:(SCLScreen *)coordinateSpace];
    }
    else {
        point = [coordinateSpace convertPoint:point toCoordinateSpace:[UIScreen mainScreen].fixedCoordinateSpace];
        point = [[SCLScreen mainScreen] convertPoint:point toScreen:self];
    }
    
    return point;
}

- (CGRect)convertRect:(CGRect)rect toCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    if ([coordinateSpace isKindOfClass:[SCLScreen class]]) {
        rect = [self convertRect:rect toScreen:(SCLScreen *)coordinateSpace];
    }
    else {
        rect = [[SCLScreen mainScreen] convertRect:rect fromScreen:self];
        rect = [coordinateSpace convertRect:rect fromCoordinateSpace:[UIScreen mainScreen].fixedCoordinateSpace];
    }
    
    return rect;
}

- (CGRect)convertRect:(CGRect)rect fromCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    if ([coordinateSpace isKindOfClass:[SCLScreen class]]) {
        rect = [self convertRect:rect fromScreen:(SCLScreen *)coordinateSpace];
    }
    else {
        rect = [coordinateSpace convertRect:rect toCoordinateSpace:[UIScreen mainScreen].fixedCoordinateSpace];
        rect = [[SCLScreen mainScreen] convertRect:rect toScreen:self];
    }
    
    return rect;
}

#pragma mark SCLCoordinateSpace

- (CGVector)convertVector:(CGVector)vector toCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    return SCLConvertVectorBetweenCoordinateSpaces(vector, self, coordinateSpace);
}

- (CGVector)convertVector:(CGVector)vector fromCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    return SCLConvertVectorBetweenCoordinateSpaces(vector, coordinateSpace, self);
}

- (CGFloat)convertAngle:(CGFloat)angle toCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    return SCLConvertAngleBetweenCoordinateSpaces(angle, self, coordinateSpace);
}

- (CGFloat)convertAngle:(CGFloat)angle fromCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace
{
    return SCLConvertAngleBetweenCoordinateSpaces(angle, coordinateSpace, self);
}

@end
