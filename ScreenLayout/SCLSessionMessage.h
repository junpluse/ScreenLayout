//
//  SCLSessionMessage.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCLSessionMessage : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(nonnull NSString *)name object:(nullable id<NSObject, NSSecureCoding>)object;
- (instancetype)initWithName:(nonnull NSString *)name object:(nullable id<NSObject, NSSecureCoding>)object ofClasses:(nullable NSArray *)classes NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic, copy, nonnull) NSString *name;

@property (readonly, nonatomic, strong, nullable) id object;

@end

extern NSString *const SCLSessionMessageNameRegisterScreen;
extern NSString *const SCLSessionMessageNameActivateConstraints;
extern NSString *const SCLSessionMessageNameDeactivateConstraints;


@interface SCLSessionManager (SCLSessionMessaging)

- (BOOL)sendMessage:(nonnull SCLSessionMessage *)message toPeers:(nonnull NSArray<MCPeerID *> *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;

- (void)handleReceivedMessage:(nonnull SCLSessionMessage *)message fromPeer:(nonnull MCPeerID *)peerID;

@end

extern NSNotificationName const SCLSessionManagerDidReceiveMessageNotification;
extern NSString *const SCLSessionManagerMessageUserInfoKey;
extern NSString *const SCLSessionManagerPeerIDUserInfoKey;

NS_ASSUME_NONNULL_END
