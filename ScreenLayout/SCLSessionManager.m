//
//  SCLSessionManager.m
//  ScreenLayout
//
//  Created by Jun on 11/26/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLSessionManager.h"
#import "SCLSessionMessage.h"
#import "SCLScreen.h"
#import "SCLLayout.h"
#import "SCLLayoutConstraint.h"
#import "SCLLayoutPool.h"
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>
#import <MultipeerConnectivity/MCNearbyServiceBrowser.h>


NSString *const SCLSessionManagerDidReceiveScreenNotification = @"SCLSessionDidReceiveScreenNotification";
NSString *const SCLSessionManagerScreenUserInfoKey = @"screen";

NSString *const SCLSessionManagerDidReceiveMessageNotification = @"SCLSessionManagerDidReceiveMessageNotification";
NSString *const SCLSessionManagerMessageUserInfoKey = @"message";
NSString *const SCLSessionManagerPeerIDUserInfoKey = @"peerID";

static NSString *const SCLSessionManagerHashDiscoveryInfoKey = @"hash";

typedef void(^SCLSessionManagerErrorHandler)(NSError *);


#pragma mark -
@interface SCLSessionManager () <NSKeyedUnarchiverDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (readwrite, atomic, copy) NSSet *screens;
@property (readwrite, atomic, copy) NSSet *constraints;

@end


#pragma mark -
@implementation SCLSessionManager {
    MCNearbyServiceAdvertiser *_serviceAdvertiser;
    MCNearbyServiceBrowser *_serviceBrowser;
    NSMutableDictionary *_discoveryInfos;
    SCLSessionManagerErrorHandler _discoveryErrorHandler;
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:SCLLayoutDidActivateConstraintsNotification object:nil];
    [notificationCenter removeObserver:self name:SCLLayoutDidDeactivateConstraintsNotification object:nil];
}

- (instancetype)init
{
    return [self initWithSecurityIdentity:nil encryptionPreference:MCEncryptionOptional];
}

#pragma mark SCLSessionManager

- (instancetype)initWithSecurityIdentity:(NSArray *)identity encryptionPreference:(MCEncryptionPreference)encryptionPreference
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    SCLScreen *screen = [SCLScreen mainScreen];
    
    MCSession *session = [[MCSession alloc] initWithPeer:screen.peerID securityIdentity:identity encryptionPreference:encryptionPreference];
    session.delegate = self;
    _session = session;
    
    [self addScreen:screen];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleLayoutDidActivateConstraintsNotification:) name:SCLLayoutDidActivateConstraintsNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleLayoutDidDeactivateConstraintsNotification:) name:SCLLayoutDidDeactivateConstraintsNotification object:nil];
    
    return self;
}

- (NSArray *)connectedScreens
{
    NSMutableSet *screens = [[NSMutableSet alloc] initWithSet:self.screens];
    [screens removeObject:[SCLScreen mainScreen]];
    
    return screens.allObjects;
}

- (SCLScreen *)screenForPeer:(MCPeerID *)peerID
{
    for (SCLScreen *screen in self.screens) {
        if ([screen.peerID isEqual:peerID]) {
            return screen;
        }
    }
    
    return nil;
}

- (void)disconnect
{
    [self stopPeerInviations];
    
    [_session disconnect];
    self.constraints = nil;
    self.screens = nil;
    
    [self addScreen:[SCLScreen mainScreen]];
}

#pragma mark SCLSessionManager (SCLSessionManagerAutomaticDiscovery)

- (void)startPeerInvitationsWithServiceType:(NSString *)serviceType errorHandler:(void (^)(NSError *))errorHandler
{
    NSString *hash = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)_session.myPeerID.hash];
    NSDictionary *discoveryInfo = @{SCLSessionManagerHashDiscoveryInfoKey: hash};
    
    MCNearbyServiceAdvertiser *advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_session.myPeerID discoveryInfo:discoveryInfo serviceType:serviceType];
    advertiser.delegate = self;
    _serviceAdvertiser = advertiser;
    
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_session.myPeerID serviceType:serviceType];
    browser.delegate = self;
    _serviceBrowser = browser;
    
    _discoveryErrorHandler = [errorHandler copy];
    _discoveryInfos = [[NSMutableDictionary alloc] init];
    
    [advertiser startAdvertisingPeer];
    [browser startBrowsingForPeers];
}

- (void)stopPeerInviations
{
    _discoveryErrorHandler = nil;
    _discoveryInfos = nil;
    
    MCNearbyServiceAdvertiser *advertiser = _serviceAdvertiser;
    advertiser.delegate = nil;
    
    MCNearbyServiceBrowser *browser = _serviceBrowser;
    browser.delegate = nil;
    
    [advertiser stopAdvertisingPeer];
    [browser stopBrowsingForPeers];
    
    _serviceAdvertiser = nil;
    _serviceBrowser = nil;
}

