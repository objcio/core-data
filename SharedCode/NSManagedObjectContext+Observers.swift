//
//  Notifications.swift
//  Moody
//
//  Created by Daniel Eggert on 24/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData


public struct ContextDidSaveNotification {

    public init(note: NSNotification) {
        guard note.name == NSManagedObjectContextDidSaveNotification else { fatalError() }
        notification = note
    }

    public var insertedObjects: AnyGenerator<ManagedObject> {
        return generatorForKey(NSInsertedObjectsKey)
    }

    public var updatedObjects: AnyGenerator<ManagedObject> {
        return generatorForKey(NSUpdatedObjectsKey)
    }

    public var deletedObjects: AnyGenerator<ManagedObject> {
        return generatorForKey(NSDeletedObjectsKey)
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    private let notification: NSNotification

    private func generatorForKey(key: String) -> AnyGenerator<ManagedObject> {
        guard let set = notification.userInfo?[key] as? NSSet else {
            return AnyGenerator { nil }
        }
        let innerGenerator = set.generate()
        return AnyGenerator { return innerGenerator.next() as? ManagedObject }
    }

}


extension ContextDidSaveNotification: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [notification.name]
        components.append(managedObjectContext.description)
        for (name, set) in [("inserted", insertedObjects), ("updated", updatedObjects), ("deleted", deletedObjects)] {
            let all = set.map { $0.objectID.description }.joinWithSeparator(", ")
            components.append("\(name): {\(all)}")
        }
        return components.joinWithSeparator(" ")
    }
}


public struct ContextWillSaveNotification {

    public init(note: NSNotification) {
        assert(note.name == NSManagedObjectContextWillSaveNotification)
        notification = note
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    private let notification: NSNotification

}


public struct ObjectsDidChangeNotification {

    init(note: NSNotification) {
        assert(note.name == NSManagedObjectContextObjectsDidChangeNotification)
        notification = note
    }

    public var insertedObjects: Set<ManagedObject> {
        return objectsForKey(NSInsertedObjectsKey)
    }

    public var updatedObjects: Set<ManagedObject> {
        return objectsForKey(NSUpdatedObjectsKey)
    }

    public var deletedObjects: Set<ManagedObject> {
        return objectsForKey(NSDeletedObjectsKey)
    }

    public var refreshedObjects: Set<ManagedObject> {
        return objectsForKey(NSRefreshedObjectsKey)
    }

    public var invalidatedObjects: Set<ManagedObject> {
        return objectsForKey(NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects: Bool {
        return notification.userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    private let notification: NSNotification

    private func objectsForKey(key: String) -> Set<ManagedObject> {
        return (notification.userInfo?[key] as? Set<ManagedObject>) ?? Set()
    }

}


extension NSManagedObjectContext {

    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's did-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addContextDidSaveNotificationObserver(handler: ContextDidSaveNotification -> ()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextDidSaveNotification, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's will-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addContextWillSaveNotificationObserver(handler: ContextWillSaveNotification -> ()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: nil) { note in
            let wrappedNote = ContextWillSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's objects-did-change notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addObjectsDidChangeNotificationObserver(handler: ObjectsDidChangeNotification -> ()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }

    public func performMergeChangesFromContextDidSaveNotification(note: ContextDidSaveNotification) {
        performBlock {
            self.mergeChangesFromContextDidSaveNotification(note.notification)
        }
    }

}

