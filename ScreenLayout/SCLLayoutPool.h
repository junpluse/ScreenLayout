//
//  SCLLayoutPool.h
//  ScreenLayout
//
//  Created by Jun on 12/5/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"

@class SCLLayout;
@class SCLLayoutConstraint;


@interface SCLLayoutPool : NSObject

+ (instancetype)sharedInstance;

@property (readonly, nonatomic) NSSet *screens;

@property (readonly, nonatomic) NSSet *constraints;
- (NSSet *)constraintsContainingScreens:(NSArray *)screens;
- (NSSet *)addConstraints:(NSArray *)constraints;
- (NSSet *)removeConstraints:(NSArray *)constraints;

@property (readonly, nonatomic) NSSet *layouts;
- (SCLLayout *)layoutContainingScreens:(NSArray *)screens;
- (SCLLayout *)layoutContainingConstraint:(SCLLayoutConstraint *)constraint;

@end
