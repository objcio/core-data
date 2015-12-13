//
//  TestVersionData.swift
//  Migrations
//
//  Created by Florian on 05/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
@testable import Migrations


protocol TestEntityDataType {
    var entityName: String { get }
    func matchesManagedObject(mo: NSManagedObject) -> Bool
}

struct TestVersionData {
    let data: [[TestEntityDataType]]

    func matchWithContext(context: NSManagedObjectContext) -> Bool {
        for entityData in data {
            let request = NSFetchRequest(entityName: entityData.first!.entityName)
            let objects = try! context.executeFetchRequest(request) as! [NSManagedObject]
            guard objects.count == entityData.count else { return false }
            guard objects.all({ o in entityData.some { $0.matchesManagedObject(o) } }) else { return false }
        }
        return true
    }
}
