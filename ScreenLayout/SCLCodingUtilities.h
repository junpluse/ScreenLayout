//
//  SCLCodingUtilities.h
//  ScreenLayout
//
//  Created by Jun on 11/25/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"


extern NSDictionary *SCLDictionaryFromPoint(CGPoint point);
extern NSDictionary *SCLDictionaryFromVector(CGVector vector);
extern NSDictionary *SCLDictionaryFromSize(CGSize size);
extern NSDictionary *SCLDictionaryFromRect(CGRect rect);
extern NSDictionary *SCLDictionaryFromAffineTransform(CGAffineTransform transform);
extern NSDictionary *SCLDictionaryFromEdgeInsets(SCLEdgeInsets insets);

extern CGPoint SCLPointFromDictionary(NSDictionary *dictionary);
extern CGVector SCLVectorFromDictionary(NSDictionary *dictionary);
extern CGSize SCLSizeFromDictionary(NSDictionary *dictionary);
extern CGRect SCLRectFromDictionary(NSDictionary *dictionary);
extern CGAffineTransform SCLAffineTransformFromDictionary(NSDictionary *dictionary);
extern SCLEdgeInsets SCLEdgeInsetsFromDictionary(NSDictionary *dictionary);


@interface NSValue (SCLCodingUtilities)

+ (instancetype)scl_valueWithCGPoint:(CGPoint)point;
+ (instancetype)scl_valueWithCGVector:(CGVector)vector;
+ (instancetype)scl_valueWithCGSize:(CGSize)size;
+ (instancetype)scl_valueWithCGRect:(CGRect)rect;
+ (instancetype)scl_valueWithCGAffineTransform:(CGAffineTransform)transform;
+ (instancetype)scl_valueWithSCLEdgeInsets:(SCLEdgeInsets)insets;

@property (readonly) CGPoint scl_CGPointValue;
@property (readonly) CGVector scl_CGVectorValue;
@property (readonly) CGSize scl_CGSizeValue;
@property (readonly) CGRect scl_CGRectValue;
@property (readonly) CGAffineTransform scl_CGAffineTransformValue;
@property (readonly) SCLEdgeInsets scl_SCLEdgeInsetsValue;

@end


@interface NSNumber (SCLCodingUtilities)

+ (instancetype)scl_numberWithCGFloat:(CGFloat)value;

@property (readonly) CGFloat scl_CGFloatValue;

@end


@interface NSCoder (SCLCodingUtilities)

- (void)scl_encodeObject:(id<NSCoding>)object forSelector:(SEL)selector;

- (id)scl_decodeObjectOfClass:(Class)aClass forSelector:(SEL)selector;
- (id)scl_decodeObjectOfClasses:(NSArray *)classes forSelector:(SEL)selector;
- (NSArray *)scl_decodeArrayOfObjectsOfClass:(Class)aClass forSelector:(SEL)selector;
- (NSDictionary *)scl_decodeDictionaryOfObjectsOfClass:(Class)objectClass keyClass:(Class)keyClass forSelector:(SEL)selector;

- (void)scl_encodeCGFloat:(CGFloat)value forSelector:(SEL)selector;
- (void)scl_encodeCGPoint:(CGPoint)point forSelector:(SEL)selector;
- (void)scl_encodeCGVector:(CGVector)vector forSelector:(SEL)selector;
- (void)scl_encodeCGSize:(CGSize)size forSelector:(SEL)selector;
- (void)scl_encodeCGRect:(CGRect)rect forSelector:(SEL)selector;
- (void)scl_encodeCGAffineTransform:(CGAffineTransform)transform forSelector:(SEL)selector;
- (void)scl_encodeSCLEdgeInsets:(SCLEdgeInsets)insets forSelector:(SEL)selector;

- (CGFloat)scl_decodeCGFloatForSelector:(SEL)selector;
- (CGPoint)scl_decodeCGPointForSelector:(SEL)selector;
- (CGVector)scl_decodeCGVectorForSelector:(SEL)selector;
- (CGSize)scl_decodeCGSizeForSelector:(SEL)selector;
- (CGRect)scl_decodeCGRectForSelector:(SEL)selector;
- (CGAffineTransform)scl_decodeCGAffineTransformForSelector:(SEL)selector;
- (SCLEdgeInsets)scl_decodeSCLEdgeInsetsForSelector:(SEL)selector;

@end


@interface NSKeyedArchiver (SCLCodingUtilities)

+ (NSData *)scl_archivedDataWithRootObject:(id)rootObject requiresSecureCoding:(BOOL)requiresSecureCoding;

@end


@interface NSKeyedUnarchiver (SCLCodingUtilities)

+ (id)scl_unarchiveObjectOfClass:(Class)aClass data:(NSData *)data requiresSecureCoding:(BOOL)requiresSecureCoding;

@end
