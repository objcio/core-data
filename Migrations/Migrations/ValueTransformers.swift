//
//  ValueTransformers.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


private var registrationToken: dispatch_once_t = 0
private let ColorsTransformerName = "ColorsTransformer"

func registerValueTransformers() {
    dispatch_once(&registrationToken) {
        ValueTransformer.registerTransformerWithName(ColorsTransformerName, transform: { colors in
            guard let colors = colors as? [UIColor] else { return nil }
            return colors.moodData
        }, reverseTransform: { (data: NSData?) -> NSArray? in
            return data?.moodColors
        })
    }
}


extension NSData {
    public var moodColors: [UIColor]? {
        guard length > 0 && length % 3 == 0 else { return nil }
        var rgbValues = Array(count: length, repeatedValue: UInt8())
        rgbValues.withUnsafeMutableBufferPointer { buffer -> () in
            let voidPointer = UnsafeMutablePointer<Void>(buffer.baseAddress)
            memcpy(voidPointer, bytes, length)
        }
        let rgbSlices = rgbValues.slices(3)
        return rgbSlices.map { slice in
            guard let color = UIColor(rawData: slice) else { fatalError("cannot fail since we know tuple is of length 3") }
            return color
        }
    }
}


extension SequenceType where Generator.Element == UIColor {
    public var moodData: NSData {
        let rgbValues = flatMap { $0.rgb }
        return rgbValues.withUnsafeBufferPointer {
            return NSData(bytes: $0.baseAddress, length: $0.count)
        }
    }
}


extension UIColor {

    private var rgb: [UInt8] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
    }

    private convenience init?(rawData: [UInt8]) {
        if rawData.count != 3 { return nil }
        let red = CGFloat(rawData[0]) / 255
        let green = CGFloat(rawData[1]) / 255
        let blue = CGFloat(rawData[2]) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}
