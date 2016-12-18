//
//  ValueTransformers.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


private let ColorsTransformerName = "ColorsTransformer"

func registerValueTransformers() {
    _ = __registerOnce
}

private let __registerOnce: () = {
    ClosureValueTransformer.registerTransformer(withName: ColorsTransformerName, transform: { (colors: NSArray?) -> NSData? in
            guard let colors = colors as? [UIColor] else { return nil }
            return colors.moodData as NSData
    }, reverseTransform: { (data: NSData?) -> NSArray? in
        return (data as? Data)?.moodColors.map { $0 as NSArray }
    })
}()


extension Data {
    public var moodColors: [UIColor]? {
        guard count > 0 && count % 3 == 0 else { return nil }
        var rgbValues = Array(repeating: UInt8(), count: count)
        rgbValues.withUnsafeMutableBufferPointer { buffer in
            let voidPointer = UnsafeMutableRawPointer(buffer.baseAddress)
            let _ = withUnsafeBytes { bytes in
                memcpy(voidPointer, bytes, count)
            }
        }
        let rgbSlices = rgbValues.sliced(size: 3)
        return rgbSlices.map { slice in
            guard let color = UIColor(rawData: slice) else { fatalError("cannot fail since we know tuple is of length 3") }
            return color
        }
    }
}


extension Sequence where Iterator.Element == UIColor {
    public var moodData: NSData {
        let rgbValues = flatMap { $0.rgb }
        return rgbValues.withUnsafeBufferPointer {
            return NSData(bytes: $0.baseAddress, length: $0.count)
        }
    }
}


extension UIColor {
    fileprivate var rgb: [UInt8] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
    }

    fileprivate convenience init?(rawData: [UInt8]) {
        if rawData.count != 3 { return nil }
        let red = CGFloat(rawData[0]) / 255
        let green = CGFloat(rawData[1]) / 255
        let blue = CGFloat(rawData[2]) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

