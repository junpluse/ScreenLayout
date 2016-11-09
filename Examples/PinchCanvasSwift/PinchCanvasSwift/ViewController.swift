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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sessionManager.startPeerInvitations(withServiceType: "pinchcanvas", errorHandler: { (error) -> Void in
            print("invitations failed with error: \(error)")
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.sessionManager.stopPeerInviations();
    }
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    func updateLabels() {
        let numberOfConnectedPeers = self.sessionManager.session.connectedPeers.count
        let numberOfConnectedScreens = SCLScreen.main().connectedScreens.count;
        
        self.textLabel.text = "\(numberOfConnectedScreens) of \(numberOfConnectedPeers) screens connected";
    }
    
    func updateImageFrame() {
        var angle: CGFloat = 0.0
        var frame: CGRect = self.view.bounds
        
        let localScreen = SCLScreen.main()
        if let layout = localScreen.layout {
            // align image rotation to the first screen in the layout
            let originScreen: SCLScreen = layout.screens.first!
            angle = originScreen.convertAngle(0.0, to: self.view)

            // extend image frame to the entire bounds of the layout
            frame = layout.bounds(in: localScreen)
            frame = localScreen.convert(frame, to: self.view)
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.imageView.transform = CGAffineTransform(rotationAngle: angle)
            self.imageView.frame = frame
        })
    }
    
    // remote peer changed state
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("peer not connected: \(peerID)")
        case .connecting:
            print("peer connecting: \(peerID)")
        case .connected:
            print("peer connected: \(peerID)")
        }
        
        self.updateLabels()
    }
    
    // screen layout changed
    override func layoutDidChange(for affectedScreens: [SCLScreen]) {
        self.updateLabels()
        self.updateImageFrame()
    }
    
}

