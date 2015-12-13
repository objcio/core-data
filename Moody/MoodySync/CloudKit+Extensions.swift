//
//  CloudKit+Sync.swift
//  Moody
//
//  Created by Florian on 26/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CloudKit


enum CloudKitRecordChange {
    case Created(CKRecord)
    case Updated(CKRecord)
    case Deleted(CKRecordID)
}


extension CKContainer {

    func fetchAllPendingNotifications(changeToken: CKServerChangeToken? = nil, processChanges: (changeReasonByID: [CKRecordID: CKQueryNotificationReason], error: NSError?, callback: (success: Bool) -> ()) -> ()) {
        let op = CKFetchNotificationChangesOperation(previousServerChangeToken: changeToken)
        var changeReasons: [CKRecordID: CKQueryNotificationReason] = [:]
        var notificationIDs: [CKNotificationID] = []
        op.notificationChangedBlock = { note in
            if let notificationID = note.notificationID {
                notificationIDs.append(notificationID)
            }
            if let n = note as? CKQueryNotification, let recordID = n.recordID {
                changeReasons[recordID] = n.queryNotificationReason
            }
        }
        op.fetchNotificationChangesCompletionBlock = { newChangeToken, error in
            processChanges(changeReasonByID: changeReasons, error: error) { success in
                guard success && notificationIDs.count > 0 else { return }
                let op = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDs)
                self.addOperation(op)
            }
            if op.moreComing {
                self.fetchAllPendingNotifications(newChangeToken, processChanges: processChanges)
            }
        }
        addOperation(op)
    }

}


extension CKDatabase {

    func fetchRecordsForChangeReasons(changeReasonsByID: [CKRecordID: CKQueryNotificationReason], completion: ([CloudKitRecordChange], NSError?) -> ()) {
        var deletedIDs: [CKRecordID] = []
        var insertedOrUpdatedIDs: [CKRecordID] = []
        for (id, reason) in changeReasonsByID {
            switch reason {
            case .RecordDeleted: deletedIDs.append(id)
            default: insertedOrUpdatedIDs.append(id)
            }
        }
        let op = CKFetchRecordsOperation(recordIDs: insertedOrUpdatedIDs)
        op.fetchRecordsCompletionBlock = { recordsByID, error in
            var changes: [CloudKitRecordChange] = deletedIDs.map(CloudKitRecordChange.Deleted)
            for (id, record) in recordsByID ?? [:] {
                guard let reason = changeReasonsByID[id] else { continue }
                switch reason {
                case .RecordCreated: changes.append(CloudKitRecordChange.Created(record))
                case .RecordUpdated: changes.append(CloudKitRecordChange.Updated(record))
                default: fatalError("should not contain anything other than inserts and updates")
                }
            }
            completion(changes, error)
        }
        addOperation(op)
    }

}


extension CKQueryOperation {

    func fetchAggregateResultsInDatabase(database: CKDatabase, previousResults: [CKRecord], completion: ([CKRecord], NSError?) -> ()) {
        var results = previousResults
        recordFetchedBlock = { record in
            results.append(record)
        }
        queryCompletionBlock = { cursor, error in
            guard let c = cursor else { return completion(results, error) }
            let nextOp = CKQueryOperation(cursor: c)
            nextOp.fetchAggregateResultsInDatabase(database, previousResults: results, completion: completion)
        }
        database.addOperation(self)
    }

}


extension NSError {

    func partiallyFailedRecords() -> [CKRecordID:NSError] {
        guard domain == CKErrorDomain else { return [:] }
        let errorCode = CKErrorCode(rawValue: code)
        guard errorCode == .PartialFailure else { return [:] }
        return userInfo[CKPartialErrorsByItemIDKey] as? [CKRecordID:NSError] ?? [:]
    }

    var partiallyFailedRecordIDsWithPermanentError: [CKRecordID] {
        var result: [CKRecordID] = []
        for (remoteID, partialError) in partiallyFailedRecords() {
            if partialError.permanentCloudKitError {
                result.append(remoteID)
            }
        }
        return result
    }

    var permanentCloudKitError: Bool {
        guard domain == CKErrorDomain else { return false }
        guard let errorCode = CKErrorCode(rawValue: code) else { return false }
        switch errorCode {
        case .InternalError: return true
        case .PartialFailure: return false
        case .NetworkUnavailable: return false
        case .NetworkFailure: return false
        case .BadContainer: return true
        case .ServiceUnavailable: return false
        case .RequestRateLimited: return false
        case .MissingEntitlement: return true
        case .NotAuthenticated: return true
        case .PermissionFailure: return true
        case .UnknownItem: return true
        case .InvalidArguments: return true
        case .ResultsTruncated: return false
        case .ServerRecordChanged: return true
        case .ServerRejectedRequest: return true
        case .AssetFileNotFound: return true
        case .AssetFileModified: return true
        case .IncompatibleVersion: return true
        case .ConstraintViolation: return true
        case .OperationCancelled: return false
        case .ChangeTokenExpired: return true
        case .BatchRequestFailed: return false
        case .ZoneBusy: return false
        case .BadDatabase: return true
        case .QuotaExceeded: return false
        case .ZoneNotFound: return true
        case .LimitExceeded: return true
        case .UserDeletedZone: return true
        }
    }

}