//
//  TestHelpers.swift
//  Migrations
//
//  Created by Florian on 02/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
@testable import Migrations


extension NSURL {
    static func testStoreURLForVersion(version: ModelVersion) -> NSURL {
        return NSBundle(forClass: MigrationsTests.self).URLForResource("\(version.name)", withExtension: "moody")!
    }
}


extension NSManagedObjectContext {
    convenience init(model: NSManagedObjectModel, storeURL: NSURL) {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        self.init(concurrencyType: .MainQueueConcurrencyType)
        persistentStoreCoordinator = psc
    }
}

