//
//  SCLPinchGestureRecognizer.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"


@interface SCLPinchGestureRecognizer : UIGestureRecognizer

- (CGVector)vectorInView:(nullable UIView *)view;

@end
