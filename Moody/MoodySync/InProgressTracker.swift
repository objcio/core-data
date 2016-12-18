//
//  InProgressTracker.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


/// Tracks managed objects that are being *in progress*.
final class InProgressTracker<O: NSManagedObject> where O: Managed {

    fileprivate var objectsInProgress = Set<O>()

    init() {}

    /// Returns those objects from the given `objects` that are not yet in progress.
    /// These new objects are then marked as being in progress.
    func objectsToProcess(from objects: [O]) -> [O] {
        let added = objects.filter { !objectsInProgress.contains($0) }
        objectsInProgress.formUnion(added)
        return added
    }

    /// Marks the given objects as being complete, i.e. no longer in progress.
    func markObjectsAsComplete(_ objects: [O]) {
        objectsInProgress.subtract(objects)
    }

}


extension InProgressTracker: CustomDebugStringConvertible {
    var debugDescription: String {
        var components = ["InProgressTracker"]
        components.append("count=\(objectsInProgress.count)")
        let all = objectsInProgress.map { $0.objectID.description }.joined(separator: ", ")
        components.append("{\(all)}")
        return components.joined(separator: " ")
    }
}

