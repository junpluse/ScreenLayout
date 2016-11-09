//
//  SCLLayout.m
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayout.h"
#import "SCLLayout+ConstraintStack.h"
#import "SCLLayoutConstraint.h"
#import "SCLLayoutObserving.h"
#import "SCLLayoutPool.h"
#import "SCLScreen.h"
#import "SCLCodingUtilities.h"
#import "SCLGeometry.h"


#pragma mark -
@implementation SCLLayout {
    NSMutableArray *_constraints;
    CALayer        *_rootLayer;
    NSMapTable     *_screenLayers;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _constraints = [[NSMutableArray alloc] init];
    
    CALayer *rootLayer = [[CALayer alloc] init];
    _rootLayer = rootLayer;
    
    NSMapTable *peerLayers = [NSMapTable strongToWeakObjectsMapTable];
    _screenLayers = peerLayers;
    
    return self;
}

#pragma mark SCLLayout

+ (SCLLayout *)layoutForScreen:(SCLScreen *)screen
{
    if (!screen) {
        return nil;
    }
    
    SCLLayoutPool *pool = [SCLLayoutPool sharedInstance];
    
    return [pool layoutContainingScreens:@[screen]];
}

- (NSArray *)screens
{
    NSMutableArray *screens = [[NSMutableArray alloc] init];
    
    [self.constraints enumerateObjectsUsingBlock:^(SCLLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        [constraint.screens enumerateObjectsUsingBlock:^(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
            if (![screens containsObject:screen]) {
                [screens addObject:screen];
            }
        }];
    }];
    
    return [screens copy];
}

- (NSArray *)constraints
{
    return [_constraints copy];
}

- (NSArray *)constraintsContainingScreens:(NSArray *)screens
{
    if (screens.count == 0) {
        return @[];
    }
    
    NSArray *constraints = self.constraints;
    
    NSIndexSet *indexes = [constraints indexesOfObjectsPassingTest:^BOOL(SCLLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        for (SCLScreen *screen in screens) {
            if (![constraint.screens containsObject:screen]) {
                return NO;
            }
        }
        return YES;
    }];
    
    return [constraints objectsAtIndexes:indexes];
}

- (CGRect)boundsInScreen:(SCLScreen *)screen
{
    __block CGRect bounds = screen.bounds;
    
    [screen enumerateScreensUsingBlock:^(SCLScreen *screen, CGRect frame, BOOL *stop) {
        bounds = CGRectUnion(bounds, frame);
    }];
    
    return bounds;
}

- (CGPoint)convertPoint:(CGPoint)point fromScreen:(SCLScreen *)fromScreen toScreen:(SCLScreen *)toScreen
{
    CALayer *fromLayer = [self layerForScreen:fromScreen];
    CALayer *toLayer   = [self layerForScreen:toScreen];
    
    if (fromLayer && toLayer) {
        point = [fromLayer convertPoint:point toLayer:toLayer];
    }
    
    return point;
}

- (CGRect)convertRect:(CGRect)rect fromScreen:(SCLScreen *)fromScreen toScreen:(SCLScreen *)toScreen
{
    CALayer *fromLayer = [self layerForScreen:fromScreen];
    CALayer *toLayer   = [self layerForScreen:toScreen];
    
    if (fromLayer && toLayer) {
        rect = [fromLayer convertRect:rect toLayer:toLayer];
    }
    
    return rect;
}

- (CGVector)convertVector:(CGVector)vector fromScreen:(SCLScreen *)fromScreen toScreen:(SCLScreen *)toScreen
{
    CGPoint fromPoint1 = CGPointZero;
    CGPoint fromPoint2 = CGPointMake(vector.dx, vector.dy);
    
    CGPoint toPoint1 = [self convertPoint:fromPoint1 fromScreen:fromScreen toScreen:toScreen];
    CGPoint toPoint2 = [self convertPoint:fromPoint2 fromScreen:fromScreen toScreen:toScreen];
    
    return CGVectorMake(toPoint2.x - toPoint1.x, toPoint2.y - toPoint1.y);
}

- (CGFloat)convertAngle:(CGFloat)angle fromScreen:(SCLScreen *)fromScreen toScreen:(SCLScreen *)toScreen
{
    CALayer *fromLayer = [self layerForScreen:fromScreen];
    CALayer *toLayer   = [self layerForScreen:toScreen];
    
    if (fromLayer && toLayer) {
        CGFloat fromRotation = [[fromLayer valueForKeyPath:@"transform.rotation.z"] scl_CGFloatValue];
        CGFloat toRotation = [[toLayer valueForKeyPath:@"transform.rotation.z"] scl_CGFloatValue];
        angle = SCLAngleNormalize(angle + (fromRotation - toRotation));
    }
    
    return angle;
}

#pragma mark SCLLayout (SCLLayoutConstraintStack)

- (BOOL)canPushConstraint:(SCLLayoutConstraint *)constraint
{
    if (_constraints.count == 0) {
        return YES;
    }
    
    NSIndexSet *indexes = [constraint.screens indexesOfObjectsPassingTest:^BOOL(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
        return [self constraintsContainingScreens:@[screen]].count > 0;
    }];
    
    return indexes.count == 1;
}

- (void)pushConstraint:(SCLLayoutConstraint *)constraint
{
    NSAssert([self canPushConstraint:constraint], @"Cannot push %@", constraint);
    
    [_constraints addObject:constraint];
    
    [self updateLayout];
}

- (SCLLayoutConstraint *)popConstraint
{
    if (_constraints.count == 0) {
        return nil;
    }
    
    SCLLayoutConstraint *poppedConstraint = [_constraints lastObject];
    [_constraints removeLastObject];
    
    [self updateLayout];
    
    return poppedConstraint;
}

