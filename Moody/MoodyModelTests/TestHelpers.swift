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
    func performChangesAndWait(_ f: @escaping () -> ()) {
        performAndWait {
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

    static func moodyTestContext(_ addStore: (NSPersistentStoreCoordinator) -> ()) -> NSManagedObjectContext {
        let model = MoodyModelVersion.current.managedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        addStore(coordinator)
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }

    func testInsertMoodsAndSave(_ isoCountries: [ISO3166.Country] = [.deu]) -> [Mood] {
        var moods: [Mood]!
        performChangesAndWait {
            moods = self.testInsertMoods(isoCountries)
        }
        return moods
    }

    func testInsertMoods(_ isoCountries:  [ISO3166.Country] = [.deu]) -> [Mood] {
        var moods: [Mood]!
        performAndWait {
            moods = isoCountries.map { Mood.insert(into: self, colors: [.white], location: nil, isoCountry: $0) }
        }
        return moods
    }

    func testDeleteObject(_ o: DelayedDeletable) {
        performChangesAndWait {
            o.markForLocalDeletion()
        }
    }
}


extension NSPersistentStoreCoordinator {
    func addInMemoryTestStore() {
        try! addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    }

    func addSQLiteTestStore() {
        let storeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("moody-test")
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try! destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        }
        try! addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    }
}


extension Managed where Self: NSManagedObject {
    func materializedObject(in context: NSManagedObjectContext) -> Self {
        var result: Self!
        context.performAndWait {
            result = (context.object(with: self.objectID) as! Self).materialize()
        }
        return result
    }

    func materialize() -> Self {
        for property in entity.properties {
            if let relationship = (self as NSManagedObject).value(forKey: property.name) as? Set<NSManagedObject> {
                let _ = relationship.count
            }
        }
        return self
    }
}


