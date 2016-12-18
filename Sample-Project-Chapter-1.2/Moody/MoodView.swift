//
//  MoodView.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit


class MoodView: UIView {

    var colors: [UIColor] = [] {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { fatalError("must have graphics context") }
        drawShape(colors, shapes: Rectangle(size: bounds.size).divide(), context: ctx)
    }

}


// MARK: - Private

private func drawShape(_ colors: [UIColor], shapes: (DivisableShape, DivisableShape), context: CGContext) {
    if let (head, tail) = colors.decomposed {
        context.setFillColor(head.cgColor)
        let path = shapes.0.path
        if tail.count == 0 {
            path.append(shapes.1.path)
        }
        context.addPath(path.cgPath)
        context.fillPath()
        drawShape(tail, shapes: shapes.1.divide(), context: context)
    }
}


private protocol DivisableShape {

    var path: UIBezierPath { get }
    func divide() -> (DivisableShape, DivisableShape)

}

private struct Rectangle: DivisableShape {

    var point1: CGPoint
    var point2: CGPoint
    var point3: CGPoint
    var point4: CGPoint

    var path: UIBezierPath {
        return UIBezierPath(points: [point1, point2, point3, point4])
    }

    init(size: CGSize) {
        point1 = CGPoint.zero
        point2 = CGPoint(x: size.width, y: 0)
        point3 = CGPoint(x: size.width, y: size.height)
        point4 = CGPoint(x: 0, y: size.height)
    }

    func divide() -> (DivisableShape, DivisableShape) {
        return (Triangle(point1: point1, point2: point2, point3: point3), Triangle(point1: point3, point2: point4, point3: point1))
    }

}

private struct Triangle: DivisableShape {

    var point1: CGPoint
    var point2: CGPoint
    var point3: CGPoint

    var path: UIBezierPath {
        return UIBezierPath(points: [point1, point2, point3])
    }

    func divide() -> (DivisableShape, DivisableShape) {
        let midPoint = CGPoint(x: (point1.x + point3.x) / 2, y: (point1.y + point3.y) / 2)
        return (Triangle(point1: point2, point2: midPoint, point3: point1), Triangle(point1: point3, point2: midPoint, point3: point2))
    }

}


extension UIBezierPath {
    fileprivate convenience init(points: [CGPoint]) {
        self.init()
        if points.count > 0 {
            move(to: points[0])
            for p in points[1..<points.count] {
                addLine(to: p)
            }
            close()
        }
    }
}

