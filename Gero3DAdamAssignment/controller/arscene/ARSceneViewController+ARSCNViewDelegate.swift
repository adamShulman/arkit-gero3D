//
//  Untitled.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import ARKit

extension ARSceneViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        guard let lightEstimate = frame.lightEstimate,
        lightEstimate.ambientIntensity < 500 else { return }
        
        self.messageController.add(Constants.badLightConditionsMessage)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable:
            self.messageController.add(Constants.trackingUnavailable)
        case .normal:
            break
        case .limited(.excessiveMotion):
            // Case handled by accelerometer.
            break
        case .limited(.insufficientFeatures):
            self.messageController.add(Constants.cameraInsufficientFeatures)
        case .limited(.initializing):
            break
        case .limited(.relocalizing):
            break
        @unknown default:
            break
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.messageController.add(error.localizedDescription)
    }
}
