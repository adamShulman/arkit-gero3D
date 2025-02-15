//
//  ARSceneViewController+RayCastPosition.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 14/02/2025.
//

import ARKit

extension ARSceneViewController {
    
    func createCubeObject() -> ReflectiveCube? {
        
        let cubeNode = ReflectiveCube()

        let raycastQuery: ARRaycastQuery? = sceneView.raycastQuery(from: sceneView.center,
                                                                   allowing: .estimatedPlane,
                                                                   alignment: .any)
        
        guard raycastQuery != nil else {
            self.messageController.add(Constants.rayCastQueryFailedMessage)
            return nil
        }

        cubeNode.raycastQuery = raycastQuery
        
        let textNode: SCNNode = createTextObject(for: cubeNode)
        cubeNode.addChildNode(textNode)
        
        return cubeNode
    }
    
    fileprivate func createTextObject(for parentNode: SCNNode, contents: String = "Gero3D") -> SCNNode {
        
        let text = SCNText(string: contents, extrusionDepth: 1.0)
        text.font = UIFont.systemFont(ofSize: 6.0)
        text.materials.first?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: text)
        let fontScale: Float = 0.01
        textNode.scale = SCNVector3(fontScale, fontScale, fontScale)
        
        let (min, max) = (text.boundingBox.min, text.boundingBox.max)
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.25 * (max.y - min.y)
        let dz = min.z + 17.0 * (max.z - min.z)
        textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, -dz)
        
        textNode.eulerAngles = parentNode.eulerAngles
        return textNode
        
    }
    
    func place(_ object: ReflectiveCube) {
        
        guard let query = object.raycastQuery else {
            self.messageController.add(Constants.cantPlaceObjectMessage)
            return
        }
       
        let trackedRaycast = createTrackedRaycastAndSetPosition(of: object,
                                                                from: query,
                                                                withInitialResult: object.mostRecentInitialPlacementResult)
        
        object.raycast = trackedRaycast
        nodeInteraction.selectedObject = object
    }
    
    func createTrackedRaycastAndSetPosition(of object: ReflectiveCube, from query: ARRaycastQuery, withInitialResult initialResult: ARRaycastResult? = nil) -> ARTrackedRaycast? {
        
        if let initialResult = initialResult {
            object.simdWorldTransform = initialResult.worldTransform
        }
        
        return sceneView.session.trackedRaycast(query) { (results) in
            self.setObjectPosition(results, with: object)
        }
    }
    
    func raycastAndUpdatePosition(of object: ReflectiveCube, from query: ARRaycastQuery) {
        
        guard let result = sceneView.session.raycast(query).first else { return }
        
        if object.allowedAlignment == .any && self.nodeInteraction.trackedObject == object {
            object.simdWorldPosition = result.worldTransform.translation
            let previousOrientation = object.simdWorldTransform.orientation
            let currentOrientation = result.worldTransform.orientation
            object.simdWorldOrientation = simd_slerp(previousOrientation, currentOrientation, 0.1)
        } else {
            object.simdWorldTransform = result.worldTransform
        }
    }
    
    private func setObjectPosition(_ results: [ARRaycastResult], with object: ReflectiveCube) {
        
        guard let result = results.first else { return }
        
        object.simdWorldTransform = result.worldTransform
                
        if object.parent == nil {
            self.sceneView.scene.rootNode.addChildNode(object)
            object.shouldUpdateAnchor = true
        }
        
        if object.shouldUpdateAnchor {
            object.shouldUpdateAnchor = false
            self.updateQueue.async {
                self.sceneView.addOrUpdateAnchor(for: object)
            }
        }
    }
}
