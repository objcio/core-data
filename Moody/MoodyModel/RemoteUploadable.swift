//
//  RemoteUploadable.swift
//  Moody
//
//  Created by Florian on 05/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreLocation


public protocol RemoteUploadable {
}


public typealias RemoteRecordID = String

public protocol RemoteRecordType {}

public struct RemoteMood: RemoteRecordType {
    public var id: RemoteRecordID?
    public var creatorID: RemoteRecordID?
    public var date: NSDate
    public var location: CLLocation?
    public var colors: [UIColor]
    public var isoCountry: ISO3166.Country

    public init(id: RemoteRecordID?, creatorID: RemoteRecordID?, date: NSDate, location: CLLocation?, colors: [UIColor], isoCountry: ISO3166.Country) {
        self.id = id
        self.creatorID = creatorID
        self.date = date
        self.location = location
        self.colors = colors
        self.isoCountry = isoCountry
    }
}


internal let RemoteIdentifierKey = "remoteIdentifier"

extension RemoteUploadable {

    public static func predicateForRemoteIdentifiers(ids: [RemoteRecordID]) -> NSPredicate {
        return NSPredicate(format: "%K in %@", RemoteIdentifierKey, ids)
    }

}


extension RemoteUploadable where Self: protocol<RemoteDeletable, DelayedDeletable> {

    public static var waitingForUploadPredicate: NSPredicate {
        let notUploaded = NSPredicate(format: "%K == NULL", RemoteIdentifierKey)
        return NSCompoundPredicate(andPredicateWithSubpredicates:[notUploaded, notMarkedForDeletionPredicate])
    }

}