#pragma mark SCLSessionManager (SCLSessionMessaging)

- (BOOL)sendMessage:(SCLSessionMessage *)message toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    
    return [_session sendData:data toPeers:peerIDs withMode:mode error:error];
}

- (void)handleReceivedMessage:(SCLSessionMessage *)message fromPeer:(MCPeerID *)peerID
{
    NSString *name = message.name;
    
    if ([name isEqual:SCLSessionMessageNameRegisterScreen]) {
        [self addScreen:message.object];
    }
    else if ([name isEqual:SCLSessionMessageNameActivateConstraints]) {
        NSArray *constraints = message.object;
        [self addConstraints:constraints];
        [SCLLayout activateConstraints:constraints];
    }
    else if ([name isEqual:SCLSessionMessageNameDeactivateConstraints]) {
        NSArray *constraints = message.object;
        [self removeConstraints:constraints];
        [SCLLayout deactivateConstraints:constraints];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCLSessionManagerDidReceiveMessageNotification object:self userInfo:@{SCLSessionManagerMessageUserInfoKey: message, SCLSessionManagerPeerIDUserInfoKey: peerID}];
}

#pragma mark SCLSessionManager (Internal)

- (void)callDelegateWithSelector:(SEL)selector usingBlock:(void(^)(id<SCLSessionManagerDelegate> delegate))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        id<SCLSessionManagerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:selector]) {
            block(delegate);
        }
        else {
            block(nil);
        }
    });
}

- (void)addScreen:(SCLScreen *)screen
{
    if (!screen || [self.screens containsObject:screen]) {
        return;
    }
    
    @synchronized(self) {
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:self.screens];
        [set addObject:screen];
        self.screens = set;
    }
    
    if (![screen.peerID isEqual:_session.myPeerID]) {
        [self callDelegateWithSelector:@selector(sessionManager:didReceiveScreen:) usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
            [delegate sessionManager:self didReceiveScreen:screen];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCLSessionManagerDidReceiveScreenNotification object:self userInfo:@{SCLSessionManagerScreenUserInfoKey: screen}];
    }
}

- (void)removeScreen:(SCLScreen *)screen
{
    if (!screen || ![self.screens containsObject:screen]) {
        return;
    }
    
    @synchronized(self) {
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:self.screens];
        [set removeObject:screen];
        self.screens = set;
    }
    
    NSSet *constraints = [[SCLLayoutPool sharedInstance] constraintsContainingScreens:@[screen]];
    [self removeConstraints:constraints.allObjects];
}

- (void)addConstraints:(NSArray *)constraints
{
    for (SCLLayoutConstraint *constraint in constraints) {
        for (SCLScreen *screen in constraint.screens) {
            [self addScreen:screen];
        }
    }
    
    @synchronized(self) {
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:self.constraints];
        [set addObjectsFromArray:constraints];
        self.constraints = set;
    }
}

- (void)removeConstraints:(NSArray *)constraints
{
    @synchronized(self) {
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:self.constraints];
        [set minusSet:[NSSet setWithArray:constraints]];
        self.constraints = set;
    }
}

