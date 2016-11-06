//
//  SCLSessionMessage.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLSessionManager.h"


@interface SCLSessionMessage : NSObject <NSCopying, NSSecureCoding>

- (instancetype)initWithName:(NSString *)name object:(id<NSObject, NSSecureCoding>)object;
- (instancetype)initWithName:(NSString *)name object:(id<NSObject, NSSecureCoding>)object ofClasses:(NSArray *)classes NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic, copy) NSString *name;

@property (readonly, nonatomic, strong) id object;

@end

extern NSString *const SCLSessionMessageNameRegisterScreen;
extern NSString *const SCLSessionMessageNameActivateConstraints;
extern NSString *const SCLSessionMessageNameDeactivateConstraints;


@interface SCLSessionManager (SCLSessionMessaging)

- (BOOL)sendMessage:(SCLSessionMessage *)message toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;

- (void)handleReceivedMessage:(SCLSessionMessage *)message fromPeer:(MCPeerID *)peerID;

@end

extern NSString *const SCLSessionManagerDidReceiveMessageNotification;
extern NSString *const SCLSessionManagerMessageUserInfoKey;
extern NSString *const SCLSessionManagerPeerIDUserInfoKey;
