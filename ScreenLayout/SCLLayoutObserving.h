//
//  SCLLayoutObserving.h
//  ScreenLayout
//
//  Created by Jun on 12/4/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLLayout.h"

/**
 @abstract The SCLLayoutObserving protocol allows objects to be notified of changes to the SCLLayout system.
 */
@protocol SCLLayoutObserving <NSObject>

/**
 @abstract This message is sent to the receiver when the SCLLayout system has changed and that effect some of the screens.
 @param affectedScreens An array containing the screens affected by the change.
 */
- (void)layoutDidChangeForScreens:(nonnull NSArray<SCLScreen *> *)affectedScreens;

@end

/**
 @abstract The SCLLayoutObserverRegistration category defines methods to register or deregister as an observer of the SCLLayout system, in the same manner as NSNotificationCenter.
 */
@interface SCLLayout (SCLLayoutObserverRegistration)

/**
 @abstract Adds an entry to the receiver's notification table with a block.
 @param block The block to be executed when the SCLLayout system has changed. Must not be nil. The block is copied and (the copy) held until the observer registration is removed. The block takes one argument: affectedScreens An array containing the screens affected by the change.
 @return An object to act as the observer.
 @discussion To unregister observations, you pass the object returned by this method to removeObserver:.
 */
+ (nonnull id<SCLLayoutObserving>)addLayoutObserverWithBlock:(nonnull void(^)(NSArray<SCLScreen *> * _Nonnull affectedScreens))block;

/**
 @abstract Adds an entry to the receiver's notification table with an observer.
 @param observer The object registering as an observer. Must not be nil.
 @discussion Be sure to invoke removeObserver: before observer specified in addObserver: is deallocated.
 */
+ (void)addLayoutObserver:(nonnull id<SCLLayoutObserving>)observer;

/**
 @abstract Removes the entry specifying a given observer from the receiver's notification table.
 @param observer The observer to remove from the notification table.
 */
+ (void)removeLayoutObserver:(nullable id<SCLLayoutObserving>)observer;

@end
