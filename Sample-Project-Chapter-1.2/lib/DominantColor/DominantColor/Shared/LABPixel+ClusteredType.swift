//
//  LABPixel+ClusteredType.swift
//  DominantColor
//
//  Created by Indragie on 12/24/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//


extension LABPixel: ClusteredType {}

extension LABPixel {
    func unpack() -> (Float, Float, Float) {
        return (L, a, b)
    }

    static var identity: LABPixel {
        return LABPixel(L: 0, a: 0, b: 0)
    }
}

func +(lhs: LABPixel, rhs: LABPixel) -> LABPixel {
    return LABPixel(L: lhs.L + rhs.L, a: lhs.a + rhs.a, b: lhs.b + rhs.b)
}

func /(lhs: LABPixel, rhs: Float) -> LABPixel {
    return LABPixel(L: lhs.L / rhs, a: lhs.a / rhs, b: lhs.b / rhs)
}

func /(lhs: LABPixel, rhs: Int) -> LABPixel {
    return lhs / Float(rhs)
}

