//
//  Notifications.swift
//  Moody
//
//  Created by Daniel Eggert on 24/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData


struct ObjectsDidChangeNotification {

    init(note: Notification) {
        assert(note.name == NSNotification.Name.NSManagedObjectContextObjectsDidChange)
        notification = note
    }

    var insertedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInsertedObjectsKey)
    }

    var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }

    var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }

    var refreshedObjects: Set<NSManagedObject> {
        return objects(forKey: NSRefreshedObjectsKey)
    }

    var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }

    var invalidatedAllObjects: Bool {
        return (notification as NSNotification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    fileprivate let notification: Notification

    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        return ((notification as NSNotification).userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }

}


extension NSManagedObjectContext {

    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's objects-did-change notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }

}


