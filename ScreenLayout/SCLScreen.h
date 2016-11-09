//
//  SCLScreen.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"

@class MCPeerID;
@class SCLLayout;
@class SCLLayoutConstraint;

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract The key for the reuseable MCPeerID object in the standard user defaults. SCLScreen stores a MCPeerID object for the +mainScreen object and reuses it.
 */
extern NSString *const SCLScreenPeerIDUserDefaultsKey;

/**
 @abstract SCLScreen represents a local/remote device's screen. SCLScreen also provides a bunch of screen-to-screen geometry conversion methods.
 */
@interface SCLScreen : NSObject <NSCopying, NSSecureCoding>

/**
 @abstract Returns the screen object representing the current device's screen.
 @return The screen object for the current device.
 */
+ (nonnull SCLScreen *)mainScreen;

/**
 @abstract Creates a SCLScreen instance with the specified name, bounds, scale, ppi and margins.
 @param name The screen name. The hard limit of name is 63 bytes in UTF8 encoding and may not be nil or an empty string.
 @param bounds The screen bounds in points.
 @param scale The scale factor for the physical screen.
 @param ppi The resolution of the physical screen in pixels per inches.
 @param margins The margins of the physical screen in inches.
 @return The newly-initialized screen.
 */
- (instancetype)initWithName:(nonnull NSString *)name bounds:(CGRect)bounds scale:(CGFloat)scale ppi:(CGFloat)ppi margins:(SCLEdgeInsets)margins;

/**
 @abstract The screen name. (read-only)
 */
@property (readonly, nonatomic, copy, nonnull) NSString *name;

/**
 @abstract The screen bounds in points. (read-only)
 */
@property (readonly, nonatomic) CGRect bounds;

/**
 @abstract The scale factor for the physical screen. (read-only)
 */
@property (readonly, nonatomic) CGFloat scale;

/**
 @abstract The resolution of the physical screen in pixels per inches. (read-only)
 */
@property (readonly, nonatomic) CGFloat ppi;

/**
 @abstract The margins of the physical screen in inches. (read-only)
 */
@property (readonly, nonatomic) SCLEdgeInsets margins;

/**
 @abstract The peerID used in SCLSessionManager. (read-only)
 */
@property (readonly, nonatomic, nonnull) MCPeerID *peerID;

/**
 @abstract The layout that contains receiver. (read-only)
 @discussion May be nil if no active constraints containing the screen exists.
 */
@property (readonly, nonatomic, nullable) SCLLayout *layout;

/**
 @abstract The active constraints that contains receiver. (read-only)
 */
@property (readonly, nonatomic, nonnull) NSArray<SCLLayoutConstraint *> *constraints;

/**
 @abstract The other screens in the layout that constains the receiver. (read-only)
 */
@property (readonly, nonatomic, nonnull) NSArray<SCLScreen *> *connectedScreens;

/**
 @abstract Returns the rectangle represents the specified screen's frame in the receiver's coordinate system.
 @param screen The screen that is to be represented.
 @return The rectangle represents the screen frame in the receiver's coordinate system.
 */
- (CGRect)rectForScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a point from the coordinate system of another screen to that of the receiver.
 @param point A point specified in the local coordinate system (bounds) of screen.
 @param screen The screen with point in its coordinate system.
 @return The point converted to the local coordinate system (bounds) of the receiver.
 */
- (CGPoint)convertPoint:(CGPoint)point fromScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a point from the receiver’s coordinate system to that of the specified screen.
 @param point A point specified in the local coordinate system (bounds) of the receiver.
 @param screen The screen into whose coordinate system point is to be converted.
 @return The point converted to the coordinate system of screen.
 */
- (CGPoint)convertPoint:(CGPoint)point toScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a rectangle from the coordinate system of another screen to that of the receiver.
 @param rect A rectangle specified in the local coordinate system (bounds) of screen.
 @param screen The screen with rect in its coordinate system.
 @return The rectangle converted to the local coordinate system (bounds) of the receiver.
 */
- (CGRect)convertRect:(CGRect)rect fromScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a rectangle from the receiver’s coordinate system to that of the specified screen.
 @param rect A rectangle specified in the local coordinate system (bounds) of screen.
 @param screen The screen into whose coordinate system rect is to be converted.
 @return The rectangle converted to the coordinate system of screen.
 */
- (CGRect)convertRect:(CGRect)rect toScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a vector from the coordinate system of another screen to that of the receiver.
 @param vector A vector specified in the local coordinate system (bounds) of screen.
 @param screen The screen with vector in its coordinate system.
 @return The vector converted to the local coordinate system (bounds) of the receiver.
 */
- (CGVector)convertVector:(CGVector)vector fromScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts a vector from the receiver’s coordinate system to that of the specified screen.
 @param vector A vector specified in the local coordinate system (bounds) of the receiver.
 @param screen The screen into whose coordinate system vector is to be converted.
 @return The vector converted to the coordinate system of screen.
 */
- (CGVector)convertVector:(CGVector)vector toScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts an angle from the coordinate system of another screen to that of the receiver.
 @param angle An angle specified in the local coordinate system (bounds) of screen.
 @param screen The screen with angle in its coordinate system.
 @return The angle converted to the local coordinate system (bounds) of the receiver.
 */
- (CGFloat)convertAngle:(CGFloat)angle fromScreen:(nullable SCLScreen *)screen;

/**
 @abstract Converts an angle from the receiver’s coordinate system to that of the specified screen.
 @param angle An angle specified in the local coordinate system (bounds) of the receiver.
 @param screen The screen into whose coordinate system angle is to be converted.
 @return The angle converted to the coordinate system of screen.
 */
- (CGFloat)convertAngle:(CGFloat)angle toScreen:(nullable SCLScreen *)screen;

/**
 @abstract Returns the screens that contain a specified point.
 @param point A point specified in the receiver's local coordinate system (bounds).
 @return The screens that contain point.
 */
- (nonnull NSArray<SCLScreen *> *)screensAtPoint:(CGPoint)point;

/**
 @abstract Returns the screens that intersect a specified rectangle.
 @param rect A rectangle specified in the receiver's local coordinate system (bounds).
 @return The screens that intersect rect.
 */
- (nonnull NSArray<SCLScreen *> *)screensIntersectRect:(CGRect)rect;

/**
 @abstract Executes a given block using each screens connected to the receiver. This method uses NSArray's -enumerateObjectsUsingBlock: internaly.
 @param block The block to apply to screens. This block has no return value and takes three arguments: the screen, its frame in the local coordinate system (bounds) of the receiver, and a reference to a Boolean value to stop further processing of the connected screens.
 */
- (void)enumerateScreensUsingBlock:(nonnull void(NS_NOESCAPE ^)(SCLScreen * _Nonnull screen, CGRect frame, BOOL * _Nullable stop))block;

/**
 @abstract Returns a array of connected screens that pass a test in a given Block.
 @param block The block to apply to screens. This block has no return value and takes three arguments: the screen, its frame in the local coordinate system (bounds) of the receiver, and a reference to a Boolean value to stop further processing of the connected screens.
 @return An array containing screens that pass the test.
 */
- (nonnull NSArray<SCLScreen *> *)screensPassingTest:(nonnull BOOL(NS_NOESCAPE ^)(SCLScreen * _Nonnull screen, CGRect frame, BOOL * _Nullable stop))predicate;

@end

NS_ASSUME_NONNULL_END
