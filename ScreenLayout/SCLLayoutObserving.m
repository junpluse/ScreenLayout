//
//  SCLLayoutObserving.m
//  ScreenLayout
//
//  Created by Jun on 12/4/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayoutObserving.h"


typedef void(^SCLLayoutObserverBlock)(NSArray<SCLScreen *> *affectedScreens);


#pragma mark -
@interface SCLLayoutObserver : NSObject <SCLLayoutObserving>

- (instancetype)initWithObject:(id<SCLLayoutObserving>)object;
- (instancetype)initWithBlock:(SCLLayoutObserverBlock)block;

@property (readonly, nonatomic, weak) id<SCLLayoutObserving> object;
@property (readonly, nonatomic, copy) SCLLayoutObserverBlock block;

- (void)invalidate;

@end


#pragma mark -
@implementation SCLLayoutObserver

- (void)dealloc
{
    [self invalidate];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleNotification:) name:SCLLayoutDidActivateConstraintsNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleNotification:) name:SCLLayoutDidDeactivateConstraintsNotification object:nil];
    
    return self;
}

#pragma mark SCLLayoutObserver

- (instancetype)initWithObject:(id<SCLLayoutObserving>)object
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _object = object;
    
    return self;
}

- (instancetype)initWithBlock:(SCLLayoutObserverBlock)block
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _block = [block copy];
    
    return self;
}

- (void)invalidate
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:SCLLayoutDidActivateConstraintsNotification object:nil];
    [notificationCenter removeObserver:self name:SCLLayoutDidDeactivateConstraintsNotification object:nil];
    
    _object = nil;
    _block = nil;
}

#pragma mark SCLLayoutObserver (Internal)

- (void)handleNotification:(NSNotification *)notification
{
    NSArray *affectedScreens = notification.userInfo[SCLLayoutAffectedScreensUserInfoKey];
    
    if (affectedScreens.count > 0) {
        [self layoutDidChangeForScreens:affectedScreens];
    }
}

#pragma mark SCLLayoutObserving

- (void)layoutDidChangeForScreens:(NSArray *)affectedScreens
{
    if (_object) {
        [_object layoutDidChangeForScreens:affectedScreens];
    }
    else if (_block) {
        _block(affectedScreens);
    }
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isEqual:_object]) {
        return YES;
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    if (_object) {
        return _object.hash;
    }
    
    return [super hash];
}

@end


#pragma mark -
@implementation SCLLayout (SCLLayoutObserverRegistration)

+ (NSMutableSet *)layoutObservers
{
    static NSMutableSet *observers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        observers = [[NSMutableSet alloc] init];
    });
    
    return observers;
}

+ (id<SCLLayoutObserving>)addLayoutObserverWithBlock:(SCLLayoutObserverBlock)block
{
    NSParameterAssert(block);
    
    SCLLayoutObserver *observer = [[SCLLayoutObserver alloc] initWithBlock:block];
    
    [self addLayoutObserver:observer];
    
    return observer;
}

+ (void)addLayoutObserver:(id<SCLLayoutObserving>)observer
{
    NSParameterAssert(observer);
    NSAssert([observer conformsToProtocol:@protocol(SCLLayoutObserving)], @"The observer must conforms to SCLLayoutObserving protocol");
    
    NSMutableSet *observers = [self layoutObservers];
    if ([observers containsObject:observer]) {
        return;
    }
    
    if (![observer isKindOfClass:[SCLLayoutObserver class]]) {
        observer = [[SCLLayoutObserver alloc] initWithObject:observer];
    }
    
    [observers addObject:observer];
}

+ (void)removeLayoutObserver:(id<SCLLayoutObserving>)observer
{
    NSMutableSet *observers = [self layoutObservers];
    
    SCLLayoutObserver *member = [observers member:observer];
    [member invalidate];
    
    [observers removeObject:member];
}

@end
