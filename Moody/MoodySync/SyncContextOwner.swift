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
/// This protocol merges changes from the main context into the sync context and vice versa.
/// It calls its `processChangedLocalObjects()` methods when objects have changed.
protocol ContextOwnerType: class, ObserverTokenStore {
    /// The UI / main thread managed object context.
    var mainManagedObjectContext: NSManagedObjectContext { get }
    /// The managed object context that is used to perform synchronization with the backend.
    var syncManagedObjectContext: NSManagedObjectContext { get }
    /// This group tracks any outstanding work.
    var syncGroup: dispatch_group_t { get }

    var didSetup: Bool { get }

    /// Will be called whenever objects on the sync managed object context have changed.
    func processChangedLocalObjects(managedObjects: [NSManagedObject])
}


extension ContextOwnerType {
    func setupContexts() {
        setupContextNotificationObserving()
    }

    private func setupContextNotificationObserving() {
        addObserverToken(
            mainManagedObjectContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.mainContextDidSave(note)
            }
        )
        addObserverToken(
            syncManagedObjectContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.syncContextDidSave(note)
            }
        )
        addObserverToken(syncManagedObjectContext.addObjectsDidChangeNotificationObserver { [weak self] note in
            self?.objectsInSyncContextDidChange(note)
        })
    }

    /// Merge changes from main -> sync context.
    private func mainContextDidSave(note: ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performMergeChangesFromContextDidSaveNotification(note)
        notifyAboutChangedObjectsFromSaveNotification(note)
    }

    /// Merge changes from sync -> main context.
    private func syncContextDidSave(note: ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        mainManagedObjectContext.performMergeChangesFromContextDidSaveNotification(note)
        notifyAboutChangedObjectsFromSaveNotification(note)
    }

    private func objectsInSyncContextDidChange(note: ObjectsDidChangeNotification) {
        precondition(didSetup, "Did not call setup()")
    }

    private func notifyAboutChangedObjectsFromSaveNotification(note: ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performBlockWithGroup(syncGroup) {
            // We unpack the notification here, to make sure it's retained
            // until this point.
            let updates = note.updatedObjects.remapToContext(self.syncManagedObjectContext)
            let inserts = note.insertedObjects.remapToContext(self.syncManagedObjectContext)
            self.processChangedLocalObjects(updates + inserts)
        }
    }
}
