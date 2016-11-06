//
//  SCLScreen.m
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLScreen.h"
#import "SCLLayout.h"
#import "SCLCodingUtilities.h"
#import <MultipeerConnectivity/MCPeerID.h>

#if TARGET_OS_IPHONE
#import "UIDevice+ScreenLayout.h"
#endif


NSString *const SCLScreenPeerIDUserDefaultsKey = @"com.screenlayout.mainscreen.peer";


#pragma mark -
@implementation SCLScreen

#pragma mark SCLScreen

+ (SCLScreen *)mainScreen
{
    static SCLScreen *mainScreen;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = nil;
        CGRect bounds = CGRectZero;
        CGFloat scale = 0.0;
        CGFloat ppi = 0.0;
        SCLEdgeInsets margins = SCLEdgeInsetsZero;
        
#if TARGET_OS_IPHONE
        UIScreen *screen = [UIScreen mainScreen];
        if ([screen respondsToSelector:@selector(fixedCoordinateSpace)]) {
            bounds = screen.fixedCoordinateSpace.bounds;
        }
        else {
            bounds = screen.bounds;
        }
        if ([screen respondsToSelector:@selector(nativeScale)]) {
            scale = screen.nativeScale;
        }
        else {
            scale = screen.scale;
        }
        
        UIDevice *device = [UIDevice currentDevice];
        name = device.name;
        ppi = device.scl_screenResolution;
        margins = device.scl_screenMargins;
#else
        NSScreen *screen = [NSScreen mainScreen];
        bounds = screen.frame;
        scale = screen.backingScaleFactor;
        
        NSHost *host = [NSHost currentHost];
        name = host.name;
#endif
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *peerData = [defaults dataForKey:SCLScreenPeerIDUserDefaultsKey];
        MCPeerID *peerID = nil;
        
        MCPeerID *(^createNewPeerID)(void) = ^MCPeerID *(void) {
            MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:name];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:peerID];
            [defaults setObject:data forKey:SCLScreenPeerIDUserDefaultsKey];
            [defaults synchronize];
            return peerID;
        };
        
        if (peerData) {
            peerID = [NSKeyedUnarchiver unarchiveObjectWithData:peerData];
            if (![peerID.displayName isEqual:name]) {
                peerID = createNewPeerID();
            }
        }
        else {
            peerID = createNewPeerID();
        }
        
        mainScreen = [[SCLScreen alloc] initWithPeer:peerID bounds:bounds scale:scale ppi:ppi margins:margins];
    });
    
    return mainScreen;
}

- (instancetype)initWithName:(NSString *)name bounds:(CGRect)bounds scale:(CGFloat)scale ppi:(CGFloat)ppi margins:(SCLEdgeInsets)margins
{
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:name];
    
    return [self initWithPeer:peerID bounds:bounds scale:scale ppi:ppi margins:margins];
}

- (instancetype)initWithPeer:(MCPeerID *)peerID bounds:(CGRect)bounds scale:(CGFloat)scale ppi:(CGFloat)ppi margins:(SCLEdgeInsets)margins
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _peerID  = [peerID copy];
    _bounds  = bounds;
    _scale   = scale;
    _ppi     = ppi;
    _margins = margins;
    
    return self;
}

- (NSString *)name
{
    return _peerID.displayName;
}

- (SCLLayout *)layout
{
    return [SCLLayout layoutForScreen:self];
}

- (NSArray *)constraints
{
    return [self.layout constraintsContainingScreens:@[self]] ?: @[];
}

- (NSArray *)connectedScreens
{
    NSArray *screens = self.layout.screens;
    
    NSIndexSet *indexes = [screens indexesOfObjectsPassingTest:^BOOL(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
        return ![screen isEqual:self];
    }];
    
    return [screens objectsAtIndexes:indexes] ?: @[];
}

- (CGRect)rectForScreen:(SCLScreen *)screen
{
    return [self.layout convertRect:screen.bounds fromScreen:screen toScreen:self];
}

