//
//  IconGenerator.swift
//  Moody
//
//  Created by Daniel Eggert on 08/09/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


private let rgbValues: [(CGFloat,CGFloat,CGFloat)] = [
    (0.301961, 0.372549, 0.211765),
    (0.705882, 0.478431, 0.443137),
    (0.705882, 0.156863, 0.223529),
    (0.47451, 0.376471, 0.266667),
    (0.470588, 0.313725, 0.243137),
    (0.301961, 0.0627451, 0.0901961),
    (0.556863, 0.243137, 0.239216),
    (0.2, 0.101961, 0.0980392),
]

class IconGenerator {

    private let view = MoodView()

    init() {
        view.colors = rgbValues.map { UIColor(red: $0.0, green: $0.1, blue: $0.2, alpha: 1) }
    }

    func generateIcons() {
        let widths = [29, 40, 60]
        let scales = [2, 3]
        widths.forEach { width in
            scales.forEach { scale in
                generateIconWithWidth(width, scale: scale)
            }
        }
    }

    private func generateIconWithWidth(width: Int, scale: Int) {
        let size = CGSize(width: width, height: width)
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        view.frame = CGRect(origin: CGPoint(), size: size)
        [view .drawRect(view.frame)]
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let pngData = UIImagePNGRepresentation(image)
        let url = iconFileURLWithName("AppIcon-\(width)@\(scale)x")
        try! pngData?.writeToURL(url, options: NSDataWritingOptions())
        print(url.path!)
    }

    func iconFileURLWithName(name: String) -> NSURL {
        var url = NSURL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        url = url.URLByAppendingPathComponent(name)
        return url.URLByAppendingPathExtension("png")
    }
}
