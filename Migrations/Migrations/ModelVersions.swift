//
//  ModelVersions.swift
//  Migrations
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import UIKit


enum Version: String {
    case version1 = "Moody"
    case version2 = "Moody 2"
    case version3 = "Moody 3"
    case version4 = "Moody 4"
    case version5 = "Moody 5"
    case version6 = "Moody 6"
}


extension Version: ModelVersion {
    static var all___: [Version] { return [.version2, .version1] }
    static var current___: Version { return .version2 }
    static var all: [Version] {
        return [.version6, .version5, .version4, .version3, .version2, .version1]
    }
    static var current: Version { return .version6 }

    var name: String { return rawValue }
    var modelBundle: Bundle { return Bundle(for: Mood.self) }
    var modelDirectoryName: String { return "Moody.momd" }

    var successor: Version? {
        switch self {
        case .version1: return .version2
        case .version2: return .version3
        case .version3: return .version4
        case .version4: return .version5
        case .version5: return .version6
        default: return nil
        }
    }

    func mappingModelsToSuccessor() -> [NSMappingModel]? {
        switch self {
        case .version1:
            let mapping = try! NSMappingModel.inferredMappingModel(forSourceModel: managedObjectModel(), destinationModel: successor!.managedObjectModel())
            return [mapping]
        default:
            guard let mapping = mappingModelToSuccessor() else { return nil }
            return [mapping]
        }
    }
}

