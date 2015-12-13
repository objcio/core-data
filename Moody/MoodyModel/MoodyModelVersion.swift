//
//  MoodyModelVersion.swift
//  Moody
//
//  Created by Florian on 06/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreDataHelpers


enum MoodyModelVersion: String {
    case Version1 = "Moody"
}


extension MoodyModelVersion: ModelVersionType {
    static var AllVersions: [MoodyModelVersion] { return [.Version1] }
    static var CurrentVersion: MoodyModelVersion { return .Version1 }

    var name: String { return rawValue }
    var modelBundle: NSBundle { return NSBundle(forClass: Mood.self) }
    var modelDirectoryName: String { return "Moody.momd" }
}
