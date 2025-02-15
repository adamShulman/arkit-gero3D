//
//  RoundedCubeNode.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import SceneKit
import ARKit

class ReflectiveCube: SCNNode {
    
    var anchor: ARAnchor?

    var raycastQuery: ARRaycastQuery?
    
    var raycast: ARTrackedRaycast?

    var mostRecentInitialPlacementResult: ARRaycastResult?

    var shouldUpdateAnchor = false
    
    var allowedAlignment: ARRaycastQuery.TargetAlignment {
        return .any
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGFloat = 0.3, chamferRadius: CGFloat = 0.05) {
        super.init()
        var cubeGeometry: SCNGeometry = SCNBox(width: size, height: size, length: size, chamferRadius: chamferRadius)
        addReflectiveMaterial(&cubeGeometry)
        self.geometry = cubeGeometry
    }
    
    private func addReflectiveMaterial(_ geometry: inout SCNGeometry) {
        let reflectiveMaterial = SCNMaterial()
        reflectiveMaterial.lightingModel = .physicallyBased
        reflectiveMaterial.metalness.contents = 1.0
        reflectiveMaterial.roughness.contents = 0.1
        reflectiveMaterial.diffuse.contents = UIColor.init(white: 0.1, alpha: 0.99)
        geometry.firstMaterial = reflectiveMaterial
    }
    
    func stopTrackedRaycast() {
        raycast?.stopTracking()
        raycast = nil
    }
}

extension ReflectiveCube {
    
    static func existingObjectContainingNode(_ node: SCNNode) -> ReflectiveCube? {
        
        if let virtualObjectRoot = node as? ReflectiveCube {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        return existingObjectContainingNode(parent)
    }
}
