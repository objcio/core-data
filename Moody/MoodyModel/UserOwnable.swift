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
    static func predicateForOwnedByUser(withIdentifier identifier: String?) -> NSPredicate
}

private let CreatorIDKey = "creatorID"

extension UserOwnable {
    public static func predicateForOwnedByUser(withIdentifier identifier: String?) -> NSPredicate {
        let noIDPredicate = NSPredicate(format: "%K = NULL", CreatorIDKey)
        let defaultOwnerPredicate = NSPredicate(format: "%K = %@", CreatorIDKey, CKCurrentUserDefaultName)
        guard let id = identifier else { return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate]) }
        let idPredicate = NSPredicate(format: "%K = %@", CreatorIDKey, id)
        return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate, idPredicate])
    }
}

extension UserOwnable where Self: NSManagedObject {
    public var belongsToCurrentUser: Bool {
        return type(of: self).predicateForOwnedByUser(withIdentifier: managedObjectContext?.userID).evaluate(with: self)
    }
}


extension Mood: UserOwnable {}


extension Country {
    public static func predicateForContainingMoods(withCreatorIdentifier identifier: String?) -> NSPredicate {
        let noIDPredicate = NSPredicate(format: "ANY moods.%K = NULL", CreatorIDKey)
        let defaultOwnerPredicate = NSPredicate(format: "ANY moods.%K = %@", CreatorIDKey, CKCurrentUserDefaultName)
        guard let id = identifier else { return NSCompoundPredicate(orPredicateWithSubpredicates: [noIDPredicate, defaultOwnerPredicate]) }
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
            setMetaData(object: newValue.map { $0 as NSString }, forKey: UserIDKey)
        }
    }
}


