//
//  MoodRemover.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodRemover: ElementChangeProcessor {

    var elementsInProgress = InProgressTracker<Mood>()

    func setup(for context: ChangeProcessorContext) {
        // no-op
    }

    func processChangedLocalElements(_ objects: [Mood], in context: ChangeProcessorContext) {
        processDeletedMoods(objects, in: context)
    }

    func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ()) {
        // no-op
        completion()
    }

    func fetchLatestRemoteRecords(in context: ChangeProcessorContext) {
        // no-op
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        let marked = Mood.markedForRemoteDeletionPredicate
        let notDeleted = Mood.notMarkedForLocalDeletionPredicate
        return NSCompoundPredicate(andPredicateWithSubpredicates:[marked, notDeleted])
    }
}


extension MoodRemover {

    fileprivate func processDeletedMoods(_ deletions: [Mood], in context: ChangeProcessorContext) {
        let allObjects = Set(deletions)
        let localOnly = allObjects.filter { $0.remoteIdentifier == nil }
        let objectsToDeleteRemotely = allObjects.subtracting(localOnly)
        deleteLocally(localOnly, context: context)
        deleteRemotely(objectsToDeleteRemotely, context: context)
    }

    fileprivate func deleteLocally(_ deletions: Set<Mood>, context: ChangeProcessorContext) {
        deletions.forEach { $0.markForLocalDeletion() }
    }

    fileprivate func deleteRemotely(_ deletions: Set<Mood>, context: ChangeProcessorContext) {
        context.remote.remove(Array(deletions), completion: context.perform { deletedRecordIDs, error in
            var deletedIDs = Set(deletedRecordIDs)
            if case .permanent(let ids)? = error {
                deletedIDs.formUnion(ids)
            }

            let toBeDeleted = deletions.filter { deletedIDs.contains($0.remoteIdentifier ?? "") }
            self.deleteLocally(toBeDeleted, context: context)
            // This will retry failures with non-permanent failures:
            self.didComplete(Array(deletions), in: context)
            context.delayedSaveOrRollback()
        })
    }

}

