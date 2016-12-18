//
//  ColorSpaceConversion.swift
//  Moody
//
//  Created by Daniel Eggert on 06/09/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation
import CoreGraphics


/// Color in the Lab color space
/// Cf. <https://en.wikipedia.org/wiki/Lab_color_space>
struct LABPixel {
    let L: Float
    let a: Float
    let b: Float
    init(L: Float, a: Float, b: Float) {
        self.L = L
        self.a = a
        self.b = b
    }
}

private let delta = Float(6.0 / 29.0)

extension LABPixel {
    init(rgb: ARGBPixel_t) {
        let xyz = XYZ(rgb: rgb)
        self.init(xyz: xyz)
    }
    init(xyz: XYZ) {
        let t0 = powf(delta, 3)
        let third = Float(1.0 / 3.0)

        let f = { (t: Float) -> Float in
            if t > t0 {
                return powf(t, third)
            } else {
                return third / delta / delta * t + 4.0 / 29.0
            }
        }

        self.L = 116.0 * f(xyz.y / tristimulus.y) - 16
        self.a = 500.0 * (f(xyz.x / tristimulus.x) - f(xyz.y / tristimulus.y))
        self.b = 200.0 * (f(xyz.y / tristimulus.y) - f(xyz.z / tristimulus.z))
    }
    init(lch: CIELCh) {
        L = lch.L
        a = lch.C * cos(lch.h)
        b = lch.C * sin(lch.h)
    }
}


/// Cylindrical representation: CIELCh
/// Cf. <https://en.wikipedia.org/wiki/Lab_color_space#Cylindrical_representation:_CIELCh_or_CIEHLC>
struct CIELCh {
    /// Luminance
    let L: Float
    /// Chroma (saturation)
    let C: Float
    /// hue
    let h: Float
    init(L: Float, C: Float, h: Float) {
        self.L = L
        self.C = C
        self.h = h
    }
    init(lab: LABPixel) {
        L = lab.L
        C = sqrt(lab.a*lab.a+lab.b*lab.b)
        h = atan2(lab.b, lab.a)
    }
}

extension ARGBPixel_t {
    fileprivate init(xyz: XYZ) {
        let matrix: [Float] = [
            0.41847,   -0.15866,  -0.082835,
            -0.091169,   0.25243,   0.015708,
            0.0009209, -0.0025498, 0.1786,
        ]
        self.a = UInt8.max
        self.r = UInt8(max(min(xyz.x * matrix[0] + xyz.y * matrix[1] + xyz.z * matrix[2], Float(UInt8.max)), 0))
        self.g = UInt8(max(min(xyz.x * matrix[3] + xyz.y * matrix[4] + xyz.z * matrix[5], Float(UInt8.max)), 0))
        self.b = UInt8(max(min(xyz.x * matrix[6] + xyz.y * matrix[7] + xyz.z * matrix[8], Float(UInt8.max)), 0))
    }
    init(lab: LABPixel) {
        let xyz = XYZ(lab: lab)
        self.init(xyz: xyz)
    }
}


extension ARGBPixel_t {
    var CGColor: CoreGraphics.CGColor {
        let scale = CGFloat(1.0 / 255.0)
        let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
        guard let linear = CoreGraphics.CGColor(colorSpace: colorSpace, components: [scale * CGFloat(r), scale * CGFloat(g), scale * CGFloat(b), scale * CGFloat(a)]) else {
            fatalError("Failed to create CGColor from components.")
        }
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        return linear.converted(to: sRGB, intent: .perceptual, options: nil)!
    }
}


struct XYZ {
    let x: Float
    let y: Float
    let z: Float

    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    init(rgb: ARGBPixel_t) {
        let matrix: [Float] = [
            0.49,    0.31,    0.20,
            0.17697, 0.81240, 0.01036,
            0.0,     0.01,    0.99,
        ]
        self.x = (Float(rgb.r) * matrix[0] + Float(rgb.g) * matrix[1] + Float(rgb.b) * matrix[2]) / Float(0.17697)
        self.y = (Float(rgb.r) * matrix[3] + Float(rgb.g) * matrix[4] + Float(rgb.b) * matrix[5]) / Float(0.17697)
        self.z = (Float(rgb.r) * matrix[6] + Float(rgb.g) * matrix[7] + Float(rgb.b) * matrix[8]) / Float(0.17697)
    }
    init(lab: LABPixel) {
        let s = Float(6.0 / 29.0)
        let f_1 = { (t: Float) -> Float in
            if t > s {
                return powf(t, 3.0)
            } else {
                return 3.0 * s * s * (t - 4.0 / 29.0)
            }
        }
        let l116 = (lab.L + 16) / 116.0
        self.x = tristimulus.x * f_1(l116 + lab.a / 500.0)
        self.y = tristimulus.y * f_1(l116)
        self.z = tristimulus.z * f_1(l116 - lab.b / 200.0)
    }
}

private let tristimulus = XYZ(x: 0.95047, y: 1, z: 1.08883)

extension XYZ: CustomDebugStringConvertible {
    var debugDescription: String {
        return "X: \(x), Y: \(y), Z: \(z)"
    }
}
extension LABPixel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "L: \(L), a: \(a), b: \(b)"
    }
}
extension ARGBPixel_t: CustomDebugStringConvertible {
    public var debugDescription: String {
        if a == UInt8.max {
            return "r: \(r), g: \(g), b: \(b)"
        } else {
            return "r: \(r), g: \(g), b: \(b), a: \(a)"
        }
    }
}

