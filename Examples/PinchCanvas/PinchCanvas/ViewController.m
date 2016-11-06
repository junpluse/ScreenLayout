//
//  ViewController.m
//  PinchCanvas
//
//  Created by Jun on 11/27/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.sessionManager startPeerInvitationsWithServiceType:@"pinchcanvas" errorHandler:^(NSError *error) {
        NSLog(@"invitations failed with error %@", error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sessionManager stopPeerInviations];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)updateLabel {
    NSUInteger numberOfConnectedPeers = self.sessionManager.session.connectedPeers.count;
    NSUInteger numberOfConnectedScreens = [SCLScreen mainScreen].connectedScreens.count;
    
    self.textLabel.text = [NSString stringWithFormat:@"%d of %d screens connected", (int)numberOfConnectedScreens, (int)numberOfConnectedPeers];
}

- (void)updateImageFrame {
    CGFloat angle = 0.0;
    CGRect  frame = self.view.bounds;
    
    SCLScreen *localScreen = [SCLScreen mainScreen];
    if (localScreen.layout != nil) {
        // align image rotation to the first screen in the layout
        SCLScreen *originScreen = localScreen.layout.screens.firstObject;
        angle = [originScreen convertAngle:0 toCoordinateSpace:self.view];
        
        // extend image frame to the entire bounds of the layout
        frame = [localScreen.layout boundsInScreen:localScreen];
        frame = [localScreen convertRect:frame toCoordinateSpace:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(angle);
        self.imageView.frame = frame;
    }];
}

#pragma mark - MCSessionDelegate

// remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateNotConnected:
            NSLog(@"peer not connected: %@", peerID);
            break;
        case MCSessionStateConnecting:
            NSLog(@"peer connecting: %@", peerID);
            break;
        case MCSessionStateConnected:
            NSLog(@"peer connected: %@", peerID);
            break;
    }
    
    [self updateLabel];
}

#pragma mark - SCLLayoutObserving

// screen layout changed
- (void)layoutDidChangeForScreens:(NSArray *)updatedScreens {
    NSLog(@"layout changed for screens: %@", updatedScreens);
    
    if ([updatedScreens containsObject:[SCLScreen mainScreen]]) {
        [self updateLabel];
        [self updateImageFrame];
    }
}

@end
