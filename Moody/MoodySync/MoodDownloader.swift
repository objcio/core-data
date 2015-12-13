//
//  MoodDownloader.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData
import MoodyModel


final class MoodDownloader: ChangeProcessorType {
    func setupForContext(context: ChangeProcessorContextType) {
        context.remote.setupMoodSubscription()
    }

    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType) {
        // no-op
    }

    func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], context: ChangeProcessorContextType, completion: () -> ()) {
        var creates: [RemoteMood] = []
        var deletes: [RemoteRecordID] = []
        for change in changes {
            switch change {
            case .Insert(let r) where r is RemoteMood: creates.append(r as! RemoteMood)
            case .Delete(let id): deletes.append(id)
            default: fatalError("change reason not implemented")
            }
        }

        insertRemoteMoods(creates, inContext: context.managedObjectContext)
        deleteMoodsWithRecordIDs(deletes, inContext: context.managedObjectContext)
        context.delayedSaveOrRollback()
        completion()
    }

    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        context.remote.fetchLatestMoods { remoteMoods in
            context.performGroupedBlock {
                self.insertRemoteMoods(remoteMoods, inContext: context.managedObjectContext)
                context.delayedSaveOrRollback()
            }
        }
    }

    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        return nil
    }

}


extension MoodDownloader {

    private func deleteMoodsWithRecordIDs(recordIDs: [RemoteRecordID], inContext moc: NSManagedObjectContext) {
        guard !recordIDs.isEmpty else { return }
        let moods = Mood.fetchInContext(moc) { (request) -> () in
            request.predicate = Mood.predicateForRemoteIdentifiers(recordIDs)
            request.returnsObjectsAsFaults = false
        }
        moods.forEach { $0.markForLocalDeletion() }
    }

    private func insertRemoteMoods(remoteMoods: [RemoteMood], inContext moc: NSManagedObjectContext) {
        let existingMoods = { () -> [RemoteRecordID: Mood] in
            let ids = remoteMoods.map { $0.id }.flatMap { $0 }
            let moods = Mood.fetchInContext(moc) { request in
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
            remoteMood.insertIntoContext(moc)
        }
    }

}

