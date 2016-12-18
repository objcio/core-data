//
//  RemoteObject.swift
//  Moody
//
//  Created by Florian on 05/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreLocation


public protocol RemoteObject: class {
}

public typealias RemoteRecordID = String

public protocol RemoteRecord {}

public struct RemoteMood: RemoteRecord {
    public var id: RemoteRecordID?
    public var creatorID: RemoteRecordID?
    public var date: Date
    public var location: CLLocation?
    public var colors: [UIColor]
    public var isoCountry: ISO3166.Country

    public init(id: RemoteRecordID?, creatorID: RemoteRecordID?, date: Date, location: CLLocation?, colors: [UIColor], isoCountry: ISO3166.Country) {
        self.id = id
        self.creatorID = creatorID
        self.date = date
        self.location = location
        self.colors = colors
        self.isoCountry = isoCountry
    }
}


internal let RemoteIdentifierKey = "remoteIdentifier"

extension RemoteObject {

    public static func predicateForRemoteIdentifiers(_ ids: [RemoteRecordID]) -> NSPredicate {
        return NSPredicate(format: "%K in %@", RemoteIdentifierKey, ids)
    }

}


extension RemoteObject where Self: RemoteDeletable & DelayedDeletable {

    public static var waitingForUploadPredicate: NSPredicate {
        let notUploaded = NSPredicate(format: "%K == NULL", RemoteIdentifierKey)
        return NSCompoundPredicate(andPredicateWithSubpredicates:[notUploaded, notMarkedForDeletionPredicate])
    }

}

