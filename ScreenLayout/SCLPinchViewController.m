//
//  SCLPinchViewController.m
//  ScreenLayout
//
//  Created by Jun on 11/28/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "SCLPinchViewController.h"
#import "SCLScreen.h"


#pragma mark -
@implementation SCLPinchViewController

- (void)dealloc
{
    [SCLLayout removeLayoutObserver:self];
}

#pragma mark SCLPinchSessionViewController (Internal)

- (void)SCLPinchViewController_commonInit
{
    SCLSessionManager *sessionManager = [[SCLSessionManager alloc] init];
    sessionManager.delegate = self;
    _sessionManager = sessionManager;
    
    SCLPinchLayoutManager *layoutManager = [[SCLPinchLayoutManager alloc] initWithSessionManager:sessionManager];
    _layoutManager = layoutManager;
    
    SCLMotionManager *motionManager = [[SCLMotionManager alloc] init];
    _motionManager = motionManager;
    
    [SCLLayout addLayoutObserver:self];
}

#pragma mark UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    [self SCLPinchViewController_commonInit];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:_layoutManager.gestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _layoutManager.enabled = YES;
    _motionManager.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _layoutManager.enabled = NO;
    _motionManager.enabled = NO;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    [self SCLPinchViewController_commonInit];
    
    return self;
}

#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

#pragma mark SCLLayoutObserving

- (void)layoutDidChangeForScreens:(NSArray *)updatedScreens
{
}

@end
