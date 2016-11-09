//
//  SCLPinchViewController.h
//  ScreenLayout
//
//  Created by Jun on 11/28/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLSessionManager.h"
#import "SCLMotionManager.h"
#import "SCLPinchLayoutManager.h"
#import "SCLLayoutObserving.h"

/**
 @abstract The SCLPinchViewController class creates a controller object with some basic implementations to manage the screen layout by pinch gestures and device motions.
 @discussion Subclassing SCLPinchViewController is good start point to build your multi-screen app. SCLPinchViewController conforms SCLLayoutObserving protocol so you just override layoutDidChangeForScreens: method to handle any changes to the screen layout.
 */
@interface SCLPinchViewController : UIViewController <SCLSessionManagerDelegate, SCLLayoutObserving>

/**
 @abstract The session manager object managed by the receiver.
 @discussion The pinch view controller creates a SCLSessionManager object at initialization time and sets itself to delegate. As default the pinch view controller do nothing in own MCSessionDelegate or SCLSessionManager delegate methods so you don't need to call super in your subclass's implemetations.
 */
@property (readonly, nonatomic, strong, nonnull) SCLSessionManager *sessionManager;

/**
 @abstract The motion manager object managed by the receiver.
 @discussion The pinch view controller creates a SCLMotionManager object at initialization time. The pinch view controller automatically enables it in viewDidAppear: and disables in viewWillDisappear:.
 */
@property (readonly, nonatomic, strong, nonnull) SCLMotionManager *motionManager;

/**
 @abstract The layout manager object managed by the receiver.
 @discussion The pinch view controller creates a SCLPinchLayoutManager object at initialization time and adds its gestureRecognizer object to own view. The pinch view controller automatically enables it in viewDidAppear: and disables in viewWillDisappear:.
 */
@property (readonly, nonatomic, strong, nonnull) SCLPinchLayoutManager *layoutManager;

@end
