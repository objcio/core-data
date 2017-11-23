//
//  CloudKitRemote.swift
//  Moody
//
//  Created by Florian on 21/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CloudKit
import MoodyModel

final class CloudKitRemote: MoodyRemote {

    let cloudKitContainer = CKContainer.default()
    let maximumNumberOfMoods = 500

    func setupMoodSubscription() {
        let subscriptionID = "MoodDownload"
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let options: CKQuerySubscriptionOptions = [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        let subscription = CKQuerySubscription(recordType: "Mood", predicate: predicate, subscriptionID: subscriptionID, options: options)
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        let op = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        op.modifySubscriptionsCompletionBlock = { (foo, bar, error: Error?) -> () in
            if let e = error { print("Failed to modify subscription: \(e)") }
        }
        cloudKitContainer.publicCloudDatabase.add(op)
    }

    func fetchLatestMoods(completion: @escaping ([RemoteMood]) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Mood", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: false) ]
        let op = CKQueryOperation(query: query)
        op.resultsLimit = maximumNumberOfMoods
        op.fetchAggregateResults(in: cloudKitContainer.publicCloudDatabase, previousResults: []) { records, _ in
            completion(records.map { RemoteMood(record: $0) }.flatMap { $0 })
        }
    }

    func fetchNewMoods(completion: @escaping ([RemoteRecordChange<RemoteMood>], @escaping (_ success: Bool) -> ()) -> ()) {
        cloudKitContainer.fetchAllPendingNotifications(changeToken: nil) { changeReasons, error, callback in
            guard error == nil else { return completion([], { _ in }) } // TODO We should handle this case with e.g. a clean refetch
            guard changeReasons.count > 0 else { return completion([], callback) }
            self.cloudKitContainer.publicCloudDatabase.fetchRecords(for: changeReasons) { changes, error in
                completion(changes.map { RemoteRecordChange(moodChange: $0) }.flatMap { $0 }, callback)
            }
        }
    }

    func upload(_ moods: [Mood], completion: @escaping ([RemoteMood], RemoteError?) -> ()) {
        let recordsToSave = moods.map { $0.cloudKitRecord }
        let op = CKModifyRecordsOperation(recordsToSave: recordsToSave,
            recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { modifiedRecords, _, error in
            let remoteMoods = modifiedRecords?.map { RemoteMood(record: $0) }.flatMap { $0 } ?? []
            let remoteError = RemoteError(cloudKitError: error)
            completion(remoteMoods, remoteError)
        }
        cloudKitContainer.publicCloudDatabase.add(op)
    }

    func remove(_ moods: [Mood], completion: @escaping ([RemoteRecordID], RemoteError?) -> ()) {
        let recordIDsToDelete = moods.map { (mood: Mood) -> CKRecordID in
            guard let name = mood.remoteIdentifier else { fatalError("Must have a remote ID") }
            return CKRecordID(recordName: name)
        }
        let op = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
        op.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
            completion((deletedRecordIDs ?? []).map { $0.recordName }, RemoteError(cloudKitError: error))
        }
        cloudKitContainer.publicCloudDatabase.add(op)
    }

    func fetchUserID(completion: @escaping (RemoteRecordID?) -> ()) {
        cloudKitContainer.fetchUserRecordID { userRecordID, error in
            completion(userRecordID?.recordName)
        }
    }

}


extension RemoteError {
    fileprivate init?(cloudKitError: Error?) {
        guard let error = cloudKitError.flatMap({ $0 as NSError }) else { return nil }
        if error.permanentCloudKitError {
            self = .permanent(error.partiallyFailedRecordIDsWithPermanentError.map { $0.recordName })
        } else {
            self = .temporary
        }
    }
}


extension RemoteRecordChange {
    fileprivate init?(moodChange: CloudKitRecordChange) {
        switch moodChange {
        case .created(let r):
            guard let remoteMood = RemoteMood(record: r) as? T else { return nil }
            self = RemoteRecordChange.insert(remoteMood)
        case .updated(let r):
            guard let remoteMood = RemoteMood(record: r) as? T else { return nil }
            self = RemoteRecordChange.update(remoteMood)
        case .deleted(let id):
            self = RemoteRecordChange.delete(id.recordName)
        }
    }
}


extension RemoteMood {
    fileprivate static var remoteRecordName: String { return "Mood" }

    fileprivate init?(record: CKRecord) {
        guard record.recordType == RemoteMood.remoteRecordName else { fatalError("wrong record type") }
        guard let date = record.object(forKey: "date") as? Date,
            let colorData = record.object(forKey: "colors") as? Data,
            let colors = colorData.moodColors,
            let countryCode = record.object(forKey: "country") as? Int,
            let creatorID = record.creatorUserRecordID?.recordName
            else { return nil }
        let isoCountry = ISO3166.Country(rawValue: Int16(countryCode)) ?? ISO3166.Country.unknown
        let location = record.object(forKey: "location") as? CLLocation
        self.id = record.recordID.recordName
        self.creatorID = creatorID
        self.date = date
        self.location = location
        self.colors = colors
        self.isoCountry = isoCountry
    }
}


extension Mood {
    fileprivate var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: RemoteMood.remoteRecordName)
        //TODO(swift3) Do we have to cast / wrap NSDate, NSData, NSNumber...?
        record["date"] = date as NSDate
        record["location"] = location
        record["colors"] = colors.moodData as NSData
        record["country"] = NSNumber(value: country?.iso3166Code.rawValue ?? 0)
        record["version"] = NSNumber(value: 1)
        return record
    }
}

