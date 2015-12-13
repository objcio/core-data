//
//  TestHelpers.swift
//  Moody
//
//  Created by Florian on 10/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers
@testable import MoodyModel

extension NSManagedObjectContext {
    func performChangesAndWait(f: () -> ()) {
        performBlockAndWait {
            f()
            try! self.save()
        }
    }

    static func moodyInMemoryTestContext() -> NSManagedObjectContext {
        return moodyTestContext { $0.addInMemoryTestStore() }
    }

    static func moodySQLiteTestContext() -> NSManagedObjectContext {
        return moodyTestContext { $0.addSQLiteTestStore() }
    }

    static func moodyTestContext(addStore: NSPersistentStoreCoordinator -> ()) -> NSManagedObjectContext {
        let model = MoodyModelVersion.CurrentVersion.managedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        addStore(coordinator)
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }

    func testInsertMoodsAndSave(isoCountries: [ISO3166.Country] = [.DEU]) -> [Mood] {
        var moods: [Mood]!
        performChangesAndWait {
            moods = self.testInsertMoods(isoCountries)
        }
        return moods
    }

    func testInsertMoods(isoCountries:  [ISO3166.Country] = [.DEU]) -> [Mood] {
        var moods: [Mood]!
        performBlockAndWait {
            moods = isoCountries.map { Mood.insertIntoContext(self, colors: [.whiteColor()], location: nil, isoCountry: $0) }
        }
        return moods
    }

    func testDeleteObject(o: DelayedDeletable) {
        performChangesAndWait {
            o.markForLocalDeletion()
        }
    }
}


extension NSPersistentStoreCoordinator {
    func addInMemoryTestStore() {
        try! addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    }

    func addSQLiteTestStore() {
        let storeURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent("moody-test")
        if NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!) {
            try! destroyPersistentStoreAtURL(storeURL, withType: NSSQLiteStoreType, options: nil)
        }
        try! addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
    }
}


extension ManagedObjectType where Self: ManagedObject {
    func materializedObjectInContext(context: NSManagedObjectContext) -> Self {
        var result: Self!
        context.performBlockAndWait {
            result = (context.objectWithID(self.objectID) as! Self).materialize()
        }
        return result
    }

    func materialize() -> Self {
        for property in entity.properties {
            if let relationship = (self as ManagedObject).valueForKey(property.name) as? Set<ManagedObject> {
                let _ = relationship.count
            }
        }
        return self
    }
}

