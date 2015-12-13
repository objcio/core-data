//
//  UserOwnable.swift
//  Moody
//
//  Created by Florian on 05/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers
import CloudKit


public protocol UserOwnable: class {
    var creatorID: String? { get }
    var belongsToCurrentUser: Bool { get }
    static func predicateForOwnedByUserWithIdentifier(id: String?) -> NSPredicate
}

private let CreatorIDKey = "creatorID"

extension UserOwnable {
    public static func predicateForOwnedByUserWithIdentifier(id: String?) -> NSPredicate {
        let noIDPredicate = NSPredicate(format: "%K = NULL", CreatorIDKey)
        let defaultOwnerPredicate = NSPredicate(format: "%K = %@", CreatorIDKey, CKOwnerDefaultName)
        guard let id = id else { return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate]) }
        let idPredicate = NSPredicate(format: "%K = %@", CreatorIDKey, id)
        return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate, idPredicate])
    }
}

extension UserOwnable where Self: ManagedObject {
    public var belongsToCurrentUser: Bool {
        return self.dynamicType.predicateForOwnedByUserWithIdentifier(managedObjectContext?.userID).evaluateWithObject(self)
    }
}


extension Mood: UserOwnable {}


extension Country {
    public static func predicateForContainingMoodsWithCreatorIdentifier(id: String?) -> NSPredicate {
        let noIDPredicate = NSPredicate(format: "ANY moods.%K = NULL", CreatorIDKey)
        let defaultOwnerPredicate = NSPredicate(format: "ANY moods.%K = %@", CreatorIDKey, CKOwnerDefaultName)
        guard let id = id else { return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate]) }
        let idPredicate = NSPredicate(format: "ANY moods.%K = %@", CreatorIDKey, id)
        return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate, idPredicate])
    }
}


private let UserIDKey = "io.objc.Moody.CloudKitUserID"

extension NSManagedObjectContext {
    public var userID: RemoteRecordID? {
        get {
            return metaData[UserIDKey] as? RemoteRecordID
        }
        set {
            guard newValue != userID else { return }
            setMetaData(newValue, forKey: UserIDKey)
        }
    }
}

