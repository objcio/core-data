//
//  Region.swift
//  Moody
//
//  Created by Florian on 03/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers


public class Region: NSManagedObject {}

extension Region: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updatedAt", ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}


extension Region: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: Date?
}

