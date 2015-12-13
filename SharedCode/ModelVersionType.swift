//
//  ModelVersionType.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


public protocol ModelVersionType: Equatable {
    static var AllVersions: [Self] { get }
    static var CurrentVersion: Self { get }
    var name: String { get }
    var successor: Self? { get }
    var modelBundle: NSBundle { get }
    var modelDirectoryName: String { get }
    func mappingModelsToSuccessor() -> [NSMappingModel]?
}


extension ModelVersionType {

    public var successor: Self? { return nil }

    public init?(storeURL: NSURL) {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, options: nil) else { return nil }
        let version = Self.AllVersions.findFirstOccurence {
            $0.managedObjectModel().isConfiguration(nil, compatibleWithStoreMetadata: metadata)
        }
        guard let result = version else { return nil }
        self = result
    }

    public func managedObjectModel() -> NSManagedObjectModel {
        let omoURL = modelBundle.URLForResource(name, withExtension: "omo", subdirectory: modelDirectoryName)
        let momURL = modelBundle.URLForResource(name, withExtension: "mom", subdirectory: modelDirectoryName)
        guard let url = omoURL ?? momURL else { fatalError("model version \(self) not found") }
        guard let model = NSManagedObjectModel(contentsOfURL: url) else { fatalError("cannot open model at \(url)") }
        return model
    }

    public func mappingModelsToSuccessor() -> [NSMappingModel]? {
        guard let mapping = mappingModelToSuccessor() else { return nil }
        return [mapping]
    }

    public func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else { return nil }
        guard let mapping = NSMappingModel(fromBundles: [modelBundle], forSourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel()) else {
            fatalError("no mapping model found for \(self) to \(nextVersion)")
        }
        return mapping
    }

    public func mappingModelsToSuccessor___() -> [NSMappingModel]? {
        guard let nextVersion = successor else { return nil }
        guard let mapping = NSMappingModel(fromBundles: [modelBundle], forSourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel())
            else { fatalError("no mapping from \(self) to \(nextVersion)") }
        return [mapping]
    }

    public func migrationStepsToVersion(version: Self) -> [MigrationStep] {
        guard self != version else { return [] }
        guard let mappings = mappingModelsToSuccessor(), let nextVersion = successor else { fatalError("couldn't find mapping models") }
        let step = MigrationStep(sourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel(), mappingModels: mappings)
        return [step] + nextVersion.migrationStepsToVersion(version)
    }

}


public struct MigrationStep {
    var sourceModel: NSManagedObjectModel
    var destinationModel: NSManagedObjectModel
    var mappingModels: [NSMappingModel]
}


extension NSManagedObjectContext {
    public convenience init<Version: ModelVersionType>(concurrencyType: NSManagedObjectContextConcurrencyType, modelVersion: Version, storeURL: NSURL, progress: NSProgress? = nil) {
        if let storeVersion = Version(storeURL: storeURL) where storeVersion != modelVersion {
            migrateStoreFromURL(storeURL, toURL: storeURL, targetVersion: modelVersion, deleteSource: true, progress: progress)
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: modelVersion.managedObjectModel())
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        self.init(concurrencyType: concurrencyType)
        persistentStoreCoordinator = psc
    }
}
