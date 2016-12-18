//
//  RemoteDeletable.swift
//  Moody
//
//  Created by Florian on 05/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers


private let MarkedForRemoteDeletionKey = "markedForRemoteDeletion"

public protocol RemoteDeletable: class {
    var changedForRemoteDeletion: Bool { get }
    var markedForRemoteDeletion: Bool { get set }
    func markForRemoteDeletion()
}


extension RemoteDeletable {
    public static var notMarkedForRemoteDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == false", MarkedForRemoteDeletionKey)
    }

    public static var markedForRemoteDeletionPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: notMarkedForRemoteDeletionPredicate)
    }

    /// Marks an object to be deleted remotely, on the backend (i.e. Cloud Kit).
    /// Once it has been deleted on the backend, it will get marked for deletion locally by the sync code base.
    /// An object marked for remote deletion will no longer match the `notMarkedForDeletionPredicate`.
    public func markForRemoteDeletion() {
        markedForRemoteDeletion = true
    }
}


extension RemoteDeletable where Self: NSManagedObject {
    public var changedForRemoteDeletion: Bool {
        return changedValue(forKey: MarkedForRemoteDeletionKey) as? Bool == true
    }
}


extension RemoteDeletable where Self: DelayedDeletable {
    public static var notMarkedForDeletionPredicate: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [notMarkedForLocalDeletionPredicate, notMarkedForRemoteDeletionPredicate])
    }
}


