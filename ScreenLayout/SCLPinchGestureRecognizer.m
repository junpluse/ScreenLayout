//
//  SCLPinchGestureRecognizer.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLPinchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


#pragma mark -
@implementation SCLPinchGestureRecognizer {
    CGPoint  _location;
    CGVector _vector;
}

#pragma mark SCLPinchGestureRecognizer

- (CGVector)vectorInView:(UIView *)view
{
    CGPoint point1 = _location;
    CGPoint point2 = _location;
    point2.x += _vector.dx;
    point2.y += _vector.dy;
    
    point1 = [self.view convertPoint:point1 toView:view];
    point2 = [self.view convertPoint:point2 toView:view];
    
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

#pragma mark UIGestureRecognizer

- (CGPoint)locationInView:(UIView *)view
{
    return [self.view convertPoint:_location toView:view];
}

#pragma mark UIGestureRecognizer (ForSubclassEyesOnly)

- (void)reset
{
    [super reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if ([touches count] == 1) {
        _location = [[touches anyObject] locationInView:self.view];
    }
    else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint startLocation = _location;
    CGPoint currentLocation = [touches.anyObject locationInView:self.view];
    
    CGVector vector;
    vector.dx = currentLocation.x - startLocation.x;
    vector.dy = currentLocation.y - startLocation.y;
    
    static CGFloat distanceTolerance = 80.0;
    CGFloat distance = (CGFloat)sqrt((vector.dx * vector.dx) + (vector.dy * vector.dy));
    
    if (distance >= distanceTolerance && self.state == UIGestureRecognizerStatePossible) {
        _vector = vector;
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateFailed;
}

@end
