//
//  ViewController.swift
//  PinchCanvasSwift
//
//  Created by Jun on 12/10/14.
//  Copyright (c) 2014 Jun Tanaka. All rights reserved.
//

import UIKit
import ScreenLayout

class ViewController: SCLPinchViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sessionManager.startPeerInvitationsWithServiceType("pinchcanvas", errorHandler: { (error) -> Void in
            print("invitations failed with error: \(error)")
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.sessionManager.stopPeerInviations();
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func updateLabels() {
        let numberOfConnectedPeers = self.sessionManager.session.connectedPeers.count
        let numberOfConnectedScreens = SCLScreen.mainScreen().connectedScreens.count;
        
        self.textLabel.text = "\(numberOfConnectedScreens) of \(numberOfConnectedPeers) screens connected";
    }
    
    func updateImageFrame() {
        var angle: CGFloat = 0.0
        var frame: CGRect = self.view.bounds
        
        let localScreen = SCLScreen.mainScreen()
        if (localScreen.layout != nil) {
            // align image rotation to the first screen in the layout
            let originScreen: SCLScreen = localScreen.layout.screens[0] as! SCLScreen
            angle = originScreen.convertAngle(0.0, toCoordinateSpace: self.view)
            
            // extend image frame to the entire bounds of the layout
            frame = localScreen.layout.boundsInScreen(localScreen)
            frame = localScreen.convertRect(frame, toCoordinateSpace: self.view)
        }
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.imageView.transform = CGAffineTransformMakeRotation(angle)
            self.imageView.frame = frame
        })
    }
    
    // remote peer changed state
    override func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state {
        case .NotConnected:
            print("peer not connected: \(peerID)")
        case .Connecting:
            print("peer connecting: \(peerID)")
        case .Connected:
            print("peer connected: \(peerID)")
        }
        
        self.updateLabels()
    }
    
    // screen layout changed
    override func layoutDidChangeForScreens(affectedScreens: [AnyObject]!) {
        self.updateLabels()
        self.updateImageFrame()
    }
    
}

