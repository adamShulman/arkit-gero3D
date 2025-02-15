//
//  ARSceneViewController+ARCoachingOverlay.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import UIKit
import ARKit

extension ARSceneViewController: ARCoachingOverlayViewDelegate {
    
    public func setupCoachingOverlay() {
            
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .anyPlane
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
