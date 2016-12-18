//
//  Extensions.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {

    private var store: NSPersistentStore {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
        guard let store = psc.persistentStores.first else { fatalError("No Store") }
        return store
    }

    public var metaData: [String: AnyObject] {
        get {
            guard let psc = persistentStoreCoordinator else { fatalError("must have PSC") }
            return psc.metadata(for: store) as [String : AnyObject]
        }
        set {
            performChanges {
                guard let psc = self.persistentStoreCoordinator else { fatalError("PSC missing") }
                psc.setMetadata(newValue, for: self.store)
            }
        }
    }

    public func setMetaData(object: AnyObject?, forKey key: String) {
        var md = metaData
        md[key] = object
        metaData = md
    }

    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }

    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }

}


private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String:NSManagedObject]

extension NSManagedObjectContext {
    public func set(_ object: NSManagedObject?, forSingleObjectCacheKey key: String) {
        var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
        cache[key] = object
        userInfo[SingleObjectCacheKey] = cache
    }

    public func object(forSingleObjectCacheKey key: String) -> NSManagedObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String:NSManagedObject] else { return nil }
        return cache[key]
    }
}

