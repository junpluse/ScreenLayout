//
//  UIDevice+ScreenLayout.h
//  ScreenLayout
//
//  Created by Jun on 11/28/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"


@interface UIDevice (ScreenLayout)

@property (readonly, nonatomic) CGFloat scl_screenResolution;
@property (readonly, nonatomic) SCLEdgeInsets scl_screenMargins;

@end
