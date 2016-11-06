//
//  SCLLayoutPool.m
//  ScreenLayout
//
//  Created by Jun on 12/5/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayoutPool.h"
#import "SCLLayoutConstraint.h"
#import "SCLLayout+ConstraintStack.h"


#pragma mark -
@implementation SCLLayoutPool {
    NSMutableSet *_constraints;
    NSMutableSet *_layouts;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _constraints = [[NSMutableSet alloc] init];
    _layouts = [[NSMutableSet alloc] init];
    
    return self;
}

#pragma mark SCLLayoutPool

+ (instancetype)sharedInstance
{
    static SCLLayoutPool *pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[SCLLayoutPool alloc] init];
    });
    
    return pool;
}

- (NSSet *)screens
{
    NSMutableSet *screens = [[NSMutableSet alloc] init];
    
    for (SCLLayoutConstraint *constraint in _constraints) {
        [screens addObjectsFromArray:constraint.screens];
    }
    
    return screens;
}

- (NSSet *)constraintsContainingScreens:(NSArray *)screens
{
    if ([screens count] == 0) {
        return nil;
    }
    
    NSSet *constraints = [_constraints objectsPassingTest:^BOOL(SCLLayoutConstraint *constraint, BOOL *stop) {
        NSArray *screensInConstraint = constraint.screens;
        NSIndexSet *indexes = [screens indexesOfObjectsPassingTest:^BOOL(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
            return [screensInConstraint containsObject:screen];
        }];
        return (indexes.count == screens.count);
    }];
    
    return constraints;
}

- (NSSet *)addConstraints:(NSArray *)constraints
{
    NSMutableSet *updatedScreens = [[NSMutableSet alloc] init];
    
    for (SCLLayoutConstraint *constraint in constraints) {
        NSSet *screens = [self addConstraint:constraint];
        [updatedScreens unionSet:screens];
    }
    
    return updatedScreens;
}

- (NSSet *)removeConstraints:(NSArray *)constraints
{
    NSMutableSet *updatedScreens = [[NSMutableSet alloc] init];
    
    for (SCLLayoutConstraint *constraint in constraints) {
        NSSet *screens = [self removeConstraint:constraint];
        [updatedScreens unionSet:screens];
    }
    
    return updatedScreens;
}

- (SCLLayout *)layoutContainingScreens:(NSArray *)screens
{
    if (screens.count == 0) {
        return nil;
    }
    
    for (SCLLayout *layout in _layouts) {
        NSArray *screensInLayout = layout.screens;
        NSIndexSet *indexes = [screens indexesOfObjectsPassingTest:^BOOL(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
            return [screensInLayout containsObject:screen];
        }];
        if (indexes.count == screens.count) {
            return layout;
        }
    }
    
    return nil;
}

- (SCLLayout *)layoutContainingConstraint:(SCLLayoutConstraint *)constraint
{
    if (!constraint) {
        return nil;
    }
    
    for (SCLLayout *layout in _layouts) {
        if ([layout.constraints containsObject:constraint]) {
            return layout;
        }
    }
    
    return nil;
}

#pragma mark SCLLayoutPool (Internal)

- (NSSet *)addConstraint:(SCLLayoutConstraint *)constraint
{
    if ([_constraints containsObject:constraint]) {
        return nil;
    }
    
    NSMutableSet *updatedScreens = [[NSMutableSet alloc] init];
    
    NSSet *conflicts = [self constraintsContainingScreens:constraint.screens];
    if (conflicts.count > 0) {
        [conflicts enumerateObjectsUsingBlock:^(SCLLayoutConstraint *conflict, BOOL *stop) {
            NSSet *screens = [self removeConstraint:conflict];
            [updatedScreens unionSet:screens];
        }];
    }
    
    NSSet *compatibleLayouts = [_layouts objectsPassingTest:^BOOL(SCLLayout *aLayout, BOOL *stop) {
        return [aLayout canPushConstraint:constraint];
    }];
    
    SCLLayout *layout = nil;
    
    if (compatibleLayouts.count == 0) {
        layout = [[SCLLayout alloc] init];
        [layout pushConstraint:constraint];
        [_layouts addObject:layout];
    }
    else {
        if (compatibleLayouts.count == 1) {
            layout = [compatibleLayouts anyObject];
        }
        else {
            layout = [[compatibleLayouts objectsPassingTest:^BOOL(SCLLayout *aLayout, BOOL *stop) {
                return [aLayout.screens containsObject:constraint.screens.firstObject];
            }] anyObject];
        }
        [layout pushConstraint:constraint];
        
        NSMutableSet *layoutsToMerge = [compatibleLayouts mutableCopy];
        [layoutsToMerge removeObject:layout];
        
        for (SCLLayout *aLayout in layoutsToMerge) {
            NSMutableSet *constraintsToMerge = [[NSMutableSet alloc] initWithArray:aLayout.constraints];
            while (constraintsToMerge.count > 0) {
                NSSet *mergedConstraits = [constraintsToMerge objectsPassingTest:^BOOL(SCLLayoutConstraint *aConstraint, BOOL *stop) {
                    if ([layout canPushConstraint:aConstraint]) {
                        [layout pushConstraint:aConstraint];
                        return YES;
                    }
                    return NO;
                }];
                if (mergedConstraits.count == 0) {
                    break;
                }
                [constraintsToMerge minusSet:mergedConstraits];
            }
            NSAssert(constraintsToMerge.count == 0, @"Failed to merge %@", aLayout);
            [_layouts removeObject:aLayout];
        }
    }
    
    [updatedScreens addObjectsFromArray:layout.screens];
    
    [_constraints addObject:constraint];
    
    return updatedScreens;
}

- (NSSet *)removeConstraint:(SCLLayoutConstraint *)constraint
{
    if (![_constraints containsObject:constraint]) {
        return nil;
    }
    
    [_constraints removeObject:constraint];
    
    NSMutableSet *updatedScreens = [[NSMutableSet alloc] init];
    
    SCLLayout *layout = [self layoutContainingConstraint:constraint];
    if (!layout) {
        return nil;
    }
    
    [updatedScreens addObjectsFromArray:layout.screens];
    
    NSArray *poppedConstraints = [layout popToConstraint:constraint];
    [layout popConstraint];
    
    if (layout.constraints.count == 0) {
        [_layouts removeObject:layout];
    }
    
    for (SCLLayoutConstraint *poppedConstraint in poppedConstraints) {
        [_constraints removeObject:poppedConstraint];
        NSSet *screens = [self addConstraint:poppedConstraint];
        [updatedScreens unionSet:screens];
    }
    
    return updatedScreens;
}

@end
