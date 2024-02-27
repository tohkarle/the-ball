//
//  MotionService.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import Foundation
import CoreMotion

protocol MotionService {
    func getStream() -> AsyncStream<(Double, Double, Double)>
    func stopStream()
}

final class MotionServiceAdapter: MotionService {
    
    static let shared = MotionServiceAdapter()
    private let motionManager = CMMotionManager()
    private var streamContinuation: AsyncStream<(Double, Double, Double)>.Continuation?
    private var timer: Timer?
    
    private init() { }
    
    func getStream() -> AsyncStream<(Double, Double, Double)> {
        return AsyncStream<(Double, Double, Double)> { [weak self] continuation in
            continuation.onTermination = { @Sendable [weak self] _ in self?.stopMonitoring() }
            self?.streamContinuation = continuation
            Task.detached { [weak self] in
                self?.startMonitoring(with: continuation)
            }
        }
    }
    
    func stopStream() {
        streamContinuation?.finish()
        streamContinuation = nil
    }
    
    private func startMonitoring(with continuation: AsyncStream<(Double, Double, Double)>.Continuation) {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0  // 50 Hz
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { motion, error in
            guard error == nil, let gravity = motion?.gravity, let userAcceleration = motion?.userAcceleration else { return }
            continuation.yield((gravity.x + userAcceleration.x, gravity.y + userAcceleration.y, gravity.z + userAcceleration.z))
//            print("Gravity ---> (\(gravity.x), \(gravity.y), \(gravity.z))")
        }
    }
    
    private func stopMonitoring() {
        guard motionManager.isDeviceMotionAvailable, motionManager.isDeviceMotionActive else { return }
        motionManager.stopDeviceMotionUpdates()
    }
}
