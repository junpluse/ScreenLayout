//
//  SCLPinchLayoutManager.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLPinchLayoutManager.h"
#import "SCLPinchGestureEvent.h"
#import "SCLPinchGestureRecognizer.h"
#import "SCLLayout.h"
#import "SCLLayoutConstraint.h"
#import "SCLScreen.h"
#import "SCLGeometry.h"
#import "UIView+ScreenLayout.h"
#import <CoreMotion/CMMotionManager.h>


static NSString *const SCLSessionMessgaeNamePinchEvent = @"SCLSessionMessgaeNamePinchEvent";


#pragma mark -
@implementation SCLPinchLayoutManager {
    CMMotionManager *_motionManager;
    NSMutableDictionary *_events;
}

#pragma mark NSObject

- (void)dealloc
{
    self.sessionManager = nil;
    [self stopObservingLayoutNotifications];
}

- (instancetype)init
{
    return [self initWithSessionManager:nil];
}

#pragma mark SCLPinchLayoutManager

- (instancetype)initWithSessionManager:(SCLSessionManager *)sessionManager
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.sessionManager = sessionManager;
    
    _enabled                   = NO;
    _ignoresDeviceRoll         = NO;
    _ignoresDevicePitch        = NO;
    _ignoresDeviceYaw          = YES;
    _ignoresOriginalTimestamps = YES;
    _ignoresScreenMargins      = NO;
    _angleTolerance            = M_PI_4 / 4;
    _timeTolerance             = 1.0;
    _motionManager             = [[CMMotionManager alloc] init];
    _events                    = [[NSMutableDictionary alloc] init];
    _gestureRecognizer         = [[SCLPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    _gestureRecognizer.enabled = NO;
    
    [self startObservingLayoutNotifications];
    
    return self;
}

- (void)setSessionManager:(SCLSessionManager *)sessionManager
{
    if (_sessionManager) {
        [self stopObservingSessionManagerNotifications];
    }
    
    _sessionManager = sessionManager;
    
    if (_sessionManager) {
        [self startObservingSessionManagerNotifications];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (enabled) {
        [self startMotionUpdates];
        _gestureRecognizer.enabled = YES;
    }
    else {
        [self stopMotionUpdates];
        _gestureRecognizer.enabled = NO;
    }
}

- (void)setIgnoresDeviceYaw:(BOOL)ignoresDeviceYaw
{
    BOOL changed = (ignoresDeviceYaw != !_ignoresDeviceYaw);
    
    _ignoresDeviceYaw = ignoresDeviceYaw;
    
    if (changed) {
        BOOL active = [_motionManager isDeviceMotionActive];
        [_motionManager stopDeviceMotionUpdates];
        if (active) {
            [_motionManager startDeviceMotionUpdates];
        }
    }
}

#pragma mark SCLPinchLayoutManager (Internal)

- (void)startObservingLayoutNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayoutDidActivateConstraintsNotification:) name:SCLLayoutDidActivateConstraintsNotification object:nil];
}

- (void)stopObservingLayoutNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCLLayoutDidActivateConstraintsNotification object:nil];
}

- (void)handleLayoutDidActivateConstraintsNotification:(NSNotification *)notification
{
    NSArray *constraints = notification.userInfo[SCLLayoutConstraintsUserInfoKey];
    
    for (SCLLayoutConstraint *constraint in constraints) {
        for (SCLScreen *screen in constraint.screens) {
            [_events removeObjectForKey:screen.peerID];
        }
    }
}

- (void)startObservingSessionManagerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionManagerDidReceiveMessageNotification:) name:SCLSessionManagerDidReceiveMessageNotification object:_sessionManager];
}

- (void)stopObservingSessionManagerNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCLSessionManagerDidReceiveMessageNotification object:_sessionManager];
}

- (void)handleSessionManagerDidReceiveMessageNotification:(NSNotification *)notification
{
    SCLSessionMessage *message = notification.userInfo[SCLSessionManagerMessageUserInfoKey];
    MCPeerID *peerID = notification.userInfo[SCLSessionManagerPeerIDUserInfoKey];
    
    if (_enabled && [message.name isEqual:SCLSessionMessgaeNamePinchEvent]) {
        SCLPinchGestureEvent *event = message.object;
        event.dateReceived = [NSDate date];
        [self setEvent:event forPeer:peerID];
    }
}

