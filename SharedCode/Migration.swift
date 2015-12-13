//
//  Migration.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


public func migrateStoreFromURL<Version: ModelVersionType>(sourceURL: NSURL, toURL: NSURL, targetVersion: Version, deleteSource: Bool = false, progress: NSProgress? = nil) {
    guard let sourceVersion = Version(storeURL: sourceURL) else { fatalError("unknown store version at URL \(sourceURL)") }
    var currentURL = sourceURL
    let migrationSteps = sourceVersion.migrationStepsToVersion(targetVersion)
    var migrationProgress: NSProgress?
    if let p = progress {
        migrationProgress = NSProgress(totalUnitCount: Int64(migrationSteps.count), parent: p, pendingUnitCount: p.totalUnitCount)
    }
    for step in migrationSteps {
        migrationProgress?.becomeCurrentWithPendingUnitCount(1)
        let manager = NSMigrationManager(sourceModel: step.sourceModel, destinationModel: step.destinationModel)
        migrationProgress?.resignCurrent()
        let destinationURL = NSURL.temporaryURL()
        for mapping in step.mappingModels {
            try! manager.migrateStoreFromURL(currentURL, type: NSSQLiteStoreType, options: nil, withMappingModel: mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
        }
        if currentURL != sourceURL {
            NSPersistentStoreCoordinator.destroyStoreAtURL(currentURL)
        }
        currentURL = destinationURL
    }
    try! NSPersistentStoreCoordinator.replaceStoreAtURL(toURL, withStoreAtURL: currentURL)
    if (currentURL != sourceURL) {
        NSPersistentStoreCoordinator.destroyStoreAtURL(currentURL)
    }
    if (toURL != sourceURL && deleteSource) {
        NSPersistentStoreCoordinator.destroyStoreAtURL(sourceURL)
    }
}
