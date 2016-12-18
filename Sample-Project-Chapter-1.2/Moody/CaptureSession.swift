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
    func captureSessionDidCapture(_ image: UIImage?)
}


class CaptureSession: NSObject {
    var isAuthorized: Bool {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    }

    var isReady: Bool {
        return !session.inputs.isEmpty
    }

    init(delegate: CaptureSessionDelegate) {
        self.delegate = delegate
        super.init()
        if isAuthorized {
            setup()
        } else {
            requestAuthorization()
        }
    }

    func start() {
        #if !IOS_SIMULATOR
            queue.async { self.session.startRunning() }
        #endif

    }

    func stop() {
        #if !IOS_SIMULATOR
            queue.async { self.session.stopRunning() }
        #endif
    }

    func createPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer(session: session)
    }

    func captureImage() {
        queue.async {
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }


    // MARK: - Private

    fileprivate let session = AVCaptureSession()
    fileprivate var photoOutput: AVCapturePhotoOutput!
    fileprivate let queue = DispatchQueue(label: "moody.capture-queue", attributes: [])
    fileprivate weak var delegate: CaptureSessionDelegate!

    fileprivate func setup() {
        #if !IOS_SIMULATOR
        session.sessionPreset = AVCaptureSessionPresetPhoto
        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back)
        if let camera = discovery?.devices.first {
            let input = try! AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }
        photoOutput = AVCapturePhotoOutput()
        if self.session.canAddOutput(photoOutput) {
            self.session.addOutput(photoOutput)
        }
        #endif
    }

    fileprivate func requestAuthorization() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { authorized in
            DispatchQueue.main.async {
                self.delegate.captureSessionDidChangeAuthorizationStatus(authorized: authorized)
                guard authorized else { return }
                self.setup()
            }
        }
    }
}


extension CaptureSession: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        var image: UIImage?

        if let buf = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buf, previewPhotoSampleBuffer: nil) {
            image = UIImage(data: data)
        }
        DispatchQueue.main.async {
            self.delegate.captureSessionDidCapture(image)
        }
    }
}

