//
//  SCLLayout+ConstraintStack.h
//  ScreenLayout
//
//  Created by Jun on 12/4/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayout.h"


@interface SCLLayout (SCLLayoutConstraintStack)

- (BOOL)canPushConstraint:(SCLLayoutConstraint *)constraint;
- (void)pushConstraint:(SCLLayoutConstraint *)constraint;
- (SCLLayoutConstraint *)popConstraint;
- (NSArray *)popToConstraint:(SCLLayoutConstraint *)constraint;

@end
