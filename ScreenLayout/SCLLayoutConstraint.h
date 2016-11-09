//
//  SCLLayoutConstraint.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"

@class SCLScreen;
@class SCLLayoutConstraint;
@class SCLLayoutConstraintItem;

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract SCLLayoutConstraint defines a relative geometry relationship between screens.
 */
@interface SCLLayoutConstraint : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract Creates a SCLLayoutConstraint instance with the specified items.
 @param items An array constaining the SCLLayoutConstraintItem objects.
 @return The newly-initialized constraint.
 */
- (instancetype)initWithItems:(nonnull NSArray<SCLLayoutConstraintItem *> *)items NS_DESIGNATED_INITIALIZER;

/**
 @abstract The items in the receiver.
 */
@property (readonly, nonatomic, copy, nonnull) NSArray<SCLLayoutConstraintItem *> *items;

/**
 @abstract The screens in the receiver's items.
 */
@property (readonly, nonatomic, nonnull) NSArray<SCLScreen *> *screens;

/**
 @abstract The unique identifier of the receiver.
 */
@property (readonly, nonatomic, nonnull) NSString *identifier;

@end

/**
 @abstract SCLLayoutConstraintItem defines relative geometry information for the screen in the constraint.
 */
@interface SCLLayoutConstraintItem : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract Creates a SCLLayoutConstraintItem instance with the specified screen, anchor point and rotation.
 @param screen The screen which the receiver defines the geometry for.
 @param anchor The anchor point in the local coordinate system (bounds) of screen.
 @param rotation The rotation of screen in the layout (in radians).
 @return The newly-initialized constraint.
 */
- (instancetype)initWithScreen:(nonnull SCLScreen *)screen anchor:(CGPoint)anchor rotation:(CGFloat)rotation NS_DESIGNATED_INITIALIZER;

/**
 @abstract The screen which the receiver defines the geometry for.
 */
@property (readonly, nonatomic, copy, nonnull) SCLScreen *screen;

/**
 @abstract The anchor point in the local coordinate system (bounds) of screen.
 */
@property (readonly, nonatomic) CGPoint anchor;

/**
 @abstract The rotation of screen in the layout (in radians).
 */
@property (readonly, nonatomic) CGFloat rotation;

@end

NS_ASSUME_NONNULL_END
