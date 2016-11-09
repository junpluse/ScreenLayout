//
//  SCLSessionManager.h
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ScreenLayoutBase.h"
#import <MultipeerConnectivity/MCSession.h>

@class SCLScreen;

@protocol SCLSessionManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract A SCLSessionManager wraps a MCSession object to communicate screen layout informations among all peers.
 @discussion A SCLSessionManager exchanges [SCLScreen mainScreen] among all peers connected to the session, and automatically synchronize all of activate/deactivate events of SCLLayoutConstraint. If you activate a constraint, the session manager sends it to the other peers in the session. The receivers activate it in the its local layout system too.
 */
@interface SCLSessionManager : NSObject <MCSessionDelegate>

/**
 @abstract Creates a SCLSessionManager instance.
 @return The newly-initialized session manager.
 @discussion This method is equivalent to calling initWithSecurityIdentity:encryptionPreference: with a nil identity and MCEncryptionOptional as the encryption preference.
 */
- (instancetype)init;

/**
 @abstract Creates a SCLSessionManager instance with the specified security identity and encryption preference for the session.
 @param identity An array containing information that can be used to identify the local peer to other nearby peers.
 @param encryptionPreference An integer value that indicates whether encryption is required, preferred, or undesirable.
 @return The newly-initialized session manager.
 @discussion The parameters passed to the receiver's MCSession object.
 */
- (instancetype)initWithSecurityIdentity:(nullable NSArray *)identity encryptionPreference:(MCEncryptionPreference)encryptionPreference NS_DESIGNATED_INITIALIZER;

/**
 @abstract The delegate object that handles session-related events. May be nil.
 @discussion A SCLSessionManager forwards all of MCSessionDelegate method calls to its delegate. Note that they are always called from main thread.
 */
@property (nonatomic, weak, nullable) id<SCLSessionManagerDelegate> delegate;

/**
 @abstract The MCSession object managed by the receiver.
 */
@property (readonly, nonatomic, nonnull) MCSession *session;

/**
 @abstract Returns the screen object provided from the specified peerID.
 @param peerID The peer which provided the screen.
 @return The screen provided from peerID, or nil if no screens has received from the peerID.
 */
- (nullable SCLScreen *)screenForPeer:(nullable MCPeerID *)peerID;

/**
 @abstract Disconnects from the session.
 */
- (void)disconnect;

@end


@interface SCLSessionManager (SCLSessionManagerAutomaticPeerInvitation)

/**
 @abstract Starts automatic peer invitations with the specified Bonjour service type.
 @param serviceType The type of service to advertise/browse peers. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type.
 @param errorHandler A block to handle errors occurred in the advertise/browse operations.
 @discussion This method runs a pair of MCNearbyServiceAdvertiser/MCNearbyServiceBrowser instances internally and invites/accepts all peers.
 */
- (void)startPeerInvitationsWithServiceType:(nonnull NSString *)serviceType errorHandler:(nullable void(^)(NSError * _Nullable error))errorHandler;

/**
 @abstract Stops automatic peer invitations.
 */
- (void)stopPeerInviations;

@end


@protocol SCLSessionManagerDelegate <MCSessionDelegate>
@optional

/**
 @abstract Indicates that a SCLScreen object has been received from a nearby peer. (optional)
 @param manager The session manager through the screen was received.
 @param screen The received screen.
 */
- (void)sessionManager:(nonnull SCLSessionManager *)manager didReceiveScreen:(nonnull SCLScreen *)screen;

@end

extern NSNotificationName const SCLSessionManagerDidReceiveScreenNotification;
extern NSString *const SCLSessionManagerScreenUserInfoKey;

NS_ASSUME_NONNULL_END
