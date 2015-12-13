//
//  DelayedDeletable.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreDataHelpers
import CoreData


private let MarkedForDeletionDateKey = "markedForDeletionDate"

public protocol DelayedDeletable: class {
    var changedForDelayedDeletion: Bool { get }
    var markedForDeletionDate: NSDate? { get set }
    func markForLocalDeletion()
}


extension DelayedDeletable {
    public static var notMarkedForLocalDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL", MarkedForDeletionDateKey)
    }
}


extension DelayedDeletable where Self: ManagedObject {
    public var changedForDelayedDeletion: Bool {
        return changedValues()[MarkedForDeletionDateKey] as? NSDate != nil
    }

    /// Mark an object to be deleted at a later point in time.
    /// An object marked for local deletion will no longer match the
    /// `notMarkedForDeletionPredicate`.
    public func markForLocalDeletion() {
        guard fault || markedForDeletionDate == nil else { return }
        markedForDeletionDate = NSDate()
    }
}


/// Objects that have been marked for local deletion more than this time (in seconds) ago will get permanently deleted.
private let DeletionAgeBeforePermanentlyDeletingObjects = NSTimeInterval(2 * 60)

extension NSManagedObjectContext {
    public func batchDeleteObjectsMarkedForLocalDeletion() {
        Mood.batchDeleteObjectsMarkedForLocalDeletionInContext(self)
        Country.batchDeleteObjectsMarkedForLocalDeletionInContext(self)
        Continent.batchDeleteObjectsMarkedForLocalDeletionInContext(self)
    }
}


extension ManagedObjectType where Self: ManagedObject {
    private static func batchDeleteObjectsMarkedForLocalDeletionInContext(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let cutoff = NSDate(timeIntervalSinceNow: -DeletionAgeBeforePermanentlyDeletingObjects)
        fetchRequest.predicate = NSPredicate(format: "%K < %@", MarkedForDeletionDateKey, cutoff)
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchRequest.resultType = .ResultTypeStatusOnly
        try! managedObjectContext.executeRequest(batchRequest)
    }
}

