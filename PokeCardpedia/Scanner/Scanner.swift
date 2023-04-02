//
//  Scanner.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import Foundation
import AVFoundation

class Scanner {
    private let captureSession = AVCaptureSession()
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video, position: .back).devices.first else {
            fatalError("No camera found")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    let device: AVCaptureDevice?
    let input: AVCaptureDeviceInput?
    let scanSession: AVCaptureSession?
    var canCapture: Bool {
        device != nil && input != nil
    }
    
    
    init() {
        self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        if let device = self.device {
            input = try? AVCaptureDeviceInput(device: device)
        } else {
            input = nil
        }
        if self.device != nil && self.input != nil {
            scanSession = AVCaptureSession()
            setUpSession()
        } else {
            scanSession = nil
        }
    }
    
    func setUpSession() {
        guard scanSession != nil else {return}
        scanSession!.addInput(input!)
    }
}
