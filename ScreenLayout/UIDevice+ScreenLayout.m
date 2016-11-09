//
//  UIDevice+ScreenLayout.m
//  ScreenLayout
//
//  Created by Jun on 11/28/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "UIDevice+ScreenLayout.h"
#include <sys/types.h>
#include <sys/sysctl.h>


typedef struct SCLDeviceScreenSpecs {
    CGFloat ppi;
    SCLEdgeInsets margins;
} SCLDeviceScreenSpecs;


#pragma mark -
@implementation UIDevice (ScreenLayout)

//
// Apple Model Identifier
// http://www.everyi.com/by-identifier/ipod-iphone-ipad-specs-by-model-identifier.html
//

- (NSString *)scl_deviceModelIdentifier
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *identifier = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return identifier;
}

- (SCLDeviceScreenSpecs)scl_screenSpecs
{
    SCLDeviceScreenSpecs specs;
    specs.ppi = 163.0;
    specs.margins = SCLEdgeInsetsZero;
    
    NSString *identifier = self.scl_deviceModelIdentifier;
    
    NSRange decimalRange = [identifier rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
    if (decimalRange.location < identifier.length - 1) {
        identifier = [identifier substringToIndex:decimalRange.location + 1];
    }
    
    int digit1 = [[identifier substringWithRange:NSMakeRange(identifier.length - 3, 1)] intValue];
    int digit2 = [[identifier substringWithRange:NSMakeRange(identifier.length - 1, 1)] intValue];
    
    if ([identifier hasPrefix:@"iPad"]) {
        if (digit1 == 1) {
            // iPad (1,1)
            specs.ppi            = 132;
            specs.margins.top    = 0.90;
            specs.margins.left   = 0.83;
            specs.margins.bottom = 0.90;
            specs.margins.right  = 0.83;
        }
        else if (digit1 == 2 && digit2 <= 4) {
            // iPad 2 (2,1-4)
            specs.ppi            = 132;
            specs.margins.top    = 0.87;
            specs.margins.left   = 0.75;
            specs.margins.bottom = 0.87;
            specs.margins.right  = 0.75;
        }
        else if (digit1 == 2 && digit2 <= 7) {
            // iPad mini (2,5-7)
            specs.ppi            = 163;
            specs.margins.top    = 0.79;
            specs.margins.left   = 0.29;
            specs.margins.bottom = 0.79;
            specs.margins.right  = 0.29;
        }
        else if (digit1 == 3 && digit2 <= 3) {
            // iPad 3rd Gen (3,1-3)
            specs.ppi            = 264;
            specs.margins.top    = 0.87;
            specs.margins.left   = 0.75;
            specs.margins.bottom = 0.87;
            specs.margins.right  = 0.75;
        }
        else if (digit1 == 3 && digit2 <= 6) {
            // iPad 4th Gen (3,3-6)
            specs.ppi            = 264;
            specs.margins.top    = 0.87;
            specs.margins.left   = 0.75;
            specs.margins.bottom = 0.87;
            specs.margins.right  = 0.75;
        }
        else if (digit1 == 4 && digit2 <= 3) {
            // iPad Air (4,1-3)
            specs.ppi            = 264;
            specs.margins.top    = 0.82;
            specs.margins.left   = 0.39;
            specs.margins.bottom = 0.82;
            specs.margins.right  = 0.39;
        }
        else if (digit1 == 4 && digit2 <= 6) {
            // iPad mini 2 (4,4-6)
            specs.ppi            = 326;
            specs.margins.top    = 0.79;
            specs.margins.left   = 0.29;
            specs.margins.bottom = 0.79;
            specs.margins.right  = 0.29;
        }
        else if (digit1 == 4 && digit2 <= 8) {
            // iPad mini 3 (4,7-8)
            specs.ppi            = 326;
            specs.margins.top    = 0.79;
            specs.margins.left   = 0.29;
            specs.margins.bottom = 0.79;
            specs.margins.right  = 0.29;
        }
        else if (digit1 == 5 && digit2 >= 3 && digit2 <= 4) {
            // iPad Air 2 (5,3-4)
            specs.ppi            = 264;
            specs.margins.top    = 0.82;
            specs.margins.left   = 0.39;
            specs.margins.bottom = 0.82;
            specs.margins.right  = 0.39;
        }
        else if (digit1 == 6 && digit2 >= 3 && digit2 <= 4) {
            // iPad Pro 9.7 inch (6,3-4)
            specs.ppi            = 264;
            specs.margins.top    = 0.82;
            specs.margins.left   = 0.39;
            specs.margins.bottom = 0.82;
            specs.margins.right  = 0.39;
        }
    }
    else if ([identifier hasPrefix:@"iPhone"]) {
        if (digit1 == 1 && digit2 == 1) {
            // iPhone (1,1)
        }
        else if (digit1 == 1 && digit2 <= 2) {
            // iPhone 3G (1,2)
        }
        else if (digit1 == 2) {
            // iPhone 3GS (2,x)
        }
        else if (digit1 == 3) {
            // iPhone 4 (3,x)
            specs.ppi            = 326;
            specs.margins.top    = 0.78;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.78;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 4) {
            // iPhone 4S (4,x)
            specs.ppi            = 326;
            specs.margins.top    = 0.78;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.78;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 5 && digit2 <= 2) {
            // iPhone 5 (5,1-2)
            specs.ppi            = 326;
            specs.margins.top    = 0.69;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.69;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 5 && digit2 <= 4) {
            // iPhone 5c (5,3-4)
            specs.ppi            = 326;
            specs.margins.top    = 0.70;
            specs.margins.left   = 0.18;
            specs.margins.bottom = 0.70;
            specs.margins.right  = 0.18;
        }
        else if (digit1 == 6) {
            // iPhone 5s (6,x)
            specs.ppi            = 326;
            specs.margins.top    = 0.69;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.69;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 7 && digit2 <= 1) {
            // iPhone 6 Plus (7,1)
            specs.ppi            = 401;
            specs.margins.top    = 0.72;
            specs.margins.left   = 0.18;
            specs.margins.bottom = 0.72;
            specs.margins.right  = 0.18;
        }
        else if (digit1 == 7 && digit2 <= 2) {
            // iPhone 6 (7,2)
            specs.ppi            = 326;
            specs.margins.top    = 0.67;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.67;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 8 && digit2 == 1) {
            // iPhone 6s (8,1)
            specs.ppi            = 326;
            specs.margins.top    = 0.67;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.67;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 8 && digit2 <= 2) {
            // iPhone 6s Plus (8,2)
            specs.ppi            = 401;
            specs.margins.top    = 0.72;
            specs.margins.left   = 0.18;
            specs.margins.bottom = 0.72;
            specs.margins.right  = 0.18;
        }
        else if (digit1 == 8 && digit2 == 4) {
            // iPhone SE (8,4)
            specs.ppi            = 326;
            specs.margins.top    = 0.69;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.69;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 9 && (digit2 == 1 || digit2 == 3)) {
            // iPhone 7 (9,1 or 9,3)
            specs.ppi            = 326;
            specs.margins.top    = 0.67;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.67;
            specs.margins.right  = 0.17;
        }
        else if (digit1 == 9 && (digit2 == 2 || digit2 == 4)) {
            // iPhone 7 Plus (9,2 or 9,4)
            specs.ppi            = 401;
            specs.margins.top    = 0.72;
            specs.margins.left   = 0.18;
            specs.margins.bottom = 0.72;
            specs.margins.right  = 0.18;
        }
    }
    else if ([identifier hasPrefix:@"iPod"]) {
        if (digit1 == 1) {
            // iPod touch 1st Gen (1,1)
        }
        else if (digit1 == 2) {
            // iPod touch 2nd Gen (2,1)
        }
        else if (digit1 == 3) {
            // iPod touch 3rd Gen (3,1)
        }
        else if (digit1 == 4) {
            // iPod touch 4th Gen (4,1)
        }
        else if (digit1 == 5 || digit1 == 6) {
            // iPod touch 5th Gen (5,1) or 6th Gen (6,1)
            specs.ppi            = 326;
            specs.margins.top    = 0.69;
            specs.margins.left   = 0.17;
            specs.margins.bottom = 0.69;
            specs.margins.right  = 0.17;
        }
    }
    
    return specs;
}

- (CGFloat)scl_screenResolution
{
    return self.scl_screenSpecs.ppi;
}

- (SCLEdgeInsets)scl_screenMargins
{
    return self.scl_screenSpecs.margins;
}

@end
