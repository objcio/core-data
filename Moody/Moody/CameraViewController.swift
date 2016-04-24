//
//  CameraViewController.swift
//  Moody
//
//  Created by Florian on 18/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit


protocol CameraViewControllerDelegate: class {
    func didTakeImage(image: UIImage)
}


class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: CameraView!
    weak var delegate: CameraViewControllerDelegate!
    var locationAuthorized: Bool = false {
        didSet { updateAuthorizationStatus() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = CaptureSession(delegate: self)
        cameraView.setupForPreviewLayer(session.createPreviewLayer())
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.snap(_:)))
        cameraView.addGestureRecognizer(recognizer)
        updateAuthorizationStatus()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        session.start()
    }

    override func viewDidDisappear(animated: Bool) {
        session.stop()
        super.viewDidDisappear(animated)
    }

    @IBAction func snap(recognizer: UITapGestureRecognizer) {
        if session.ready {
            session.takeImage { image in
                guard let img = image else { return }
                self.delegate.didTakeImage(img)
            }
        } else if readyToSnap {
            self.showImagePicker()
        }
    }


    // MARK: Private

    private var session: CaptureSession!
    private var imagePicker: UIImagePickerController?

    private var readyToSnap: Bool {
        return session.authorized && locationAuthorized
    }

    private func showImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        presentViewController(imagePicker!, animated: true, completion: nil)
    }

    private func updateAuthorizationStatus() {
        cameraView.authorized = readyToSnap
    }

}


extension CameraViewController: CaptureSessionDelegate {

    func captureSessionDidChangeAuthorizationStatus(authorized: Bool) {
        updateAuthorizationStatus()
    }

}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate.didTakeImage(image)
        }
        dismissViewControllerAnimated(true, completion: nil)
        imagePicker = nil
    }

}

