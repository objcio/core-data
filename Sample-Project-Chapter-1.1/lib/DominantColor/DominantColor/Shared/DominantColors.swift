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
    case low
    /// CIE 94 - Perceptual non-uniformity corrections
    case medium
    /// CIE 2000 - Additional corrections for neutral colors, lightness, chroma, and hue
    case high
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
    public static let Default = DominantColorOptions(maxSampledPixelCount: 1000, accuracy: .medium, k: 16, seed: 3571, deemphasizeBlacks: false)
    public static let Moody = DominantColorOptions(maxSampledPixelCount: 800, accuracy: .high, k: 11, seed: 1300304177, deemphasizeBlacks: true)
}


extension CGImage {
    public func dominantColors(_ options: DominantColorOptions = .Default) -> AnyIterator<CGColor> {
        let labValues = self.labValuesWithMaxPixelCount(options.maxSampledPixelCount)

        // Cluster the colors using the k-means algorithm
        var clusters = kmeans(labValues, k: options.k, seed: options.seed, distance: options.distanceFunction)

        // Sort the clusters by size in descending order so that the
        // most dominant colors come first.
        clusters.sort {
            return $0.size > $1.size
        }

        var clusterGenerator = clusters.makeIterator()
        return AnyIterator { () -> CGColor? in
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
    func labValuesWithMaxPixelCount(_ maxPixelCount: Int) -> [LABPixel] {
        let width = self.width
        let height = self.height
        let (scaledWidth, scaledHeight) = scaledDimensionsForPixelLimit(maxPixelCount, width, height)

        // Downsample the image if necessary, so that the total number of
        // pixels sampled does not exceed the specified maximum.
        let context = createLinearARGBContextWithWidth(scaledWidth, height: scaledHeight)
        context.draw(self, in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))

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

private func createLinearARGBContextWithWidth(_ width: Int, height: Int) -> CGContext {
    let bitsPerComponent = 8
    let bitsPerPixel = 4 * bitsPerComponent
    let bytesPerRow = width * bitsPerPixel / 8
    let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
    guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { fatalError("Unable to create bitmap context") }
    return ctx
}

private func enumerateARGBContext(_ context: CGContext, handler: (ARGBPixel_t) -> Void) {
    precondition(context.bitsPerComponent == 8, "Need 8 bits / component")
    precondition(context.bitsPerPixel == 8 * 4, "Need 32 bits / pixel")
    precondition(context.alphaInfo == .premultipliedFirst, "Need premultiplied alpha as first component")
    let (width, height) = (context.width, context.height)
    let data = unsafeBitCast(context.data, to: UnsafeMutablePointer<ARGBPixel_t>.self)
    for y in 0..<height {
        for x in 0..<width {
            handler(data[Int(x + y * width)])
        }
    }
}

extension DominantColorOptions {
    fileprivate var distanceFunction: (LABPixel, LABPixel) -> Float {
        switch accuracy {
        case .low:
            return CIE76SquaredColorDifference
        case .medium:
            return CIE94SquaredColorDifference()
        case .high:
            return CIE2000SquaredColorDifference()
        }
    }
}

// Computes the proportionally scaled dimensions such that the
// total number of pixels does not exceed the specified limit.
private func scaledDimensionsForPixelLimit(_ limit: Int, _ width: Int, _ height: Int) -> (Int, Int) {
    if width * height > limit {
        let ratio = Float(width) / Float(height)
        let maxWidth = sqrt(ratio * Float(limit))
        return (Int(maxWidth), Int(Float(limit) / maxWidth))
    }
    return (width, height)
}

