//
//  ScreenLayoutBase.h
//  ScreenLayout
//
//  Created by Jun on 11/28/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#if TARGET_OS_IPHONE
#define SCLEdgeInsets UIEdgeInsets
#define SCLEdgeInsetsZero UIEdgeInsetsZero
#define SCLEdgeInsetsMake UIEdgeInsetsMake
#define SCLEdgeInsetsInsetRect UIEdgeInsetsInsetRect
#define SCLEdgeInsetsEqualToEdgeInsets UIEdgeInsetsEqualToEdgeInsets
#else
typedef struct SCLEdgeInsets {
    CGFloat top, left, bottom, right;
} SCLEdgeInsets;

static inline SCLEdgeInsets SCLEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    SCLEdgeInsets insets = {top, left, bottom, right};
    return insets;
}

static inline CGRect SCLEdgeInsetsInsetRect(CGRect rect, SCLEdgeInsets insets) {
    rect.origin.x    += insets.left;
    rect.origin.y    += insets.top;
    rect.size.width  -= (insets.left + insets.right);
    rect.size.height -= (insets.top  + insets.bottom);
    return rect;
}

static inline BOOL SCLEdgeInsetsEqualToEdgeInsets(SCLEdgeInsets insets1, SCLEdgeInsets insets2) {
    return insets1.left == insets2.left && insets1.top == insets2.top && insets1.right == insets2.right && insets1.bottom == insets2.bottom;
}

extern const SCLEdgeInsets SCLEdgeInsetsZero;
#endif

#ifndef CGVECTOR_DEFINED
#define CGVECTOR_DEFINED 1
struct CGVector {
    CGFloat dx;
    CGFloat dy;
};

typedef struct CGVector CGVector;

CG_INLINE CGVector CGVectorMake(CGFloat dx, CGFloat dy) {
    CGVector vector; vector.dx = dx; vector.dy = dy; return vector;
}
#endif

static inline BOOL SCLVectorEqualToVector(CGVector vector1, CGVector vector2) {
    return vector1.dx == vector2.dx && vector1.dy == vector2.dy;
}
