//
//  InProgressTracker.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation
import CoreDataHelpers


/// Tracks managed objects that are being *in progress*.
class InProgressTracker<O: ManagedObject where O: ManagedObjectType> {

    private var objectsInProgress = Set<O>()

    init() {}

    /// Returns those objects from the given `objects` that are not yet in progress.
    /// These new objects are then marked as being in progress.
    func objectsToProcessFromObjects(objects: [O]) -> [O] {
        let added = objects.filter { !objectsInProgress.contains($0) }
        objectsInProgress.unionInPlace(added)
        return added
    }

    /// Marks the given objects as being complete, i.e. no longer in progress.
    func markObjectsAsComplete(objects: [O]) {
        objectsInProgress.subtractInPlace(objects)
    }

}


extension InProgressTracker: CustomDebugStringConvertible {
    var debugDescription: String {
        var components = ["InProgressTracker"]
        components.append("count=\(objectsInProgress.count)")
        let all = objectsInProgress.map { $0.objectID.description }.joinWithSeparator(", ")
        components.append("{\(all)}")
        return components.joinWithSeparator(" ")
    }
}
