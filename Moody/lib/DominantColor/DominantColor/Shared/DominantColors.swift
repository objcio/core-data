//
//  DominantColors.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import UIKit
import CoreGraphics


// MARK: Main

public enum GroupingAccuracy {
    /// CIE 76 - Euclidian distance
    case Low
    /// CIE 94 - Perceptual non-uniformity corrections
    case Medium
    /// CIE 2000 - Additional corrections for neutral colors, lightness, chroma, and hue
    case High
}

public struct DominantColorOptions {
    /// Maximum number of pixels to sample in the image. If
    /// the total number of pixels in the image exceeds this
    /// value, it will be downsampled to meet the constraint.
    let maxSampledPixelCount: Int
    /// Level of accuracy to use when grouping similar colors.
    /// Higher accuracy will come with a performance tradeoff.
    let accuracy: GroupingAccuracy
    /// Number of clusters for the k-means algorithm
    let k: Int
    /// Seed to use when choosing the initial points for grouping
    /// of similar colors. The same seed is guaranteed to return
    /// the same colors every time.
    let seed: UInt32
    /// Make black(s) less dominant
    let deemphasizeBlacks: Bool
    public static let Default = DominantColorOptions(maxSampledPixelCount: 1000, accuracy: .Medium, k: 16, seed: 3571, deemphasizeBlacks: false)
    public static let Moody = DominantColorOptions(maxSampledPixelCount: 800, accuracy: .High, k: 11, seed: 1300304177, deemphasizeBlacks: true)
}


extension CGImage {
    public func dominantColors(options: DominantColorOptions = .Default) -> AnyGenerator<CGColor> {
        let labValues = self.labValuesWithMaxPixelCount(options.maxSampledPixelCount)

        // Cluster the colors using the k-means algorithm
        var clusters = kmeans(labValues, k: options.k, seed: options.seed, distance: options.distanceFunction)

        // Sort the clusters by size in descending order so that the
        // most dominant colors come first.
        clusters.sortInPlace {
            return $0.size > $1.size
        }

        var clusterGenerator = clusters.generate()
        return AnyGenerator { () -> CGColor? in
            return clusterGenerator.next().flatMap {
                let lab = $0.centroid
                let adjustedLAB = options.deemphasizeBlacks ? lab.deemphasizeBlacks : lab
                return ARGBPixel_t(lab: adjustedLAB).CGColor
            }
        }
    }
}

extension LABPixel {
    var deemphasizeBlacks: LABPixel {
        let lch = CIELCh(lab: self)
        let adjusted = CIELCh(L: lch.L * 1.1, C: lch.C * 1.3, h: lch.h)
        return LABPixel(lch: adjusted)
    }
}

// MARK: Private

private extension CGImage {
    private func labValuesWithMaxPixelCount(maxPixelCount: Int) -> [LABPixel] {
        let width = CGImageGetWidth(self)
        let height = CGImageGetHeight(self)
        let (scaledWidth, scaledHeight) = scaledDimensionsForPixelLimit(maxPixelCount, width, height)

        // Downsample the image if necessary, so that the total number of
        // pixels sampled does not exceed the specified maximum.
        let context = createLinearARGBContextWithWidth(scaledWidth, height: scaledHeight)
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight), self)

        var labValues: [LABPixel] = []
        labValues.reserveCapacity(Int(scaledWidth * scaledHeight))

        enumerateARGBContext(context) { pixel in
            // ignore any pixels that have alpha transparency
            if pixel.a == UInt8.max {
                // Convert the colors to the LAB color space:
                labValues.append(LABPixel(rgb: pixel))
            }
        }
        return labValues
    }
}

private func createLinearARGBContextWithWidth(width: Int, height: Int) -> CGContext {
    let bitsPerComponent = 8
    let bitsPerPixel = 4 * bitsPerComponent
    let bytesPerRow = width * bitsPerPixel / 8
    let bitmapInfo = CGImageAlphaInfo.PremultipliedFirst.rawValue
    let colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear)!
    guard let ctx = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else { fatalError("Unable to create bitmap context") }
    return ctx
}

private func enumerateARGBContext(context: CGContext, handler: (ARGBPixel_t) -> Void) {
    precondition(CGBitmapContextGetBitsPerComponent(context) == 8, "Need 8 bits / component")
    precondition(CGBitmapContextGetBitsPerPixel(context) == 8 * 4, "Need 32 bits / pixel")
    precondition(CGBitmapContextGetAlphaInfo(context) == .PremultipliedFirst, "Need premultiplied alpha as first component")
    let (width, height) = (CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context))
    let data = unsafeBitCast(CGBitmapContextGetData(context), UnsafeMutablePointer<ARGBPixel_t>.self)
    for y in 0..<height {
        for x in 0..<width {
            handler(data[Int(x + y * width)])
        }
    }
}

extension DominantColorOptions {
    private var distanceFunction: (LABPixel, LABPixel) -> Float {
        switch accuracy {
        case .Low:
            return CIE76SquaredColorDifference
        case .Medium:
            return CIE94SquaredColorDifference()
        case .High:
            return CIE2000SquaredColorDifference()
        }
    }
}

// Computes the proportionally scaled dimensions such that the
// total number of pixels does not exceed the specified limit.
private func scaledDimensionsForPixelLimit(limit: Int, _ width: Int, _ height: Int) -> (Int, Int) {
    if width * height > limit {
        let ratio = Float(width) / Float(height)
        let maxWidth = sqrt(ratio * Float(limit))
        return (Int(maxWidth), Int(Float(limit) / maxWidth))
    }
    return (width, height)
}
