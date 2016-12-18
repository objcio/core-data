//
//  TestVersionData.swift
//  Migrations
//
//  Created by Florian on 05/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
@testable import Migrations


protocol TestEntityData {
    var entityName: String { get }
    func matches(_ object: NSManagedObject) -> Bool
}

struct TestVersionData {
    let data: [[TestEntityData]]

    func match(with context: NSManagedObjectContext) -> Bool {
        for entityData in data {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityData.first!.entityName)
            let objects = try! context.fetch(request)
            guard objects.count == entityData.count else { return false }
            guard objects.all({ o in entityData.some { $0.matches(o) } }) else { return false }
        }
        return true
    }
}

