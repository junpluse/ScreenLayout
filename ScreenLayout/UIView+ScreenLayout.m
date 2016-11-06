//
//  UIView+ScreenLayout.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "UIView+ScreenLayout.h"
#import "SCLGeometry.h"


#pragma mark -
@implementation UIView (ScreenLayout)

#pragma mark UIView (ScreenLayout)

- (CGVector)scl_convertVector:(CGVector)vector fromView:(UIView *)view
{
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointMake(vector.dx, vector.dy);
    
    point1 = [self convertPoint:point1 fromView:view];
    point2 = [self convertPoint:point2 fromView:view];
    
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

- (CGVector)scl_convertVector:(CGVector)vector toView:(UIView *)view
{
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointMake(vector.dx, vector.dy);
    
    point1 = [self convertPoint:point1 toView:view];
    point2 = [self convertPoint:point2 toView:view];
    
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

- (CGFloat)scl_convertAngle:(CGFloat)angle fromView:(UIView *)view
{
    CGVector vector = SCLVectorFromAngle(angle);
    
    vector = [self scl_convertVector:vector fromView:view];
    
    return SCLAngleFromVector(vector);
}

- (CGFloat)scl_convertAngle:(CGFloat)angle toView:(UIView *)view
{
    CGVector vector = SCLVectorFromAngle(angle);
    
    vector = [self scl_convertVector:vector toView:view];
    
    return SCLAngleFromVector(vector);
}

- (CGPoint)scl_convertPointToMainScreen:(CGPoint)point
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return point;
    }
    
    if (SCLCoordinateSpaceAvailable) {
        point = [self convertPoint:point toCoordinateSpace:screen.fixedCoordinateSpace];
    }
    else {
        point = [self convertPoint:point toView:nil];
        point = [self.window convertPoint:point toWindow:nil];
    }
    return point;
}

- (CGPoint)scl_convertPointFromMainScreen:(CGPoint)point
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return point;
    }
    
    if (SCLCoordinateSpaceAvailable) {
        point = [self convertPoint:point fromCoordinateSpace:screen.fixedCoordinateSpace];
    }
    else {
        point = [self.window convertPoint:point fromWindow:nil];
        point = [self convertPoint:point fromView:nil];
    }
    return point;
}

- (CGRect)scl_convertRectToMainScreen:(CGRect)rect
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return rect;
    }
    
    if (SCLCoordinateSpaceAvailable) {
        rect = [self convertRect:rect toCoordinateSpace:screen.fixedCoordinateSpace];
    }
    else {
        rect = [self convertRect:rect toView:nil];
        rect = [self.window convertRect:rect toWindow:nil];
    }
    return rect;
}

- (CGRect)scl_convertRectFromMainScreen:(CGRect)rect
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return rect;
    }
    
    if (SCLCoordinateSpaceAvailable) {
        rect = [self convertRect:rect fromCoordinateSpace:screen.fixedCoordinateSpace];
    }
    else {
        rect = [self.window convertRect:rect fromWindow:nil];
        rect = [self convertRect:rect fromView:nil];
    }
    return rect;
}


- (CGVector)scl_convertVectorFromMainScreen:(CGVector)vector
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return vector;
    }
    
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointMake(vector.dx, vector.dy);
    point1 = [self scl_convertPointFromMainScreen:point1];
    point2 = [self scl_convertPointFromMainScreen:point2];
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

- (CGVector)scl_convertVectorToMainScreen:(CGVector)vector
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return vector;
    }
    
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointMake(vector.dx, vector.dy);
    point1 = [self scl_convertPointToMainScreen:point1];
    point2 = [self scl_convertPointToMainScreen:point2];
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

- (CGFloat)scl_convertAngleFromMainScreen:(CGFloat)angle
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return angle;
    }
    
    CGVector vector = SCLVectorFromAngle(angle);
    vector = [self scl_convertVectorFromMainScreen:vector];
    return SCLAngleFromVector(vector);
}

- (CGFloat)scl_convertAngleToMainScreen:(CGFloat)angle
{
    UIScreen *screen = self.window.screen;
    if (![screen isEqual:[UIScreen mainScreen]]) {
        return angle;
    }
    
    CGVector vector = SCLVectorFromAngle(angle);
    vector = [self scl_convertVectorToMainScreen:vector];
    return SCLAngleFromVector(vector);
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
