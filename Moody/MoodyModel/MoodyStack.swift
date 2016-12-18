//
//  MoodyStack.swift
//  Moody
//
//  Created by Florian on 18/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers

private let ubiquityToken: String = {
    guard let token = FileManager.default.ubiquityIdentityToken else { return "unknown" }
    let string = NSKeyedArchiver.archivedData(withRootObject: token).base64EncodedString(options: [])
    return string.removingCharacters(in: CharacterSet.letters.inverted)
}()
private let storeURL = URL.documents.appendingPathComponent("\(ubiquityToken).moody")

private let moodyContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Moody", managedObjectModel: MoodyModelVersion.current.managedObjectModel())
    let storeDescription = NSPersistentStoreDescription(url: storeURL)
    storeDescription.shouldMigrateStoreAutomatically = false
    container.persistentStoreDescriptions = [storeDescription]
    return container
}()

public func createMoodyContainer(migrating: Bool = false, progress: Progress? = nil, completion: @escaping (NSPersistentContainer) -> ()) {
    Mood.registerValueTransformers()
    moodyContainer.loadPersistentStores { _, error in
        if error == nil {
            moodyContainer.viewContext.mergePolicy = MoodyMergePolicy(mode: .local)
            DispatchQueue.main.async { completion(moodyContainer) }
        } else {
            guard !migrating else { fatalError("was unable to migrate store") }
            DispatchQueue.global(qos: .userInitiated).async {
                migrateStore(from: storeURL, to: storeURL, targetVersion: MoodyModelVersion.current, deleteSource: true, progress: progress)
                createMoodyContainer(migrating: true, progress: progress,
                     completion: completion)
            }
        }
    }
}


