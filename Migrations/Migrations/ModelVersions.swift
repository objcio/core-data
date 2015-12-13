//
//  ModelVersions.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import UIKit


enum ModelVersion: String {
    case Version1 = "Moody"
    case Version2 = "Moody 2"
    case Version3 = "Moody 3"
    case Version4 = "Moody 4"
    case Version5 = "Moody 5"
    case Version6 = "Moody 6"
}


extension ModelVersion: ModelVersionType {
    static var AllVersions___: [ModelVersion] { return [.Version2, .Version1] }
    static var CurrentVersion___: ModelVersion { return .Version2 }
    static var AllVersions: [ModelVersion] {
        return [.Version6, .Version5, .Version4, .Version3, .Version2, .Version1]
    }
    static var CurrentVersion: ModelVersion { return .Version6 }

    var name: String { return rawValue }
    var modelBundle: NSBundle { return NSBundle(forClass: Mood.self) }
    var modelDirectoryName: String { return "Moody.momd" }

    var successor: ModelVersion? {
        switch self {
        case .Version1: return .Version2
        case .Version2: return .Version3
        case .Version3: return .Version4
        case .Version4: return .Version5
        case .Version5: return .Version6
        default: return nil
        }
    }

    func mappingModelsToSuccessor() -> [NSMappingModel]? {
        switch self {
        case .Version1:
            let mapping = try! NSMappingModel.inferredMappingModelForSourceModel(managedObjectModel(), destinationModel: successor!.managedObjectModel())
            return [mapping]
        default:
            guard let mapping = mappingModelToSuccessor() else { return nil }
            return [mapping]
        }
    }
}
