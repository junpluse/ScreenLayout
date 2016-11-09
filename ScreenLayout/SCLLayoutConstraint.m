//
//  SCLLayoutConstraint.m
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayoutConstraint.h"
#import "SCLLayoutPool.h"
#import "SCLCodingUtilities.h"
#import "SCLScreen.h"


#pragma mark -
@interface SCLLayoutConstraint ()

@property (readonly, nonatomic, copy) NSUUID *uuid;

@end


#pragma mark -
@implementation SCLLayoutConstraint

#pragma mark SCLLayoutConstraint

- (instancetype)initWithItems:(NSArray *)items
{
    NSAssert(items.count > 1, @"The items.count must be greather than 1");
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _uuid = [[NSUUID alloc] init];
    _items = [items copy];
    
    return self;
}

- (NSArray *)screens
{
    NSMutableArray *screens = [[NSMutableArray alloc] init];
    
    for (SCLLayoutConstraintItem *item in _items) {
        if (![screens containsObject:item.screen]) {
            [screens addObject:item.screen];
        }
    }
    
    return [screens copy];
}

- (NSString *)identifier
{
    return [_uuid UUIDString];
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [_uuid isEqual:[object uuid]];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return _uuid.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p; screens=[%@]>", NSStringFromClass([self class]), self, [[self.screens valueForKeyPath:@"name"] componentsJoinedByString:@", "]];
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *items = [aDecoder scl_decodeArrayOfObjectsOfClass:[SCLLayoutConstraintItem class] forSelector:@selector(items)];

    self = [self initWithItems:items];
    if (!self) {
        return nil;
    }
    
    _uuid = [aDecoder scl_decodeObjectOfClass:[NSUUID class] forSelector:@selector(uuid)];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder scl_encodeObject:_uuid forSelector:@selector(uuid)];
    [aCoder scl_encodeObject:_items forSelector:@selector(items)];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end


#pragma mark -
@implementation SCLLayoutConstraintItem

#pragma mark SCLLayoutConstraintItem

- (instancetype)initWithScreen:(SCLScreen *)screen anchor:(CGPoint)anchor rotation:(CGFloat)rotation
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _screen = [screen copy];
    _anchor = anchor;
    _rotation = rotation;
    
    return self;
}

#pragma mark NSObject

- (BOOL)isEqual:(SCLLayoutConstraintItem *)object
{
    if ([object isKindOfClass:[self class]]) {
        if (![_screen isEqual:object.screen]) {
            return NO;
        }
        if (!CGPointEqualToPoint(_anchor, object.anchor)) {
            return NO;
        }
        if (_rotation != object.rotation) {
            return NO;
        }
        return YES;
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    NSUInteger hash1 = _screen.hash;
    NSUInteger hash2 = [NSData dataWithBytesNoCopy:&_anchor length:sizeof(CGPoint)].hash;
    NSUInteger hash3 = (NSUInteger)round(_rotation);
    
    return hash1 ^ hash2 ^ hash3;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    SCLScreen *screen = [aDecoder scl_decodeObjectOfClass:[SCLScreen class] forSelector:@selector(screen)];
    CGPoint anchor = [aDecoder scl_decodeCGPointForSelector:@selector(anchor)];
    CGFloat rotation = [aDecoder scl_decodeCGFloatForSelector:@selector(rotation)];

    return [self initWithScreen:screen anchor:anchor rotation:rotation];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder scl_encodeObject:_screen forSelector:@selector(screen)];
    [aCoder scl_encodeCGPoint:_anchor forSelector:@selector(anchor)];
    [aCoder scl_encodeCGFloat:_rotation forSelector:@selector(rotation)];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
