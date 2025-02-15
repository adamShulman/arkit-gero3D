//
//  SCNNodeInteraction.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import Foundation
import ARKit

class SCNNodeInteraction: NSObject, UIGestureRecognizerDelegate {
    
    let sceneView: ARSCNView
    let viewController: ARSceneViewController
    var selectedObject: ReflectiveCube?
    
    var trackedObject: ReflectiveCube? {
        didSet {
            guard trackedObject != nil else { return }
            selectedObject = trackedObject
        }
    }
    
    private var currentTrackingPosition: CGPoint?
    
    init(sceneView: ARSCNView, viewController: ARSceneViewController) {
        
        self.sceneView = sceneView
        self.viewController = viewController
        super.init()
        
        addPanGestureRecognizer()
        addTapGestureRecognizer()

    }
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    private func addPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        
        let touchLocation = gesture.location(in: sceneView)
        
        if let tappedObject = sceneView.virtualObject(at: touchLocation) {
            
            selectedObject = tappedObject
            
        } else if let object = selectedObject {
            
            move(object, position: touchLocation)
            
        } else {
            
            guard let object = viewController.createCubeObject() else { return }
            viewController.place(object)
            
        }
    }
    
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:

            if let object = objectInteracting(with: gesture, in: sceneView) {
                trackedObject = object
            }
            
        case .changed:
            
            guard let object = trackedObject else { return }
            
            translate(object, position: updatedTrackingPosition(for: object, from: gesture))

            gesture.setTranslation(.zero, in: sceneView)
            
        case .ended:

            guard let object = trackedObject else { break }
            
            move(object, position: updatedTrackingPosition(for: object, from: gesture))
            
            fallthrough
            
        default:
            
            currentTrackingPosition = nil
            trackedObject = nil
            
        }
    }
    
    func updatedTrackingPosition(for object: ReflectiveCube, from gesture: UIPanGestureRecognizer) -> CGPoint {
        
        let translation = gesture.translation(in: sceneView)
        let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
        let updatedPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
        currentTrackingPosition = updatedPosition
        
        return updatedPosition
    }
    
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> ReflectiveCube? {
        
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)
            
            if let object = sceneView.virtualObject(at: touchLocation) {
                return object
            }
        }
        
        return nil
    }
    
    func translate(_ object: ReflectiveCube, position: CGPoint) {
        
        object.stopTrackedRaycast()
        
        if let query = sceneView.raycastQuery(from: position, allowing: .estimatedPlane, alignment: object.allowedAlignment) {
            viewController.raycastAndUpdatePosition(of: object, from: query)
        }
    }
    
    func move(_ object: ReflectiveCube, position: CGPoint) {
        
        object.stopTrackedRaycast()
        object.shouldUpdateAnchor = true
        
        if let query = sceneView.raycastQuery(from: position, allowing: .estimatedPlane, alignment: object.allowedAlignment),
            let raycast = viewController.createTrackedRaycastAndSetPosition(of: object, from: query) {
            object.raycast = raycast
        } else {
            object.shouldUpdateAnchor = false
            viewController.updateQueue.async {
                self.sceneView.addOrUpdateAnchor(for: object)
            }
        }
    }
}


