//
//  GeographicRegion.swift
//  Moody
//
//  Created by Florian on 03/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreDataHelpers


public class GeographicRegion: ManagedObject {}

extension GeographicRegion: ManagedObjectType {
    public static var entityName: String { return "GeographicRegion" }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updatedAt", ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}


extension GeographicRegion: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: NSDate?
}
