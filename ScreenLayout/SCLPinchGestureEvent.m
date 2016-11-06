//
//  SCLPinchGestureEvent.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLPinchGestureEvent.h"
#import "SCLCodingUtilities.h"
#import "SCLGeometry.h"
#import "SCLScreen.h"


#pragma mark -
@implementation SCLPinchGestureEvent

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dateCreated = [[NSDate alloc] init];
    
    return self;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [_dateCreated isEqual:[object dateCreated]];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return _dateCreated.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p; location=%@; direction=%f; created:%@; received:%@>", NSStringFromClass([self class]), self, NSStringFromCGPoint(self.location), self.direction, self.dateCreated, self.dateReceived];
}

#pragma mark MSCPinchGestureEvent

- (double)direction
{
    return SCLAngleNormalize(SCLAngleFromVector(_vector));
}

- (CGPoint)anchorPointInScreen:(SCLScreen *)screen ignoresMargins:(BOOL)ignoresMargins
{
    CGRect bounds = screen.bounds;
    
    if (!ignoresMargins) {
        SCLEdgeInsets margins = screen.margins;
        bounds.origin.x -= margins.left * screen.ppi / screen.scale;
        bounds.origin.y -= margins.top * screen.ppi / screen.scale;
        bounds.size.width += (margins.left + margins.right) * screen.ppi / screen.scale;
        bounds.size.height += (margins.top + margins.bottom) * screen.ppi / screen.scale;
    }
    
    CGPoint anchorPoint = _location;
    
    if (fabs(_vector.dx) > fabs(_vector.dy)) {
        if (_vector.dx > 0) {
            anchorPoint.x = CGRectGetMaxX(bounds);
        }
        else {
            anchorPoint.x = CGRectGetMinX(bounds);
        }
    }
    else {
        if (_vector.dy > 0) {
            anchorPoint.y = CGRectGetMaxY(bounds);
        }
        else {
            anchorPoint.y = CGRectGetMinY(bounds);
        }
    }
    
    return anchorPoint;
}

- (CGPoint)edgeIntersectionInScreen:(SCLScreen *)screen ignoresMargins:(BOOL)ignoresMargins
{
    CGRect bounds = screen.bounds;
    
    if (!ignoresMargins) {
        SCLEdgeInsets margins = screen.margins;
        bounds.origin.x -= margins.left * screen.ppi / screen.scale;
        bounds.origin.y -= margins.top * screen.ppi / screen.scale;
        bounds.size.width += (margins.left + margins.right) * screen.ppi / screen.scale;
        bounds.size.height += (margins.top + margins.bottom) * screen.ppi / screen.scale;
    }
    
    CGVector deltaToEdge = CGVectorMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    if (_vector.dx > 0) {
        deltaToEdge.dx = CGRectGetMaxX(bounds) - _location.x;
    }
    else if (_vector.dx < 0) {
        deltaToEdge.dx = CGRectGetMinX(bounds) - _location.x;
    }
    
    if (_vector.dy > 0) {
        deltaToEdge.dy = CGRectGetMaxY(bounds) - _location.y;
    }
    else if (_vector.dy < 0) {
        deltaToEdge.dy = CGRectGetMinY(bounds) - _location.y;
    }
    
    CGPoint intersection = _location;
    
    CGFloat vectorRatio = _vector.dx / _vector.dy;
    static const CGFloat ratioThreshold = 10;
    
    if (deltaToEdge.dx == CGFLOAT_MAX || fabs(vectorRatio) < 1.0 / ratioThreshold) {
        intersection.y += deltaToEdge.dy;
    }
    else if (deltaToEdge.dy == CGFLOAT_MAX || fabs(vectorRatio) > ratioThreshold) {
        intersection.x += deltaToEdge.dx;
    }
    else {
        CGFloat deltaRatio  = deltaToEdge.dx / deltaToEdge.dy;
        
        if (fabs(vectorRatio) > fabs(deltaRatio)) {
            intersection.x += deltaToEdge.dx;
            intersection.y += deltaToEdge.dx / vectorRatio;
        }
        else {
            intersection.x += deltaToEdge.dy * vectorRatio;
            intersection.y += deltaToEdge.dy;
        }
    }
    
    return intersection;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) clone = [[[self class] allocWithZone:zone] init];
    
    clone.location     = _location;
    clone.vector       = _vector;
    clone.attitude     = _attitude;
    clone.dateCreated  = _dateCreated;
    clone.dateReceived = _dateReceived;
    
    return clone;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _location     = [aDecoder scl_decodeCGPointForSelector:@selector(location)];
    _vector       = [aDecoder scl_decodeCGVectorForSelector:@selector(vector)];
    _attitude     = [aDecoder scl_decodeObjectOfClass:[CMAttitude class] forSelector:@selector(attitude)];
    _dateCreated  = [aDecoder scl_decodeObjectOfClass:[NSDate class] forSelector:@selector(dateCreated)];
    _dateReceived = [aDecoder scl_decodeObjectOfClass:[NSDate class] forSelector:@selector(dateReceived)];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder scl_encodeCGPoint:_location forSelector:@selector(location)];
    [aCoder scl_encodeCGVector:_vector forSelector:@selector(vector)];
    [aCoder scl_encodeObject:_attitude forSelector:@selector(attitude)];
    [aCoder scl_encodeObject:_dateCreated forSelector:@selector(dateCreated)];
    [aCoder scl_encodeObject:_dateReceived forSelector:@selector(dateReceived)];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
