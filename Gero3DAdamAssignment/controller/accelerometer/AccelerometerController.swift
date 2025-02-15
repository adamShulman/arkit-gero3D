//
//  AccelerometerController.swift
//  Gero3DAdamAssignment
//
//  Created by Adam Shulman on 13/02/2025.
//

import UIKit
import CoreMotion

protocol AccelerometerControllerDelegate: AnyObject {
    func accelerometerController(_ controller: AccelerometerController, didUpdateAccelerationWithMessage message: String)
}

class AccelerometerController: NSObject {
    
    private let motionManager = CMMotionManager()
    private let accelerationTreshold: Double = 2.0
    
    weak public var delegate: (any AccelerometerControllerDelegate)?
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
        
    public func startUpdates(interval: TimeInterval = 0.1) {
        
        guard motionManager.isAccelerometerAvailable else { return }
                
        motionManager.deviceMotionUpdateInterval = interval
        
        motionManager.startAccelerometerUpdates(to: operationQueue) { [weak self] motionData, error in
            guard let data = motionData else { return }
            DispatchQueue.main.async {
                self?.processAcceleration(data.acceleration)
            }
        }
    }
    
    public func stopUpdates() {
        
        guard motionManager.isAccelerometerActive else { return }
        
        motionManager.stopAccelerometerUpdates()
    }
    
    private func processAcceleration(_ acceleration: CMAcceleration) {
        
        let mag = sqrt(acceleration.x * acceleration.x +
                       acceleration.y * acceleration.y +
                       acceleration.z * acceleration.z)
        guard mag > accelerationTreshold else { return }
        
        let message: String = Constants.fastMovementMessage
        delegate?.accelerometerController(self, didUpdateAccelerationWithMessage: message)
    }
    
}
