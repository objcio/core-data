//
//  NSPersistentStoreCoordinator+Extensions2.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


extension NSPersistentStoreCoordinator {
    public static func destroyStoreAtURL(url: NSURL) {
        do {
            let psc = self.init(managedObjectModel: NSManagedObjectModel())
            try psc.destroyPersistentStoreAtURL(url, withType: NSSQLiteStoreType, options: nil)
        } catch let e {
            print("failed to destroy persistent store at \(url)", e)
        }
    }

    public static func replaceStoreAtURL(targetURL: NSURL, withStoreAtURL sourceURL: NSURL) throws {
        let psc = self.init(managedObjectModel: NSManagedObjectModel())
        try psc.replacePersistentStoreAtURL(targetURL, destinationOptions: nil, withPersistentStoreFromURL: sourceURL, sourceOptions: nil, storeType: NSSQLiteStoreType)
    }
}

