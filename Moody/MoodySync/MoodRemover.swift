//
//  MoodRemover.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodRemover: ElementChangeProcessorType {

    var elementsInProgress = InProgressTracker<Mood>()

    func setupForContext(context: ChangeProcessorContextType) {
        // no-op
    }

    func processChangedLocalElements(objects: [Mood], context: ChangeProcessorContextType) {
        processDeletedMoods(objects, context: context)
    }

    func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], context: ChangeProcessorContextType, completion: () -> ()) {
        // no-op
        completion()
    }

    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no-op
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        let marked = Mood.markedForRemoteDeletionPredicate
        let notDeleted = Mood.notMarkedForLocalDeletionPredicate
        return NSCompoundPredicate(andPredicateWithSubpredicates:[marked, notDeleted])
    }
}


extension MoodRemover {

    private func processDeletedMoods(deletions: [Mood], context: ChangeProcessorContextType) {
        let allObjects = Set(deletions)
        let localOnly = allObjects.filter { $0.remoteIdentifier == nil }
        let objectsToDeleteRemotely = Array(allObjects.subtract(localOnly))
        deleteMoodsLocally(localOnly, context: context)
        deleteMoodsRemotely(objectsToDeleteRemotely, context: context)
    }

    private func deleteMoodsLocally(deletions: [Mood], context: ChangeProcessorContextType) {
        deletions.forEach { $0.markForLocalDeletion() }
    }

    private func deleteMoodsRemotely(deletions: [Mood], context: ChangeProcessorContextType) {
        context.remote.removeMoods(deletions, completion: context.performGroupedBlock { deletedRecordIDs, error in
            var deletedIDs = Set(deletedRecordIDs)
            if case .Permanent(let ids)? = error {
                deletedIDs.unionInPlace(ids)
            }

            let toBeDeleted = deletions.filter { deletedIDs.contains($0.remoteIdentifier ?? "") }
            self.deleteMoodsLocally(toBeDeleted, context: context)
            // This will retry failures with non-permanent failures:
            self.didCompleteElements(Array(deletions), context: context)
            context.delayedSaveOrRollback()
        })
    }

}
