//
//  ManagedObject.swift
//  Moody
//
//  Created by Florian on 29/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}


extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}


extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name!  }
}

