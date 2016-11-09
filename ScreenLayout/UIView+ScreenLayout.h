//
//  UIView+ScreenLayout.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLCoordinateSpace.h"


@interface UIView (ScreenLayout) <SCLCoordinateSpace>

- (CGVector)scl_convertVector:(CGVector)vector toView:(nullable UIView *)view;
- (CGVector)scl_convertVector:(CGVector)vector fromView:(nullable UIView *)view;
- (CGFloat)scl_convertAngle:(CGFloat)angle toView:(nullable UIView *)view;
- (CGFloat)scl_convertAngle:(CGFloat)angle fromView:(nullable UIView *)view;

- (CGPoint)scl_convertPointToMainScreen:(CGPoint)point;
- (CGPoint)scl_convertPointFromMainScreen:(CGPoint)point;
- (CGRect)scl_convertRectToMainScreen:(CGRect)rect;
- (CGRect)scl_convertRectFromMainScreen:(CGRect)rect;
- (CGVector)scl_convertVectorToMainScreen:(CGVector)vector;
- (CGVector)scl_convertVectorFromMainScreen:(CGVector)vector;
- (CGFloat)scl_convertAngleToMainScreen:(CGFloat)angle;
- (CGFloat)scl_convertAngleFromMainScreen:(CGFloat)angle;

@end
