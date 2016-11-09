//
//  SCLLayout.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"
#import "SCLLayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract A SCLLayout instance represents a group of screens connected each other by chained constraints. SCLLayout also provides a bunch of screen-to-screen geometry conversion methods.
 */
@interface SCLLayout : NSObject

/**
 @abstract Returns the layout that contains the specified screen.
 @return The layout containing screen.
 */
+ (nullable SCLLayout *)layoutForScreen:(nonnull SCLScreen *)screen;

/**
 @abstract The screens in the receiver.
 */
@property (readonly, nonatomic, nonnull) NSArray<SCLScreen *> *screens;

/**
 @abstract The active constraints composing the receiver.
 */
@property (readonly, nonatomic, nonnull) NSArray<SCLLayoutConstraint *> *constraints;

/**
 @abstract Returns the constraints that contain all of the specified screens.
 @param screens One or more screens in the layout.
 @return The constraints containing all of screens.
 */
- (nonnull NSArray<SCLLayoutConstraint *> *)constraintsContainingScreens:(nonnull NSArray<SCLScreen *> *)screens;

/**
 @abstract Returns the smallest rectangle that contains all of screens in the receiver, in the specified screen's coordinate system (bounds).
 @param screen A screen on which the bounds took place.
 @return The bounding rectanble in screen.
 */
- (CGRect)boundsInScreen:(nonnull SCLScreen *)screen;

/**
 @abstract Converts a point from the coordinate system of a screen to that of another one.
 @param point A point specified in the local coordinate system (bounds) of screen.
 @param fromScreen The screen with point in its coordinate system.
 @param toScreen The screen into whose coordinate system point is to be converted.
 @return The point converted to the coordinate system of toScreen.
 */
- (CGPoint)convertPoint:(CGPoint)point fromScreen:(nullable SCLScreen *)fromScreen toScreen:(nullable SCLScreen *)toScreen;

/**
 @abstract Converts a rectangle from the coordinate system of a screen to that of another one.
 @param rect A rectangle specified in the local coordinate system (bounds) of screen.
 @param fromScreen The screen with point in its coordinate system.
 @param toScreen The screen into whose coordinate system rect is to be converted.
 @return The rectangle converted to the coordinate system of toScreen.
 */
- (CGRect)convertRect:(CGRect)rect fromScreen:(nullable SCLScreen *)fromScreen toScreen:(nullable SCLScreen *)toScreen;

/**
 @abstract Converts a vector from the coordinate system of a screen to that of another one.
 @param vector A vector specified in the local coordinate system (bounds) of screen.
 @param fromScreen The screen with vector in its coordinate system.
 @param toScreen The screen into whose coordinate system vector is to be converted.
 @return The vector converted to the coordinate system of toScreen.
 */
- (CGVector)convertVector:(CGVector)vector fromScreen:(nullable SCLScreen *)fromScreen toScreen:(nullable SCLScreen *)toScreen;

/**
 @abstract Converts an angle from the coordinate system of a screen to that of another one.
 @param angle An angle specified in the local coordinate system (bounds) of screen.
 @param fromScreen The screen with angle in its coordinate system.
 @param toScreen The screen into whose coordinate system angle is to be converted.
 @return The angle converted to the coordinate system of toScreen.
 */
- (CGFloat)convertAngle:(CGFloat)angle fromScreen:(nullable SCLScreen *)fromScreen toScreen:(nullable SCLScreen *)toScreen;

@end


@interface SCLLayout (SCLLayoutConstraintActivation)

/**
 @abstract Activates each constraint in the specified array, and returns an array that contains the screens affected by the activation.
 @param constraints An array of constraints to activate.
 @return An array constaining the screens affected by the constraints.
 @discussion This method also posts a SCLLayoutDidActivateConstraintsNotification with a nil object and a userInfo dictionary containing the constraints and the affected screens.
 */
+ (nonnull NSArray<SCLScreen *> *)activateConstraints:(nonnull NSArray<SCLLayoutConstraint *> *)constraints;

/**
 @abstract Deactivates each constraint in the specified array, and returns an array that contains the screens affected by the deactivation.
 @param constraints An array of constraints to deactivate.
 @return An array constaining the screens affected by the constraints.
 @discussion This method also posts a SCLLayoutDidDeactivateConstraintsNotification with a nil object and a userInfo dictionary containing the constraints and the affected screens.
 */
+ (nonnull NSArray<SCLScreen *> *)deactivateConstraints:(nonnull NSArray<SCLLayoutConstraint *> *)constraints;

@end


@interface SCLLayoutConstraint (SCLLayoutConstraintActivation)

/**
 @abstract The receiver may be activated or deactivated by manipulating this property. Only active constraints affect the calculated layout. If you set this property, the receiver just calls SCLLayout's +activateConstraints: or +deactivateConstraints: with itself.
 */
@property (nonatomic, getter=isActive) BOOL active;

@end


extern NSNotificationName const SCLLayoutDidActivateConstraintsNotification;
extern NSNotificationName const SCLLayoutDidDeactivateConstraintsNotification;
extern NSString *const SCLLayoutConstraintsUserInfoKey;
extern NSString *const SCLLayoutAffectedScreensUserInfoKey;

NS_ASSUME_NONNULL_END
