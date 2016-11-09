//
//  SCLPinchLayoutManager.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLSessionMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract A SCLPinchLayoutManager automatically creates SCLLayoutConstraint objects by 'pinch' gestures across screens.
 @discussion To start, you have to add the SCLPinchLayoutManager.gestureRecognizer to your view and set SCLPinchLayoutManager.enabled to YES.
 */
@interface SCLPinchLayoutManager : NSObject

/**
 @abstract Creates a SCLPinchLayoutManager instance with the specified session manager.
 @param sessionManager The SCLSessionManager object which the receiver uses to communicate gesture informations to remote peers.
 @return The newly-initialized layout manager.
 */
- (instancetype)initWithSessionManager:(nullable SCLSessionManager *)sessionManager NS_DESIGNATED_INITIALIZER;

/**
 @abstract The session manager object which the receiver uses.
 */
@property (nonatomic, strong, nullable) SCLSessionManager *sessionManager;

/**
 @abstract Determines whether the receiver is currently handling gesture informations. Default is NO.
 @discussion If you set this property to YES/NO, the receiver also set the SCLPinchLayoutManager.gestureRecognizer.enabled to YES/NO and start/stop the internal CMMotionManager object that handles device attitude updates.
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 @abstract Determines whether the receiver ignores roll of each device to match two gesture events. Default is NO.
 @discussion If NO, the receiver compares the roll of each device when the gesture happened. If the absolute difference of rolls is greater than SCLSessionManager.angleTolerance, the receiver fails to match.
 */
@property (nonatomic) BOOL ignoresDeviceRoll;

/**
 @abstract Determines whether the receiver ignores pitch of each device to match two gesture events. Default is NO.
 @discussion If NO, the receiver compares the pitch of each device when the gesture happened. If the absolute difference of pitches is greater than SCLSessionManager.angleTolerance, the receiver fails to match.
 */
@property (nonatomic) BOOL ignoresDevicePitch;

/**
 @abstract Determines whether the receiver ignores yaw of each device to match two gesture events. Default is YES.
 @discussion If NO, the receiver uses yaw of each device to calibrate direction of gestures. If the absolute difference of directions is smaller than SCLSessionManager.angleTolerance, the receiver fails to match.
 */
@property (nonatomic) BOOL ignoresDeviceYaw;

/**
 @abstract The tolerance for absolute difference of angles to match two gesture events. Default is M_PI_4/4 (0.3926990817).
 */
@property (nonatomic) double angleTolerance;

/**
 @abstract Determines whether the receiver ignores original timestamp of each gesture event to match. Default is YES.
 @discussion If YES, the receiver compares alternative timestamp attached when the gesture event is received via network. If the absolute difference of timestamps is greater than SCLSessionManager.timeTolerance, the receiver fails to match.
 */
@property (nonatomic) BOOL ignoresOriginalTimestamps;

/**
 @abstract The tolerance for absolute difference of timestamps to match two gesture events. Default is 1 sec.
 */
@property (nonatomic) NSTimeInterval timeTolerance;

/**
 @abstract Determines whether the receiver ignores screen margins of each device. Default is NO.
 @discussion If YES, the receiver ignores spaces of screen margins to layout them.
 */
@property (nonatomic) BOOL ignoresScreenMargins;

/**
 @abstract The gesture recognizer to detect gesture events in the local screen.
 @discussion You have to add this gesture recognizer to your view.
 */
@property (readonly, nonatomic, nonnull) UIGestureRecognizer *gestureRecognizer;

@end

NS_ASSUME_NONNULL_END
