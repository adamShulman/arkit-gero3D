//
//  ARSceneViewController.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import UIKit
import SceneKit
import ARKit

class ARSceneViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let coachingOverlay = ARCoachingOverlayView()
    let accelerometerController = AccelerometerController()
    let updateQueue = DispatchQueue(label: "com.shulman.Gero3dAdamAssignment.updateQueue")
    
    lazy var nodeInteraction = SCNNodeInteraction(sceneView: sceneView, viewController: self)
    
    lazy var messageController: MessageViewController = {
        return children.lazy.compactMap({ $0 as? MessageViewController }).first!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        accelerometerController.delegate = self
        messageController.messageLabel.text = nil
        nodeInteraction.selectedObject = nil
        
        setupCoachingOverlay()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopSession()
    }
    
    private func startSession() {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.worldAlignment = .gravity
        configuration.environmentTexturing = .automatic
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        accelerometerController.startUpdates()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    private func stopSession() {
        
        sceneView.session.pause()
        
        accelerometerController.stopUpdates()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

extension ARSceneViewController: AccelerometerControllerDelegate {
    func accelerometerController(_ controller: AccelerometerController, didUpdateAccelerationWithMessage message: String) {
        messageController.add(message)
    }
}


