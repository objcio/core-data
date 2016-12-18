//
//  TestHelpers.swift
//  Migrations
//
//  Created by Florian on 02/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
@testable import Migrations


extension URL {
    static func testStoreURL(for version: Version) -> URL {
        return Bundle(for: MigrationsTests.self).url(forResource: version.name, withExtension: "moody")!
    }
}


extension NSManagedObjectContext {
    convenience init(model: NSManagedObjectModel, storeURL: URL) {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        self.init(concurrencyType: .mainQueueConcurrencyType)
        persistentStoreCoordinator = psc
    }
}


