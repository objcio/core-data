//
//  SyncContextOwner.swift
//  Moody
//
//  Created by Daniel Eggert on 15/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import MoodyModel
import CoreData
import CoreDataHelpers


/// Implements the integration with Core Data change notifications.
///
/// This protocol merges changes from the view context into the sync context and vice versa.
/// It calls its `process(changedLocalObjects:)` methods when objects have changed.
protocol ContextOwner: class, ObserverTokenStore {
    /// The view managed object context.
    var viewContext: NSManagedObjectContext { get }
    /// The managed object context that is used to perform synchronization with the backend.
    var syncContext: NSManagedObjectContext { get }
    /// This group tracks any outstanding work.
    var syncGroup: DispatchGroup { get }

    /// Will be called whenever objects on the sync managed object context have changed.
    func processChangedLocalObjects(_ objects: [NSManagedObject])
}


extension ContextOwner {
    func setupContexts() {
        setupQueryGenerations()
        setupContextNotificationObserving()
    }

    fileprivate func setupQueryGenerations() {
        let token = NSQueryGenerationToken.current
        viewContext.perform {
            try! self.viewContext.setQueryGenerationFrom(token)
        }
        syncContext.perform {
            try! self.syncContext.setQueryGenerationFrom(token)
        }
    }

    fileprivate func setupContextNotificationObserving() {
        addObserverToken(
            viewContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.viewContextDidSave(note)
            }
        )
        addObserverToken(
            syncContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.syncContextDidSave(note)
            }
        )
        addObserverToken(
            syncContext.addObjectsDidChangeNotificationObserver { [weak self] note in
                self?.objectsInSyncContextDidChange(note)
        })
    }

    /// Merge changes from view -> sync context.
    fileprivate func viewContextDidSave(_ note: ContextDidSaveNotification) {
        syncContext.performMergeChanges(from: note)
        notifyAboutChangedObjects(from: note)
    }

    /// Merge changes from sync -> view context.
    fileprivate func syncContextDidSave(_ note: ContextDidSaveNotification) {
        viewContext.performMergeChanges(from: note)
        notifyAboutChangedObjects(from: note)
    }

    fileprivate func objectsInSyncContextDidChange(_ note: ObjectsDidChangeNotification) {
        // no-op
    }

    fileprivate func notifyAboutChangedObjects(from notification: ContextDidSaveNotification) {
        syncContext.perform(group: syncGroup) {
            // We unpack the notification here, to make sure it's retained
            // until this point.
            let updates = notification.updatedObjects.remap(to: self.syncContext)
            let inserts = notification.insertedObjects.remap(to: self.syncContext)
            self.processChangedLocalObjects(updates + inserts)
        }
    }
}

