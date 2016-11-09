//
//  SCLCoordinateSpace.h
//  ScreenLayout
//
//  Created by Jun on 12/9/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLScreen.h"


#define SCLCoordinateSpaceAvailable ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)


extern CGVector SCLConvertVectorBetweenCoordinateSpaces(CGVector vector, _Nullable id<UICoordinateSpace> from, _Nullable id<UICoordinateSpace> to) NS_AVAILABLE_IOS(8_0);
extern CGFloat SCLConvertAngleBetweenCoordinateSpaces(CGFloat angle, _Nullable id<UICoordinateSpace> from, _Nullable id<UICoordinateSpace> to) NS_AVAILABLE_IOS(8_0);


/**
 @abstract The SCLCoordinateSpace protocol extends UICoordinateSpace protocol (available in iOS 8) to support vector or angle conversions between coordinate spaces. See the UICoordinateSpace Protocol Reference for more detail.
 */
@protocol SCLCoordinateSpace <UICoordinateSpace>

- (CGVector)convertVector:(CGVector)vector toCoordinateSpace:(nullable id<UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
- (CGVector)convertVector:(CGVector)vector fromCoordinateSpace:(nullable id<UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
- (CGFloat)convertAngle:(CGFloat)angle toCoordinateSpace:(nullable id<UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
- (CGFloat)convertAngle:(CGFloat)angle fromCoordinateSpace:(nullable id<UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);

@end

/**
 @abstract The SCLScreenCoordinateSpaceSupports category implements SCLCoordinateSpace (including UICoordinateSpace) protocol methods for SCLScreen objects. That allows direct SCLScreen to UIView geometry conversions.
 */
@interface SCLScreen (SCLScreenCoordinateSpaceSupports) <SCLCoordinateSpace>
@end
