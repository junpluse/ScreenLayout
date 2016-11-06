//
//  ScreenLayout.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for ScreenLayout.
FOUNDATION_EXPORT double ScreenLayoutVersionNumber;

//! Project version string for ScreenLayout.
FOUNDATION_EXPORT const unsigned char ScreenLayoutVersionString[];

#import <ScreenLayout/ScreenLayoutBase.h>

#import <ScreenLayout/SCLCodingUtilities.h>
#import <ScreenLayout/SCLGeometry.h>
#import <ScreenLayout/SCLLayout.h>
#import <ScreenLayout/SCLLayoutConstraint.h>
#import <ScreenLayout/SCLScreen.h>
#import <ScreenLayout/SCLSessionManager.h>
#import <ScreenLayout/SCLSessionMessage.h>

#if TARGET_OS_IPHONE
#import <ScreenLayout/SCLCoordinateSpace.h>
#import <ScreenLayout/SCLMotionManager.h>
#import <ScreenLayout/SCLPinchLayoutManager.h>
#import <ScreenLayout/SCLPinchViewController.h>
#import <ScreenLayout/UIDevice+ScreenLayout.h>
#import <ScreenLayout/UIView+ScreenLayout.h>
#endif
