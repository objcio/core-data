//
//  CloudKitRemote.swift
//  Moody
//
//  Created by Florian on 21/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CloudKit
import MoodyModel

struct CloudKitRemote: MoodyRemoteType {

    let cloudKitContainer = CKContainer.defaultContainer()
    let maximumNumberOfMoods = 500

    func setupMoodSubscription() {
        let subscriptionID = "MoodDownload"
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let options: CKSubscriptionOptions = [.FiresOnRecordCreation, .FiresOnRecordUpdate, .FiresOnRecordDeletion]
        let subscription = CKSubscription(recordType: "Mood", predicate: predicate, subscriptionID: subscriptionID, options: options)
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        let op = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        op.modifySubscriptionsCompletionBlock = { (foo, bar, error: NSError?) -> () in
            if let e = error { print("Failed to modify subscription: \(e)") }
        }
        cloudKitContainer.publicCloudDatabase.addOperation(op)
    }

    func fetchLatestMoods(completion: ([RemoteMood]) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Mood", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: false) ]
        let op = CKQueryOperation(query: query)
        op.resultsLimit = maximumNumberOfMoods
        op.fetchAggregateResultsInDatabase(cloudKitContainer.publicCloudDatabase, previousResults: []) { records, _ in
            completion(records.map { RemoteMood(record: $0) }.flatMap { $0 })
        }
    }

    func fetchNewMoods(completion: ([RemoteRecordChange<RemoteMood>], (success: Bool) -> ()) -> ()) {
        cloudKitContainer.fetchAllPendingNotifications { changeReasons, error, callback in
            guard error == nil else { return completion([], { _ in }) } // TODO We should handle this case with e.g. a clean refetch
            guard changeReasons.count > 0 else { return completion([], callback) }
            self.cloudKitContainer.publicCloudDatabase.fetchRecordsForChangeReasons(changeReasons) { changes, error in
                completion(changes.map { RemoteRecordChange(moodChange: $0) }.flatMap { $0 }, callback)
            }
        }
    }

    func uploadMoods(moods: [Mood], completion: ([RemoteMood], RemoteError?) -> ()) {
        let recordsToSave = moods.map { $0.cloudKitRecord }
        let op = CKModifyRecordsOperation(recordsToSave: recordsToSave,
            recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { modifiedRecords, _, error in
            let remoteMoods = modifiedRecords?.map { RemoteMood(record: $0) }.flatMap { $0 } ?? []
            let remoteError = RemoteError(cloudKitError: error)
            completion(remoteMoods, remoteError)
        }
        cloudKitContainer.publicCloudDatabase.addOperation(op)
    }

    func removeMoods(moods: [Mood], completion: ([RemoteRecordID], RemoteError?) -> ()) {
        let recordIDsToDelete = moods.map { (mood: Mood) -> CKRecordID in
            guard let name = mood.remoteIdentifier else { fatalError("Must have a remote ID") }
            return CKRecordID(recordName: name)
        }
        let op = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
        op.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
            completion((deletedRecordIDs ?? []).map { $0.recordName }, RemoteError(cloudKitError: error))
        }
        cloudKitContainer.publicCloudDatabase.addOperation(op)
    }

    func fetchUserID(completion: RemoteRecordID? -> ()) {
        cloudKitContainer.fetchUserRecordIDWithCompletionHandler { userRecordID, error in
            completion(userRecordID?.recordName)
        }
    }

}


extension RemoteError {
    private init?(cloudKitError: NSError?) {
        guard let error = cloudKitError else { return nil }
        if error.permanentCloudKitError {
            self = .Permanent(error.partiallyFailedRecordIDsWithPermanentError.map { $0.recordName })
        } else {
            self = .Temporary
        }
    }
}


extension RemoteRecordChange {
    private init?(moodChange: CloudKitRecordChange) {
        switch moodChange {
        case .Created(let r):
            guard let remoteMood = RemoteMood(record: r) as? T else { return nil }
            self = RemoteRecordChange.Insert(remoteMood)
        case .Updated(let r):
            guard let remoteMood = RemoteMood(record: r) as? T else { return nil }
            self = RemoteRecordChange.Update(remoteMood)
        case .Deleted(let id):
            self = RemoteRecordChange.Delete(id.recordName)
        }
    }
}


extension RemoteMood {
    private static var remoteRecordName: String { return "Mood" }

    private init?(record: CKRecord) {
        guard record.recordType == RemoteMood.remoteRecordName else { fatalError("wrong record type") }
        guard let date = record.objectForKey("date") as? NSDate,
            let colorData = record.objectForKey("colors") as? NSData,
            let colors = colorData.moodColors,
            let countryCode = record.objectForKey("country") as? Int,
            let creatorID = record.creatorUserRecordID?.recordName
            else { return nil }
        let isoCountry = ISO3166.Country(rawValue: Int16(countryCode)) ?? ISO3166.Country.Unknown
        let location = record.objectForKey("location") as? CLLocation
        self.id = record.recordID.recordName
        self.creatorID = creatorID
        self.date = date
        self.location = location
        self.colors = colors
        self.isoCountry = isoCountry
    }
}


extension Mood {
    private var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: RemoteMood.remoteRecordName)
        record.setObject(date, forKey: "date")
        record.setObject(location, forKey: "location")
        record.setObject(colors.moodData, forKey: "colors")
        record.setObject(Int(country?.iso3166Code.rawValue ?? 0), forKey: "country")
        record.setObject(1, forKey: "version")
        return record
    }
}

