//
//  SCLMotionManager.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"


typedef NS_OPTIONS(NSUInteger, SCLMotionEventMask) {
    SCLMotionEventNone  = 0,
    SCLMotionEventTilt  = 1 << 0,
    SCLMotionEventShake = 1 << 1
};

/**
 @abstract A SCLMotionManager automatically deactivates SCLLayoutConstraint objects that contains [SCLScreen mainScreen] when detects device motions.
 */
@interface SCLMotionManager : NSObject

/**
 @abstract Creates a SCLMotionManager instance.
 @return The newly-initialized motion manager.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 @abstract Determines whether the receiver is currently handling motion events. Default is NO.
 @discussion If you set this property to YES/NO, the receiver start/stop the internal CMMotionManager object that handles device motion updates.
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 @abstract An integer bit mask that determines what type of motion events the receiver uses to deactivate constraints. Default is SCLMotionEventTilt|SCLMotionEventShake.
 @discussion If any of the specified events is detected, the receiver deactivate constraints that contains [SCLScreen mainScreen].
 */
@property (nonatomic) SCLMotionEventMask eventsToDeativateConstraints;

@end
