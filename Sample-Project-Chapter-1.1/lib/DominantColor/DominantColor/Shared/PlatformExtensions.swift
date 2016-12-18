//
//  PlatformExtensions.swift
//  DominantColor
//
//  Created by Indragie on 12/25/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import UIKit

public extension UIImage {
    /**
    Computes the dominant colors in the receiver

    :param: maxSampledPixels   Maximum number of pixels to sample in the image. If
                               the total number of pixels in the image exceeds this
                               value, it will be downsampled to meet the constraint.
    :param: accuracy           Level of accuracy to use when grouping similar colors.
                               Higher accuracy will come with a performance tradeoff.
    :param: seed               Seed to use when choosing the initial points for grouping
                               of similar colors. The same seed is guaranteed to return
                               the same colors every time.
    :param: memoizeConversions Whether to memoize conversions from RGB to the LAB color
                               space (used for grouping similar colors). Memoization
                               will only yield better performance for large values of
                               `maxSampledPixels` in images that are primarily comprised
                               of flat colors. If this information about the image is
                               not known beforehand, it is best to not memoize.

    :returns: A list of dominant colors in the image sorted from most dominant to
              least dominant.
    */
    public func dominantColors(_ options: DominantColorOptions = .Default) -> AnyIterator<UIColor> {
        guard let cgImage = cgImage else { fatalError("Can't convert to CGImage") }
        let colors = cgImage.dominantColors(options)
        return AnyIterator { () -> UIColor? in
            return colors.next().flatMap { UIColor(cgColor: $0) }
        }
    }
}

