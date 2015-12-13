//
//  ValueTransformer.swift
//  Moody
//
//  Created by Florian on 15/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation


class ValueTransformer<A: AnyObject, B: AnyObject>: NSValueTransformer {

    typealias Transform = A? -> B?
    typealias ReverseTransform = B? -> A?

    private let transform: Transform
    private let reverseTransform: ReverseTransform

    init(transform: Transform, reverseTransform: ReverseTransform) {
        self.transform = transform
        self.reverseTransform = reverseTransform
        super.init()
    }

    static func registerTransformerWithName(name: String, transform: Transform, reverseTransform: ReverseTransform) {
        let vt = ValueTransformer(transform: transform, reverseTransform: reverseTransform)
        NSValueTransformer.setValueTransformer(vt, forName: name)
    }

    override static func transformedValueClass() -> AnyClass {
        return B.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return transform(value as? A)
    }

    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return reverseTransform(value as? B)
    }

}

