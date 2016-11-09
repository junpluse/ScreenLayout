//
//  SCLSessionMessage.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLSessionMessage.h"
#import "SCLScreen.h"
#import "SCLLayoutConstraint.h"
#import "SCLCodingUtilities.h"


NSString *const SCLSessionMessageNameRegisterScreen = @"SCLSessionMessageNameRegisterScreen";
NSString *const SCLSessionMessageNameActivateConstraints = @"SCLSessionMessageNameActivateConstraints";
NSString *const SCLSessionMessageNameDeactivateConstraints = @"SCLSessionMessageNameDeactivateConstraints";


#pragma mark -
@interface SCLSessionMessage ()

@property (readonly, nonatomic, copy) NSSet *classNames;

@end


#pragma mark -
@implementation SCLSessionMessage

#pragma mark SCLSessionMessage

- (instancetype)initWithName:(NSString *)name object:(id<NSObject, NSSecureCoding>)object
{
    if (!object) {
        return [self initWithName:name object:nil ofClasses:nil];
    }
    
    return [self initWithName:name object:object ofClasses:@[[object class]]];
}

- (instancetype)initWithName:(NSString *)name object:(id<NSObject, NSSecureCoding>)object ofClasses:(NSArray *)classes
{
    NSParameterAssert(name);
    
    if (object) {
        NSParameterAssert(classes);
        NSAssert([object conformsToProtocol:@protocol(NSObject)], @"The object must conforms NSObject protocol");
        NSAssert([object conformsToProtocol:@protocol(NSSecureCoding)], @"The object must conforms NSSecureCoding protocol");
    }
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _name = [name copy];
    _object = object;
    
    NSMutableSet *classNames = [[NSMutableSet alloc] init];
    [classes enumerateObjectsUsingBlock:^(Class class, NSUInteger idx, BOOL *stop) {
        NSString *className = NSStringFromClass(class);
        [classNames addObject:className];
    }];
    _classNames = [classNames copy];
    
    return self;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        if (![_name isEqual:[object name]]) {
            return NO;
        }
        if (![_object isEqual:[object object]]) {
            return NO;
        }
        if (![_classNames isEqual:[object classNames]]) {
            return NO;
        }
        return YES;
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    NSUInteger hash1 = [_name hash];
    NSUInteger hash2 = [_object hash];
    NSUInteger hash3 = [_classNames hash];
    
    return hash1 ^ hash2 ^ hash3;
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
    NSString *name = [aDecoder scl_decodeObjectOfClass:[NSString class] forSelector:@selector(name)];
    NSSet *classNames = [aDecoder scl_decodeObjectOfClasses:@[[NSSet class], [NSString class]] forSelector:@selector(classNames)];
    id<NSObject, NSSecureCoding> object = nil;
    
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    [classNames enumerateObjectsUsingBlock:^(NSString *className, BOOL *stop) {
        Class class = NSClassFromString(className);
        if (class) {
            [classes addObject:class];
        }
    }];
    if (classes.count > 0) {
        object = [aDecoder scl_decodeObjectOfClasses:classes forSelector:@selector(object)];
    }

    return [self initWithName:name object:object ofClasses:classes];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder scl_encodeObject:_name forSelector:@selector(name)];
    [aCoder scl_encodeObject:_object forSelector:@selector(object)];
    [aCoder scl_encodeObject:_classNames forSelector:@selector(classNames)];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
