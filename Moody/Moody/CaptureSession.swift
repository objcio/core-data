//
//  CaptureSession.swift
//  Moody
//
//  Created by Florian on 19/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import AVFoundation


protocol CaptureSessionDelegate: class {
    func captureSessionDidChangeAuthorizationStatus(authorized: Bool)
}


class CaptureSession {

    var authorized: Bool {
        return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
    }

    var ready: Bool {
        return !session.inputs.isEmpty
    }

    init(delegate: CaptureSessionDelegate) {
        self.delegate = delegate
        if authorized {
            setup()
        } else {
            requestAuthorization()
        }
    }

    func start() {
        dispatch_async(queue) { self.session.startRunning() }
    }

    func stop() {
        dispatch_async(queue) { self.session.stopRunning() }
    }

    func createPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer(session: session)
    }

    func takeImage(completion: UIImage? -> ()) {
        dispatch_async(queue) {
            guard let connection = self.cameraOutput.connectionWithMediaType(AVMediaTypeVideo) else {
                dispatch_async(dispatch_get_main_queue()) { completion(nil) }
                return
            }
            guard let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue) else { fatalError("Unknown orientation constant") }
            connection.videoOrientation = orientation
            self.cameraOutput.captureStillImageAsynchronouslyFromConnection(connection) { buffer, error in
                var image: UIImage?
                if let buf = buffer, let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buf) {
                   image = UIImage(data: data)
                }
                dispatch_async(dispatch_get_main_queue()) { completion(image) }
            }
        }
    }


    // MARK: - Private

    private let session = AVCaptureSession()
    private var cameraOutput: AVCaptureStillImageOutput!
    private let queue = dispatch_queue_create("moody.capture-queue", DISPATCH_QUEUE_SERIAL)
    private weak var delegate: CaptureSessionDelegate!

    private func setup() {
        session.sessionPreset = AVCaptureSessionPresetPhoto
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice],
           let camera = devices.findFirstOccurence({ $0.position == .Back })
        {
            let input = try! AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }
        cameraOutput = AVCaptureStillImageOutput()
        if self.session.canAddOutput(cameraOutput) {
            self.session.addOutput(cameraOutput)
        }
    }

    private func requestAuthorization() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { auth in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate.captureSessionDidChangeAuthorizationStatus(auth)
                guard auth else { return }
                self.setup()
            }
        }
    }

}