- (void)handleLayoutDidActivateConstraintsNotification:(NSNotification *)notification
{
    NSMutableSet *constraints = [[NSMutableSet alloc] initWithArray:notification.userInfo[SCLLayoutConstraintsUserInfoKey]];
    [constraints minusSet:self.constraints];
    
    if (constraints.count > 0) {
        [self addConstraints:constraints.allObjects];
        
        SCLSessionMessage *message = [[SCLSessionMessage alloc] initWithName:SCLSessionMessageNameActivateConstraints object:constraints.allObjects ofClasses:@[[NSArray class], [SCLLayoutConstraint class]]];
        [self sendMessage:message toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)handleLayoutDidDeactivateConstraintsNotification:(NSNotification *)notification
{
    NSMutableSet *constraints = [[NSMutableSet alloc] initWithArray:notification.userInfo[SCLLayoutConstraintsUserInfoKey]];
    [constraints intersectSet:self.constraints];
    
    if (constraints.count > 0) {
        [self removeConstraints:constraints.allObjects];
        
        SCLSessionMessage *message = [[SCLSessionMessage alloc] initWithName:SCLSessionMessageNameDeactivateConstraints object:constraints.allObjects ofClasses:@[[NSArray class], [SCLLayoutConstraint class]]];
        [self sendMessage:message toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)peerConnected:(MCPeerID *)peerID
{
    SCLSessionMessage *screenMessage = [[SCLSessionMessage alloc] initWithName:SCLSessionMessageNameRegisterScreen object:[SCLScreen mainScreen]];
    [self sendMessage:screenMessage toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
    
    NSArray *constraints = self.constraints.allObjects;
    NSArray *sortedConstraints = [constraints sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *id1 = [obj1 identifier];
        NSString *id2 = [obj2 identifier];
        return [id1 compare:id2];
    }];
    SCLLayoutConstraint *firstConstraint = sortedConstraints.firstObject;
    SCLScreen *firstScreen = firstConstraint.screens.firstObject;
    
    if ([firstScreen.peerID isEqual:_session.myPeerID]) {
        SCLSessionMessage *constraintsMessage = [[SCLSessionMessage alloc] initWithName:SCLSessionMessageNameActivateConstraints object:constraints ofClasses:@[[NSArray class], [SCLLayoutConstraint class]]];
        [self sendMessage:constraintsMessage toPeers:@[peerID] withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)peerDisconnected:(MCPeerID *)peerID
{
    SCLScreen *screen = [self screenForPeer:peerID];
    if (screen) {
        [self removeScreen:screen];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self shouldInvitePeer:peerID]) {
            [self invitePeer:peerID];
        }
    });
}

- (BOOL)shouldInvitePeer:(MCPeerID *)peerID
{
    if ([_session.connectedPeers containsObject:peerID]) {
        return NO;
    }
    
    NSDictionary *info = _discoveryInfos[peerID];
    if (!info) {
        return NO;
    }
    
    NSString *hash1 = _serviceAdvertiser.discoveryInfo[SCLSessionManagerHashDiscoveryInfoKey];
    NSString *hash2 = info[SCLSessionManagerHashDiscoveryInfoKey];
    
    return [hash1 compare:hash2] == NSOrderedAscending;
}

- (void)invitePeer:(MCPeerID *)peerID
{
    [_serviceBrowser invitePeer:peerID toSession:_session withContext:nil timeout:10];
}

#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == MCSessionStateConnected) {
            [self peerConnected:peerID];
        }
        else if (state == MCSessionStateNotConnected) {
            [self peerDisconnected:peerID];
        }
    });
    
    [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
        [delegate session:session peer:peerID didChangeState:state];
    }];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    @try {
        SCLSessionMessage *message = nil;
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        unarchiver.delegate = self;
        message = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        [unarchiver finishDecoding];
        
        if ([message isKindOfClass:[SCLSessionMessage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceivedMessage:message fromPeer:peerID];
            });
        }
        else {
            [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
                [delegate session:session didReceiveData:data fromPeer:peerID];
            }];
        }
    }
    @catch (NSException *exception) {
        if ([exception.name isEqual:NSInvalidUnarchiveOperationException]) {
            [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
                [delegate session:session didReceiveData:data fromPeer:peerID];
            }];
        }
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
        [delegate session:session didReceiveStream:stream withName:streamName fromPeer:peerID];
    }];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
        [delegate session:session didStartReceivingResourceWithName:resourceName fromPeer:peerID withProgress:progress];
    }];
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
        [delegate session:session didFinishReceivingResourceWithName:resourceName fromPeer:peerID atURL:localURL withError:error];
    }];
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    [self callDelegateWithSelector:_cmd usingBlock:^(id<SCLSessionManagerDelegate> delegate) {
        if (delegate) {
            [delegate session:session didReceiveCertificate:certificate fromPeer:peerID certificateHandler:certificateHandler];
        }
        else {
            certificateHandler(YES);
        }
    }];
}

#pragma mark MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
//    BOOL accept = YES;
    BOOL accept = ![_session.connectedPeers containsObject:peerID];
    invitationHandler(accept, _session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    SCLSessionManagerErrorHandler handler = _discoveryErrorHandler;
    if (handler) {
        handler(error);
    }
}

#pragma mark MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if (info) {
        [_discoveryInfos setObject:info forKey:peerID];
    }
    else {
        [_discoveryInfos removeObjectForKey:peerID];
    }
    
    if ([self shouldInvitePeer:peerID]) {
        [self invitePeer:peerID];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [_discoveryInfos removeObjectForKey:peerID];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    SCLSessionManagerErrorHandler handler = _discoveryErrorHandler;
    if (handler) {
        handler(error);
    }
}

#pragma mark NSKeyedUnarchiverDelegate

- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id)object
{
    if ([object isKindOfClass:[SCLScreen class]]) {
        id member = [self.screens member:object];
        if (member) {
            return member;
        }
    }
    else if ([object isKindOfClass:[SCLLayoutConstraint class]]) {
        id member = [self.constraints member:object];
        if (member) {
            return member;
        }
    }
    
    return object;
}

@end