- (CGPoint)convertPoint:(CGPoint)point fromScreen:(SCLScreen *)screen
{
    return [self.layout convertPoint:point fromScreen:screen toScreen:self];
}

- (CGPoint)convertPoint:(CGPoint)point toScreen:(SCLScreen *)screen
{
    return [self.layout convertPoint:point fromScreen:self toScreen:screen];
}

- (CGRect)convertRect:(CGRect)rect fromScreen:(SCLScreen *)screen
{
    return [self.layout convertRect:rect fromScreen:screen toScreen:self];
}

- (CGRect)convertRect:(CGRect)rect toScreen:(SCLScreen *)screen
{
    return [self.layout convertRect:rect fromScreen:self toScreen:screen];
}

- (CGVector)convertVector:(CGVector)vector fromScreen:(SCLScreen *)screen
{
    return [self.layout convertVector:vector fromScreen:screen toScreen:self];
}

- (CGVector)convertVector:(CGVector)vector toScreen:(SCLScreen *)screen
{
    return [self.layout convertVector:vector fromScreen:self toScreen:screen];
}

- (CGFloat)convertAngle:(CGFloat)angle fromScreen:(SCLScreen *)screen
{
    return [self.layout convertAngle:angle fromScreen:screen toScreen:self];
}

- (CGFloat)convertAngle:(CGFloat)angle toScreen:(SCLScreen *)screen
{
    return [self.layout convertAngle:angle fromScreen:self toScreen:screen];
}

- (NSArray *)screensAtPoint:(CGPoint)point
{
    return [self screensPassingTest:^BOOL(SCLScreen *screen, CGRect frame, BOOL *stop) {
        return CGRectContainsPoint(frame, point);
    }];
}

- (NSArray *)screensIntersectRect:(CGRect)rect
{
    return [self screensPassingTest:^BOOL(SCLScreen *screen, CGRect frame, BOOL *stop) {
        return CGRectIntersectsRect(frame, rect);
    }];
}

- (void)enumerateScreensUsingBlock:(void(^)(SCLScreen *screen, CGRect frame, BOOL *stop))block
{
    [self.connectedScreens enumerateObjectsUsingBlock:^(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
        CGRect frame = [self convertRect:screen.bounds fromScreen:screen];
        return block(screen, frame, stop);
    }];
}

- (NSArray *)screensPassingTest:(BOOL(^)(SCLScreen *screen, CGRect frame, BOOL *stop))predicate
{
    NSArray *screens = self.connectedScreens;
    
    NSIndexSet *indexes = [screens indexesOfObjectsPassingTest:^BOOL(SCLScreen *screen, NSUInteger idx, BOOL *stop) {
        CGRect frame = [self convertRect:screen.bounds fromScreen:screen];
        return predicate(screen, frame, stop);
    }];
    
    return [screens objectsAtIndexes:indexes];
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [_peerID isEqual:[object peerID]];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return _peerID.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p; name=%@>", NSStringFromClass([self class]), self, self.name];
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _bounds  = [aDecoder scl_decodeCGRectForSelector:@selector(bounds)];
    _scale   = [aDecoder scl_decodeCGFloatForSelector:@selector(scale)];
    _ppi     = [aDecoder scl_decodeCGFloatForSelector:@selector(ppi)];
    _margins = [aDecoder scl_decodeSCLEdgeInsetsForSelector:@selector(margins)];
    _peerID  = [aDecoder scl_decodeObjectOfClass:[MCPeerID class] forSelector:@selector(peerID)];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder scl_encodeCGRect:_bounds forSelector:@selector(bounds)];
    [aCoder scl_encodeCGFloat:_scale forSelector:@selector(scale)];
    [aCoder scl_encodeCGFloat:_ppi forSelector:@selector(ppi)];
    [aCoder scl_encodeSCLEdgeInsets:_margins forSelector:@selector(margins)];
    [aCoder scl_encodeObject:_peerID forSelector:@selector(peerID)];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
