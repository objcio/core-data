//
//  MoodUploader.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodUploader: ElementChangeProcessorType {
    var elementsInProgress = InProgressTracker<Mood>()

    func setupForContext(context: ChangeProcessorContextType) {
        // no-op
    }

    func processChangedLocalElements(objects: [Mood], context: ChangeProcessorContextType) {
        processInsertedMoods(objects, context: context)
    }

    func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], context: ChangeProcessorContextType, completion: () -> ()) {
        // no-op
        completion()
    }

    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no-op
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        return Mood.waitingForUploadPredicate
    }
}

extension MoodUploader {
    private func processInsertedMoods(insertions: [Mood], context: ChangeProcessorContextType) {
        context.remote.uploadMoods(insertions,
            completion: context.performGroupedBlock { remoteMoods, error in

            guard !(error?.isPermanent ?? false) else {
                // Since the error was permanent, delete these objects:
                insertions.forEach { $0.markForLocalDeletion() }
                self.elementsInProgress.markObjectsAsComplete(insertions)
                return
            }

            for mood in insertions {
                guard let remoteMood = remoteMoods.findFirstOccurence({ mood.date == $0.date }) else { continue }
                mood.remoteIdentifier = remoteMood.id
                mood.creatorID = remoteMood.creatorID
            }
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete(insertions)
        })
    }
}