- (NSArray *)popToConstraint:(SCLLayoutConstraint *)constraint
{
    NSUInteger index = [_constraints indexOfObject:constraint];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSRange range = NSMakeRange(index + 1, _constraints.count - index - 1);
    NSArray *poppedConstraints = [_constraints subarrayWithRange:range];
    [_constraints removeObjectsInRange:range];
    
    [self updateLayout];
    
    return poppedConstraints;
}

#pragma mark SCLLayout (Internal)

- (CALayer *)layerForScreen:(SCLScreen *)screen
{
    return [_screenLayers objectForKey:screen];
}

- (void)updateLayout
{
    [_constraints enumerateObjectsUsingBlock:^(SCLLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        [constraint.items enumerateObjectsUsingBlock:^(SCLLayoutConstraintItem *item, NSUInteger idx, BOOL *stop) {
            SCLScreen *screen = item.screen;
            
            if ([_screenLayers objectForKey:screen]) {
                return;
            }
            
            static const CGFloat BASE_PPI = 163.0;
            
            CGRect bounds = screen.bounds;
            CGFloat scale = screen.ppi / screen.scale / BASE_PPI;
            
            CGPoint anchorPoint = item.anchor;
            anchorPoint.x /= bounds.size.width;
            anchorPoint.y /= bounds.size.height;
            
            CGPoint position = CGPointZero;
            CGFloat rotation = item.rotation;
            
            NSUInteger otherIndex = [constraint.items indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return ![obj isEqual:item];
            }];
            SCLLayoutConstraintItem *otherItem = constraint.items[otherIndex];
            SCLScreen *otherScreen = otherItem.screen;
            
            CALayer *otherLayer = [_screenLayers objectForKey:otherScreen];
            if (otherLayer) {
                position = [otherLayer convertPoint:otherItem.anchor toLayer:_rootLayer];
                rotation += [[otherLayer valueForKeyPath:@"transform.rotation.z"] scl_CGFloatValue];
                rotation -= otherItem.rotation;
                rotation = SCLAngleNormalize(rotation);
            }
            
            CALayer *layer = [[CALayer alloc] init];
            layer.bounds = bounds;
            layer.anchorPoint = anchorPoint;
            layer.position = position;
            [layer setValue:@(scale) forKey:@"transform.scale"];
            [layer setValue:@(rotation) forKeyPath:@"transform.rotation.z"];
            
            [_rootLayer addSublayer:layer];
            [_screenLayers setObject:layer forKey:screen];
        }];
    }];
    
    NSArray *screens = self.screens;
    [_screenLayers.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(SCLScreen *screen, CALayer *layer, BOOL *stop) {
        if (![screens containsObject:screen]) {
            [layer removeFromSuperlayer];
            [_screenLayers removeObjectForKey:screen];
        }
    }];
}

#pragma mark NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p; constraints=%lu; screens=[%@]>", NSStringFromClass([self class]), self, (unsigned long)_constraints.count, [[self.screens valueForKeyPath:@"name"] componentsJoinedByString:@", "]];
}

@end


NSNotificationName const SCLLayoutDidActivateConstraintsNotification = @"SCLLayoutDidActivateConstraintsNotification";
NSNotificationName const SCLLayoutDidDeactivateConstraintsNotification = @"SCLLayoutDidDeactivateConstraintsNotification";
NSString *const SCLLayoutConstraintsUserInfoKey = @"constraints";
NSString *const SCLLayoutAffectedScreensUserInfoKey = @"affectedScreens";


#pragma mark -
@implementation SCLLayout (SCLLayoutConstraintActivation)

+ (NSArray *)activateConstraints:(NSArray *)constraints
{
    if (!constraints || constraints.count == 0) {
        return nil;
    }
    
    SCLLayoutPool *pool = [SCLLayoutPool sharedInstance];
    
//    NSLog(@"will activate (constraints:%lu layouts:%@)", (unsigned long)pool.constraints.count, pool.layouts);
    NSArray *affectedScreens = [pool addConstraints:constraints].allObjects;
//    NSLog(@"did activate (constraints:%lu layouts:%@)", (unsigned long)pool.constraints.count, pool.layouts);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCLLayoutDidActivateConstraintsNotification object:nil userInfo:@{SCLLayoutConstraintsUserInfoKey: constraints, SCLLayoutAffectedScreensUserInfoKey: affectedScreens}];
    
    return affectedScreens;
}

+ (NSArray *)deactivateConstraints:(NSArray *)constraints
{
    if (!constraints || constraints.count == 0) {
        return nil;
    }
    
    SCLLayoutPool *pool = [SCLLayoutPool sharedInstance];
    
//    NSLog(@"will deactivate (constraints:%lu layouts:%@)", (unsigned long)pool.constraints.count, pool.layouts);
    NSArray *affectedScreens = [pool removeConstraints:constraints].allObjects;
//    NSLog(@"did deactivate (constraints:%lu, layouts:%@)", (unsigned long)pool.constraints.count, pool.layouts);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCLLayoutDidDeactivateConstraintsNotification object:nil userInfo:@{SCLLayoutConstraintsUserInfoKey: constraints, SCLLayoutAffectedScreensUserInfoKey: affectedScreens}];
    
    return affectedScreens;
}

@end


#pragma mark -
@implementation SCLLayoutConstraint (SCLLayoutConstraintActivation)

- (BOOL)isActive
{
    SCLLayoutPool *pool = [SCLLayoutPool sharedInstance];
    
    return [pool.constraints containsObject:self];
}

- (void)setActive:(BOOL)active
{
    if (active) {
        [SCLLayout activateConstraints:@[self]];
    }
    else {
        [SCLLayout deactivateConstraints:@[self]];
    }
}

@end
