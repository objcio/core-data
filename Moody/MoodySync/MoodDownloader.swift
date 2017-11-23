//
//  MoodDownloader.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodDownloader: ChangeProcessor {
    func setup(for context: ChangeProcessorContext) {
        context.remote.setupMoodSubscription()
    }

    func processChangedLocalObjects(_ objects: [NSManagedObject], in context: ChangeProcessorContext) {
        // no-op
    }

    func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ()) {
        var creates: [RemoteMood] = []
        var deletionIDs: [RemoteRecordID] = []
        for change in changes {
            switch change {
            case .insert(let r) where r is RemoteMood: creates.append(r as! RemoteMood)
            case .delete(let id): deletionIDs.append(id)
            default: fatalError("change reason not implemented")
            }
        }

        insert(creates, into: context.context)
        deleteMoods(with: deletionIDs, in: context.context)
        context.delayedSaveOrRollback()
        completion()
    }

    func fetchLatestRemoteRecords(in context: ChangeProcessorContext) {
        context.remote.fetchLatestMoods { remoteMoods in
            context.perform {
                self.insert(remoteMoods, into: context.context)
                context.delayedSaveOrRollback()
            }
        }
    }

    func entityAndPredicateForLocallyTrackedObjects(in context: ChangeProcessorContext) -> EntityAndPredicate<NSManagedObject>? {
        return nil
    }

}


extension MoodDownloader {

    fileprivate func deleteMoods(with ids: [RemoteRecordID], in context: NSManagedObjectContext) {
        guard !ids.isEmpty else { return }
        let moods = Mood.fetch(in: context) { (request) -> () in
            request.predicate = Mood.predicateForRemoteIdentifiers(ids)
            request.returnsObjectsAsFaults = false
        }
        moods.forEach { $0.markForLocalDeletion() }
    }

    fileprivate func insert(_ remoteMoods: [RemoteMood], into context: NSManagedObjectContext) {
        let existingMoods = { () -> [RemoteRecordID: Mood] in
            let ids = remoteMoods.map { $0.id }.flatMap { $0 }
            let moods = Mood.fetch(in: context) { request in
                request.predicate = Mood.predicateForRemoteIdentifiers(ids)
                request.returnsObjectsAsFaults = false
            }
            var result: [RemoteRecordID: Mood] = [:]
            for mood in moods {
                result[mood.remoteIdentifier!] = mood
            }
            return result
        }()

        for remoteMood in remoteMoods {
            guard let id = remoteMood.id else { continue }
            guard existingMoods[id] == nil else { continue }
            let _ = remoteMood.insert(into: context)
        }
    }

}