- (void)handleGesture:(SCLPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        SCLPinchGestureEvent *event = [[SCLPinchGestureEvent alloc] init];
        event.location = [sender.view scl_convertPointToMainScreen:[sender locationInView:sender.view]];
        event.vector   = [sender.view scl_convertVectorToMainScreen:[sender vectorInView:sender.view]];
        event.attitude = _motionManager.deviceMotion.attitude;
        [self setEvent:event forPeer:_sessionManager.session.myPeerID];
    }
}

- (void)startMotionUpdates
{
    CMAttitudeReferenceFrame frame = [self preferredAttitudeReferenceFrame];
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame];
}

- (void)stopMotionUpdates
{
    [_motionManager stopDeviceMotionUpdates];
}

- (CMAttitudeReferenceFrame)preferredAttitudeReferenceFrame
{
    if (_ignoresDeviceYaw) {
        return CMAttitudeReferenceFrameXArbitraryZVertical;
    }
    else {
        NSUInteger availableFrames = [CMMotionManager availableAttitudeReferenceFrames];
        if (availableFrames & CMAttitudeReferenceFrameXTrueNorthZVertical) {
            return CMAttitudeReferenceFrameXTrueNorthZVertical;
        }
        else if (availableFrames & CMAttitudeReferenceFrameXMagneticNorthZVertical) {
            return CMAttitudeReferenceFrameXMagneticNorthZVertical;
        }
        else if (availableFrames & CMAttitudeReferenceFrameXArbitraryCorrectedZVertical) {
            return CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
        }
        else {
            return CMAttitudeReferenceFrameXArbitraryZVertical;
        }
    }
}

- (void)setEvent:(SCLPinchGestureEvent *)event forPeer:(MCPeerID *)peerID
{
    _events[peerID] = event;
    
    MCPeerID *myPeerID = _sessionManager.session.myPeerID;
    
    if ([peerID isEqual:myPeerID]) {
        void(^sendMessage)(void) = ^{
            SCLSessionMessage *message = [[SCLSessionMessage alloc] initWithName:SCLSessionMessgaeNamePinchEvent object:event];
            [_sessionManager sendMessage:message toPeers:_sessionManager.session.connectedPeers withMode:MCSessionSendDataUnreliable error:nil];
        };
        NSArray *matchedPeers = [_events keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
            return [self canCreateConstraintWithEventForPeerID:key];
        }].allObjects;
        if (matchedPeers.count > 0) {
            NSArray *sortedMatchedPeers = [matchedPeers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                SCLPinchGestureEvent *event1 = _events[obj1];
                SCLPinchGestureEvent *event2 = _events[obj2];
                return [event1.dateCreated compare:event2.dateCreated];
            }];
            NSUInteger index = [sortedMatchedPeers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                SCLPinchGestureEvent *event1 = _events[myPeerID];
                SCLPinchGestureEvent *event2 = _events[obj];
                return [event1.dateCreated compare:event2.dateCreated] == NSOrderedAscending;
            }];
            if (index != NSNotFound) {
                MCPeerID *selectedPeerID = sortedMatchedPeers[index];
                SCLLayoutConstraint *constraint = [self createConstraintWithRemoteEventForPeer:selectedPeerID];
                constraint.active = YES;
            }
            else {
                sendMessage();
            }
            [matchedPeers enumerateObjectsUsingBlock:^(MCPeerID *matchedPeerID, NSUInteger idx, BOOL *stop) {
                [_events removeObjectForKey:matchedPeerID];
            }];
            [_events removeObjectForKey:myPeerID];
        }
        else {
            sendMessage();
        }
    }
    else if ([self canCreateConstraintWithEventForPeerID:peerID]) {
        SCLPinchGestureEvent *event1 = _events[myPeerID];
        SCLPinchGestureEvent *event2 = _events[peerID];
        if ([event1.dateCreated compare:event2.dateCreated] == NSOrderedAscending) {
            SCLLayoutConstraint *constraint = [self createConstraintWithRemoteEventForPeer:peerID];
            constraint.active = YES;
        }
        [_events removeObjectForKey:myPeerID];
        [_events removeObjectForKey:peerID];
    }
}

