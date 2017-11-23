//
//  MoodUploader.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodUploader: ElementChangeProcessor {
    var elementsInProgress = InProgressTracker<Mood>()

    func setup(for context: ChangeProcessorContext) {
        // no-op
    }

    func processChangedLocalElements(_ objects: [Mood], in context: ChangeProcessorContext) {
        processInsertedMoods(objects, in: context)
    }

    func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ()) {
        // no-op
        completion()
    }

    func fetchLatestRemoteRecords(in context: ChangeProcessorContext) {
        // no-op
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        return Mood.waitingForUploadPredicate
    }
}

extension MoodUploader {
    fileprivate func processInsertedMoods(_ insertions: [Mood], in context: ChangeProcessorContext) {
        context.remote.upload(insertions,
            completion: context.perform { remoteMoods, error in

            guard !(error?.isPermanent ?? false) else {
                // Since the error was permanent, delete these objects:
                insertions.forEach { $0.markForLocalDeletion() }
                self.elementsInProgress.markObjectsAsComplete(insertions)
                return
            }

            for mood in insertions {
                guard let remoteMood = remoteMoods.first(where: { mood.date == $0.date }) else { continue }
                mood.remoteIdentifier = remoteMood.id
                mood.creatorID = remoteMood.creatorID
            }
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete(insertions)
        })
    }
}

