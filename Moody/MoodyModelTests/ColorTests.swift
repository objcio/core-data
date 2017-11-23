//
//  ColorTests.swift
//  Moody
//
//  Created by Daniel Eggert on 18/10/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
@testable import MoodyModel

private func AssertEqual(_ rgb1: ARGBPixel_t, _ rgb2: ARGBPixel_t, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(Double(rgb1.a), Double(rgb2.a), accuracy: Double(1), "\(message) alpha", file: file, line: line)
    XCTAssertEqual(Double(rgb1.r), Double(rgb2.r), accuracy: Double(1), "\(message) red", file: file, line: line)
    XCTAssertEqual(Double(rgb1.g), Double(rgb2.g), accuracy: Double(1), "\(message) green", file: file, line: line)
    XCTAssertEqual(Double(rgb1.b), Double(rgb2.b), accuracy: Double(1), "\(message) blue", file: file, line: line)
}

private func AssertEqual(_ xyz1: XYZ, _ xyz2: XYZ, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(Double(xyz1.x), Double(xyz2.x), accuracy: Double(1), "\(message) X", file: file, line: line)
    XCTAssertEqual(Double(xyz1.y), Double(xyz2.y), accuracy: Double(1), "\(message) Y", file: file, line: line)
    XCTAssertEqual(Double(xyz1.z), Double(xyz2.z), accuracy: Double(1), "\(message) Z", file: file, line: line)
}


class ColorTests: XCTestCase {

    fileprivate var colorsToTest: [ARGBPixel_t] {
        return [
            ARGBPixel_t(a: 255, r: 0, g: 0, b: 0),
            ARGBPixel_t(a: 255, r: 127, g: 127, b: 127),
            ARGBPixel_t(a: 255, r: 255, g: 255, b: 255),
            ARGBPixel_t(a: 255, r: 255, g: 0, b: 0),
            ARGBPixel_t(a: 255, r: 0, g: 255, b: 0),
            ARGBPixel_t(a: 255, r: 0, g: 0, b: 255),
            ARGBPixel_t(a: 255, r: 237, g: 10, b: 12),
            ARGBPixel_t(a: 255, r: 12, g: 240, b: 88),
            ARGBPixel_t(a: 255, r: 78, g: 24, b: 244),
        ]
    }

    fileprivate func verifyThatItConvertsRGBToLABAndBack(_ rgb: ARGBPixel_t, file: StaticString = #file, line: UInt = #line) {
        let rgbConverted = ARGBPixel_t(lab: LABPixel(rgb: rgb))
        AssertEqual(rgb, rgbConverted, "\(rgb.r)-\(rgb.g)-\(rgb.b)", file: file, line: line)
    }

    func testThatItConvertsRGBToLABAndBack() {
        colorsToTest.forEach { color in
            verifyThatItConvertsRGBToLABAndBack(color)
        }
    }

    fileprivate func verifyThatItConvertsLABAndRGBToXYZ(_ rgb: ARGBPixel_t, file: StaticString = #file, line: UInt = #line) {
        let lab = LABPixel(rgb: rgb)
        AssertEqual(XYZ(rgb: rgb), XYZ(lab: lab), "\(rgb.r)-\(rgb.g)-\(rgb.b)", file: file, line: line)
    }

    func testThatItConvertsLABAndRGBToXYZ() {
        colorsToTest.forEach { color in
            verifyThatItConvertsLABAndRGBToXYZ(color)
        }
    }

    fileprivate func verifyThatItConvertsFromRGBToXYZAndBack(_ rgb: ARGBPixel_t, file: StaticString = #file, line: UInt = #line) {
        let xyz = XYZ(lab: LABPixel(rgb: rgb))
        let rgbConverted = ARGBPixel_t(lab: LABPixel(xyz: xyz))
        AssertEqual(rgb, rgbConverted, "\(rgb.r)-\(rgb.g)-\(rgb.b)", file: file, line: line)
    }

    func testThatItConvertsFromRGBToXYZAndBack() {
        colorsToTest.forEach { color in
            verifyThatItConvertsFromRGBToXYZAndBack(color)
        }
    }

    fileprivate func verifyThatItConverstFromRGBToLabToLChAndBack(_ rgb: ARGBPixel_t, file: StaticString = #file, line: UInt = #line) {
        let lch = CIELCh(lab: LABPixel(rgb: rgb))
        print(rgb)
        print(lch)
        let rgbConverted = ARGBPixel_t(lab: LABPixel(lch: lch))
        AssertEqual(rgb, rgbConverted, "\(rgb.r)-\(rgb.g)-\(rgb.b)", file: file, line: line)
    }

    func testThatItConverstFromRGBToLabToLChAndBack() {
        colorsToTest.forEach { color in
            verifyThatItConverstFromRGBToLabToLChAndBack(color)
        }
    }

}

