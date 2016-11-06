//
//  SCLPinchGestureEvent.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"
#import <CoreMotion/CMAttitude.h>

@class SCLScreen;


@interface SCLPinchGestureEvent : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic) CGPoint location;
@property (nonatomic) CGVector vector;
@property (nonatomic, copy) CMAttitude *attitude;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateReceived;
@property (readonly, nonatomic) double direction;

- (CGPoint)anchorPointInScreen:(SCLScreen *)screen ignoresMargins:(BOOL)ignoresMargins;
- (CGPoint)edgeIntersectionInScreen:(SCLScreen *)screen ignoresMargins:(BOOL)ignoresMargins;

@end
