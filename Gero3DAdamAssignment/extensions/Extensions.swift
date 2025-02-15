//
//  Extension.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import ARKit

extension CGPoint {
    
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}

extension ARSCNView {
    
    func addOrUpdateAnchor(for object: ReflectiveCube) {
        
        if let anchor = object.anchor {
            session.remove(anchor: anchor)
        }
        
        let newAnchor = ARAnchor(transform: object.simdWorldTransform)
        object.anchor = newAnchor
        session.add(anchor: newAnchor)
    }
    
    func virtualObject(at point: CGPoint) -> ReflectiveCube? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.compactMap { result in
            return ReflectiveCube.existingObjectContainingNode(result.node)
        }.first
    }
}

extension float4x4 {
 
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
 
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
}


