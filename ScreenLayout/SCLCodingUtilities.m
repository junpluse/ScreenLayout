//
//  SCLCodingUtilities.m
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLCodingUtilities.h"


NSDictionary *SCLDictionaryFromPoint(CGPoint point)
{
    return @{
        @"x": @(point.x),
        @"y": @(point.y)
    };
}

NSDictionary *SCLDictionaryFromVector(CGVector vector)
{
    return @{
        @"dx": @(vector.dx),
        @"dy": @(vector.dy)
    };
}

NSDictionary *SCLDictionaryFromSize(CGSize size)
{
    return @{
        @"width": @(size.width),
        @"height": @(size.height)
    };
}

NSDictionary *SCLDictionaryFromRect(CGRect rect)
{
    return @{
        @"origin": SCLDictionaryFromPoint(rect.origin),
        @"size": SCLDictionaryFromSize(rect.size)
    };
}

NSDictionary *SCLDictionaryFromAffineTransform(CGAffineTransform transform)
{
    return @{
        @"a": @(transform.a),
        @"b": @(transform.b),
        @"c": @(transform.c),
        @"d": @(transform.d),
        @"tx": @(transform.tx),
        @"ty": @(transform.ty)
    };
}

NSDictionary *SCLDictionaryFromEdgeInsets(SCLEdgeInsets insets)
{
    return @{
        @"top": @(insets.top),
        @"left": @(insets.left),
        @"bottom": @(insets.bottom),
        @"right": @(insets.right)
    };
}

CGPoint SCLPointFromDictionary(NSDictionary *dictionary)
{
    CGPoint point;
    point.x = [dictionary[@"x"] scl_CGFloatValue];
    point.y = [dictionary[@"y"] scl_CGFloatValue];
    return point;
}

CGVector SCLVectorFromDictionary(NSDictionary *dictionary)
{
    CGVector vector;
    vector.dx = [dictionary[@"dx"] scl_CGFloatValue];
    vector.dy = [dictionary[@"dy"] scl_CGFloatValue];
    return vector;
}

CGSize SCLSizeFromDictionary(NSDictionary *dictionary)
{
    CGSize size;
    size.width = [dictionary[@"width"] scl_CGFloatValue];
    size.height = [dictionary[@"height"] scl_CGFloatValue];
    return size;
}

CGRect SCLRectFromDictionary(NSDictionary *dictionary)
{
    CGRect rect;
    rect.origin = SCLPointFromDictionary(dictionary[@"origin"]);
    rect.size = SCLSizeFromDictionary(dictionary[@"size"]);
    return rect;
}

CGAffineTransform SCLAffineTransformFromDictionary(NSDictionary *dictionary)
{
    CGAffineTransform transform;
    transform.a = [dictionary[@"a"] scl_CGFloatValue];
    transform.b = [dictionary[@"b"] scl_CGFloatValue];
    transform.c = [dictionary[@"c"] scl_CGFloatValue];
    transform.d = [dictionary[@"d"] scl_CGFloatValue];
    transform.tx = [dictionary[@"tx"] scl_CGFloatValue];
    transform.ty = [dictionary[@"ty"] scl_CGFloatValue];
    return transform;
}

SCLEdgeInsets SCLEdgeInsetsFromDictionary(NSDictionary *dictionary)
{
    SCLEdgeInsets insets;
    insets.top = [dictionary[@"top"] scl_CGFloatValue];
    insets.left = [dictionary[@"left"] scl_CGFloatValue];
    insets.bottom = [dictionary[@"bottom"] scl_CGFloatValue];
    insets.right = [dictionary[@"right"] scl_CGFloatValue];
    return insets;
}


#pragma mark -
@implementation NSValue (SCLCodingUtilities)

+ (instancetype)scl_valueWithCGPoint:(CGPoint)point
{
    return [self value:&point withObjCType:@encode(CGPoint)];
}

+ (instancetype)scl_valueWithCGVector:(CGVector)vector
{
    return [self value:&vector withObjCType:@encode(CGVector)];
}

+ (instancetype)scl_valueWithCGSize:(CGSize)size
{
    return [self value:&size withObjCType:@encode(CGSize)];
}

+ (instancetype)scl_valueWithCGRect:(CGRect)rect
{
    return [self value:&rect withObjCType:@encode(CGRect)];
}

+ (instancetype)scl_valueWithCGAffineTransform:(CGAffineTransform)transform
{
    return [self value:&transform withObjCType:@encode(CGAffineTransform)];
}

+ (instancetype)scl_valueWithSCLEdgeInsets:(SCLEdgeInsets)insets
{
    return [self value:&insets withObjCType:@encode(SCLEdgeInsets)];
}

- (CGPoint)scl_CGPointValue
{
    CGPoint point;
    [self getValue:&point];
    return point;
}

- (CGVector)scl_CGVectorValue
{
    CGVector vector;
    [self getValue:&vector];
    return vector;
}

- (CGSize)scl_CGSizeValue
{
    CGSize size;
    [self getValue:&size];
    return size;
}

