//
//  SegueHandler.swift
//  Moody
//
//  Created by Florian on 12/06/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


public protocol SegueHandler {
     associatedtype SegueIdentifier: RawRepresentable
}


extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    public func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
        else { fatalError("Unknown segue: \(segue))") }
        return segueIdentifier
    }

    public func performSegue(withIdentifier segueIdentifier: SegueIdentifier) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: nil)
    }
}


