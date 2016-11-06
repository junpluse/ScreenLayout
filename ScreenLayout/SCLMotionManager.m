//
//  SCLMotionManager.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLMotionManager.h"
#import "SCLScreen.h"
#import "SCLLayout.h"
#import "SCLLayoutConstraint.h"
#import <CoreMotion/CMMotionManager.h>


#pragma mark -
@implementation SCLMotionManager {
    CMMotionManager  *_motionManager;
    NSOperationQueue *_motionQueue;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _enabled       = NO;
    _motionManager = [[CMMotionManager alloc] init];
    _motionQueue   = [[NSOperationQueue alloc] init];
    _eventsToDeativateConstraints = SCLMotionEventTilt | SCLMotionEventShake;
    
    return self;
}

#pragma mark SCLMotionManager

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (enabled) {
        [_motionManager startDeviceMotionUpdatesToQueue:_motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
            [self handleDeviceMotionUpdate:motion];
        }];
    }
    else {
        [_motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark SCLMotionManager (Internal)

- (void)handleDeviceMotionUpdate:(CMDeviceMotion *)deviceMotion
{
    static const double accelerationThreshold = 2.5;
    static const double rotationThreshold     = 1;
    
    SCLMotionEventMask events = _eventsToDeativateConstraints;
    
    if (events & SCLMotionEventShake) {
        CMAcceleration userAccel = deviceMotion.userAcceleration;
        if ((fabs(userAccel.x) > accelerationThreshold ||
             fabs(userAccel.y) > accelerationThreshold ||
             fabs(userAccel.z) > accelerationThreshold)) {
            [self removeConstraints];
        }
    }
    
    if (events & SCLMotionEventTilt) {
        CMRotationRate rotationRate = deviceMotion.rotationRate;
        if (fabs(rotationRate.x) > rotationThreshold ||
            fabs(rotationRate.y) > rotationThreshold ||
            fabs(rotationRate.z) > rotationThreshold) {
            [self removeConstraints];
        }
    }
}

- (void)removeConstraints
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SCLScreen *screen = [SCLScreen mainScreen];
        NSArray *constraints = [screen.layout constraintsContainingScreens:@[screen]];
        if (constraints.count) {
            [SCLLayout deactivateConstraints:constraints];
        }
    });
}

@end