- (CGRect)scl_CGRectValue
{
    CGRect rect;
    [self getValue:&rect];
    return rect;
}

- (CGAffineTransform)scl_CGAffineTransformValue
{
    CGAffineTransform transform;
    [self getValue:&transform];
    return transform;
}

- (SCLEdgeInsets)scl_SCLEdgeInsetsValue
{
    SCLEdgeInsets insets;
    [self getValue:&insets];
    return insets;
}

@end


#pragma mark -
@implementation NSNumber (SCLCodingUtilities)

+ (instancetype)scl_numberWithCGFloat:(CGFloat)value
{
    return [self numberWithDouble:(double)value];
}

- (CGFloat)scl_CGFloatValue
{
    return (CGFloat)[self doubleValue];
}

@end


#pragma mark -
@implementation NSCoder (SCLCodingUtilities)

- (void)scl_encodeObject:(id<NSCoding>)object forSelector:(SEL)selector
{
    [self encodeObject:object forKey:NSStringFromSelector(selector)];
}

- (id)scl_decodeObjectOfClass:(Class)aClass forSelector:(SEL)selector
{
    return [self decodeObjectOfClass:aClass forKey:NSStringFromSelector(selector)];
}

- (id)scl_decodeObjectOfClasses:(NSArray *)classes forSelector:(SEL)selector
{
    return [self decodeObjectOfClasses:[NSSet setWithArray:classes] forKey:NSStringFromSelector(selector)];
}

- (NSArray *)scl_decodeArrayOfObjectsOfClass:(Class)aClass forSelector:(SEL)selector
{
    return [self scl_decodeObjectOfClasses:@[[NSArray class], aClass] forSelector:selector];
}

- (NSDictionary *)scl_decodeDictionaryOfObjectsOfClass:(Class)objectClass keyClass:(Class)keyClass forSelector:(SEL)selector
{
    return [self scl_decodeObjectOfClasses:@[[NSDictionary class], objectClass, keyClass] forSelector:selector];
}

- (void)scl_encodeCGFloat:(CGFloat)value forSelector:(SEL)selector;
{
    NSNumber *number = @(value);
    [self scl_encodeObject:number forSelector:selector];
}

- (void)scl_encodeCGPoint:(CGPoint)point forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromPoint(point);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (void)scl_encodeCGVector:(CGVector)vector forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromVector(vector);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (void)scl_encodeCGSize:(CGSize)size forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromSize(size);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (void)scl_encodeCGRect:(CGRect)rect forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromRect(rect);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (void)scl_encodeCGAffineTransform:(CGAffineTransform)transform forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromAffineTransform(transform);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (void)scl_encodeSCLEdgeInsets:(SCLEdgeInsets)insets forSelector:(SEL)selector
{
    NSDictionary *dictionary = SCLDictionaryFromEdgeInsets(insets);
    [self scl_encodeObject:dictionary forSelector:selector];
}

- (CGFloat)scl_decodeCGFloatForSelector:(SEL)selector
{
    NSNumber *number = [self scl_decodeObjectOfClass:[NSNumber class] forSelector:selector];
    return [number scl_CGFloatValue];
}

- (CGPoint)scl_decodeCGPointForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLPointFromDictionary(dictionary);
}

- (CGVector)scl_decodeCGVectorForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLVectorFromDictionary(dictionary);
}

- (CGSize)scl_decodeCGSizeForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLSizeFromDictionary(dictionary);
}

- (CGRect)scl_decodeCGRectForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLRectFromDictionary(dictionary);
}

- (CGAffineTransform)scl_decodeCGAffineTransformForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLAffineTransformFromDictionary(dictionary);
}

- (SCLEdgeInsets)scl_decodeSCLEdgeInsetsForSelector:(SEL)selector
{
    NSDictionary *dictionary = [self scl_decodeDictionaryOfObjectsOfClass:[NSNumber class] keyClass:[NSString class] forSelector:selector];
    return SCLEdgeInsetsFromDictionary(dictionary);
}

@end


#pragma mark -
@implementation NSKeyedArchiver (SCLCodingUtilities)

+ (NSData *)scl_archivedDataWithRootObject:(id)rootObject requiresSecureCoding:(BOOL)requiresSecureCoding
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setRequiresSecureCoding:requiresSecureCoding];
    [archiver encodeObject:rootObject forKey:NSKeyedArchiveRootObjectKey];
    [archiver finishEncoding];
    
    return [data copy];
}

@end


#pragma mark -
@implementation NSKeyedUnarchiver (SCLCodingUtilities)

+ (id)scl_unarchiveObjectOfClass:(Class)aClass data:(NSData *)data requiresSecureCoding:(BOOL)requiresSecureCoding
{
    id object = nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setRequiresSecureCoding:requiresSecureCoding];
    object = [unarchiver decodeObjectOfClass:aClass forKey:NSKeyedArchiveRootObjectKey];
    [unarchiver finishDecoding];
    
    return object;
}

@end