- (BOOL)canCreateConstraintWithEventForPeerID:(MCPeerID *)peerID
{
    SCLSessionManager *sessionManager = _sessionManager;
    
    MCPeerID *peerA = sessionManager.session.myPeerID;
    MCPeerID *peerB = peerID;
    if ([peerA isEqual:peerB]) {
        return NO;
    }
    
    SCLPinchGestureEvent *eventA = _events[peerA];
    SCLPinchGestureEvent *eventB = _events[peerB];
    if (!eventA || !eventB || ![self matchTestWithEvent:eventA andEvent:eventB]) {
        return NO;
    }
    
    SCLScreen *screenA = [sessionManager screenForPeer:peerA];
    SCLScreen *screenB = [sessionManager screenForPeer:peerB];
    if (!screenA || !screenB) {
        return NO;
    }
    
    return YES;
}

- (SCLLayoutConstraint *)createConstraintWithRemoteEventForPeer:(MCPeerID *)aPeerID
{
    SCLSessionManager *sessionManager = _sessionManager;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [@[sessionManager.session.myPeerID, aPeerID] enumerateObjectsUsingBlock:^(MCPeerID *peerID, NSUInteger idx, BOOL *stop) {
        SCLScreen *screen = [sessionManager screenForPeer:peerID];
        SCLPinchGestureEvent *event = _events[peerID];
//        CGPoint anchor = [event anchorPointInScreen:screen ignoresMargins:_ignoresScreenMargins];
        CGPoint anchor = [event edgeIntersectionInScreen:screen ignoresMargins:_ignoresScreenMargins];
        CGFloat rotation = SCLAngleNormalize(-SCLAngleRoundQuartery(event.direction));
        if (peerID == aPeerID) {
            rotation = SCLAngleNormalize(rotation - M_PI);
        }
        SCLLayoutConstraintItem *item = [[SCLLayoutConstraintItem alloc] initWithScreen:screen anchor:anchor rotation:rotation];
        [items addObject:item];
    }];
    
    SCLLayoutConstraint *constraint = [[SCLLayoutConstraint alloc] initWithItems:items];
    
    return constraint;
}

- (BOOL)matchTestWithEvent:(SCLPinchGestureEvent *)eventA andEvent:(SCLPinchGestureEvent *)eventB
{
    if ([eventA isEqual:eventB]) {
        return NO;
    }
    
    NSDate *dateA;
    NSDate *dateB;
    if (_ignoresOriginalTimestamps) {
        dateA = eventA.dateReceived ?: eventA.dateCreated;
        dateB = eventB.dateReceived ?: eventB.dateCreated;
    }
    else {
        dateA = eventA.dateCreated;
        dateB = eventB.dateCreated;
    }
    if (fabs(dateA.timeIntervalSince1970 - dateB.timeIntervalSince1970) > _timeTolerance) {
        return NO;
    }
    
    CMAttitude *attitudeA = eventA.attitude;
    CMAttitude *attitudeB = eventB.attitude;
    if (!_ignoresDeviceRoll) {
        double angleA = attitudeA.roll;
        double angleB = attitudeB.roll;
        if (SCLAngleDifference(angleA, angleB) > _angleTolerance) {
            return NO;
        }
    }
    if (!_ignoresDevicePitch) {
        double angleA = attitudeA.pitch;
        double angleB = attitudeB.pitch;
        if (SCLAngleDifference(angleA, angleB) > _angleTolerance) {
            return NO;
        }
    }
    if (!_ignoresDeviceYaw) {
        double angleA = attitudeA.yaw + eventA.direction;
        double angleB = attitudeB.yaw + eventB.direction + M_PI;
        if (SCLAngleDifference(angleA, angleB) > _angleTolerance) {
            return NO;
        }
    }
    
    return YES;
}

@end
