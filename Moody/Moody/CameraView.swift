//
//  CameraView.swift
//  Moody
//
//  Created by Florian on 19/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import AVFoundation


class CameraView: UIView {

    @IBOutlet weak var label: UILabel!

    var authorized: Bool = false {
        didSet {
            label.text = authorized ? localized(.CameraView_tapToCapture) : localized(.CameraView_needAccess)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setupForPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.insertSublayer(previewLayer, atIndex: 0)
        self.previewLayer = previewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }


    // MARK: Private

    private var previewLayer: AVCaptureVideoPreviewLayer!

    private func setup() {
        backgroundColor = UIColor.blackColor()
    }


}

