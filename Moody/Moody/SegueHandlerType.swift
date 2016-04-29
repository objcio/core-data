//
//  SegueHandlerType.swift
//  Moody
//
//  Created by Florian on 12/06/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


public protocol SegueHandlerType {
     associatedtype SegueIdentifier: RawRepresentable
}


extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {

    public func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Unknown segue: \(segue))") }
        return segueIdentifier
    }

    public func performSegue(segueIdentifier: SegueIdentifier) {
        performSegueWithIdentifier(segueIdentifier.rawValue, sender: nil)
    }

}

